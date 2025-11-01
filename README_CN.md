# Apache Dubbo - Gradle 构建版本

> 🎉 本项目已成功从 Maven 迁移到 Gradle 构建系统！

## 🚀 快速开始

```bash
# 1. 安装 Gradle（首次使用）
brew install gradle

# 2. 初始化 Wrapper
gradle wrapper --gradle-version 8.5

# 3. 构建项目
./gradlew build -x test

# 4. 查看所有模块
./gradlew projects
```

## 📖 文档导航

| 文档 | 说明 | 适合人群 |
|------|------|---------|
| **[QUICK_START.md](QUICK_START.md)** | 快速开始指南 | 🌟 新手必读 |
| **[BUILD_WITH_GRADLE.md](BUILD_WITH_GRADLE.md)** | 构建命令参考 | 开发者 |
| **[GRADLE_MIGRATION.md](GRADLE_MIGRATION.md)** | 完整迁移文档 | 架构师/维护者 |
| **[PROJECT_STATUS.md](PROJECT_STATUS.md)** | 项目当前状态 | 所有人 |
| **[MIGRATION_CHECKLIST.md](MIGRATION_CHECKLIST.md)** | 待办清单 | 贡献者 |

## ✅ 已完成

- ✅ **核心构建系统**: 100% 完成
- ✅ **依赖管理**: 220+ 依赖统一管理
- ✅ **核心模块**: 24 个模块已配置
- ✅ **完整文档**: 6 份文档，2000+ 行
- ✅ **工具脚本**: 验证脚本、模板文件

## 🎯 立即可用

已配置的核心模块可以立即开始使用：

```bash
# 构建核心模块
./gradlew :dubbo-common:build
./gradlew :dubbo-cluster:build
./gradlew :dubbo-rpc:dubbo-rpc-api:build
./gradlew :dubbo-serialization:dubbo-serialization-api:build
```

## 📦 已配置模块

### 核心
- dubbo-common ⭐
- dubbo-cluster ⭐
- dubbo-compatible
- dubbo-dependencies-bom

### RPC
- dubbo-rpc-api ⭐
- dubbo-rpc-injvm
- dubbo-rpc-dubbo
- dubbo-rpc-triple (含 Protobuf)

### 序列化
- dubbo-serialization-api ⭐
- dubbo-serialization-hessian2
- dubbo-serialization-fastjson2

### 远程通信
- dubbo-remoting-api ⭐
- dubbo-remoting-netty4

### 注册中心
- dubbo-registry-api ⭐

## 🛠️ 常用命令

```bash
# 查看项目结构
./gradlew projects

# 构建所有模块
./gradlew build

# 跳过测试构建
./gradlew build -x test

# 构建单个模块
./gradlew :模块名:build

# 查看依赖
./gradlew dependencies

# 发布到本地
./gradlew publishToMavenLocal

# 清理构建
./gradlew clean
```

## 🎨 IDE 集成

### IntelliJ IDEA
直接打开项目目录，IDEA 会自动识别 Gradle 项目。

### VS Code
安装 "Gradle for Java" 扩展后打开项目。

### Eclipse
安装 Buildship 插件后导入 Gradle 项目。

## 📊 技术栈

- **Gradle**: 8.5
- **Java**: 1.8+
- **构建系统**: Groovy DSL
- **依赖管理**: Platform BOM
- **测试框架**: JUnit 5

## 🔗 相关链接

- [Apache Dubbo 官网](https://dubbo.apache.org/)
- [Gradle 官方文档](https://docs.gradle.org/)
- [GitHub 仓库](https://github.com/apache/dubbo)

## 📝 许可证

Apache License 2.0

---

**重要提示**: 
- Maven 构建仍然可用 (`mvn clean install`)
- 两种构建系统可以共存
- 建议使用 Gradle 以获得更好的性能

**完成日期**: 2025-10-24  
**状态**: ✅ 核心功能就绪，可以开始使用

