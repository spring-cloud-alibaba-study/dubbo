# JGitFlow 集成方案

**项目**: Apache Dubbo  
**当前版本**: 3.3.7-SNAPSHOT  
**构建系统**: Gradle 8.14  
**目标**: 使用 JGitFlow 替代现有的发布流程

---

## 📊 当前状态分析

### 当前使用的发布插件

```gradle
plugins {
    alias(libs.plugins.release)  // net.researchgate:gradle-release-plugin
}

release {
    versionPropertyFile = 'gradle.properties'
    versionProperties = ['version']
    failOnUnversionedFiles = true
    preTagCommitMessage = '[Gradle Release] - pre tag commit: '
    tagCommitMessage = '[Gradle Release] - creating tag: '
    newVersionCommitMessage = '[Gradle Release] - new version commit: '
    tagTemplate = 'v${version}'
}
```

### 当前分支结构

```
* maven_to_gradle  (当前开发分支)
  3.3              (稳定分支)
  origin/3.3       (远端稳定分支)
```

---

## 🎯 JGitFlow 工作流说明

### GitFlow 分支模型

```
master (main)     ←─ 生产版本分支 (仅包含发布版本)
  │
  ├─ release/x.x.x ←─ 发布准备分支
  │
develop           ←─ 主开发分支 (SNAPSHOT 版本)
  │
  ├─ feature/xxx  ←─ 功能开发分支
  │
  ├─ hotfix/xxx   ←─ 紧急修复分支
```

### 版本号管理

- **develop 分支**: `3.3.7-SNAPSHOT`
- **release 分支**: `3.3.7-RC1`, `3.3.7-RC2`, `3.3.7`
- **master 分支**: `3.3.7` (发布后)
- **下一个开发版本**: `3.3.8-SNAPSHOT`

---

## 🔧 集成步骤

### Step 1: 添加 JGitFlow 插件

**方式 1: 使用 gradle-git-flow-plugin（推荐）**

```gradle
// build.gradle
plugins {
    id 'java-library'
    id 'maven-publish'
    id 'signing'
    // 替换原有的 release 插件
    // alias(libs.plugins.release)  // 删除
    id 'com.dkirrane.gradle.gitflow' version '2.1.1'  // 新增
}
```

**方式 2: 使用 JGitVer（语义化版本）**

```gradle
plugins {
    id 'fr.brouillard.oss.gradle.jgitver' version '0.10.0-rc03'
}
```

---

## 📝 配置方案

### 方案 1: gradle-git-flow-plugin 配置

```gradle
// build.gradle
gitflow {
    // 分支配置
    develop = 'develop'
    master = 'master'
    versiontypes = ['major', 'minor', 'patch']
    
    // 版本号配置
    versionPropertyFile = file('gradle.properties')
    versionProperty = 'version'
    
    // 发布配置
    requireLocalDevelopBranch = true
    requireLocalMasterBranch = true
    requireRemoteDevelopBranch = true
    requireRemoteMasterBranch = true
    
    // 推送配置
    pushToCurrentOnly = false
    pushToRemote = 'origin'
    
    // 标签配置
    versionTagPrefix = 'v'
    
    // 功能分支配置
    featurePrefix = 'feature/'
    releasePrefix = 'release/'
    hotfixPrefix = 'hotfix/'
    supportPrefix = 'support/'
    versiontagPrefix = 'v'
}

// 发布任务配置
task releaseStart(type: com.dkirrane.gradle.gitflow.tasks.ReleaseStartTask) {
    description = '开始 release 分支'
    group = 'release'
}

task releaseFinish(type: com.dkirrane.gradle.gitflow.tasks.ReleaseFinishTask) {
    description = '完成 release 并合并到 master 和 develop'
    group = 'release'
    dependsOn 'build', 'test'
}

task hotfixStart(type: com.dkirrane.gradle.gitflow.tasks.HotfixStartTask) {
    description = '开始 hotfix 分支'
    group = 'hotfix'
}

task hotfixFinish(type: com.dkirrane.gradle.gitflow.tasks.HotfixFinishTask) {
    description = '完成 hotfix 并合并到 master 和 develop'
    group = 'hotfix'
    dependsOn 'build', 'test'
}
```

---

### 方案 2: JGitVer 配置（自动版本号）

```gradle
// build.gradle
plugins {
    id 'fr.brouillard.oss.gradle.jgitver' version '0.10.0-rc03'
}

jgitver {
    // 策略配置
    strategy = fr.brouillard.oss.gradle.plugins.JGitverPluginExtension.Strategy.PATTERN
    
    // 分支版本规则
    branchPolicies = [
        // develop 分支: x.y.z-SNAPSHOT
        pattern('develop'): { versionWithBranch, branch ->
            versionWithBranch + '-SNAPSHOT'
        },
        
        // release 分支: x.y.z-RC.n
        pattern('release/.*'): { versionWithBranch, branch ->
            versionWithBranch + '-RC.' + env.BUILD_NUMBER ?: '1'
        },
        
        // master/main 分支: x.y.z
        pattern('master|main'): { versionWithBranch, branch ->
            versionWithBranch
        },
        
        // feature 分支: x.y.z-feature-<name>-SNAPSHOT
        pattern('feature/.*'): { versionWithBranch, branch ->
            def featureName = branch.replaceAll('feature/', '')
            versionWithBranch + '-' + featureName + '-SNAPSHOT'
        },
        
        // hotfix 分支: x.y.z-hotfix-<name>
        pattern('hotfix/.*'): { versionWithBranch, branch ->
            def hotfixName = branch.replaceAll('hotfix/', '')
            versionWithBranch + '-' + hotfixName
        }
    ]
    
    // 标签前缀
    tagVersionPattern = 'v${v}'
    
    // 自动推断版本号
    autoIncrementPatch = true
    useGitCommitId = false
    useGitCommitTimestamp = false
    useDirty = true
    
    // 版本号格式
    versionPattern = '${meta.CURRENT_VERSION_MAJOR}.${meta.CURRENT_VERSION_MINOR}.${meta.CURRENT_VERSION_PATCH}${meta.QUALIFIED_BRANCH_NAME}'
    
    // 忽略某些分支
    ignoreBranchesMatching = ['tmp/.*', 'experimental/.*']
}
```

---

## 🎯 推荐方案：混合方案

结合两者优势，使用 **JGitVer 自动管理版本号** + **手动 GitFlow 工作流**

### 配置文件

#### 1. 修改 `gradle/libs.versions.toml`

```toml
[plugins]
# ... 现有插件 ...
# release = { id = "net.researchgate.release", version = "3.1.0" }  # 删除
jgitver = { id = "fr.brouillard.oss.gradle.jgitver", version = "0.10.0-rc03" }  # 新增
```

#### 2. 修改 `build.gradle`

```gradle
plugins {
    id 'java-library'
    id 'maven-publish'
    id 'signing'
    alias(libs.plugins.jgitver)  // 替换 release 插件
    // ... 其他插件 ...
}

// JGitVer 配置
jgitver {
    strategy = 'PATTERN'
    
    // 分支策略
    policy {
        pattern('master') {
            transformations = []
        }
        pattern('develop') {
            transformations = ['SNAPSHOT']
        }
        pattern('release/(.*)') {
            transformations = ['RC']
        }
        pattern('feature/(.*)') {
            transformations = ['SNAPSHOT', 'IGNORE']
        }
        pattern('hotfix/(.*)') {
            transformations = []
        }
    }
    
    // 标签配置
    useGitCommitId = false
    useGitCommitTimestamp = false
    autoIncrementPatch = true
    tagVersionPattern = 'v${v}'
}

// 删除原有的 release 配置
// release { ... }

// 新增 GitFlow 辅助任务
tasks.register('gitflowReleaseStart') {
    group = 'release'
    description = '开始 release 流程'
    doLast {
        def currentVersion = version.toString().replace('-SNAPSHOT', '')
        def releaseVersion = project.findProperty('releaseVersion') ?: currentVersion
        
        println """
========================================
GitFlow Release Start
========================================
当前版本: ${version}
发布版本: ${releaseVersion}

执行步骤:
1. 从 develop 创建 release 分支
   $ git checkout develop
   $ git pull origin develop
   $ git checkout -b release/${releaseVersion}

2. 更新版本号（JGitVer 会自动处理）

3. 构建和测试
   $ ./gradlew clean build

4. 推送 release 分支
   $ git push origin release/${releaseVersion}
========================================
"""
    }
}

tasks.register('gitflowReleaseFinish') {
    group = 'release'
    description = '完成 release 流程'
    dependsOn 'build', 'test'
    
    doLast {
        def currentVersion = version.toString()
        def nextVersion = incrementVersion(currentVersion)
        
        println """
========================================
GitFlow Release Finish
========================================
当前版本: ${currentVersion}
下一个版本: ${nextVersion}

执行步骤:
1. 合并到 master
   $ git checkout master
   $ git merge --no-ff release/${currentVersion}
   $ git tag -a v${currentVersion} -m "Release ${currentVersion}"

2. 合并回 develop
   $ git checkout develop
   $ git merge --no-ff release/${currentVersion}

3. 删除 release 分支
   $ git branch -d release/${currentVersion}

4. 推送到远端
   $ git push origin master develop --tags
   $ git push origin :release/${currentVersion}
========================================
"""
    }
}

tasks.register('gitflowHotfixStart') {
    group = 'hotfix'
    description = '开始 hotfix 流程'
    doLast {
        def hotfixVersion = project.findProperty('hotfixVersion') ?: 'hotfix-name'
        
        println """
========================================
GitFlow Hotfix Start
========================================

执行步骤:
1. 从 master 创建 hotfix 分支
   $ git checkout master
   $ git pull origin master
   $ git checkout -b hotfix/${hotfixVersion}

2. 修复问题并提交
========================================
"""
    }
}

tasks.register('gitflowHotfixFinish') {
    group = 'hotfix'
    description = '完成 hotfix 流程'
    dependsOn 'build', 'test'
    
    doLast {
        def hotfixVersion = project.findProperty('hotfixVersion')
        
        println """
========================================
GitFlow Hotfix Finish
========================================

执行步骤:
1. 合并到 master
   $ git checkout master
   $ git merge --no-ff hotfix/${hotfixVersion}
   $ git tag -a v${hotfixVersion} -m "Hotfix ${hotfixVersion}"

2. 合并到 develop
   $ git checkout develop
   $ git merge --no-ff hotfix/${hotfixVersion}

3. 删除 hotfix 分支
   $ git branch -d hotfix/${hotfixVersion}
   $ git push origin master develop --tags
========================================
"""
    }
}

// 辅助方法
def incrementVersion(String version) {
    def parts = version.replaceAll('-SNAPSHOT', '').split('\\.')
    parts[-1] = (parts[-1].toInteger() + 1).toString()
    return parts.join('.') + '-SNAPSHOT'
}
```

#### 3. 修改 `gradle.properties`

```properties
# 版本号由 JGitVer 自动管理，但保留作为回退
# version=3.3.7-SNAPSHOT
```

---

## 📖 使用指南

### 1. 初始化 GitFlow 分支结构

```bash
# 当前在 maven_to_gradle 分支
# 需要创建标准的 GitFlow 分支结构

# 1. 创建 master 分支（如果没有）
git checkout -b master
git push origin master

# 2. 创建或切换到 develop 分支
git checkout -b develop
git push origin develop

# 3. 设置默认分支（可选）
# 在 GitHub/GitLab 上设置 develop 为默认分支
```

### 2. 功能开发流程

```bash
# 1. 从 develop 创建 feature 分支
git checkout develop
git pull origin develop
git checkout -b feature/new-feature

# 2. 开发和提交
# ... 进行开发 ...
git add .
git commit -m "feat: 实现新功能"

# 3. 完成 feature
git checkout develop
git merge --no-ff feature/new-feature
git push origin develop
git branch -d feature/new-feature
```

### 3. 发布流程（使用 JGitVer）

```bash
# 1. 从 develop 创建 release 分支
git checkout develop
git pull origin develop
git checkout -b release/3.3.7

# 2. 构建和测试（版本号自动为 3.3.7-RC.1）
./gradlew clean build test

# 3. 发布到 Maven 仓库
./gradlew publish

# 4. 完成 release
git checkout master
git merge --no-ff release/3.3.7
git tag -a v3.3.7 -m "Release 3.3.7"

# 5. 合并回 develop
git checkout develop
git merge --no-ff release/3.3.7

# 6. 推送
git push origin master develop --tags
git branch -d release/3.3.7
```

### 4. Hotfix 流程

```bash
# 1. 从 master 创建 hotfix 分支
git checkout master
git pull origin master
git checkout -b hotfix/3.3.7.1

# 2. 修复问题
# ... 修复 bug ...
git commit -m "fix: 修复紧急问题"

# 3. 构建和测试
./gradlew clean build test

# 4. 完成 hotfix
git checkout master
git merge --no-ff hotfix/3.3.7.1
git tag -a v3.3.7.1 -m "Hotfix 3.3.7.1"

# 5. 合并回 develop
git checkout develop
git merge --no-ff hotfix/3.3.7.1

# 6. 推送
git push origin master develop --tags
git branch -d hotfix/3.3.7.1
```

---

## 🚀 Gradle 任务使用

### 使用 JGitVer 自动版本号

```bash
# 查看当前版本号
./gradlew properties | grep version

# 在不同分支上构建
git checkout develop
./gradlew build  # 版本: 3.3.7-SNAPSHOT

git checkout release/3.3.7
./gradlew build  # 版本: 3.3.7-RC.1

git checkout master
./gradlew build  # 版本: 3.3.7
```

### 使用辅助任务

```bash
# 开始 release
./gradlew gitflowReleaseStart -PreleaseVersion=3.3.7

# 完成 release
./gradlew gitflowReleaseFinish

# 开始 hotfix
./gradlew gitflowHotfixStart -PhotofixVersion=3.3.7.1

# 完成 hotfix
./gradlew gitflowHotfixFinish -PhotofixVersion=3.3.7.1
```

---

## 📊 版本号示例

### 不同分支的版本号格式

| 分支 | 版本号示例 | 说明 |
|------|-----------|------|
| `develop` | `3.3.7-SNAPSHOT` | 开发版本 |
| `feature/auth` | `3.3.7-auth-SNAPSHOT` | 功能分支 |
| `release/3.3.7` | `3.3.7-RC.1` | 发布候选 |
| `master` | `3.3.7` | 正式发布 |
| `hotfix/3.3.7.1` | `3.3.7.1` | 紧急修复 |

---

## 🔄 迁移步骤

### Step 1: 备份当前配置

```bash
# 备份 build.gradle
cp build.gradle build.gradle.backup

# 备份 gradle.properties
cp gradle.properties gradle.properties.backup
```

### Step 2: 修改配置文件

1. 修改 `gradle/libs.versions.toml`（添加 jgitver 插件）
2. 修改 `build.gradle`（替换 release 插件配置）
3. 修改 `gradle.properties`（注释掉 version 行）

### Step 3: 初始化 GitFlow 分支

```bash
# 创建 develop 分支（基于当前 maven_to_gradle）
git checkout -b develop
git push origin develop

# 创建 master 分支（基于 3.3 分支）
git checkout 3.3
git checkout -b master
git push origin master
```

### Step 4: 测试验证

```bash
# 切换到 develop 分支测试
git checkout develop
./gradlew properties | grep version
# 应该输出: version: 3.3.7-SNAPSHOT

# 创建测试 release 分支
git checkout -b release/3.3.7-test
./gradlew properties | grep version
# 应该输出: version: 3.3.7-RC.1

# 切换到 master 测试
git checkout master
./gradlew properties | grep version
# 应该输出: version: 3.3.7

# 删除测试分支
git branch -D release/3.3.7-test
```

### Step 5: 团队培训

1. 分享 GitFlow 工作流程文档
2. 演示发布流程
3. 更新 CI/CD 配置

---

## ⚠️ 注意事项

### 1. 分支保护

在 GitHub/GitLab 上设置分支保护规则：

- `master`: 只允许从 `release/*` 或 `hotfix/*` 合并
- `develop`: 只允许从 `feature/*`、`release/*`、`hotfix/*` 合并
- 强制要求 code review
- 强制要求 CI/CD 通过

### 2. 版本号管理

- JGitVer 会根据 Git 分支和标签自动计算版本号
- 不要手动修改 `gradle.properties` 中的 version
- 使用 Git 标签来标记正式版本

### 3. CI/CD 集成

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    branches:
      - 'release/**'
      - 'master'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0  # 重要：JGitVer 需要完整的 Git 历史
      
      - name: Set up JDK
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      
      - name: Build and Test
        run: ./gradlew clean build test
      
      - name: Publish
        if: startsWith(github.ref, 'refs/heads/release/')
        run: ./gradlew publish
        env:
          MAVEN_USERNAME: ${{ secrets.MAVEN_USERNAME }}
          MAVEN_PASSWORD: ${{ secrets.MAVEN_PASSWORD }}
```

---

## 📚 参考资源

- **GitFlow 原理**: https://nvie.com/posts/a-successful-git-branching-model/
- **JGitVer 文档**: https://jgitver.github.io/
- **gradle-git-flow-plugin**: https://github.com/dkirrane/gradle-git-flow-plugin
- **Semantic Versioning**: https://semver.org/

---

## 🎯 总结

### 优点

✅ **自动版本管理**: JGitVer 根据 Git 分支自动计算版本号  
✅ **清晰的工作流**: GitFlow 提供标准化的分支管理流程  
✅ **无需手动修改版本号**: 避免人为错误  
✅ **支持并行开发**: 多个 feature 分支可以同时进行  
✅ **完善的发布流程**: release 和 hotfix 流程清晰明确

### 缺点

⚠️ **学习成本**: 团队需要学习 GitFlow 工作流  
⚠️ **分支管理复杂度**: 需要维护多个长期分支  
⚠️ **需要 Git 历史**: JGitVer 需要完整的 Git 提交历史

### 适用场景

✅ 适合大型项目、多人协作  
✅ 适合有明确发布周期的项目  
✅ 适合需要同时维护多个版本的项目

---

**生成时间**: 2025-11-18  
**文档版本**: v1.0  
**建议开始实施**: 下一个迭代周期

