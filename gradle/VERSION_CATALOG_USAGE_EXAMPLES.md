# Version Catalog 使用示例

## 概述

本项目采用 **Version Catalog** (Gradle 7+ 最佳实践) 进行依赖版本管理。

**文件位置**: `gradle/libs.versions.toml`

## 快速对比

### ❌ 旧方式 (ext {})

```gradle
// build.gradle
ext {
    springVersion = '5.3.39'
    nettyVersion = '4.1.100.Final'
}

// 子模块 build.gradle
dependencies {
    implementation "org.springframework:spring-core:${rootProject.ext.springVersion}"
    implementation "io.netty:netty-all:${rootProject.ext.nettyVersion}"
}
```

### ✅ 新方式 (Version Catalog)

```gradle
// gradle/libs.versions.toml
[versions]
spring = "5.3.39"
netty = "4.1.100.Final"

[libraries]
spring-core = { module = "org.springframework:spring-core", version.ref = "spring" }
netty-all = { module = "io.netty:netty-all", version.ref = "netty" }

// 子模块 build.gradle
dependencies {
    implementation libs.spring.core     // ✅ 类型安全 + IDE 自动补全
    implementation libs.netty.all
}
```

## 实际使用示例

### 示例 1：普通模块依赖

```gradle
// dubbo-common/build.gradle
dependencies {
    // ========================================
    // 推荐方式：使用 Version Catalog
    // ========================================
    implementation libs.javassist
    implementation libs.netty.all
    api libs.slf4j.api
    
    // ========================================
    // 替代方式：使用 BOM (保持向后兼容)
    // ========================================
    api enforcedPlatform(project(':dubbo-dependencies-bom'))
    implementation "org.javassist:javassist"           // 版本由 BOM 管理
    implementation "io.netty:netty-all"
    
    // ========================================
    // 测试依赖：使用 Bundle (依赖组合)
    // ========================================
    testImplementation libs.bundles.testing           // JUnit + Mockito + Hamcrest
}
```

### 示例 2：使用依赖组合 (Bundles)

```gradle
// dubbo-rpc/dubbo-rpc-api/build.gradle
dependencies {
    // 单行引入多个相关依赖
    implementation libs.bundles.spring.core           // Spring Core + Beans + Context
    implementation libs.bundles.grpc                  // gRPC Core + Netty + Protobuf + Stub
    
    testImplementation libs.bundles.testing
}
```

### 示例 3：Spring 6 模块（需要特定版本）

```gradle
// dubbo-config/dubbo-config-spring6/build.gradle
dependencies {
    // 使用 Version Catalog 的 Spring 6 版本
    compileOnly(libs.spring6.core) {
        version {
            strictly libs.versions.spring6.get()       // 强制使用 Spring 6
        }
    }
    compileOnly(libs.spring6.beans) {
        version {
            strictly libs.versions.spring6.get()
        }
    }
    compileOnly(libs.spring6.context) {
        version {
            strictly libs.versions.spring6.get()
        }
    }
}
```

### 示例 4：Spring Boot Starter 模块

```gradle
// dubbo-spring-boot-project/dubbo-spring-boot-starter/build.gradle
dependencies {
    api enforcedPlatform(project(':dubbo-dependencies-bom'))
    api project(':dubbo-spring-boot-project:dubbo-spring-boot-autoconfigure')
    
    // Spring Boot 依赖使用 Version Catalog
    api libs.springBoot.starter
    api libs.springBoot.autoconfigure
}
```

### 示例 5：Protobuf 插件配置

```gradle
// dubbo-demo/dubbo-demo-spring-boot-idl/dubbo-demo-spring-boot-idl-consumer/build.gradle
plugins {
    id 'java'
    alias(libs.plugins.protobuf)                      // 使用 Version Catalog 定义的插件
}

dependencies {
    implementation libs.protobuf.java
    implementation libs.protobuf.javaUtil
    implementation libs.grpc.protobuf
    implementation libs.grpc.stub
}

protobuf {
    protoc {
        artifact = "com.google.protobuf:protoc:${libs.versions.protobufProtoc.get()}"
    }
    plugins {
        grpc {
            artifact = "io.grpc:protoc-gen-grpc-java:${libs.versions.grpc.get()}"
        }
    }
}
```

### 示例 6：测试模块

```gradle
// dubbo-common/build.gradle
dependencies {
    // 使用 Bundle 一次性添加所有测试依赖
    testImplementation libs.bundles.testing
    
    // 或者单独添加
    testImplementation libs.junit.jupiter.engine
    testImplementation libs.junit.jupiter.api
    testImplementation libs.mockito.core
    testImplementation libs.awaitility
    testImplementation libs.hamcrest
}

test {
    useJUnitPlatform()                                // JUnit 5
}
```

### 示例 7：获取版本号（用于插件配置）

```gradle
// build.gradle
tasks.withType(JavaCompile) {
    options.compilerArgs += ["-Anetty.version=${libs.versions.netty.get()}"]
}

// 或在字符串中使用
dependencies {
    implementation "io.netty:netty-codec-http2:${libs.versions.netty.get()}"
}
```

## 插件使用

### ✅ 推荐方式：使用 alias()

```gradle
// build.gradle
plugins {
    id 'java-library'
    alias(libs.plugins.shadow) apply false           // Shadow JAR plugin
    alias(libs.plugins.protobuf) apply false         // Protobuf plugin
    alias(libs.plugins.javadoc) apply false          // Aggregate Javadoc
    alias(libs.plugins.release)                      // Release plugin
}

// 子模块
plugins {
    id 'java'
    alias(libs.plugins.shadow)                       // 应用 Shadow 插件
}
```

### ❌ 旧方式：硬编码版本

```gradle
plugins {
    id 'com.github.johnrengelman.shadow' version '7.1.2' apply false  // ❌ 版本硬编码
}
```

## 常用访问器映射表

### 版本访问器

| TOML 定义 | Gradle 访问器 | 说明 |
|-----------|--------------|------|
| `[versions]`<br>`spring = "5.3.39"` | `libs.versions.spring.get()` | 获取版本字符串 |
| `netty = "4.1.100.Final"` | `libs.versions.netty.get()` | 获取 Netty 版本 |
| `junit = "5.12.2"` | `libs.versions.junit.get()` | 获取 JUnit 版本 |

### 库访问器

| TOML 定义 | Gradle 访问器 | 实际坐标 |
|-----------|--------------|---------|
| `spring-core = { module = "org.springframework:spring-core", version.ref = "spring" }` | `libs.spring.core` | `org.springframework:spring-core:5.3.39` |
| `netty-all = { module = "io.netty:netty-all", version.ref = "netty" }` | `libs.netty.all` | `io.netty:netty-all:4.1.100.Final` |
| `junit-jupiter-api = { ... }` | `libs.junit.jupiter.api` | JUnit Jupiter API |

**命名规则**:
- TOML 中的 `-` (连字符) → Gradle 中的 `.` (点)
- 示例: `spring-core` → `libs.spring.core`

### Bundle 访问器

| TOML 定义 | Gradle 访问器 | 包含的库 |
|-----------|--------------|---------|
| `spring-core = ["spring-core", "spring-beans", "spring-context"]` | `libs.bundles.spring.core` | Spring Core 全家桶 |
| `testing = ["junit-jupiter-api", "mockito-core", ...]` | `libs.bundles.testing` | 测试依赖组合 |
| `grpc = ["grpc-core", "grpc-netty", ...]` | `libs.bundles.grpc` | gRPC 完整依赖 |

### 插件访问器

| TOML 定义 | Gradle 访问器 |
|-----------|--------------|
| `shadow = { id = "com.github.johnrengelman.shadow", version = "7.1.2" }` | `alias(libs.plugins.shadow)` |
| `protobuf = { id = "com.google.protobuf", version = "0.8.18" }` | `alias(libs.plugins.protobuf)` |

## 混合使用策略（推荐）

在迁移过程中，可以同时使用 Version Catalog 和 BOM：

```gradle
dependencies {
    // ========================================
    // 方式 1：使用 BOM（旧模块保持兼容）
    // ========================================
    api enforcedPlatform(project(':dubbo-dependencies-bom'))
    implementation "org.springframework:spring-core"            // 版本由 BOM 管理
    
    // ========================================
    // 方式 2：使用 Version Catalog（新模块推荐）
    // ========================================
    implementation libs.netty.all                               // 直接使用 Catalog
    
    // ========================================
    // 方式 3：混合使用
    // ========================================
    implementation "io.grpc:grpc-netty"                         // BOM 管理
    implementation libs.grpc.stub                               // Catalog 提供类型安全
}
```

## IDE 支持

### IntelliJ IDEA

Version Catalog 在 IDEA 中有完整支持：

1. **自动补全**: 输入 `libs.` 后自动显示所有可用库
   ```gradle
   implementation libs.     ← 弹出补全列表
   ```

2. **版本显示**: 鼠标悬停在 `libs.spring.core` 上，显示实际版本号

3. **跳转到定义**: Ctrl/Cmd + Click 跳转到 `libs.versions.toml`

4. **重构支持**: 重命名 TOML 中的库，自动更新所有引用

### VS Code

需要安装 Gradle 扩展：
- [Gradle for Java](https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-gradle)

## 迁移建议

### 渐进式迁移（推荐）

```
阶段 1: 创建 Version Catalog
  ✅ gradle/libs.versions.toml
  ✅ 定义所有版本

阶段 2: 更新根 build.gradle
  ✅ 插件使用 alias()
  ✅ ext {} 从 Version Catalog 读取

阶段 3: 迁移核心模块（可选）
  - dubbo-common
  - dubbo-rpc:dubbo-rpc-api
  - dubbo-cluster

阶段 4: 迁移其他模块（可选）
  - 保持 BOM 方式（向后兼容）
  - 或使用 Version Catalog（类型安全）
```

### 优先迁移的模块

1. **测试依赖**: 使用 `libs.bundles.testing`
2. **新模块**: 直接使用 Version Catalog
3. **Protobuf 模块**: 使用 `alias(libs.plugins.protobuf)`

### 暂不迁移的模块

1. **BOM 模块**: 继续使用 `ext {}` (需要向 Maven 项目提供)
2. **稳定的旧模块**: 保持 BOM 方式（降低风险）

## 常见问题

### Q1: Version Catalog 和 BOM 同时使用会冲突吗？

**不会！** 可以混合使用：
- Version Catalog: 用于内部开发（类型安全）
- BOM: 用于外部发布（Maven 兼容）

```gradle
dependencies {
    api enforcedPlatform(project(':dubbo-dependencies-bom'))    // BOM 管理版本
    implementation libs.spring.core                             // Catalog 提供便利
}
```

### Q2: 如何查看 Version Catalog 中的所有依赖？

```bash
./gradlew :help --task dependencies
# 或直接查看文件
cat gradle/libs.versions.toml
```

### Q3: 旧模块必须迁移吗？

**不需要！** Version Catalog 是增量迁移：
- 旧模块：保持 BOM 方式
- 新模块：使用 Version Catalog
- 混合使用：两种方式同时存在

### Q4: Version Catalog 如何更新版本？

编辑 `gradle/libs.versions.toml` 文件：
```toml
[versions]
spring = "5.3.40"  # 从 5.3.39 升级到 5.3.40
```

所有使用 `libs.spring.core` 的模块自动使用新版本！

### Q5: 如何处理特殊版本需求？

使用 `strictly`:
```gradle
implementation(libs.spring.core) {
    version {
        strictly '5.3.38'  // 强制使用特定版本
    }
}
```

## 性能影响

Version Catalog 对构建性能的影响：
- ✅ 配置时间：**几乎无影响** (毫秒级)
- ✅ 编译时间：**无影响**
- ✅ IDE 性能：**略有提升** (更好的缓存)

## 参考资源

- [Gradle Version Catalog 官方文档](https://docs.gradle.org/current/userguide/platforms.html)
- [Version Catalog 规范](https://docs.gradle.org/current/userguide/platforms.html#sub:conventional-dependencies-toml)
- [迁移指南](./version-catalog-migration-guide.md)
- [TOML 文件](../gradle/libs.versions.toml)

## 快速参考

### 添加新依赖的步骤

1. 编辑 `gradle/libs.versions.toml`:
   ```toml
   [versions]
   newlib = "1.0.0"
   
   [libraries]
   newlib = { module = "com.example:newlib", version.ref = "newlib" }
   ```

2. 在子模块中使用:
   ```gradle
   dependencies {
       implementation libs.newlib
   }
   ```

### 更新依赖版本

1. 只需修改一处:
   ```toml
   [versions]
   spring = "5.3.40"  # 从 5.3.39 升级
   ```

2. 所有模块自动使用新版本！

---

**推荐做法**: 新模块直接使用 Version Catalog，旧模块保持不变（除非需要大幅修改）。

