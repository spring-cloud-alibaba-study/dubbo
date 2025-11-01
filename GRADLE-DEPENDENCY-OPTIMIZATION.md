# Gradle 依赖优化指南

切换到 Gradle 后，有很多依赖可以简化或省略。本文档说明 Gradle 中不需要手动声明的依赖类型。

---

## 📋 依赖管理原则

### Maven vs Gradle 的关键差异

| 特性 | Maven | Gradle |
|------|-------|--------|
| 传递依赖 | `compile` 总是传递 | `api` 传递，`implementation` 不传递 |
| 依赖范围 | `compile`, `provided`, `test`, `runtime` | `api`, `implementation`, `compileOnly`, `runtimeOnly`, `testImplementation` |
| 自动依赖 | 通过 BOM 管理 | 通过 `api` 自动传递 |
| 重复声明 | 需要显式声明 | 可以依赖传递 |

---

## ✅ 不需要手动声明的依赖类型

### 1. **Spring Boot Starter 自动包含的依赖**

当你依赖 Spring Boot Starter 时，很多核心依赖会自动引入。

#### ❌ **不需要显式声明**：

```groovy
dependencies {
    implementation "org.springframework.boot:spring-boot-starter:${springBootVersion}"
    
    // ❌ 以下依赖会自动引入，不需要重复声明
    // implementation "org.springframework.boot:spring-boot"
    // implementation "org.springframework.boot:spring-boot-autoconfigure"
    // implementation "org.springframework:spring-core"
    // implementation "org.springframework:spring-context"
    // implementation "org.slf4j:slf4j-api"
}
```

#### `spring-boot-starter` 自动包含：
- `spring-boot`
- `spring-boot-autoconfigure`
- `spring-core`
- `spring-context`
- `spring-aop`
- `spring-beans`
- `spring-expression`
- `slf4j-api`
- `logback-classic` (如果没有排除)
- `jakarta.annotation-api` 或 `javax.annotation-api`

---

### 2. **通过 `api` 传递的依赖**

如果某个模块使用 `api` 声明依赖，下游模块会自动获得这些依赖。

#### 示例：dubbo-spring-boot-starter

```groovy
// dubbo-spring-boot-starter/build.gradle
dependencies {
    api project(':dubbo-spring-boot-project:dubbo-spring-boot-autoconfigure')
    compileOnly "org.springframework.boot:spring-boot-starter:${springBootStarterVersion}"
}
```

#### ✅ **使用方只需声明**：

```groovy
// 你的应用 build.gradle
dependencies {
    implementation project(':dubbo-spring-boot-project:dubbo-spring-boot-starters:dubbo-spring-boot-starter')
    
    // ✅ dubbo-spring-boot-autoconfigure 会自动引入
    // ✅ 所有 Dubbo 核心模块会自动引入
}
```

---

### 3. **父模块已声明的 `api` 依赖**

#### 示例：dubbo-config-spring

```groovy
// dubbo-config-spring/build.gradle
dependencies {
    api project(':dubbo-config:dubbo-config-api')  // 使用 api
    api project(':dubbo-common')
    // ...
}
```

#### ✅ **使用方自动获得**：

```groovy
// 你的模块 build.gradle
dependencies {
    implementation project(':dubbo-config:dubbo-config-spring')
    
    // ✅ dubbo-config-api 自动可用（因为是 api 依赖）
    // ✅ dubbo-common 自动可用
}
```

---

### 4. **Spring Boot 与 Dubbo 集成的自动依赖**

#### ❌ **不需要显式声明**：

```groovy
dependencies {
    implementation project(':dubbo-spring-boot-project:dubbo-spring-boot-starters:dubbo-spring-boot-starter')
    
    // ❌ 以下依赖会通过 starter 自动引入
    // implementation project(':dubbo-common')
    // implementation project(':dubbo-cluster')
    // implementation project(':dubbo-rpc:dubbo-rpc-api')
    // implementation project(':dubbo-remoting:dubbo-remoting-api')
    // implementation project(':dubbo-registry:dubbo-registry-api')
}
```

---

### 5. **JDK 内置的依赖**

某些依赖在 JDK 中已经存在，不需要额外声明：

```groovy
// ❌ 不需要声明（JDK 自带）
// implementation 'javax.xml.bind:jaxb-api'  // JDK 8 及以下
// implementation 'javax.annotation:javax.annotation-api'  // JDK 8 及以下
```

**注意**：JDK 9+ 移除了这些模块，如果需要支持 JDK 9+，需要显式声明。

---

### 6. **编译时依赖 vs 运行时依赖**

#### `compileOnly` - 仅编译时需要

```groovy
dependencies {
    // ✅ 仅编译时需要，运行时由其他模块提供
    compileOnly project(':dubbo-common')
    compileOnly "javax.servlet:javax.servlet-api:${servletVersion}"
    compileOnly "org.springframework.boot:spring-boot-autoconfigure:${springBootVersion}"
}
```

**使用场景**：
- 库模块（不是最终应用）
- 接口定义模块
- SPI 扩展点定义
- Servlet API（由容器提供）

---

## 🔍 具体场景分析

### 场景 1：创建 Spring Boot Provider 应用

#### ❌ **过度声明**（不推荐）：

```groovy
dependencies {
    implementation project(':dubbo-spring-boot-project:dubbo-spring-boot-starters:dubbo-spring-boot-starter')
    implementation project(':dubbo-registry:dubbo-registry-zookeeper')
    implementation project(':dubbo-config:dubbo-config-spring')
    implementation "org.springframework.boot:spring-boot-starter:${springBootVersion}"
    
    // ❌ 以下都是重复的，会自动引入
    implementation project(':dubbo-common')  // ❌ starter 已包含
    implementation project(':dubbo-cluster')  // ❌ starter 已包含
    implementation project(':dubbo-rpc:dubbo-rpc-api')  // ❌ starter 已包含
    implementation project(':dubbo-remoting:dubbo-remoting-api')  // ❌ starter 已包含
    implementation "org.springframework:spring-context:${springVersion}"  // ❌ spring-boot-starter 已包含
}
```

#### ✅ **精简后**（推荐）：

```groovy
dependencies {
    // 核心 starter
    implementation project(':dubbo-spring-boot-project:dubbo-spring-boot-starters:dubbo-spring-boot-starter')
    
    // 注册中心实现（可选，根据需要选择）
    implementation project(':dubbo-registry:dubbo-registry-zookeeper')
    
    // Spring Boot
    implementation "org.springframework.boot:spring-boot-starter:${springBootVersion}"
    implementation "org.springframework.boot:spring-boot-starter-log4j2:${springBootVersion}"
}

configurations {
    all*.exclude group: 'org.springframework.boot', module: 'spring-boot-starter-logging'
    all*.exclude group: 'ch.qos.logback'
}
```

---

### 场景 2：创建接口定义模块

#### ✅ **推荐**：

```groovy
// 接口模块通常只需要很少的依赖
dependencies {
    // 仅编译时需要
    compileOnly project(':dubbo-common')
    
    // 如果使用了某些注解
    compileOnly "javax.validation:validation-api:${validationApiVersion}"
}
```

#### ❌ **不推荐**：

```groovy
dependencies {
    // ❌ 接口模块不应该依赖实现
    implementation project(':dubbo-rpc:dubbo-rpc-dubbo')  // ❌ 这是实现细节
    implementation project(':dubbo-registry:dubbo-registry-zookeeper')  // ❌ 这是实现细节
}
```

---

### 场景 3：创建 Dubbo SPI 扩展模块

#### ✅ **推荐**：

```groovy
dependencies {
    // SPI 定义通常只需要 compileOnly
    compileOnly project(':dubbo-common')
    compileOnly project(':dubbo-rpc:dubbo-rpc-api')
    
    // 测试时需要完整依赖
    testImplementation project(':dubbo-common')
    testImplementation project(':dubbo-rpc:dubbo-rpc-api')
}
```

---

## 🎯 最佳实践

### 1. **使用 `api` 还是 `implementation`？**

| 场景 | 使用 |
|------|------|
| 依赖出现在公共 API 中 | `api` |
| 依赖仅在内部使用 | `implementation` |
| 接口定义模块 | `compileOnly`（在库中）或 `api`（在 starter 中） |
| 可选功能 | `compileOnly` + 文档说明 |

#### 示例：

```groovy
dependencies {
    // ✅ 公共 API 中使用，需要传递
    api project(':dubbo-common')
    api "com.google.protobuf:protobuf-java:${protobufVersion}"
    
    // ✅ 仅内部使用，不传递
    implementation "com.alibaba.fastjson2:fastjson2:${fastjson2Version}"
    implementation "org.javassist:javassist:${javassistVersion}"
    
    // ✅ 编译时需要，运行时由使用方提供
    compileOnly "org.springframework.boot:spring-boot-autoconfigure:${springBootVersion}"
    compileOnly "javax.servlet:javax.servlet-api:${servletVersion}"
}
```

---

### 2. **依赖传递链优化**

#### 原则：**越上层越具体，越底层越通用**

```
Application (最上层)
  ↓ implementation
Dubbo Starter (中间层)
  ↓ api
Dubbo Core Modules (底层)
  ↓ api/implementation
Third-party Libraries (最底层)
```

#### 配置示例：

```groovy
// dubbo-common (底层) - 使用 api 暴露核心依赖
dependencies {
    api "org.javassist:javassist:${javassistVersion}"  // 公共 API
    implementation "io.netty:netty-all:${netty4Version}"  // 内部使用
}

// dubbo-spring-boot-autoconfigure (中间层) - 选择性暴露
dependencies {
    api project(':dubbo-spring-boot-project:dubbo-spring-boot')
    compileOnly "org.springframework.boot:spring-boot-autoconfigure:${springBootVersion}"
}

// dubbo-spring-boot-starter (Starter 层) - 聚合依赖
dependencies {
    api project(':dubbo-spring-boot-project:dubbo-spring-boot-autoconfigure')
    compileOnly "org.springframework.boot:spring-boot-starter:${springBootStarterVersion}"
}

// 你的应用 (最上层) - 只声明直接需要的
dependencies {
    implementation project(':dubbo-spring-boot-project:dubbo-spring-boot-starters:dubbo-spring-boot-starter')
    implementation project(':dubbo-registry:dubbo-registry-zookeeper')  // 可选组件
    implementation "org.springframework.boot:spring-boot-starter:${springBootVersion}"
}
```

---

### 3. **检查重复依赖**

#### 使用 Gradle 命令检查：

```bash
# 查看某个模块的依赖树
./gradlew :your-module:dependencies

# 查看运行时依赖
./gradlew :your-module:dependencies --configuration runtimeClasspath

# 查看编译时依赖
./gradlew :your-module:dependencies --configuration compileClasspath

# 查找特定依赖的来源
./gradlew :your-module:dependencyInsight --dependency spring-core --configuration runtimeClasspath
```

---

### 4. **常见可省略的依赖清单**

#### ✅ **已经由 Starter 提供**：

```groovy
// ❌ 不需要显式声明（dubbo-spring-boot-starter 已包含）
// implementation project(':dubbo-common')
// implementation project(':dubbo-cluster')
// implementation project(':dubbo-rpc:dubbo-rpc-api')
// implementation project(':dubbo-rpc:dubbo-rpc-dubbo')
// implementation project(':dubbo-rpc:dubbo-rpc-triple')
// implementation project(':dubbo-remoting:dubbo-remoting-api')
// implementation project(':dubbo-remoting:dubbo-remoting-netty4')
// implementation project(':dubbo-registry:dubbo-registry-api')
// implementation project(':dubbo-serialization:dubbo-serialization-api')
// implementation project(':dubbo-serialization:dubbo-serialization-hessian2')
// implementation project(':dubbo-config:dubbo-config-api')
```

#### ✅ **已经由 Spring Boot Starter 提供**：

```groovy
// ❌ 不需要显式声明（spring-boot-starter 已包含）
// implementation "org.springframework:spring-core"
// implementation "org.springframework:spring-context"
// implementation "org.springframework:spring-beans"
// implementation "org.springframework:spring-aop"
// implementation "org.slf4j:slf4j-api"
// implementation "jakarta.annotation:jakarta.annotation-api"
```

---

## 🧹 优化建议

### 步骤 1：审查现有依赖

```bash
# 对每个模块执行
./gradlew :your-module:dependencies --configuration runtimeClasspath > deps.txt
```

### 步骤 2：识别重复依赖

查找在依赖树中出现多次的依赖，检查是否可以移除直接声明。

### 步骤 3：简化 build.gradle

**优化前**：
```groovy
dependencies {
    implementation project(':dubbo-spring-boot-project:dubbo-spring-boot-starters:dubbo-spring-boot-starter')
    implementation project(':dubbo-common')  // ❌ 重复
    implementation project(':dubbo-cluster')  // ❌ 重复
    implementation project(':dubbo-config:dubbo-config-api')  // ❌ 重复
    implementation "org.springframework:spring-context:${springVersion}"  // ❌ 重复
}
```

**优化后**：
```groovy
dependencies {
    implementation project(':dubbo-spring-boot-project:dubbo-spring-boot-starters:dubbo-spring-boot-starter')
    // 其他依赖会自动传递
}
```

### 步骤 4：验证构建

```bash
./gradlew clean build -x test
./gradlew :your-module:dependencies
```

---

## ⚠️ 注意事项

### 1. **不要过度依赖传递**

虽然传递依赖很方便，但如果你的代码**直接使用**了某个依赖，最好显式声明：

```groovy
dependencies {
    // ✅ 虽然 spring-context 会通过 spring-boot-starter 传递，
    // 但如果你直接使用了 @Configuration 等注解，建议显式声明
    implementation "org.springframework:spring-context:${springVersion}"
}
```

**原则**：如果你的代码 `import` 了某个包，就应该显式声明依赖。

---

### 2. **版本冲突处理**

如果出现版本冲突，可以使用 `resolutionStrategy`：

```groovy
configurations.all {
    resolutionStrategy {
        // 强制使用特定版本
        force "org.springframework:spring-core:${springVersion}"
        
        // 失败时快速失败
        failOnVersionConflict()
    }
}
```

---

### 3. **测试依赖不要用传递**

测试依赖应该显式声明：

```groovy
dependencies {
    // ✅ 测试依赖显式声明
    testImplementation "org.junit.jupiter:junit-jupiter:${junitVersion}"
    testImplementation "org.mockito:mockito-core:${mockitoVersion}"
    testImplementation "org.springframework.boot:spring-boot-starter-test:${springBootVersion}"
}
```

---

## 📊 总结

| 依赖类型 | 是否需要显式声明 | 原因 |
|---------|----------------|------|
| Spring Boot Starter 包含的依赖 | ❌ 否 | 自动传递 |
| `api` 依赖的传递依赖 | ❌ 否 | 自动传递 |
| 直接在代码中 `import` 的包 | ✅ 是 | 明确依赖关系 |
| `compileOnly` 依赖（库模块） | ✅ 是 | 编译时需要 |
| 测试依赖 | ✅ 是 | 不传递 |
| JDK 内置的类 | ❌ 否 | JDK 自带 |

---

## 🔗 相关文档

- [Gradle 依赖管理官方文档](https://docs.gradle.org/current/userguide/dependency_management.html)
- [Spring Boot Dependency Management](https://docs.spring.io/spring-boot/docs/current/reference/html/dependency-versions.html)
- `GRADLE-MIGRATION-STATUS.md` - 迁移状态报告

---

**最后更新**: 2025-11-01

