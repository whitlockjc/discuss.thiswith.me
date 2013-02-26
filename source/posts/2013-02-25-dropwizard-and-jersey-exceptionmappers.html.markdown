---
title: Dropwizard and Jersey ExceptionMappers
date: 2013-02-25 12:00 -07:00
tags: dropwizard, java, jersey, json
---

The past month I've been using an [open source](http://en.wikipedia.org/wiki/Open_source_software) project called
[Dropwizard](http://dropwizard.codahale.com/).  Dropwizard is a self-described as being a "Java framework for
developing ops-friendly, high-performance, RESTful web services".  Dropwizard is an awesome piece of kit that bundles
best of breed Java tooling like [Jetty](http://www.eclipse.org/jetty/),
[Guava](http://code.google.com/p/guava-libraries/) and [Jersey](http://jersey.java.net/).  Speaking of Jersey, this is
what I'd like to talk about today, specifically about how Dropwizard exposes the ability to create your own Jersey
ExceptionMapper and how the built-in Dropwizard ExceptionMappers might cause you some grief, with a workaround.

### What is an ExceptionMapper?

Jersey, or should I say [JAX-RS](http://jax-rs-spec.java.net/), exposes a mechanism that will allow you to map a thrown
Exception or Throwable to a REST response, instead of being unhandled and being presented to
the user as some stacktrace or error text.  _(This mechanism requires than you implement the generic
ExceptionMapper interface and then register it.)_  This is excellent for REST APIs that like to
return errors back to the client as part of using the API, like returning a [JSON](http://www.json.org/) representation
of an Exception that can be parsed and handled on the client.

### Custom ExceptionMappers in Dropwizard

My initial impression of Dropwizard in the context of Jersey and needing to register custom ExceptionMappers was very
positive since Dropwizard exposes an API for registering ExceptionMappers.  Here is a very brief example for those of
you looking to register your custom ExceptionMapper within Dropwizard:

```java
package org.thoughtspark.dropwizard.app;

import org.thoughtspark.dropwizard.app.ApplicationConfiguration;
import org.thoughtspark.dropwizard.app.GenericExceptionMapper;

import com.yammer.dropwizard.Service;
import com.yammer.dropwizard.config.Bootstrap;
import com.yammer.dropwizard.config.Environment;

/**
 * Example Dropwizard {@link Service}.
 */
public class ApplicationService extends Service<ApplicationConfiguration> {

    /**
     * Entry point for running this services in isolation via Dropwizard.
     *
     * @param args the arguments
     */
    public static void main(String[] args) throws Exception {
        new ApplicationService().run(args);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void initialize(Bootstrap<ApplicationConfiguration> bootstrap) {
        bootstrap.setName("application");
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void run(ApplicationConfiguration applicationConfiguration, Environment environment) throws Exception {
        // Register the custom ExceptionMapper(s)
        environment.addProvider(new GenericExceptionMapper());
    }

}

```

The GenericExceptionMapper being registered will handle all Throwables thrown and return a JSON payload representing
the error and its message.

### Dropwizards Secret "Gotcha"

Everything was going great until I started using Dropwizard
[Validation](http://dropwizard.codahale.com/manual/core/#validation).  I noticed that whenever my bean validation
failed, instead of seeing a JSON payload of my validation exception, I was always seeing an HTML version of the
exception...almost as if I never registered my custom ExceptionMapper, or maybe my custom ExceptionMapper just wasn't
working.  Seeing that all Exceptions extend Throwable, I didn't see how my ExceptionMapper wasn't configured properly
so I dropped into the debugger.

After some looking around, I see that the actual exception being throw was of type InvalidEntityException.  At this
point, I created a new ExceptionMapper specifically for the InvalidEntityException, restarted Dropwizard and it
worked!  Instead of the HTML responses for InvalidEntityExceptions, I saw my JSON representation.  Everything was
working great...that is until I restarted the server for a different reason and I noticed that the
InvalidEntityExceptions had gone back to HTML.  I knew I hadn't changed anything related to the ExceptionMapper so I
started debugging.  After being unable to get the debugger to hit any break points in my ExceptionMappers I started
looking into the Dropwizard sources, thank goodness for open source software, and that is when I saw something,
Dropwizard is registering its own ExceptionMapper for the InvalidEntityException.  What was still bugging me was why my
ExceptionMapper worked once and upon server restart it stopped working, without any changes to my code.  Once again I
found myself in the bowels of Dropwizard's source and that's when I found my problem.

Dropwizard is adding its custom ExceptionMappers into Jersey's singletons Set, a Set that does not guarantee order.
This explains why one time my ExceptionMapper would work and another time, the built-in Dropwizard ExceptionMapper
would work.  Now that we know the problem, below is one way to work around the problem:

```java
package org.thoughtspark.dropwizard.app;

import org.thoughtspark.dropwizard.app.ApplicationConfiguration;
import org.thoughtspark.dropwizard.app.GenericExceptionMapper;

import com.fasterxml.jackson.jaxrs.json.JsonParseExceptionMapper;
import com.sun.jersey.api.core.ResourceConfig;
import com.yammer.dropwizard.Service;
import com.yammer.dropwizard.config.Bootstrap;
import com.yammer.dropwizard.config.Environment;
import com.yammer.dropwizard.jersey.InvalidEntityExceptionMapper;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

/**
 * Example Dropwizard {@link Service}.
 */
public class ApplicationService extends Service<ApplicationConfiguration> {

    /**
     * Entry point for running this services in isolation via Dropwizard.
     *
     * @param args the arguments
     */
    public static void main(String[] args) throws Exception {
        new ApplicationService().run(args);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void initialize(Bootstrap<ApplicationConfiguration> bootstrap) {
        bootstrap.setName("application");
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void run(ApplicationConfiguration applicationConfiguration, Environment environment) throws Exception {
        // Remove all of Dropwizard's custom ExceptionMappers
        ResourceConfig jrConfig = environment.getJerseyResourceConfig();
        Set<Object> dwSingletons = jrConfig.getSingletons();
        List<Object> singletonsToRemove = new ArrayList<Object>();

        for (Object s : dwSingletons) {
            if (s instanceof ExceptionMapper && s.getClass().getName().startsWith("com.yammer.dropwizard.jersey.")) {
                singletonsToRemove.add(s);
            }
        }

        for (Object s : singletonsToRemove) {
            jrConfig.getSingletons().remove(s);
        }

        // Register the custom ExceptionMapper(s)
        environment.addProvider(new GenericExceptionMapper());
    }

}
```

In the code above, I remove all Dropwizard ExceptionMappers so that I have complete control over how my application
renders Jersey Exceptions.  Now no matter how many times I restart the server, my custom ExceptionMapper will be used
and I can always expect JSON to be returned for Exceptions thrown on the server.  Of course, you might need to change
the approach above based on your needs but for this scenario, I just wanted any ExceptionMapper that Dropwizard
provided to be done away with so I could use my custom versions that returned JSON instead of HTML.

### Conclusion

Dropwizard is awesome and anytime I have to write Java-based REST servers, I'll be using it.  I do question the
built-in ExceptionMappers, especially with their inability to be configured to output something other than the
hardcoded HTML, but with the workaround above, I don't have to be stuck because of them.  Please do not let this take
away from Dropwizard and if you get tired of having to use the workaround above, I'm sure the team would welcome a
patch...if you beat me to it.