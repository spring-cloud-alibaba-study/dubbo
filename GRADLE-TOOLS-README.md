# Dubbo Gradle 迁移工具使用指南

本目录包含用于验证和完成 Dubbo 项目从 Maven 到 Gradle 迁移的工具集。

---

## 📁 工具清单

| 工具 | 文件名 | 用途 |
|------|-------|------|
| ✅ Python 验证工具 | `verify-dependencies.py` | 精确对比 pom.xml 和 build.gradle 的依赖 |
| ✅ Bash 验证工具 | `verify-gradle-migration.sh` | 快速验证迁移完整性 |
| ✅ 依赖修复工具 | `fix-dependencies-v2.sh` | 自动补全缺失的依赖 |
| ✅ Maven 清理工具 | `remove-maven-files.sh` | 安全删除 Maven 文件 |
| 📄 验证报告 | `gradle-migration-verification.md` | 详细验证报告 |
| 📄 最终报告 | `GRADLE-MIGRATION-FINAL-REPORT.md` | 迁移最终状态报告 |

---

## 🚀 快速开始

### 步骤 1: 验证迁移

运行 Python 验证工具检查所有依赖是否已迁移：

```bash
python3 verify-dependencies.py
```

**预期输出：**
```
✅ 验证通过！可以安全删除 pom.xml 文件。
```

### 步骤 2: 补全缺失依赖（如果需要）

如果验证发现缺失的依赖：

```bash
./fix-dependencies-v2.sh
```

然后重新运行验证：

```bash
python3 verify-dependencies.py
```

### 步骤 3: 测试 Gradle 构建

```bash
# 清理并构建（跳过测试以加快速度）
./gradlew clean build -x test

# 运行测试
./gradlew test
```

### 步骤 4: 删除 Maven 文件

运行交互式清理工具：

```bash
./remove-maven-files.sh
```

**推荐选项：**
- **选项 1** (保守方案) - 保留根 pom.xml
- **选项 2** (归档方案) - 最安全，可恢复

---

## 📖 详细工具说明

### 1. Python 验证工具 (`verify-dependencies.py`)

**功能：**
- 扫描所有包含 pom.xml 的模块
- 解析 Maven 依赖（排除 test 和 optional）
- 解析 Gradle 依赖
- 对比并生成详细报告

**使用方法：**
```bash
python3 verify-dependencies.py
```

**输出文件：**
- `gradle-migration-verification.md` - 详细报告

**返回值：**
- `0` - 验证通过
- `1` - 发现问题

---

### 2. Bash 验证工具 (`verify-gradle-migration.sh`)

**功能：**
- 快速扫描所有模块
- 检查 build.gradle 是否存在
- 简单的依赖对比

**使用方法：**
```bash
./verify-gradle-migration.sh
```

**输出文件：**
- `gradle-migration-verification-report.md`
- `gradle-migration-issues.txt`
- `missing-dependencies.csv`

---

### 3. 依赖修复工具 (`fix-dependencies-v2.sh`)

**功能：**
- 自动补全验证工具发现的缺失依赖
- 清理之前错误添加的依赖
- 使用 Python 精确插入依赖到 dependencies 块

**使用方法：**
```bash
./fix-dependencies-v2.sh
```

**修复的模块：**
- `dubbo-compatible`
- `dubbo-config-spring6`
- `dubbo-compiler`
- `dubbo-reactive`
- `dubbo-triple-servlet`
- `dubbo-metrics-prometheus`
- `dubbo-remoting-netty4`
- `dubbo-remoting-http3`
- `dubbo-dependencies-all`
- `dubbo-rpc-api`

---

### 4. Maven 清理工具 (`remove-maven-files.sh`)

**功能：**
- 交互式删除 Maven 文件
- 提供 3 种删除方案
- 安全提示和确认

**使用方法：**
```bash
./remove-maven-files.sh
```

**方案对比：**

| 方案 | 删除内容 | 保留内容 | 可恢复性 | 推荐度 |
|------|---------|---------|---------|--------|
| 1. 保守方案 | 子模块 pom.xml | 根 pom.xml | 部分 | ⭐⭐⭐⭐⭐ |
| 2. 归档方案 | 移动到 .archive/ | 无 | 完全 | ⭐⭐⭐⭐⭐ |
| 3. 完全删除 | 所有 Maven 文件 | 无 | 无 | ⭐⭐⭐ |
| 4. 仅清理 | target 目录 | 所有源文件 | N/A | ⭐⭐⭐⭐ |

---

## 📊 验证报告说明

### 报告结构

```
# Gradle 迁移依赖验证报告

## 📊 统计信息
- 总模块数
- 聚合模块数
- 有/缺失 build.gradle 的模块
- 存在问题的模块

## ❌ 发现的问题
- 每个问题模块的详细信息
- 缺失的依赖列表

## 🔧 修复建议
- 具体的修复步骤

## 📝 详细模块列表
- 按类别分组的模块列表
```

### 问题类型

1. **缺失 build.gradle** - 需要创建构建文件
2. **缺失依赖** - 需要添加依赖
3. **BOM 依赖** - 这是误报，Gradle 自动处理
4. **Scope 不同** - 功能等效，无需修改

---

## ✅ 验证通过标准

当满足以下条件时，可以安全删除 pom.xml：

- [x] 所有非聚合模块都有 build.gradle
- [x] 所有实际依赖都已迁移（排除 BOM）
- [x] `./gradlew build` 执行成功
- [x] `./gradlew test` 执行成功
- [x] `./gradlew publishToMavenLocal` 执行成功

---

## 🔍 常见问题

### Q1: 验证工具报告 BOM 依赖缺失

**A:** 这是正常的。Maven 的 `<scope>import</scope>` 依赖（BOM）在 Gradle 中通过 `dependencyManagement` 或 `platform()` 自动处理，不需要显式声明。

**示例：**
```xml
<!-- Maven - 需要显式声明 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-dependencies</artifactId>
    <scope>import</scope>
    <type>pom</type>
</dependency>
```

```groovy
// Gradle - 自动处理，无需声明
// Spring Boot plugin 会自动导入 BOM
```

### Q2: 验证工具报告依赖缺失，但实际已存在

**A:** 可能是以下原因：
1. **groupId 不同** - 如 `io.netty` vs `io.netty.incubator`
2. **Scope 不同** - Maven 用 `provided`，Gradle 用 `implementation` 或 `compileOnly`
3. **artifactId 匹配问题** - 验证工具使用简单的字符串匹配

**解决方案：** 手动检查 build.gradle 文件，确认依赖确实存在且功能等效。

### Q3: 删除 pom.xml 后构建失败

**A:** 按以下步骤排查：

1. 检查是否有遗漏的依赖：
   ```bash
   python3 verify-dependencies.py
   ```

2. 清理并重新构建：
   ```bash
   ./gradlew clean build --refresh-dependencies
   ```

3. 查看详细错误日志：
   ```bash
   ./gradlew build --info --stacktrace
   ```

4. 如果是依赖问题，从归档中恢复 pom.xml 对比：
   ```bash
   # 如果使用了归档方案
   diff .archive/maven/dubbo-xxx/pom.xml dubbo-xxx/build.gradle
   ```

---

## 📚 相关文档

- [BUILD_WITH_GRADLE.md](BUILD_WITH_GRADLE.md) - Gradle 构建指南
- [GRADLE-MIGRATION-FINAL-REPORT.md](GRADLE-MIGRATION-FINAL-REPORT.md) - 迁移最终报告
- [README_GRADLE.md](README_GRADLE.md) - Gradle 项目说明

---

## 🤝 贡献

如果您发现验证工具的问题或有改进建议，请：

1. 检查 [GRADLE-MIGRATION-FINAL-REPORT.md](GRADLE-MIGRATION-FINAL-REPORT.md)
2. 提交 Issue 或 Pull Request
3. 更新此文档

---

## 📝 更新日志

### v1.0.0 (2025-11-01)
- ✅ 创建 Python 验证工具
- ✅ 创建 Bash 验证工具
- ✅ 创建依赖修复工具
- ✅ 创建 Maven 清理工具
- ✅ 生成迁移最终报告

---

**最后更新**: 2025-11-01

**维护者**: Dubbo Gradle Migration Team

