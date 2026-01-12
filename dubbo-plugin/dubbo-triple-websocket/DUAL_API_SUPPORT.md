# Dual Servlet/WebSocket API Support

## Package Structure

This module supports both `javax` and `jakarta` APIs through package separation:

### javax API (Spring Boot 2.x)
```
org.apache.dubbo.rpc.protocol.tri.websocket
├── TripleWebSocketFilter.java
├── TripleEndpoint.java
├── TripleBinaryMessageHandler.java
├── TripleTextMessageHandler.java
├── WebSocketStreamChannel.java
└── ... (other classes)
```

### jakarta API (Spring Boot 3.x)
```
org.apache.dubbo.rpc.protocol.tri.websocket.jakarta
├── TripleWebSocketFilter.java         (jakarta version)
├── TripleEndpoint.java                (jakarta version)
├── TripleBinaryMessageHandler.java    (jakarta version)
├── TripleTextMessageHandler.java      (jakarta version)
├── WebSocketStreamChannel.java        (jakarta version)
└── ... (other classes)
```

## Dependencies

```gradle
// Servlet API
compileOnly "javax.servlet:javax.servlet-api:${servletVersion}"
compileOnly "jakarta.servlet:jakarta.servlet-api:${jakartaServletApiVersion}"

// WebSocket API
compileOnly "javax.websocket:javax.websocket-api:${websocketApiVersion}"
compileOnly "jakarta.websocket:jakarta.websocket-api:${jakartaWebsocketApiVersion}"
compileOnly "jakarta.websocket:jakarta.websocket-client-api:${jakartaWebsocketClientApiVersion}"
```

## Usage

**Spring Boot 2.x:**
```java
import org.apache.dubbo.rpc.protocol.tri.websocket.TripleWebSocketFilter;
import org.apache.dubbo.rpc.protocol.tri.websocket.TripleEndpoint;
```

**Spring Boot 3.x:**
```java
import org.apache.dubbo.rpc.protocol.tri.websocket.jakarta.TripleWebSocketFilter;
import org.apache.dubbo.rpc.protocol.tri.websocket.jakarta.TripleEndpoint;
```

## Why Dual Support?

- **Backward Compatibility**: Existing Spring Boot 2.x applications continue to work
- **Forward Compatibility**: Full support for Spring Boot 3.x and Jakarta EE
- **Zero Breaking Changes**: Old code remains unchanged in the original package
- **Clear Separation**: Package naming makes the API version explicit
- **WebSocket Support**: Full WebSocket protocol support for both API versions
