---
title: Using Node.js Code in the Browser
date: 2014-10-20 22:00 -07:00
tags: javascript, node.js, browser, browserify
---

For the past few months, I've been working on [swagger-tools][swagger-tools], a JavaScript library that exposes various
utilities for working with [Swagger][swagger] documents.  Need a command line utility to validate your Swagger
document(s)?  swagger-tools has it.  Need an API for validating your Swagger document(s)?  swagger-tools has it.
Want to use your Swagger document(s) to validate your API requests or to wire up your request handlers?  swagger-tools
has it...and much more.  But this post isn't about swagger-tools, sorry for the shameless plug.

There might come a time when it might make sense to expose your Node.js module to the browser.  This happened recently
for swagger-tools and I learned a lot during the process.  My hope is that this will help shed some light on the
available options and what I believe is a pretty decent approach to this.

### Getting Started

When I started this process, the first thing I did was look for existing projects that work in Node.js and the browser.
While the concept is simple, I wanted to see how some of the _professionals_ do it.  Since I already use
[Lo-Dash][lodash], I started there.  As expected, an [immediately-invoked function expression][iife] and a few
statements that check the environment to identify if the code is running in the browser or Node.js.  Pretty simple
stuff.  Just for due diligence, I looked at a few other projects and they all had the same recipe:

```javascript
(function() {
  // The code for YOUR_MODULE_NAME

  if (typeof exports !== 'undefined') {
    if (typeof module !== 'undefined' && module.exports) {
      exports = module.exports = YOUR_MODULE_NAME;
    }

    exports.YOUR_MODULE_NAME = YOUR_MODULE_NAME;
  } else {
    this.YOUR_MODULE_NAME = YOUR_MODULE_NAME;
  }
})(this);
```

This example is quite simplistic but the purpose is to give you an example of how you might do this.  _(If you want a
good example of how to do this and also how to handle more of the JavaScript module environments, checkout how Lo-Dash
does it.  They were even nice enough to support [Narwhal][narwhal] and [Rhino][rhino]!)_  Unfortunately for me, what
allowed these projects to use such a simple approach for writing code that works in both the browser and Node.js was a
luxury I did not have: These projects did not have any external dependencies, including no dependencies on any core
Node.js modules.

### The Problem

Any time you have a Node.js module with dependencies, you can't just _port_ your module to run in the browser.  You not
only have to worry about making your code working in the browser but you also have to make sure your dependencies and
their dependencies and so on run in the browser.  You will also need to do this for core Node.js modules, which can be
a daunting task.

Let's assume you can do this yourself, you now need to make sure your code can load modules in the browser and in
Node.js.  The problem is that the browser doesn't have a built-in `require` function for loading modules.  What do you
do?  Do you separate your source base into a Node.js modules that wires things up the Node.js way and a browser module
that wires this up the browser way and figure out some way to share code between them?  It's not as easy as it sounds.

### Enter Browserify

Thankfully, there is an open source project called [Browserify][browserify] that handles all of this for you.  Changes
are good that if you started the same way I did, you likely ran across numerous posts mentioning Browserify already.
What Browserify does is:

> Browserify lets you require('modules') in the browser by bundling up all of your dependencies.

That's a pretty simple explanation of what Browserify does.  It also helps solve most of the issues related to your
code, or code you depend on, using core Node.js modules.  _(For complete information on the Node.js core module
browser compatibility, view the [Browserify compatibility documentation][browserify-compatibility].)_

With Browserify, you can generate a browser bundle from your Node.js files/modules.  This means one source base for
Node.js and from that same source base, you can generate a working browser bundle.  I have used Browserify successfully
on my [carvoyant][carvoyant-js] library and [swagger-tools][swagger-tools].  During the development of each of these
projects, I am yet to need to break my source base up for the applicable parts that could/should run in the browser.
_(In swagger-tools, of course I do not include the Connect middleware in my browser bundle but that separation was due
to applicability and not because of some lack in Browserify.)_

To avoid listing out the same examples and documentation Browserify uses to explain/justify its use, I suggest you
visit it's [documentation][browserify-documentation].  Instead, I would like to share a few things I've had to do while
using Browserify and a new trick I learned to build [Bower][bower] modules using Browserify, complete with dependency
management handled by Bower instead of having to bundle all dependencies with your brower bundle.

### Browserify Tips

Making your Node.js module more browser friendly is an iterative process.  If you want to use Browserify to take your
Node.js module as-is and create a standalone browser module, it will do that.  But chances are good that your first
build will be huge, especially if you use any of the core Node.js modules.

#### Trimming the Fat

What I've noticed when using Browserify is that I tend to start with a large browser bundle and I will then try to
figure out how, if it's even possible, to make my bundle smaller.  The reason your browser bundle is typically so large
is because Browserify will build a browser bundle that includes all of your dependencies in it.  _(Think of this as
analogous to the Uber JAR in the Java space or a static binary for C/C++/...)_

To remove some of the size, some modules like Lo-Dash will allow you to cherry pick the actual module features you use
instead of requiring the whole Lo-Dash module.  Unfortunately, not all modules are as flexible Lo-Dash is.  Of course,
you can analyze you modules and see if you're importing large modules or unnecessary modules and refactor accordingly.

In the end, the biggest gain I've seen is by instructing Browserify to not include certain dependencies where possible.
For example, let's say you depend on a module that already has a browser version available.  Bundling that module is no
longer a requirement because you can include it either using Bower or a CDN or by shipping their module with your code.

The way to do this isn't as obvious as you might thing.  If you look at the Browserify documentation, you might be
inclined to `exclude` or `ignore` certain files/modules.  This will definitely make your browser bundle smaller but the
bundle will not work when ran in the browser.  The reason for this is that excluded/ignored modules are replaced with
`undefined`/`{}` respectively.

To properly tell Browserify to exclude a module, and to do it in a way that in the browser you can resolve externally
provided dependencies, is to use a Browserify transform.  For this purpose, there are many options out there but the
best one I've found is [exposify][exposify].  With exposify you can configure how Browserify will resolve modules that
are provided for you externally.  For example, if you were to load Lo-Dash using a `script` tag, you could tell exposify
that the `lodash` module could be provided by `_` global variable.  To see this in action, have a look at
[swagger-tools/gulpfile.js#L57][swagger-tools-gulpfile-L57].  _(Long story short, exposify lets you associate a module
name with a global variable by name.)_

Thanks to Browserify and exposify, I could create a Bower module for swagger-tools and not include all of the required
dependencies with the generated browser bundle.  I was able to set the proper Bower dependencies for modules that had
a Bower module published and do the default Browserify thing by bundling the modules that did not.  This saved me
_708k_ or _67%_ of my file size for my development module and _48k_ or _37%_ for my minified production module.

Of course Browserify has transforms for the usual suspects when it comes to exclusion of source maps, minifcation,
uglification, etc.

#### External Files

One of the things I needed for swagger-tools was to include some JSON files with my module.  In Node.js land, this works
by default.  In Browserify land, you need to use another Browserify transform called [brfs][brfs].  What brfs does is it
will find any place in your code where you `require` a file, `fs.readFile` or `fs.readFileSync` and it will inline that
file's contents into your module.  So if you were to `var schema = require('./path/to/schema.json')`, brfs will make it
so that in the browser bundle, `schema` is set to the string content of your `schema.json` file.

#### Building Bundles

As I mentioned above, Browserify builds standalone browser bundles.  I think in many cases, these large static binaries
can serve a purpose as they give you a completely safe environment for your module.  _(This is great for standalone
application binaries where you don't care if others use your code.)_  On the other hand, being able to leverage package
mangers to share your module and to create smaller binaries is nice as well.  I couldn't make my mind up so for
swagger-tools, I build both.  _(To see how I'm building 4 binaries, two standalone binaries and two Bower binaries, for
swagger-tools, check out [swagger-tools/gulpfile.js#L35][swagger-tools-gulpfile-L35].)_

### Conclusion

Browserify is a wonderful tool to make it very simple to have one code base for your Node.js module and your browser
module.  I find that Browserify was very unobstrusive and that given the right transform, I could basically do all of
the things I needed to build the browser bundle I required.  I realize that this was not some walk through or tutorial
but don't fret, the [Browserify Documentation][browserify-documentation] is very easy to read and understand.

[brfs]: https://github.com/substack/brfs
[browserify]: http://browserify.org/
[browserify-compatibility]: https://github.com/substack/node-browserify#compatibility
[browserify-documentation]: https://github.com/substack/node-browserify
[carvoyant]: https://github.com/whitlockjc/carvoyant
[exposify]: https://github.com/thlorenz/exposify
[iife]: http://en.wikipedia.org/wiki/Immediately-invoked_function_expression
[lodash]: https://lodash.com/
[narwhal]: https://github.com/tlrobinson/narwhal
[rhino]: https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino
[swagger]: http://swagger.io
[swagger-tools]: https://github.com/apigee-127/swagger-tools
[swagger-tools-gulpfile-L35]: https://github.com/apigee-127/swagger-tools/blob/master/gulpfile.js#L35
[swagger-tools-gulpfile-L57]: https://github.com/apigee-127/swagger-tools/blob/master/gulpfile.js#L57
