# Dual Servlet API Support

## Package Structure

This module supports both `javax.servlet` and `jakarta.servlet` APIs through package separation:

### javax.servlet (Spring Boot 2.x)
```
org.apache.dubbo.rpc.protocol.tri.servlet
├── TripleFilter.java
├── ServletStreamChannel.java
├── HttpMetadataAdapter.java
└── ... (other classes)
```

### jakarta.servlet (Spring Boot 3.x)
```
org.apache.dubbo.rpc.protocol.tri.servlet.jakarta
├── TripleFilter.java            (jakarta version)
├── ServletStreamChannel.java    (jakarta version)
├── HttpMetadataAdapter.java     (jakarta version)
└── ... (other classes)
```

## Dependencies

```gradle
// javax.servlet (HTTP/2 support)
compileOnly "org.apache.tomcat:tomcat-servlet-api:9.0.95"

// jakarta.servlet (Spring Boot 3.x)
compileOnly "jakarta.servlet:jakarta.servlet-api:${jakartaServletApiVersion}"
```

## Usage

**Spring Boot 2.x:**
```java
import org.apache.dubbo.rpc.protocol.tri.servlet.TripleFilter;
```

**Spring Boot 3.x:**
```java
import org.apache.dubbo.rpc.protocol.tri.servlet.jakarta.TripleFilter;
```

## Why Dual Support?

- **Backward Compatibility**: Existing Spring Boot 2.x applications continue to work
- **Forward Compatibility**: Full support for Spring Boot 3.x and Jakarta EE
- **Zero Breaking Changes**: Old code remains unchanged in the original package
- **Clear Separation**: Package naming makes the API version explicit
