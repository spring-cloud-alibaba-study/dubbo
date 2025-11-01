# 使用 Gradle 构建 Apache Dubbo

## 快速开始

### 前置要求
- JDK 8 或更高版本
- Git

### 构建步骤

1. **克隆项目**（如果还未克隆）
```bash
git clone https://github.com/apache/dubbo.git
cd dubbo
```

2. **构建项目**
```bash
# Linux/Mac
./gradlew build

# Windows
gradlew.bat build
```

3. **跳过测试构建**（更快）
```bash
./gradlew build -x test
```

## 常用命令

### 构建相关
```bash
# 清理构建输出
./gradlew clean

# 编译代码
./gradlew assemble

# 运行所有测试
./gradlew test

# 完整构建（清理 + 构建 + 测试）
./gradlew clean build
```

### 模块构建
```bash
# 构建单个模块
./gradlew :dubbo-common:build

# 构建多个模块
./gradlew :dubbo-common:build :dubbo-cluster:build

# 列出所有项目
./gradlew projects
```

### 发布相关
```bash
# 发布到本地 Maven 仓库
./gradlew publishToMavenLocal

# 生成 POM 文件
./gradlew generatePomFileForMavenJavaPublication
```

### 依赖管理
```bash
# 查看项目依赖
./gradlew dependencies

# 查看特定配置的依赖
./gradlew dependencies --configuration compileClasspath

# 查看依赖更新
./gradlew dependencyUpdates
```

### 代码质量
```bash
# 运行所有检查
./gradlew check

# 生成测试报告
./gradlew test
# 报告位置: build/reports/tests/test/index.html
```

## 性能优化

### 使用并行构建
```bash
./gradlew build --parallel
```

### 使用构建缓存
```bash
./gradlew build --build-cache
```

### 增加内存
编辑 `gradle.properties`：
```properties
org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=1g
```

### 离线构建
```bash
./gradlew build --offline
```

## 故障排查

### 清理并重新构建
```bash
./gradlew clean build --refresh-dependencies
```

### 查看详细日志
```bash
./gradlew build --info
./gradlew build --debug
./gradlew build --stacktrace
```

### Gradle Daemon 问题
```bash
# 停止 Gradle Daemon
./gradlew --stop

# 查看 Daemon 状态
./gradlew --status
```

## 开发技巧

### 持续构建（自动重新构建）
```bash
./gradlew build --continuous
```

### 仅构建影响的模块
```bash
./gradlew build --configure-on-demand
```

### 构建扫描
```bash
./gradlew build --scan
```

## IDE 配置

### IntelliJ IDEA
1. 打开项目：`File -> Open` -> 选择 `build.gradle`
2. 等待 Gradle 同步完成
3. 配置 JDK：`File -> Project Structure -> Project`

### Eclipse
1. 安装 Buildship 插件
2. 导入：`File -> Import -> Gradle -> Existing Gradle Project`

### VS Code
1. 安装 "Gradle for Java" 扩展
2. 打开项目文件夹
3. 使用命令面板运行 Gradle 任务

## 更多信息

- [完整迁移指南](GRADLE_MIGRATION.md)
- [Gradle 官方文档](https://docs.gradle.org/)
- [Dubbo 官方网站](https://dubbo.apache.org/)

