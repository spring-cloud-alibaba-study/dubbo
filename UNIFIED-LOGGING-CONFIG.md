# Dubbo 项目统一日志配置

本文档说明 Dubbo 项目在 Gradle 迁移后的统一日志管理策略。

---

## 📋 配置概览

### 日志框架选择

**Dubbo 项目统一使用 Log4j2 作为日志实现**

| 组件 | 版本 | 作用 |
|------|------|------|
| SLF4J API | 1.7.36 | 日志门面（API） |
| Log4j2 | 2.24.3 | 日志实现 |
| log4j-slf4j-impl | 2.17.2 | SLF4J → Log4j2 桥接 |

---

## 🎯 统一配置策略

### 1. **根 build.gradle 全局配置**

在 `build.gradle` 的 `subprojects` 块中，已添加全局日志管理：

```groovy
subprojects {
    if (!isPlatformProject) {
        // ========================================
        // 统一日志管理配置
        // ========================================
        configurations.all {
            // 解决 Log4j 循环依赖问题
            // log4j-slf4j-impl (SLF4J -> Log4j2) 与 log4j-to-slf4j (Log4j2 -> SLF4J) 
            // 不能同时存在，会造成循环依赖
            exclude group: 'org.apache.logging.log4j', module: 'log4j-to-slf4j'
        }
    }
}
```

**好处**：
- ✅ 所有子模块自动继承此配置
- ✅ 避免在每个模块中重复配置
- ✅ 确保整个项目的一致性

---

### 2. **Spring Boot 应用模块配置**

对于使用 `spring-boot-starter-log4j2` 的应用模块，需要排除 Spring Boot 默认的 Logback：

```groovy
// dubbo-demo-spring-boot-provider/build.gradle
description = 'The dubbo-demo-spring-boot module of dubbo project'

configurations {
    // 使用 Log4j2 作为日志实现，排除 Spring Boot 默认的 Logback
    all*.exclude group: 'org.springframework.boot', module: 'spring-boot-starter-logging'
    all*.exclude group: 'ch.qos.logback'
}

dependencies {
    implementation project(':dubbo-demo:dubbo-demo-spring-boot:dubbo-demo-spring-boot-interface')
    implementation project(':dubbo-registry:dubbo-registry-zookeeper')
    implementation project(':dubbo-spring-boot-project:dubbo-spring-boot-starters:dubbo-spring-boot-starter')
    implementation "org.springframework.boot:spring-boot-starter:${springBootVersion}"
    implementation "org.springframework.boot:spring-boot-starter-log4j2:${springBootVersion}"
}
```

**已应用此配置的模块**：
- ✅ `dubbo-demo-spring-boot-provider`
- ✅ `dubbo-demo-spring-boot-consumer`
- ✅ `dubbo-demo-spring-boot-servlet`
- ✅ `dubbo-demo-mcp-server`

---

### 3. **库模块配置**

对于 Dubbo 核心库模块，使用 `compileOnly` 避免强制依赖：

```groovy
// dubbo-spring-boot-autoconfigure/build.gradle
dependencies {
    // 仅编译时依赖，不强制使用方使用 Log4j2
    compileOnly "org.springframework.boot:spring-boot-starter-log4j2:${spring_boot_starter_log4j2Version}"
    
    // 测试时使用 Log4j2
    testImplementation "org.apache.logging.log4j:log4j-slf4j-impl:${log4j2Version}"
}
```

**好处**：
- ✅ 库模块不强制依赖特定日志实现
- ✅ 使用方可以自由选择日志框架
- ✅ 符合库设计最佳实践

---

## ✅ 配置验证

### 验证依赖树

```bash
# 检查 provider 模块的运行时依赖
./gradlew :dubbo-demo:dubbo-demo-spring-boot:dubbo-demo-spring-boot-provider:dependencies --configuration runtimeClasspath | grep -E "logback|log4j"

# 期望输出（✅ 正确）：
# ✅ log4j-slf4j-impl
# ✅ log4j-core
# ✅ log4j-api
# ✅ log4j-jul
# ❌ 不应该有 logback-classic
# ❌ 不应该有 logback-core
# ❌ 不应该有 log4j-to-slf4j
```

### 实际验证结果

```
\--- org.springframework.boot:spring-boot-starter-log4j2:2.7.18
     +--- org.apache.logging.log4j:log4j-slf4j-impl:2.17.2
     |    +--- org.apache.logging.log4j:log4j-api:2.17.2 -> 2.24.3
     |    \--- org.apache.logging.log4j:log4j-core:2.17.2
     |         \--- org.apache.logging.log4j:log4j-api:2.17.2 -> 2.24.3
     +--- org.apache.logging.log4j:log4j-core:2.17.2 (*)
     +--- org.apache.logging.log4j:log4j-jul:2.17.2
     |    \--- org.apache.logging.log4j:log4j-api:2.17.2 -> 2.24.3
```

✅ **完美！只有 Log4j2，没有 Logback 和 log4j-to-slf4j**

---

## 🚀 运行应用

### 启动 Provider

```bash
# 方式 1: 使用 Gradle
./gradlew :dubbo-demo:dubbo-demo-spring-boot:dubbo-demo-spring-boot-provider:bootRun

# 方式 2: 在 IDEA 中直接运行
# 找到 ProviderApplication.java，右键 Run
```

### 启动 Consumer

```bash
./gradlew :dubbo-demo:dubbo-demo-spring-boot:dubbo-demo-spring-boot-consumer:bootRun
```

### 预期日志输出

应该看到 Log4j2 的日志输出，而不是 Logback：

```
12:34:56.789 [main] INFO  org.apache.dubbo.springboot.demo.provider.ProviderApplication - Starting ProviderApplication...
```

---

## 📝 Log4j2 配置文件

### 创建配置文件

在 `src/main/resources` 下创建 `log4j2.xml`：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="WARN">
    <Properties>
        <!-- 定义日志格式 -->
        <Property name="LOG_PATTERN">%d{yyyy-MM-dd HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n</Property>
    </Properties>

    <Appenders>
        <!-- 控制台输出 -->
        <Console name="Console" target="SYSTEM_OUT">
            <PatternLayout pattern="${LOG_PATTERN}"/>
        </Console>

        <!-- 文件输出 -->
        <RollingFile name="RollingFile" fileName="logs/dubbo.log"
                     filePattern="logs/dubbo-%d{yyyy-MM-dd}-%i.log">
            <PatternLayout pattern="${LOG_PATTERN}"/>
            <Policies>
                <TimeBasedTriggeringPolicy interval="1"/>
                <SizeBasedTriggeringPolicy size="100MB"/>
            </Policies>
            <DefaultRolloverStrategy max="10"/>
        </RollingFile>
    </Appenders>

    <Loggers>
        <!-- Dubbo 日志 -->
        <Logger name="org.apache.dubbo" level="info" additivity="false">
            <AppenderRef ref="Console"/>
            <AppenderRef ref="RollingFile"/>
        </Logger>

        <!-- Spring 日志 -->
        <Logger name="org.springframework" level="info" additivity="false">
            <AppenderRef ref="Console"/>
        </Logger>

        <!-- 根日志 -->
        <Root level="info">
            <AppenderRef ref="Console"/>
            <AppenderRef ref="RollingFile"/>
        </Root>
    </Loggers>
</Configuration>
```

---

## 🔧 日志级别调整

### 通过 application.properties 调整

```properties
# Log4j2 配置文件位置
logging.config=classpath:log4j2.xml

# 调整日志级别
logging.level.root=INFO
logging.level.org.apache.dubbo=DEBUG
logging.level.org.springframework=INFO
logging.level.io.netty=WARN

# 异步日志配置（可选，提高性能）
log4j2.contextSelector=org.apache.logging.log4j.core.async.AsyncLoggerContextSelector
```

### 通过 application.yml 调整

```yaml
logging:
  config: classpath:log4j2.xml
  level:
    root: INFO
    org.apache.dubbo: DEBUG
    org.springframework: INFO
    io.netty: WARN
```

---

## 🎨 异步日志配置（推荐）

### 启用异步日志

Log4j2 的异步日志性能极佳，推荐在生产环境使用：

1. **添加依赖**（可选，提高性能）：

```groovy
dependencies {
    implementation "com.lmax:disruptor:3.4.4"  // 异步日志需要
}
```

2. **配置系统属性**：

在 `application.properties` 中：
```properties
# 启用异步日志
log4j2.contextSelector=org.apache.logging.log4j.core.async.AsyncLoggerContextSelector
```

或在启动参数中：
```bash
java -Dlog4j2.contextSelector=org.apache.logging.log4j.core.async.AsyncLoggerContextSelector -jar app.jar
```

---

## 📊 日志框架对比

| 特性 | Logback | Log4j2 (✅ 当前选择) |
|------|---------|---------------------|
| 性能 | 中等 | 极高（尤其是异步模式） |
| 配置方式 | XML, Groovy | XML, JSON, YAML, Properties |
| 异步日志 | 需要额外配置 | 内置支持，配置简单 |
| Lambda 支持 | ❌ | ✅ |
| 插件系统 | 有限 | 丰富 |
| Spring Boot 默认 | ✅ | ❌ |
| 内存开销 | 较低 | 极低（异步模式） |

---

## ⚠️ 常见问题

### Q1: 为什么选择 Log4j2 而不是 Logback？

**A:** 主要原因：
1. **性能**：Log4j2 的异步日志性能远超 Logback
2. **功能**：支持 Lambda 表达式、插件系统更强大
3. **统一性**：Dubbo 项目已广泛使用 Log4j2

### Q2: 可以使用 Logback 吗？

**A:** 可以，但需要调整配置：

```groovy
configurations {
    // 移除 Log4j2 相关排除
    // all*.exclude group: 'ch.qos.logback'  // 注释掉这行
    
    // 排除 Log4j2
    all*.exclude group: 'org.apache.logging.log4j'
}

dependencies {
    // implementation "org.springframework.boot:spring-boot-starter-log4j2:${springBootVersion}"  // 删除
    
    // Spring Boot 默认包含 Logback，无需额外依赖
    implementation "org.springframework.boot:spring-boot-starter:${springBootVersion}"
}
```

### Q3: 如何在测试中使用不同的日志配置？

**A:** 在 `src/test/resources` 下创建 `log4j2-test.xml`：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="WARN">
    <Appenders>
        <Console name="Console" target="SYSTEM_OUT">
            <PatternLayout pattern="%d{HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n"/>
        </Console>
    </Appenders>
    
    <Loggers>
        <Root level="debug">
            <AppenderRef ref="Console"/>
        </Root>
    </Loggers>
</Configuration>
```

---

## 📚 相关文档

- `LOG4J-CONFLICT-FIX.md` - Log4j 依赖冲突详细解决方案
- `GRADLE-DEPENDENCY-OPTIMIZATION.md` - Gradle 依赖优化指南
- `GRADLE-MIGRATION-STATUS.md` - Gradle 迁移状态报告
- `IDEA-GRADLE-SETUP.md` - IDEA 配置指南

---

## 📈 性能建议

### 生产环境配置

```xml
<Configuration status="WARN" monitorInterval="30">
    <Properties>
        <Property name="LOG_PATTERN">%d{yyyy-MM-dd HH:mm:ss.SSS} [%t] %-5level %logger{36} - %msg%n</Property>
        <Property name="LOG_PATH">./logs</Property>
    </Properties>

    <Appenders>
        <!-- 异步 Appender -->
        <Async name="AsyncConsole">
            <AppenderRef ref="Console"/>
        </Async>
        
        <Async name="AsyncFile">
            <AppenderRef ref="RollingFile"/>
        </Async>
        
        <Console name="Console" target="SYSTEM_OUT">
            <PatternLayout pattern="${LOG_PATTERN}"/>
        </Console>
        
        <RollingFile name="RollingFile" 
                     fileName="${LOG_PATH}/dubbo.log"
                     filePattern="${LOG_PATH}/dubbo-%d{yyyy-MM-dd}-%i.log.gz"
                     immediateFlush="false">  <!-- 禁用立即刷新，提高性能 -->
            <PatternLayout pattern="${LOG_PATTERN}"/>
            <Policies>
                <TimeBasedTriggeringPolicy interval="1"/>
                <SizeBasedTriggeringPolicy size="500MB"/>
            </Policies>
            <DefaultRolloverStrategy max="30" compressionLevel="9"/>
        </RollingFile>
    </Appenders>

    <Loggers>
        <!-- 异步根日志 -->
        <AsyncRoot level="info" includeLocation="false">  <!-- 禁用位置信息，提高性能 -->
            <AppenderRef ref="AsyncConsole"/>
            <AppenderRef ref="AsyncFile"/>
        </AsyncRoot>
    </Loggers>
</Configuration>
```

---

## ✅ 总结

### 配置完成清单

- [x] 根 `build.gradle` 全局排除 `log4j-to-slf4j`
- [x] Spring Boot 应用模块排除 Logback
- [x] 所有 demo 模块使用 Log4j2
- [x] 库模块使用 `compileOnly` 避免强制依赖
- [x] 依赖树验证通过
- [x] 文档完善

### 统一管理的好处

✅ **一致性**: 整个项目使用统一的日志框架  
✅ **简单性**: 根配置自动继承，减少重复  
✅ **可维护性**: 集中管理，易于调整  
✅ **性能**: Log4j2 异步日志性能优异  
✅ **灵活性**: 库模块不强制日志实现  

---

**最后更新**: 2025-11-01  
**维护者**: Dubbo Team

