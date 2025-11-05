# Version Catalog 使用指南

## 🎯 Gradle 7.0+ 最佳实践

Version Catalog 是 Gradle 7.0 引入的官方推荐依赖管理方案。

### 架构设计

```
当前方案（混合模式）：
┌─────────────────────────────────────────────┐
│  gradle/libs.versions.toml (Version Catalog) │  ← Gradle 7+ 最佳实践
│  - 类型安全的依赖声明                         │
│  - IDE 自动补全支持                           │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  build.gradle (ext {})                      │  ← 向后兼容
│  - 从 Version Catalog 获取版本               │
│  - 供 BOM 模块使用                           │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  dubbo-dependencies-bom (java-platform)     │  ← Maven 兼容
│  - 对外发布的 BOM                            │
│  - 其他 Maven 项目可导入                     │
└─────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────┐
│  Subprojects (子模块)                        │  ← 推荐使用 Version Catalog
│  - 优先使用 libs.xxx (类型安全)              │
│  - 或使用 BOM (无版本号)                     │
└─────────────────────────────────────────────┘
```

## 📖 使用方式

### 方式 1：直接使用 Version Catalog（✅ 推荐用于新模块）

```gradle
// dubbo-common/build.gradle
dependencies {
    // ✅ 类型安全，IDE 自动补全
    api libs.javassist
    api libs.byte.buddy
    
    // ✅ 使用 bundle (依赖组合)
    api libs.bundles.netty
    api libs.bundles.spring.framework
    
    // ✅ 测试依赖
    testImplementation libs.bundles.junit5
    testImplementation libs.mockito.core
}
```

**优势：**
- ✅ 编译时类型检查
- ✅ IDE 自动补全 (libs.)
- ✅ 重构友好（重命名自动同步）
- ✅ 版本集中管理
- ✅ 可导入/导出给其他项目

### 方式 2：使用 BOM（✅ 推荐用于现有模块）

```gradle
// dubbo-rpc/dubbo-rpc-triple/build.gradle
dependencies {
    // 首先声明 BOM
    api enforcedPlatform(project(':dubbo-dependencies-bom'))
    
    // 然后无版本声明依赖
    api "io.netty:netty-all"
    api "com.google.protobuf:protobuf-java"
    api "io.grpc:grpc-core"
}
```

**优势：**
- ✅ 与 Maven 完全兼容
- ✅ 版本冲突自动解决
- ✅ 适合复杂的传递依赖场景

### 方式 3：混合使用（✅ 最灵活）

```gradle
// dubbo-plugin/dubbo-mcp/build.gradle
dependencies {
    // 使用 BOM 作为基础
    api enforcedPlatform(project(':dubbo-dependencies-bom'))
    
    // BOM 中有的依赖，无版本号
    api "io.netty:netty-all"
    
    // BOM 中没有的依赖，使用 Version Catalog
    implementation libs.mcp  // 类型安全！
    
    // 测试依赖使用 bundle
    testImplementation libs.bundles.junit5
}
```

## 📝 Version Catalog 文件结构

### gradle/libs.versions.toml

```toml
[versions]
# 版本号定义
netty4 = "4.2.2.Final"
spring = "5.3.39"

[libraries]
# 库定义（格式：group:artifact）
netty-all = { module = "io.netty:netty-all", version.ref = "netty4" }
spring-core = { module = "org.springframework:spring-core", version.ref = "spring" }

[bundles]
# 依赖组合（常一起使用的依赖）
spring-framework = ["spring-core", "spring-beans", "spring-context"]

[plugins]
# 插件定义
shadow = { id = "com.github.johnrengelman.shadow", version = "7.1.2" }
```

## 🚀 实际应用示例

### 示例 1：简单模块（dubbo-common）

```gradle
plugins {
    id 'java-library'
}

dependencies {
    // 使用 Version Catalog - 类型安全！
    api libs.javassist
    api libs.byte.buddy
    api libs.netty.all
    
    // 日志
    api libs.slf4j.api
    
    // 工具类
    api libs.commons.lang3
    api libs.commons.io
    
    // 测试
    testImplementation libs.bundles.junit5
    testImplementation libs.mockito.inline
}
```

### 示例 2：gRPC 模块（dubbo-rpc-triple）

```gradle
plugins {
    id 'java-library'
    alias(libs.plugins.protobuf)  // ✅ 插件也从 Version Catalog
}

dependencies {
    // 使用 BOM
    api enforcedPlatform(project(':dubbo-dependencies-bom'))
    
    // 核心依赖（无版本号，BOM 管理）
    api "io.netty:netty-codec-http2"
    api "io.grpc:grpc-core"
    api "io.grpc:grpc-stub"
    api "io.grpc:grpc-protobuf"
    
    // 工具依赖（Version Catalog）
    implementation libs.fastjson2
    implementation libs.gson
    
    // 测试
    testImplementation libs.bundles.junit5
}

protobuf {
    // 使用 Version Catalog 中的版本
    protoc {
        artifact = "com.google.protobuf:protoc:${libs.versions.protobuf.protoc.get()}"
    }
}
```

### 示例 3：Spring Boot 模块

```gradle
plugins {
    id 'java-library'
    alias(libs.plugins.shadow)  // ✅ Shadow plugin from catalog
}

dependencies {
    // Spring Boot（Version Catalog）
    api libs.spring.boot.starter
    api libs.spring.boot.autoconfigure
    
    // Dubbo 内部模块
    api project(':dubbo-common')
    api project(':dubbo-config:dubbo-config-api')
    
    // 测试
    testImplementation libs.spring.boot.starter.test
    testImplementation libs.bundles.junit5
}
```

## 🔄 从 ext{} 迁移到 Version Catalog

### 当前方式（ext{}）

```gradle
// build.gradle
ext {
    netty4Version = '4.2.2.Final'
    springVersion = '5.3.39'
}

// 子模块
dependencies {
    api "io.netty:netty-all:${netty4Version}"  // ❌ 字符串拼接，不安全
}
```

### 新方式（Version Catalog）

```toml
# gradle/libs.versions.toml
[versions]
netty4 = "4.2.2.Final"

[libraries]
netty-all = { module = "io.netty:netty-all", version.ref = "netty4" }
```

```gradle
// 子模块
dependencies {
    api libs.netty.all  // ✅ 类型安全，自动补全
}
```

## 📊 对比表

| 特性 | ext{} 变量 | Version Catalog | BOM |
|------|-----------|----------------|-----|
| **类型安全** | ❌ | ✅ | ❌ |
| **IDE 自动补全** | ❌ | ✅ | ❌ |
| **集中管理** | ✅ | ✅ | ✅ |
| **Maven 兼容** | ❌ | ❌ | ✅ |
| **版本冲突解决** | ❌ | ❌ | ✅ (enforcedPlatform) |
| **可导出** | ❌ | ✅ | ✅ |
| **Gradle 版本** | 任意 | 7.0+ | 5.0+ |

## 🎓 推荐策略

### 新项目/新模块
```gradle
// ✅ 优先使用 Version Catalog
dependencies {
    api libs.netty.all
    api libs.spring.core
}
```

### 现有模块（迁移中）
```gradle
// ✅ 保持使用 BOM，逐步迁移到 Version Catalog
dependencies {
    api enforcedPlatform(project(':dubbo-dependencies-bom'))
    api "io.netty:netty-all"  // BOM 管理版本
    
    // 新依赖使用 Version Catalog
    implementation libs.some.new.library
}
```

### BOM 模块
```gradle
// ✅ 从 Version Catalog 读取版本，保持 Maven 兼容
dependencies {
    constraints {
        api "io.netty:netty-all:${libs.versions.netty4.get()}"
    }
}
```

## 🛠️ 常用操作

### 查看所有可用的 libs

```bash
./gradlew dependencies --configuration libs
```

### 在 IntelliJ IDEA 中使用

输入 `libs.` 后会自动提示所有可用的依赖：
```
libs.netty.all
libs.spring.core
libs.bundles.junit5
libs.plugins.shadow
```

### 获取版本号

```gradle
// 在 build.gradle 中
def nettyVersion = libs.versions.netty4.get()
println "Using Netty version: ${nettyVersion}"
```

### 条件依赖

```gradle
dependencies {
    if (JavaVersion.current() >= JavaVersion.VERSION_17) {
        implementation libs.some.jdk17.library
    } else {
        implementation libs.some.jdk8.library
    }
}
```

## 📚 bundles 使用

Bundles 用于组合常一起使用的依赖：

```toml
[bundles]
spring-framework = ["spring-core", "spring-beans", "spring-context"]
junit5 = ["junit-jupiter-api", "junit-jupiter-engine", "junit-jupiter-params"]
```

```gradle
dependencies {
    // 一次性添加多个相关依赖
    api libs.bundles.spring.framework
    testImplementation libs.bundles.junit5
}
```

## 🔧 Version Catalog 高级用法

### 版本范围

```toml
[versions]
spring = { strictly = "[5.3, 6.0[" }  # 5.3.x 系列
```

### 版本引用

```toml
[versions]
grpc = "1.73.0"
grpc-kotlin = "1.4.2"

[libraries]
grpc-core = { module = "io.grpc:grpc-core", version.ref = "grpc" }
grpc-kotlin-stub = { module = "io.grpc:grpc-kotlin-stub", version.ref = "grpc-kotlin" }
```

### 动态版本（不推荐生产环境）

```toml
[versions]
snapshot = "1.0.+"  # 使用最新的 1.0.x
latest = "latest.release"  # 使用最新的发布版
```

## ⚡ 性能提示

1. **Version Catalog 不影响构建性能**：版本在配置阶段解析，与 ext{} 性能相同
2. **BOM 有轻微性能开销**：但换来版本一致性，值得
3. **建议同时使用**：Version Catalog（新代码） + BOM（Maven 兼容）

## 📖 参考文档

- [Gradle Version Catalog 官方文档](https://docs.gradle.org/current/userguide/platforms.html)
- [Java Platform Plugin (BOM)](https://docs.gradle.org/current/userguide/java_platform_plugin.html)
- [依赖管理最佳实践](https://docs.gradle.org/current/userguide/dependency_management.html)

## ✅ 迁移检查清单

- [x] 创建 `gradle/libs.versions.toml`
- [ ] 更新 root `build.gradle` 使用 Version Catalog 插件
- [ ] 迁移常用依赖到 Version Catalog
- [ ] 更新 BOM 从 Version Catalog 获取版本
- [ ] 在新模块中使用 Version Catalog
- [ ] 团队培训和文档更新

## 🎯 当前状态

✅ **已完成：**
- Version Catalog 文件创建 (`gradle/libs.versions.toml`)
- 包含 150+ 依赖定义
- 插件版本管理
- Bundle 组合定义

⏳ **进行中：**
- 根 `build.gradle` 部分引用 Version Catalog
- BOM 模块继续使用 ext{} 变量

📋 **下一步：**
- 在新模块中使用 Version Catalog
- 逐步迁移现有模块
- 完全采用 Gradle 7+ 最佳实践

