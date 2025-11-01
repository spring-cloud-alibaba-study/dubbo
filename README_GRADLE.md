# Apache Dubbo - Gradle 构建系统

## 项目已迁移至 Gradle！

本项目现在使用 Gradle 作为主要构建工具，提供更快的构建速度和更灵活的配置。

## 🚀 快速开始

```bash
# 构建项目
./gradlew build

# 跳过测试快速构建
./gradlew build -x test

# 清理并重新构建
./gradlew clean build
```

## 📚 文档

- **[构建指南](BUILD_WITH_GRADLE.md)** - 快速开始和常用命令
- **[迁移文档](GRADLE_MIGRATION.md)** - 详细的迁移说明和配置指南

## 🎯 主要特性

✅ **更快的构建速度** - 增量构建和并行编译  
✅ **依赖管理优化** - 更智能的依赖解析  
✅ **完整的多模块支持** - 120+ 子模块  
✅ **向后兼容** - Maven POM 文件仍然保留  
✅ **现代化工具链** - 支持最新 Java 特性  

## 📦 项目结构

```
dubbo/
├── build.gradle                 # 根构建配置
├── settings.gradle             # 项目和模块配置
├── gradle.properties           # 全局属性
├── gradlew                     # Unix/Linux wrapper
├── gradlew.bat                 # Windows wrapper
├── gradle/wrapper/             # Wrapper 文件
├── dubbo-common/              # 核心模块
├── dubbo-cluster/             # 集群模块
├── dubbo-rpc/                 # RPC 模块
├── dubbo-registry/            # 注册中心模块
├── dubbo-config/              # 配置模块
├── dubbo-remoting/            # 通信模块
├── dubbo-serialization/       # 序列化模块
├── dubbo-metadata/            # 元数据模块
├── dubbo-metrics/             # 监控指标模块
├── dubbo-plugin/              # 插件模块
├── dubbo-spring-boot-project/ # Spring Boot 集成
├── dubbo-demo/                # 示例项目
└── dubbo-distribution/        # 分发模块
```

## 🛠️ 常用命令

| 功能 | 命令 |
|-----|------|
| 构建项目 | `./gradlew build` |
| 运行测试 | `./gradlew test` |
| 清理构建 | `./gradlew clean` |
| 发布到本地 | `./gradlew publishToMavenLocal` |
| 查看依赖 | `./gradlew dependencies` |
| 构建单个模块 | `./gradlew :dubbo-common:build` |

## 📋 系统要求

- **JDK**: 8+ （推荐 JDK 11 或 17）
- **内存**: 至少 2GB RAM
- **磁盘**: 至少 1GB 可用空间

## 🔧 IDE 支持

### IntelliJ IDEA
直接打开项目，IDEA 会自动识别 Gradle 项目。

### Eclipse
需要安装 Buildship 插件后导入 Gradle 项目。

### VS Code
安装 "Gradle for Java" 扩展后使用。

## ⚡ 性能建议

在 `gradle.properties` 中配置：

```properties
# 并行构建
org.gradle.parallel=true

# 构建缓存
org.gradle.caching=true

# 增加内存
org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=1g
```

## 🐛 故障排查

遇到问题？试试这些：

```bash
# 清理并刷新依赖
./gradlew clean build --refresh-dependencies

# 查看详细日志
./gradlew build --info --stacktrace

# 停止 Gradle Daemon
./gradlew --stop
```

## 🌐 国内加速

如果依赖下载慢，可以配置国内镜像源。详见 [GRADLE_MIGRATION.md](GRADLE_MIGRATION.md#常见问题)。

## 📖 更多资源

- [Apache Dubbo 官网](https://dubbo.apache.org/)
- [Gradle 官方文档](https://docs.gradle.org/)
- [项目 GitHub](https://github.com/apache/dubbo)

## 🤝 贡献

欢迎贡献！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何参与。

## 📄 许可证

Apache License 2.0 - 详见 [LICENSE](LICENSE)

---

**注意**: Maven 构建仍然可用，但推荐使用 Gradle 以获得更好的性能。

