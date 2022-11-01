---
title: "Documenting Cloud Pub/Sub Using AsyncAPI"
date: 2022-11-01T12:00:00-04:00
description: "This article discsuses how to document your Cloud Pub/Sub topology using AsyncAPI."
disableComments: false
tags:
- article
- asyncapi
- googlecloud
- googlepubsub
- technology
- tutorial
toc: true
type: post
---

[AsyncAPI][asyncapi], the _"the industry standard for defining asynchronous APIs"_, recently released version 2.5.0 of
its specification. What is significant about this release is that for the first time,
[Google Cloud Pub/Sub][google-pubsub] is
[natively supported](https://www.asyncapi.com/blog/release-notes-2.5.0#added-new-google-cloud-pubsub-bindings). As the
author of the Cloud Pub/Sub support for AsyncAPI, I would like to spend some time introducing to you to this feature.

## Background

> The AsyncAPI specification does not assume any kind of software topology, architecture or pattern.

The AsyncAPI object model is not tied to any specific _"software topology, architecture or pattern"_, meaning you should
be able to use document your asynchronous APIs using AsyncAPI regardless of your software topology, architecture or
pattern. But AsyncAPI **does** have support for documenting specific software topologies, architectures and patterns
using [Protocol][asyncapi-protocol] [Bindings][asyncapi-bindings] _(two separate links, one common term)_.

Protocol Bindings are AsyncAPI's way of defining protocol-specific documentation, or documentation specific to the
_"software topology, architecture or pattern"_ being used. And this is how native Cloud Pub/Sub support was added to
AsyncAPI.

This article will describe using AsyncAPI to document your Cloud Pub/Sub topology with common AsyncAPI, and the
newly-added Cloud Pub/Sub Protocol Bindings.

## Google Cloud Pub/Sub Bindings

The [Google Cloud Pub/Sub Bindings](https://github.com/asyncapi/bindings/tree/master/googlepubsub) consists of two
binding objects _(at this time)_ available using the `googlepubsub` protocol. Each of these objects are discussed
below.

### Channel Binding Object

> A channel is an addressable component, made available by the [server][asyncapi-server], for the organization of
> messages. A channel is an addressable component, made available by the server, for the organization of
> [messages][asyncapi-message].

The [Channel Binding Object][asyncapi-channel-binding-object] is used to document Cloud Pub/Sub's
[Topic][google-pubsub-topic] object, and contains the pertinent `Topic` configuration to allow for proper API
interaction. The [AsyncAPI documentation][asyncapi-channel-binding-object] is the source of truth for the particulars of
the Cloud Pub/Sub `Channel Binding Object` configuration, but below is an example _(sourced from the documentation)_:

```yaml
# ...
channels:
  topic-avro-schema:
    bindings:
      googlepubsub:
        topic: projects/your-project/topics/topic-avro-schema
        schemaSettings:
          encoding: json
          name: projects/your-project/schemas/message-avro
# ...
  topic-proto-schema:
    bindings:
      googlepubsub:
        topic: projects/your-project/topics/topic-proto-schema
        messageRetentionDuration: 86400s
        messageStoragePolicy:
          allowedPersistenceRegions:
          - us-central1
          - us-central2
          - us-east1
          - us-east4
          - us-east5
          - us-east7
          - us-south1
          - us-west1
          - us-west2
          - us-west3
          - us-west4
        schemaSettings:
          encoding: binary
          name: projects/your-project/schemas/message-proto
# ...
```

The configuration of the `Channel Binding Object` is pretty straight forward.

### Message Binding Object

> A message is the mechanism by which information is exchanged via a channel between [servers][asyncapi-server] and
> applications.

The [Message Binding Object][asyncapi-message-binding-object] is used to document Cloud Pub/Sub's
[PubsubMessage][google-pubsub-pubsubmessage] object, alongside with pertintent parts of the Google Cloud Pub/Sub
[Schema][google-pubsub-schema] object. As with the `Channel Binding Object`, the `Mesage Binding Object` for Cloud
Pub/Sub documents the pertinent `PubsubMessage/Schema` configuration to allow for proper API interaction. As above, the
[AsyncAPI documentation][asyncapi-message-binding-object] is the source of truth for the particulars of the Cloud
Pub/Sub `Message Binding Object` configuration, but below is an example _(sourced from the documentation)_:

```yaml
# ...
components:
  messages:
    messageAvro:
      bindings:
        googlepubsub:
          schema:
            name: projects/your-project/schemas/message-avro
            type: avro
      contentType: application/json
      name: MessageAvro
      payload:
        fields:
        - name: message
          type: string
        name: Message
        type: record
      schemaFormat: application/vnd.apache.avro+yaml;version=1.9.0
    messageProto:
      bindings:
        googlepubsub:
          schema:
            name: projects/your-project/schemas/message-proto
            type: protobuf
      contentType: application/octet-stream
      name: MessageProto
      payload: true
# ...
```

The AsyncAPI example above contains both the Cloud Pub/Sub Protocol Bindings and common AsyncAPI, which is discussed
separately below.

## Common AsyncAPI Support

As mentioned earlier, the
_"AsyncAPI specification does not assume any kind of software topology, architecture or pattern"_ and a good bit of
Cloud Pub/Sub could be documented without the addition of the Cloud Pub/Sub Protocol Bindings mentioned above. The
sections below explain how to use the agnostic AsyncAPI support for documenting Cloud Pub/Sub.

### Server Object

> An object representing a message broker, a server or any other kind of computer program capable of sending and/or
> receiving data.

The [Server Object][asyncapi-server-object] is used to docuement where your [servers][asyncapi-server] are located. For
Cloud Pub/Sub, there are both HTTP/REST and gRPC [endpoints][google-pubsub-service-endpoints], each of which are
available globally and regionally. While not strictly required, you _should_ document which Cloud Pub/Sub endpoints you
are using. Part of the native Cloud Pub/Sub support, the `googlepubsub` protocol is now available and would be used as
the `protocol` value for your Cloud Pub/Sub `Server Object`(s).

An easy way to document Cloud Pub/Sub servers with AsyncAPI is to leverage the
[Server Variable Object][asyncapi-server-variable-object]s. This allows you to make your `Server Object`(s) dynamic and
be specific about the Cloud Pub/Sub endpoint(s) your API is using. Below is an example:

```yaml
# ...
servers:
  cloudPubSub:
    url: '{cloudPubSubEndpoint}.googleapis.com'
    description: The API for Cloud Pub/Sub.
    protocol: googlepubsub
    variables:
      cloudPubSubEndpoint:
        # Default to the global endpoint but allow region-specific endpoints.
        default: pubsub
        description: The Cloud Pub/Sub endpoint region.
# ...
```

The example above defaults to using the global Cloud Pub/Sub service endpoint, but allows using any supported Cloud
Pub/Sub region. If you wanted to be specific about which region(s) your Cloud Pub/Sub usage includes, you could throw an
`enum` property into the [Server Variable Object][asyncapi-server-variable-object] to be more specific. Here is an
example:

```yaml
# ...
servers:
  cloudPubSub:
    url: '{cloudPubSubEndpoint}.googleapis.com'
    description: The API for Cloud Pub/Sub.
    protocol: googlepubsub
    variables:
      cloudPubSubEndpoint:
        description: The Cloud Pub/Sub endpoint region.
        # Restrict to only the following region-specific endpoints.
        enum:
        - us-central1
        - us-central2
        - us-east1
        - us-east4
        - us-east5
        - us-east7
        - us-south1
        - us-west1
        - us-west2
        - us-west3
        - us-west4
# ...
```

### Channels Object

> Holds the relative paths to the individual channel and their operations. Channel paths are relative to servers.
>
> Channels are also known as "topics", "routing keys", "event types" or "paths".

The [Channels Object][asyncapi-channels-object] is where AsyncAPI collects information about
[Channel][asyncapi-channel](s) an API exposes. As this relates to Cloud Pub/Sub, the _"channel path"_ is analogous to
the `Topic` name. Below is an example:

```yaml
# ...
channels:
  /projects/your-project/topics/topic-avro-schema:
    # ...
# ...
```

There isn't much to this section other than to point out that the `Channel Object`'s key corresponds to the Cloud
Pub/Sub `Topic` name. _(This is also where you would define the `Channel Binding Object` described above.)_

### Message Object

> Describes a message received on a given channel and operation.

The [Message Object][asyncapi-message] is where AsyncAPI collects information about the [Message][asyncapi-message]s
exchanged over a `Channel`. While most AsyncAPI `Message Object` properties are pretty straight forward, like using the
`PubsubMessage`'s `messageId` for the value of AsyncAPI's `messageId`, there are some compatibility issues between
AsyncAPI and Cloud Pub/Sub as it relates to defining the `Message Object`'s `payload` property.

When defining a Cloud Pub/Sub `Topic`, you are asked to provide _(or reference)_ a `Schema` for validating messages
publisehd to the `Topic`. Since Cloud Pub/Sub `Schema`s are reused across `Topic`s, documenting the
[SchemaSettings][google-pubsub-schemasettings] within the `Channel Binding Object` does not make sense because a
`Schema` is not tied to a `Topic`. Another reason that the `SchemaSettings` is not documented in the
`Channel Binding Object` is because AsyncAPI already has a mechanism for defining schemas for message validation and
that is by using the `payload` property _(the property affected by compatibility issues)_ of the `Message Object`.

Cloud Pub/Sub currently supports two types of schemas: [Apahce Avro][avro] and
[Protobuf][protobuf]. Unfortunately, only Avro is supported by AsyncAPI _(at this time)_ and this is the
_"compatibility issue"_ mentioned above. For Avro `Schema`s, the `payload` property of the `Message Object` can be used
normally to describe your Cloud Pub/Sub `Schema` in AsyncAPI. Below is an example
_(completed with `Message Binding Object`)_:

```yaml
# ...
components:
  messages:
    messageAvro:
      bindings:
        googlepubsub:
          schema:
            name: projects/your-project/schemas/message-avro
            type: avro
      contentType: application/json
      name: MessageAvro
      payload:
        fields:
        - name: message
          type: string
        name: Message
        type: record
      schemaFormat: application/vnd.apache.avro+yaml;version=1.9.0
# ...
```

But for Protobuf `Schema`s, the `payload` property is unusable at this time. For documentation of Protobuf `Schema`
objects in AsyncAPI, you might consider using a [Specification Extension][asyncapi-specification-extension] so that you
can at least provide documentation to the API consumer. Below is an example
_(the `Specification Extension` name used is purely for example purposes)_:

```yaml
# ...
components:
  messages:
    messageProto:
      bindings:
        googlepubsub:
          schema:
            name: projects/your-project/schemas/message-proto
            type: protobuf
      contentType: application/octet-stream
      name: MessageProto
      payload: true
      x-protobuf-payload: |
        syntax = "proto2";

        message Message {
          required string message = 1;
        }
# ...
```

Regardless of the `Schema` type, there are two properties that need to be discussed before moving on from the
`Message Object`.

#### contentType

> The content type to use when encoding/decoding a message's payload. The value MUST be a specific media type
> (e.g. `application/json`).

The value of the `contentType` property should be set based on the [Encoding][google-pubsub-encoding] of the
`SchemaSettings`. When `Encoding` is `JSON`, `contentType` should be set to `application/json`. And when `Encoding` is
`BINARY`, `contentType` should be `application/octet-stream`.

#### schemaFormat

> A string containing the name of the schema format used to define the message payload.

The value of the `schemaFormat` property depends on whether you're using Avro or Protobuf for your `Message` `Schema`.
When an Avro `Schema` is used for the `PubsubMessage`, the value of `schemaFormat` should be based on the appropriate
Avro media type and Avro version. _(See the examples above.)_ When a Protobuf `Schema` is used for the `PubsubMessage`,
`schemaFormat` should be omitted because AsyncAPI does not support Protobuf natively at this time.

## Conclusion

Documenting your APIs is extremely important, and for asynchronous APIs, AsyncAPI is the _"industry standard"_. Prior to
the 2.5.0 release of AsyncAPI, while you could document parts of your Cloud Pub/Sub topology, there was a large gap as
there was no way to document Cloud Pub/Sub specific information that may affect your API consumers. With AsyncAPI 2.5.0
there is native Cloud Pub/Sub support and which should help using AsyncAPI to document your Cloud Pub/Sub topology more
complete. So if you're using Cloud Pub/Sub, you now have no reason not to use AsyncAPI for documenting your APIs.

[asyncapi]: https://www.asyncapi.com/
[asyncapi-bindings]: https://www.asyncapi.com/docs/reference/specification/v2.5.0#definitionsBindings
[asyncapi-channel]: https://www.asyncapi.com/docs/reference/specification/v2.5.0#definitionsChannel
[asyncapi-channel-binding-object]: https://github.com/asyncapi/bindings/tree/master/googlepubsub#channel-binding-object
[asyncapi-channels-object]: https://www.asyncapi.com/docs/reference/specification/v2.5.0#channelsObject
[asyncapi-message]: https://www.asyncapi.com/docs/reference/specification/v2.5.0#definitionsMessage
[asyncapi-message-binding-object]: https://github.com/asyncapi/bindings/tree/master/googlepubsub#message-binding-object
[asyncapi-protocol]: https://www.asyncapi.com/docs/reference/specification/v2.5.0#definitionsProtocol
[asyncapi-server]: https://www.asyncapi.com/docs/reference/specification/v2.5.0#definitionsServer
[asyncapi-server-object]: https://www.asyncapi.com/docs/reference/specification/v2.5.0#serverObject
[asyncapi-server-variable-object]: https://www.asyncapi.com/docs/reference/specification/v2.5.0#serverVariableObject
[asyncapi-specification-extension]: https://www.asyncapi.com/docs/reference/specification/v2.5.0#specificationExtensions
[avro]: https://avro.apache.org/
[google-pubsub]: https://cloud.google.com/pubsub
[google-pubsub-encoding]: https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.topics#Encoding
[google-pubsub-pubsubmessage]: https://cloud.google.com/pubsub/docs/reference/rest/v1/PubsubMessage
[google-pubsub-schema]: https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.schemas#Schema
[google-pubsub-schemasettings]: https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.topics#SchemaSettings
[google-pubsub-service-endpoints]: https://cloud.google.com/pubsub/docs/reference/service_apis_overview#service_endpoints
[google-pubsub-topic]: https://cloud.google.com/pubsub/docs/reference/rest/v1/projects.topics#Topic
[protobuf]: https://developers.google.com/protocol-buffers
