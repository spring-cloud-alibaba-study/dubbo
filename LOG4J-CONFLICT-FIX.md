# Log4j 依赖冲突修复说明

## 问题描述

运行 Spring Boot Demo 应用时遇到以下错误：

### 错误 1: Log4j 循环依赖
```
Exception in thread "main" java.lang.ExceptionInInitializerError
Caused by: org.apache.logging.log4j.LoggingException: 
    log4j-slf4j-impl cannot be present with log4j-to-slf4j
```

### 错误 2: Logback 与 Log4j2 冲突
```
Exception in thread "main" java.lang.IllegalArgumentException: 
    LoggerFactory is not a Logback LoggerContext but Logback is on the classpath. 
    Either remove Logback or the competing implementation 
    (class org.apache.logging.slf4j.Log4jLoggerFactory loaded from 
    file:/Users/admin/.m2/repository/org/apache/logging/log4j/log4j-slf4j-impl/2.17.2/log4j-slf4j-impl-2.17.2.jar).
```

---

## 问题原因

项目中同时存在多个互斥的日志实现：

### 问题 1: Log4j 桥接库冲突
| 依赖 | 作用 | 来源 |
|------|------|------|
| `log4j-slf4j-impl` | SLF4J → Log4j2 | `spring-boot-starter-log4j2` |
| `log4j-to-slf4j` | Log4j2 → SLF4J | 其他传递依赖 |

这两个库会造成**循环依赖**，因此 Log4j2 会抛出异常阻止启动。

### 问题 2: Logback 与 Log4j2 共存
| 依赖 | 作用 | 来源 |
|------|------|------|
| `logback-classic` + `logback-core` | SLF4J 的 Logback 实现 | Spring Boot 默认 |
| `log4j-slf4j-impl` | SLF4J 的 Log4j2 实现 | `spring-boot-starter-log4j2` |

Spring Boot 期望使用 Logback，但实际加载的是 Log4j2，导致类型不匹配。

---

## 技术背景

### Log4j 桥接库说明

- **log4j-slf4j-impl**：
  - 将 SLF4J API 调用路由到 Log4j2 实现
  - 使用场景：你的应用使用 SLF4J API，但希望 Log4j2 作为底层日志框架
  - 这是 Spring Boot 使用 Log4j2 的标准配置

- **log4j-to-slf4j**：
  - 将 Log4j2 API 调用路由到 SLF4J
  - 使用场景：你的应用使用 SLF4J 作为日志门面，需要把 Log4j2 API 的调用转发到 SLF4J
  - 通常用于统一使用 Logback 作为日志实现

### 为什么不能共存？

```
应用代码 → SLF4J API → log4j-slf4j-impl → Log4j2 API → log4j-to-slf4j → SLF4J API → ...
                                                          ↑________________↓
                                                             循环依赖！
```

---

## 解决方案

在所有使用 `spring-boot-starter-log4j2` 的模块中**排除冲突的日志依赖**：

### 完整的排除配置

```groovy
// 在 build.gradle 中添加全局排除配置
configurations.all {
    // 排除 log4j-to-slf4j，避免与 log4j-slf4j-impl 冲突
    exclude group: 'org.apache.logging.log4j', module: 'log4j-to-slf4j'
    // 排除 Spring Boot 默认的 Logback，使用 Log4j2
    exclude group: 'org.springframework.boot', module: 'spring-boot-starter-logging'
    exclude group: 'ch.qos.logback', module: 'logback-classic'
    exclude group: 'ch.qos.logback', module: 'logback-core'
}
```

### 为什么需要这些排除？

1. **排除 `log4j-to-slf4j`**：避免与 `log4j-slf4j-impl` 形成循环依赖
2. **排除 `spring-boot-starter-logging`**：这是 Spring Boot 默认的日志依赖，包含 Logback
3. **排除 `logback-classic` 和 `logback-core`**：确保 Logback 完全被移除

### 已修复的模块

- ✅ `dubbo-demo-spring-boot-provider`
- ✅ `dubbo-demo-spring-boot-consumer`
- ✅ `dubbo-demo-spring-boot-servlet`
- ✅ `dubbo-demo-mcp-server`

---

## 验证

### 验证依赖已正确排除

```bash
# 检查 provider 模块的运行时依赖
./gradlew :dubbo-demo:dubbo-demo-spring-boot:dubbo-demo-spring-boot-provider:dependencies --configuration runtimeClasspath | grep log4j

# 应该只看到 log4j-slf4j-impl，不应该看到 log4j-to-slf4j
```

### 运行应用

```bash
cd dubbo-demo/dubbo-demo-spring-boot/dubbo-demo-spring-boot-provider
../../../gradlew bootRun
```

应该能正常启动，不再出现 `LoggingException`。

---

## 最佳实践

### 在 Dubbo Spring Boot 项目中使用 Log4j2

1. **添加依赖**

```groovy
dependencies {
    implementation "org.springframework.boot:spring-boot-starter:${springBootVersion}"
    implementation "org.springframework.boot:spring-boot-starter-log4j2:${springBootVersion}"
}
```

2. **排除冲突的桥接库**

```groovy
configurations.all {
    // 使用 Log4j2 作为日志实现时，必须排除 log4j-to-slf4j
    exclude group: 'org.apache.logging.log4j', module: 'log4j-to-slf4j'
    
    // 同时也建议排除默认的 Logback
    exclude group: 'org.springframework.boot', module: 'spring-boot-starter-logging'
}
```

3. **添加 Log4j2 配置文件**

在 `src/main/resources` 下创建 `log4j2.xml` 或 `log4j2-spring.xml`：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="WARN">
    <Appenders>
        <Console name="Console" target="SYSTEM_OUT">
            <PatternLayout pattern="%d{HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n"/>
        </Console>
    </Appenders>
    <Loggers>
        <Root level="info">
            <AppenderRef ref="Console"/>
        </Root>
        <Logger name="org.apache.dubbo" level="info"/>
    </Loggers>
</Configuration>
```

---

## 日志框架选择指南

### 使用 Log4j2（当前配置）

**优点**：
- 性能优秀（异步日志性能极高）
- 功能强大（支持插件、Lambda 表达式等）
- 配置灵活

**配置**：
```groovy
dependencies {
    implementation "org.springframework.boot:spring-boot-starter:${springBootVersion}"
    implementation "org.springframework.boot:spring-boot-starter-log4j2:${springBootVersion}"
}

configurations.all {
    exclude group: 'org.apache.logging.log4j', module: 'log4j-to-slf4j'
    exclude group: 'org.springframework.boot', module: 'spring-boot-starter-logging'
}
```

### 使用 Logback（Spring Boot 默认）

**优点**：
- Spring Boot 默认集成，开箱即用
- 配置简单
- 社区支持好

**配置**：
```groovy
dependencies {
    implementation "org.springframework.boot:spring-boot-starter:${springBootVersion}"
    // 不需要额外依赖，spring-boot-starter 已包含 logback
}
```

### 使用 SLF4J Simple（测试环境）

**优点**：
- 极简配置
- 适合测试

**配置**：
```groovy
dependencies {
    testImplementation "org.slf4j:slf4j-simple:${slf4jVersion}"
}

configurations.testRuntimeClasspath {
    exclude group: 'org.springframework.boot', module: 'spring-boot-starter-logging'
    exclude group: 'org.apache.logging.log4j', module: 'log4j-slf4j-impl'
}
```

---

## 常见问题

### Q1: 我该选择 Logback 还是 Log4j2？

**A:** 两者都很优秀，选择建议：

- **选择 Logback**：如果你追求稳定性和简单性
- **选择 Log4j2**：如果你需要极致性能（异步日志场景）或高级功能

### Q2: 如何全局排除冲突的日志依赖？

**A:** 在根 `build.gradle` 的 `allprojects` 或 `subprojects` 中配置：

```groovy
subprojects {
    configurations.all {
        exclude group: 'org.apache.logging.log4j', module: 'log4j-to-slf4j'
        exclude group: 'org.springframework.boot', module: 'spring-boot-starter-logging'
    }
}
```

### Q3: 其他模块也有同样的问题吗？

**A:** 只有**使用 spring-boot-starter-log4j2 的可运行模块**需要排除。

库模块（autoconfigure、common 等）不需要，因为它们使用 `compileOnly`。

---

## 相关文档

- [Apache Log4j 2 官方文档](https://logging.apache.org/log4j/2.x/)
- [Spring Boot Logging 文档](https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.logging)
- [SLF4J 官方文档](http://www.slf4j.org/)

---

**最后更新**: 2025-11-01

