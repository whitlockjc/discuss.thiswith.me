---
title: "Kafka Quick Start With SASL"
date: 2022-01-11T16:43:39-05:00
description: "This article discusses how to extend the Kafka Quick Start to use SASL/PLAIN."
disableComments: false
tags:
- article
- kafka
- technology
- tutorial
toc: true
type: post
---

Recently I found myself playing around with [Apache Kafka][kafka], an
_"open-source distributed event streaming platform"_, and I can't speak highly enough to the excellent
[Kafka QuickStart][kafka-quickstart] guide.  Within a few minutes, this guide has you running a full
_(albeit simplified)_ Kafka installation, consuming/publishing events and in doing so, the underlying Kafka concepts are
made easy to understand without having to dive into the complexities of a Kafka installation.  What I would like to do
is provide a similar guide to enabling a simple layer of security to your Kafka installation.  This guide will be a
complete, step-by-stype guide for enabling SASL/PLAIN for your Kafka installation using the exact same process as the
Kafka QuickStart guide.

## Overview

The Kafka QuickStart guide goes beyond just running Kafka, touching on things like Kafka Connect and Kafka Streams, but
for our purposes we only need to concern ourselves with the first five steps:

1. Get Kafka
2. Start the Kafka Environment
3. Create a Topic to Store Your Events
4. Write Some Events into the Topic
5. Read the Events

Let's get started.

## Step 1: Get Kafka

To avoid writing a document that is outdated anytime a new release of Apache Kafka drops, and the Kafka QuickStart guide
updates, the simplest thing here is to
[link to the guide itself](https://kafka.apache.org/quickstart#quickstart_download) and rely on your ability to follow
_Step 1_ from there.  From this point forward, the place where you extracted Kafka will be referred to as `$KAFKA_HOME`.

## Step 2: Start the Kafka Environment

Once you've downloaded and extracted Apache Kafka, the real work begins in _Step 2_.  The Kafka QuickStart guide greatly
simplifies what's going on by describing this step as _"Start[ing] the Kafka Environment"_ but we have to do a little
more explaining here.  The _"Kafka Environment"_ consistes of two components, each of which need to be separately
configured to achieve our goal.

### Step 2a: Configuring ZooKeeper for SASL

As of the time of writing this, [ZooKeeper][zookeeper] is a prerequisite for Kafka but its purpose and importance do not
matter.  Enabling SASL for ZooKeeper **is not** required but to be completely thorough, we will document the process
anyway.  If you choose to enable SASL between Kafka clients and brokers, but **do not** want to require SASL between
Kafka and ZooKeeper, just skip the steps documented in this section.

The first step is to create a copy of the ZooKeeper configuration, reason being that we want to clearly separate our
SASL vs. SASL-less configuration files.  To do this, run the following:

```plain
cp ${KAFKA_HOME}/config/zookeeper.properties ${KAFKA_HOME}/config/zookeeper_sasl.properties
```

The next step is to update `${KAFKA_HOME}/config/zookeeper_sasl.properties` so that it has the following contents
appended to the very end:

```ini
# SASL
authProvider.sasl=org.apache.zookeeper.server.auth.SASLAuthenticationProvider
requireClientAuthScheme=sasl
```

Below is a brief description of each of the configuration items above:

* `authProvider.sasl`: Configures ZooKeeper to use the SASL authentication provider
* `requireClientAuthScheme`: Configures ZooKeeper to require SASL for all client conntexts

The final step is to create a [JAAS][jaas] configuration file that configures the ZooKeeper users and configures the
JAAS [LoginModule][jaas-loginmodule] to use the appropriate credentials.  To do this, run the following:

```plain
touch ${KAFKA_HOME}/config/zookeeper_jaas.config
```

And finally, we populate `${KAFKA_HOME}/config/zookeeper_jaas.config` with the following:

```scala
Server {
   org.apache.kafka.common.security.plain.PlainLoginModule required
   username="zookeeper"
   password="zookeeper-secret"
   user_zookeeper="zookeeper-secret";
};
```

The content of this file configures ZooKeeper to have a `zookeeper` user, which will be used by the Kafka Broker later
to establish its connection to ZooKeeper.

### Step 2b: Starting ZooKeeper

Before we can start ZooKeeper as per the Kafka QuickStart guide, we need to set
the `KAFKA_OPTS` environment variable so that it will use the ZooKeeper-specific JAAS configuration file by running the
following:

```plain
export KAFKA_OPTS="-Djava.security.auth.login.config=${KAFKA_HOME}/config/zookeeper_jaas.config"
```

Once that environment variable is set, we can run the following to start ZooKeeper per the Kafka QuickStart guide:

```plain
bin/zookeeper-server-start.sh config/zookeeper_sasl.properties
```

At this point, assuming ZooKeeper starts up properly, you can safely move on to the next step.

### Step 2c: Configuring Kafka Broker for SASL

The steps for updating the Kafka Broker to use SASL is identical to ZooKeeper, albeit the configuration file chnages are
slightly different _(as they are different systems being configured)_.  Just like with ZooKeeper, we will create a copy
of the Kafka Broker configuration file and update it for enabling SASL instead of modifying the original file.  That
being said, the first step is to create a copy of the Kafka Broker configuration.  To do this, run the following:

```plain
cp ${KAFKA_HOME}/config/server.properties ${KAFKA_HOME}/config/server_sasl.properties
```

The next step is to update `${KAFKA_HOME}/config/server_sasl.properties` so that it has the following contents
appended to the very end:

```ini
# SASL
sasl.enabled.mechanisms=PLAIN
sasl.mechanism.inter.broker.protocol=PLAIN
security.inter.broker.protocol=SASL_PLAINTEXT
listeners=SASL_PLAINTEXT://localhost:9092
advertised.listeners=SASL_PLAINTEXT://localhost:9092
```

As with ZooKeeper, below is a brief description of each of the configuration items above:

* `sasl.enabled.mechanisms`: Enables the `SASL/PLAIN` SASL mechanism for communicating with the Kafka Broker
* `sasl.mechanism.inter.broker.protocol`: Enables the `SASL/PLAIN` sasl mechamism for inter-broker communications
* `security.inter.broker.protocol`: Configures `SASL/PLAIN` as the security protocol for inter-broker communications
* `listeners`: Exposes a `SASL/PLAIN` REST API for the given host/port combination
* `advertised.listeners`: Tells ZooKeeper which listeners are available for Kafka client connections

As with ZooKeeper, the final step is to create a [JAAS][jaas] configuration file that configures the Kafka Broker users.
This file also is used to configure the credentials used by the Kafka Broker when establishing a connection to
ZooKeeper, based on the content above.  To do this, run the following:

```plain
touch ${KAFKA_HOME}/config/server_jaas.config
```

And finally, we populate `${KAFKA_HOME}/config/server_jaas.config` with the following:

```scala
KafkaServer {
   org.apache.kafka.common.security.plain.PlainLoginModule required
   username="admin"
   password="admin-secret"
   user_admin="admin-secret"
   user_consumer="consumer-secret"
   user_producer="producer-secret";
};

Client {
   org.apache.kafka.common.security.plain.PlainLoginModule required
   username="zookeeper"
   password="zookeeper-secret";
};
```

The content of this file configures three users for connecting to the Kafka Broker
_(`admin`, `consumer` and `producer`)_.  This file also configures the ZooKeeper client credentials to use the
`zookeeper` user configured in the ZooKeeper section above.

### Step 2d: Starting the Kafka Broker

Before we can start the Kafka Broker as per the Kafka QuickStart guide, we need to set
the `KAFKA_OPTS` environment variable so that it will use the Kafka Broker-specific JAAS configuration file by running
the following:

```plain
export KAFKA_OPTS="-Djava.security.auth.login.config=${KAFKA_HOME}/config/server_jaas.config"
```

Once that environment variable is set, we can run the following to start the Kafka Broker per the Kafka QuickStart
guide:

```plain
bin/kafka-server-start.sh config/server_sasl.properties
```

At this point, assuming the Kafka Broker starts up properly, you can safely move on to the next step.

## Step 3: Create a Topic to Store Your Events

Each step from this point forward will be mostly identical, in that we will be configuring Kafka Clients for connections
to the Kafka Broker to perform Kafka interactions.  And per the Kafka QuickStart guide, the first step is to create a
topic for us to interact with.  Since SASL is now enabled for our Kafka Broker, we must follow the necessaty steps to
configure our Kafka Client to use SASL.

Since the Kafka QuickStart guide **does not** use a configuration file for the Kafka Client used to create the topic, we
will create a very simplified Kafka Client configuration file by performing the following:

```plain
touch ${KAFKA_HOME}/config/admin_sasl.properties
```

We then need to populate this file with the following content, to tell the Kafka Client to use SASL:

```ini
# SASL
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
```

The next step is to create a JAAS file that configures the credentials used by the Kafka Client to connect to the Kafka
Broker.  To do this, perform the following:

```plain
touch ${KAFKA_HOME}/config/admin_jaas.config
```

And as we've done a few times already, we need to populate the Kafka Client credentials into the file:

```scala
KafkaClient {
   org.apache.kafka.common.security.plain.PlainLoginModule required
   username="admin"
   password="admin-secret";
};
```

Now that we have our Kafka Client configuration file on disk and the necessary JAAS file as well, we can follow the same
steps we have a couple times already and tell Kafka to use our JAAS file.  To do this, we need to set the `KAFKA_OPTS` environment variable so that it will use the necessary JAAS configuration file by running the following:

```plain
export KAFKA_OPTS="-Djava.security.auth.login.config=${KAFKA_HOME}/config/admin_jaas.config"
```

And finally, we can run the Kafka Client command to create our topic per the Kafka QuickStart guide:

```plain
bin/kafka-topics.sh --create --partitions 1 --replication-factor 1 \
    --topic quickstart-events --bootstrap-server localhost:9092 \
    --command-config config/admin_sasl.properties
```

The only difference between the command used in the Kafka QuickStart guide and this guide is that we now must use the
`--command-config` flag to tell it to use the Kafka Client configuration file we created above.  As long as the command
runs without issue, we now have a Kafka topic to interact with to complete the rest of the Kafka QuickStart using SASL
authentication.

## Step 4: Write Some Events Into the Topic

This step will become somewhat repetitive, as we will perform the same steps we have a few times already.  But to be
thorough, we will repeat the entire process.  The first step is to create a Kafka Client configuration file based on the
one provided by the Kafka QuickStart guide.  The purpose is to clearly separate our SASL and non-SASL configuration
files.  To do this, perform the following:

```plain
cp ${KAFKA_HOME}/config/producer.properties ${KAFKA_HOME}/config/producer_sasl.properties
```

The next step is to append the following content to `${KAFKA_HOME}/config/producer_sasl.properties`:

```properties
# SASL
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
```

The next step is to create our JAAS file that will contain the Kafka Client credentials used by our producer client.  To
do this, perform the following:

```plain
touch ${KAFKA_HOME}/config/producer_jaas.config
```

And as we've done a few times, we need to populate this file with the Kafka Client credentials for our producer:

```scala
KafkaClient {
   org.apache.kafka.common.security.plain.PlainLoginModule required
   username="producer"
   password="producer-secret";
};
```

This file configures the Kafka Client to use the `producer` credentials when connecting to the Kafka Broker.  And again,
as we've done a few times already we now need to tell our Kafka Client command how which JAAS file to use for our Kafka
Client, which involves setting the `KAFKA_OPTS` environment variable so that it will use the necessary JAAS
configuration file.  To do this, run the following:

```plain
export KAFKA_OPTS="-Djava.security.auth.login.config=${KAFKA_HOME}/config/producer_jaas.config"
```

We can now pick up where the Kafka QuickStart guide continues by running the producer Kafka Client command and altering
it to use our Kafka Client configuration file configured for SASL by using the following:

```plain
bin/kafka-console-producer.sh --topic quickstart-events --bootstrap-server localhost:9092 \
    --producer.config config/producer_sasl.properties
```

If this command runs successfully, it will sit there and wait for input.  Type in a few _"events"_ by typing some string
and hitting `Enter` to submit the event.  After submitting a few events, we're now ready to pick up with the last
section of our guide by using a Kafka Client to consume these newly-produced events.

## Step 5: Read the Events

The last step in our Kafka QuickStart guide is a repeat of the same process we've done a few times already, but
thankfully for the last time.  The good news is that by now you should have an idea of what to expect, and repeating
this process should drive it home what is required to configure a Kafka Client for SASL.

The first step is to create a Kafka Client configuration file based on the
one provided by the Kafka QuickStart guide.  The purpose is to clearly separate our SASL and non-SASL configuration
files.  To do this, perform the following:

```plain
cp ${KAFKA_HOME}/config/consumer.properties ${KAFKA_HOME}/config/consumer_sasl.properties
```

The next step is to append the following content to `${KAFKA_HOME}/config/consumer_sasl.properties`:

```properties
# SASL
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
```

The next step is to create our JAAS file that will contain the Kafka Client credentials used by our producer client.  To
do this, perform the following:

```plain
touch ${KAFKA_HOME}/config/consumer_jaas.config
```

And as we've done a few times, we need to populate this file with the Kafka Client credentials for our producer:

```scala
KafkaClient {
   org.apache.kafka.common.security.plain.PlainLoginModule required
   username="consumer"
   password="consumer-secret";
};
```

This file configures the Kafka Client to use the `consumer` credentials when connecting to the Kafka Broker.  And again,
as we've done a few times already we now need to tell our Kafka Client command how which JAAS file to use for our Kafka
Client, which involves setting the `KAFKA_OPTS` environment variable so that it will use the necessary JAAS
configuration file.  To do this, run the following:

```plain
export KAFKA_OPTS="-Djava.security.auth.login.config=${KAFKA_HOME}/config/consumer_jaas.config"
```

We can now pick up where the Kafka QuickStart guide continues by running the producer Kafka Client command and altering
it to use our Kafka Client configuration file configured for SASL by using the following:

```plain
bin/kafka-console-consumer.sh --topic quickstart-events --from-beginning --bootstrap-server localhost:9092 \
   --consumer.config config/consumer_sasl.properties
```

If this command runs successfully, it will print all events you created in the previous step and sit there waiting for
new events to be produced.

At this point, we have successfully gone through the Kafka QuickStart guide but with the necessary extension work to
enable and use SASL security for our Kafka Installation.  Pat yourself on the back, pour one out for the homies and
let's wrap this up.

## Deviating From the Happy Path

It must be said that this SASL-based extension to the Kafka QuickStart guide only followed the _happy path_ but there is
some utility in seeing what happens whenever we deviate from the happy path.  If you would like to see some of what
failing SASL looks like, feel free to take any of the commands we ran above starting the Kafka components and using the
non-SASL version.  For example, instead of using `${KAFKA_HOME}/config/server_sasl.properties` when starting up the
Kafka Broker, use `${KAFKA_HOME}/config/server.properties` and you should see that the Kafka Broker is unable to
connect to ZooKeeper.

## Simplifying the Process

For each Kafka component above, especially the plethora of Kafka Clients we configured, there was a very consistent and
repeatable process that was followed.  That being said, we can break down the SASLification _(I made that up)_ into the
following steps:

1. Configure the Kafka component to enable/require/use SASL _(component-specific)_
2. Create a JAAS file with the SASL credentials for the component to use
3. Configure the environment to use the JAAS file _(Set the `KAFKA_OPTS` environment variable)_
4. Run the Kafka component with the appropriate configuration file

There is even one more simplification that could be used in many cases and that's leveraging the `sasl.jaas.config`
configuration option in the Kafka conifguration file to throw your JAAS configuration into it.  So instead of having a
separate JAAS file and having to set the `KAFKA_OPTS` environment variable, you could omit that step and just set the
`sasl.jaas.config`.  For example, in _Step 5_ we configured a Kafka Client for the consumer and we could just has easily
used the following content for `${KAFKA_HOME}/config/consumer_sasl.properties`:

```ini
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username="consumer" password="consumer-secret";
```

As with most things, there are a few different ways to accomplish the same thing but for teaching purposes it made sense
to break things up into individual chunks instead of combining them.  But at least now you know how you can simplify the
process.

## In Closing

When I first got into Kafka, the Kafka QuickStart guide simplified the process greatly and I am forever appreciative.
But as I wanted to learn more about enabling SASL, there wasn't a simplified document that provided the same value.  I
hope that I was able to provide that for you, and that you enjoyed the journey as much as I did.  Good luck!

[jaas]: https://docs.oracle.com/javase/7/docs/technotes/guides/security/jaas/JAASRefGuide.html
[jaas-loginmodule]: https://docs.oracle.com/javase/7/docs/technotes/guides/security/jaas/JAASLMDevGuide.html
[kafka]: https://kafka.apache.org/
[kafka-connect]: https://kafka.apache.org/documentation/#connect
[kafka-quickstart]: https://kafka.apache.org/quickstart
[kafka-streams]: https://kafka.apache.org/documentation/streams/
[zookeeper]: https://zookeeper.apache.org/
