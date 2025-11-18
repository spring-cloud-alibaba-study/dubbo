# 合并 3.3 分支报告

## 📊 合并概览

**源分支**: origin/3.3 (Maven 构建)  
**目标分支**: maven_to_gradle (Gradle 构建)  
**合并时间**: 2025-11-07  
**合并状态**: ⚠️ 有冲突需要解决

---

## ✅ 成功自动合并的文件（9个）

### 1. GitHub Workflows 配置
- `.github/workflows/build-and-test-pr.yml`
- `.github/workflows/build-and-test-scheduled-3.3.yml`
- `.github/workflows/release-test.yml`

### 2. Java 源代码更新
- `dubbo-common/src/main/java/org/apache/dubbo/common/url/component/URLParam.java`
- `dubbo-common/src/test/java/org/apache/dubbo/config/context/ConfigManagerTest.java`
- `dubbo-common/src/test/java/org/apache/dubbo/metadata/definition/ServiceDefinitionBuilderTest.java`
- `dubbo-registry/dubbo-registry-api/src/main/java/org/apache/dubbo/registry/integration/RegistryDirectory.java`
- `dubbo-remoting/dubbo-remoting-api/src/main/java/org/apache/dubbo/remoting/exchange/support/DefaultFuture.java`
- `dubbo-remoting/dubbo-remoting-netty4/src/main/java/org/apache/dubbo/remoting/transport/netty4/NettyEventLoopFactory.java`

---

## ⚠️ 冲突文件（2个 - 修改/删除冲突）

### 1. `pom.xml`
- **冲突原因**: 当前分支删除了（转为 Gradle），3.3 分支修改了
- **建议处理**: 保持删除状态（当前使用 Gradle）

### 2. `dubbo-dependencies-bom/pom.xml`
- **冲突原因**: 当前分支删除了（转为 Gradle BOM），3.3 分支修改了
- **建议处理**: 保持删除状态（当前使用 Gradle BOM）

---

## 🔍 3.3 分支 pom.xml 的重要更新

从 3.3 分支的最近 10 次提交中，发现以下重要更新：

### 1. 版本更新
```
f284fab1a Update to 3.3.7-SNAPSHOT
f1585880b Prepare 3.3.6 release
```

### 2. JDK 支持
```
3720471e5 feat: Add JDK 25 support and fix build failures
```

### 3. 新功能
```
adc61430f Dubbo MCP Integration
5b9adb04d Support for Mutiny Reactive
```

### 4. 依赖版本更新
```
ed7ae8e3c Bump io.projectreactor:reactor-core from 3.7.6 to 3.7.11
cc350d373 Bump spring-6.version from 6.2.8 to 6.2.11
50099c107 Bump org.apache.dubbo:hessian-lite from 4.0.3 to 4.0.4
55a3a4b87 Set grpc_version at parent pom to 1.73
e0fb53131 remove useless properties
```

---

## 📋 冲突解决方案

### 方案1: 保持当前 Gradle 配置（推荐）

**理由**:
- ✅ 当前分支已完全转为 Gradle 构建
- ✅ 恢复 pom.xml 会导致混乱（双构建系统）
- ✅ Gradle 配置已包含所有必要的依赖

**操作**:
```bash
# 标记冲突文件为删除状态（接受我们的更改）
git rm pom.xml
git rm dubbo-dependencies-bom/pom.xml

# 完成合并提交
git commit -m "Merge branch 'origin/3.3' into maven_to_gradle

- Auto-merged: GitHub workflows and Java source files
- Resolved conflicts: Keep pom.xml deleted (using Gradle)
- Merged code changes from 3.3 branch"
```

**需要后续处理**:
⚠️ 确保以下依赖版本也在 Gradle 配置中更新：
1. `io.projectreactor:reactor-core` → 3.7.11
2. `spring-6.version` → 6.2.11
3. `hessian-lite` → 4.0.4
4. `grpc_version` → 1.73

### 方案2: 保留 pom.xml 作为参考

**理由**:
- 保留 Maven 配置作为依赖版本的参考
- 团队可能还需要 Maven 构建

**操作**:
```bash
# 恢复 pom.xml 文件
git checkout origin/3.3 -- pom.xml dubbo-dependencies-bom/pom.xml

# 添加并提交
git add pom.xml dubbo-dependencies-bom/pom.xml
git commit -m "Merge branch 'origin/3.3' into maven_to_gradle (keep both build systems)"
```

**注意**: 需要同时维护 Maven 和 Gradle 两套配置

---

## 🎯 推荐方案：方案1（保持 Gradle）

### 执行步骤

#### Step 1: 解决冲突（保持删除状态）
```bash
git rm pom.xml
git rm dubbo-dependencies-bom/pom.xml
```

#### Step 2: 完成合并提交
```bash
git commit -m "Merge branch 'origin/3.3' into maven_to_gradle

Merged changes:
- GitHub workflows updates
- Java source code improvements from 3.3
- URLParam, ConfigManagerTest updates
- RegistryDirectory, DefaultFuture fixes
- NettyEventLoopFactory improvements

Conflict resolution:
- Kept pom.xml deleted (project uses Gradle)
- Kept dubbo-dependencies-bom/pom.xml deleted (using Gradle BOM)

Note: 3.3 branch dependency updates need to be synced to Gradle config:
- reactor-core: 3.7.11
- spring-6: 6.2.11
- hessian-lite: 4.0.4
- grpc: 1.73"
```

#### Step 3: 同步 3.3 分支的依赖更新到 Gradle

检查并更新 `gradle/libs.versions.toml` 或相应的 Gradle 配置文件：

```toml
[versions]
reactor = "3.7.11"        # 从 3.7.6 更新
spring = "6.2.11"         # 从 6.2.8 更新
hessian = "4.0.4"         # 从 4.0.3 更新
grpc = "1.73"             # 确保一致
```

---

## 📝 合并后待办事项

### 高优先级
- [ ] 验证合并提交成功
- [ ] 检查 Gradle 构建是否正常
- [ ] 更新 Gradle 依赖版本（同步 3.3 分支）
- [ ] 运行完整测试套件

### 中优先级
- [ ] 验证 JDK 25 支持（如果需要）
- [ ] 验证 Dubbo MCP Integration 功能
- [ ] 验证 Mutiny Reactive 支持
- [ ] 检查所有自动合并的代码更改

### 低优先级
- [ ] 更新文档（如有必要）
- [ ] 代码格式化（运行 spotlessApply）
- [ ] 清理临时文件

---

## 🔍 需要验证的依赖版本

| 依赖 | 3.3 分支版本 | 当前 Gradle 版本 | 需要更新？ |
|------|-------------|-----------------|-----------|
| reactor-core | 3.7.11 | 需检查 | ⚠️ |
| spring-6 | 6.2.11 | 需检查 | ⚠️ |
| hessian-lite | 4.0.4 | 需检查 | ⚠️ |
| grpc | 1.73 | 需检查 | ⚠️ |

---

## 📊 合并影响分析

### 代码变更
- ✅ 自动合并了 9 个文件
- ✅ 包含 GitHub workflows 更新
- ✅ 包含多个 Java 源文件的 bug 修复和改进

### 构建系统
- ✅ 保持 Gradle 构建系统
- ✅ 不引入 Maven 配置
- ⚠️ 需要手动同步依赖版本

### 测试影响
- ⚠️ 测试用例可能因为合并的代码变更需要验证
- ⚠️ 需要确保所有测试通过

---

## ⚠️ 注意事项

1. **依赖版本同步**: 3.3 分支更新了多个依赖版本，需要在 Gradle 配置中手动同步
2. **JDK 25 支持**: 3.3 分支添加了 JDK 25 支持，确认 Gradle 配置也支持
3. **新功能集成**: Dubbo MCP Integration 和 Mutiny Reactive 支持可能需要额外配置
4. **测试验证**: 合并后务必运行完整测试套件
5. **代码审查**: 建议审查自动合并的 9 个文件的变更

---

## 🎉 总结

合并 3.3 分支的主要收益：
1. ✅ 获取最新的 bug 修复和改进
2. ✅ 获取依赖版本更新
3. ✅ 获取新功能支持（MCP、Mutiny）
4. ✅ 获取 JDK 25 支持
5. ✅ 保持 Gradle 构建系统的简洁性

合并方式：
- ✅ 接受所有代码更改（9个文件自动合并）
- ✅ 保持 pom.xml 删除状态（使用 Gradle）
- ⚠️ 需要手动同步依赖版本更新

---

**生成时间**: 2025-11-07  
**合并状态**: 待完成（需要解决冲突）  
**推荐方案**: 方案1 - 保持 Gradle 配置

