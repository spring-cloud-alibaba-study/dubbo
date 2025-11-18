# JGitVer 自定义分支配置说明

## 🎯 核心概念

**JGitVer 使用正则表达式模式匹配分支名**，所以你可以指定**任何分支名称**作为开发分支、发布分支等。

---

## ✅ 当前配置（已更新）

### 配置说明

```gradle
jgitver {
    policy {
        // 1. 生产分支（正式版本）
        pattern('master|main|3\\.3') {
            transformations = []
        }
        // 版本号: 3.3.7
        
        // 2. 开发分支（SNAPSHOT 版本）
        pattern('develop|maven_to_gradle') {
            transformations = ['SNAPSHOT']
        }
        // 版本号: 3.3.7-SNAPSHOT
        
        // 3. 发布分支（RC 版本）
        pattern('release/(.*)') {
            transformations = ['RC']
        }
        // 版本号: 3.3.7-RC.1
        
        // 4. 功能分支（SNAPSHOT 版本）
        pattern('feature/(.*)') {
            transformations = ['SNAPSHOT', 'IGNORE']
        }
        // 版本号: 3.3.7-SNAPSHOT
        
        // 5. 修复分支（正式版本）
        pattern('hotfix/(.*)') {
            transformations = []
        }
        // 版本号: 3.3.7.1
    }
}
```

---

## 📋 分支名称配置示例

### 1. 使用任何分支作为开发分支

```gradle
// 示例 1: 只使用 maven_to_gradle 作为开发分支
pattern('maven_to_gradle') {
    transformations = ['SNAPSHOT']
}

// 示例 2: 使用多个分支作为开发分支
pattern('develop|maven_to_gradle|dev|development') {
    transformations = ['SNAPSHOT']
}

// 示例 3: 使用正则表达式匹配所有 dev 开头的分支
pattern('dev.*') {
    transformations = ['SNAPSHOT']
}

// 示例 4: 使用数字版本分支作为开发分支
pattern('\\d+\\.\\d+') {  // 匹配 3.3, 3.4 等
    transformations = ['SNAPSHOT']
}
```

### 2. 自定义发布分支模式

```gradle
// 标准 release 分支
pattern('release/(.*)') {
    transformations = ['RC']
}

// 自定义发布分支前缀
pattern('rel/(.*)') {
    transformations = ['RC']
}

// 多个发布分支前缀
pattern('release/(.*)|rel/(.*)|rc/(.*)') {
    transformations = ['RC']
}
```

### 3. 自定义功能分支模式

```gradle
// 标准 feature 分支
pattern('feature/(.*)') {
    transformations = ['SNAPSHOT', 'IGNORE']
}

// 自定义功能分支前缀
pattern('feat/(.*)') {
    transformations = ['SNAPSHOT', 'IGNORE']
}

// 多个功能分支前缀
pattern('feature/(.*)|feat/(.*)|task/(.*)') {
    transformations = ['SNAPSHOT', 'IGNORE']
}
```

### 4. 按团队习惯自定义

```gradle
jgitver {
    policy {
        // 生产分支: master, main, 或数字版本分支（如 3.3, 3.4）
        pattern('master|main|\\d+\\.\\d+') {
            transformations = []
        }
        
        // 开发分支: 你们团队使用的任何开发分支名
        pattern('dev|develop|development|trunk|maven_to_gradle') {
            transformations = ['SNAPSHOT']
        }
        
        // 发布分支: 支持多种命名
        pattern('release/(.*)|rel/(.*)|rc/(.*)') {
            transformations = ['RC']
        }
        
        // 功能分支: 支持多种命名
        pattern('feature/(.*)|feat/(.*)|task/(.*)') {
            transformations = ['SNAPSHOT', 'IGNORE']
        }
        
        // 修复分支: 支持多种命名
        pattern('hotfix/(.*)|fix/(.*)|patch/(.*)') {
            transformations = []
        }
    }
}
```

---

## 🎨 版本号转换说明

### transformations 参数

| 转换类型 | 说明 | 示例 |
|---------|------|------|
| `[]` | 无转换，使用原始版本号 | 3.3.7 |
| `['SNAPSHOT']` | 添加 -SNAPSHOT 后缀 | 3.3.7-SNAPSHOT |
| `['RC']` | 添加 -RC.n 后缀 | 3.3.7-RC.1 |
| `['IGNORE']` | 忽略分支名称 | - |
| `['SNAPSHOT', 'IGNORE']` | 添加 SNAPSHOT 并忽略分支名 | 3.3.7-SNAPSHOT |

---

## 💡 实际应用场景

### 场景 1: 使用现有分支而不是 develop

**你的情况**：当前在 `maven_to_gradle` 分支开发

```gradle
// ✅ 已配置
pattern('develop|maven_to_gradle') {
    transformations = ['SNAPSHOT']
}
```

**结果**：
- `maven_to_gradle` 分支 → 版本号：3.3.7-SNAPSHOT
- 无需创建 develop 分支

### 场景 2: 使用数字版本分支（如 3.3, 3.4）

**Apache 项目常见做法**：使用 3.3, 3.4 等分支

```gradle
// 稳定分支作为生产版本
pattern('\\d+\\.\\d+') {
    transformations = []
}

// 或者作为开发版本
pattern('\\d+\\.\\d+') {
    transformations = ['SNAPSHOT']
}
```

**结果**：
- `3.3` 分支 → 版本号：3.3.7（或 3.3.7-SNAPSHOT）
- `3.4` 分支 → 版本号：3.4.0（或 3.4.0-SNAPSHOT）

### 场景 3: 多个并行开发分支

**需求**：同时维护多个版本

```gradle
// 3.3.x 开发分支
pattern('3\\.3') {
    transformations = ['SNAPSHOT']
}

// 3.4.x 开发分支
pattern('3\\.4') {
    transformations = ['SNAPSHOT']
}

// 4.0.x 开发分支
pattern('4\\.0') {
    transformations = ['SNAPSHOT']
}
```

---

## 🔍 正则表达式说明

### 常用模式

```gradle
// 1. 精确匹配
pattern('develop')                    // 只匹配 develop

// 2. 多个分支（OR 逻辑）
pattern('develop|maven_to_gradle')    // develop 或 maven_to_gradle

// 3. 前缀匹配
pattern('feature/.*')                 // 所有 feature/ 开头的分支

// 4. 数字版本
pattern('\\d+\\.\\d+')                // 3.3, 3.4, 4.0 等
pattern('\\d+\\.\\d+\\.\\d+')         // 3.3.7, 3.4.0 等

// 5. 捕获组
pattern('release/(.*)')               // release/3.3.7 → 捕获 3.3.7

// 6. 复杂模式
pattern('(dev|develop).*')            // dev, develop, development 等
```

### 转义字符

```gradle
// . 需要转义（否则匹配任意字符）
pattern('3\\.3')        // ✅ 正确：匹配 3.3
pattern('3.3')          // ❌ 错误：匹配 303, 313, 323 等

// 管道符 | 不需要转义
pattern('master|main')  // ✅ 正确
```

---

## 📊 当前项目配置对比

### 修改前（标准 GitFlow）

```gradle
pattern('develop') {
    transformations = ['SNAPSHOT']
}
```

**问题**: 要求必须有 develop 分支

### 修改后（灵活配置）✅

```gradle
pattern('develop|maven_to_gradle') {
    transformations = ['SNAPSHOT']
}
```

**优点**: 
- ✅ 可以使用 develop 分支
- ✅ 也可以使用 maven_to_gradle 分支
- ✅ 无需创建新分支
- ✅ 保持现有工作流

---

## 🎯 推荐配置（根据你的项目）

### 方案 1: 保持现有分支结构

```gradle
jgitver {
    policy {
        // 稳定版本分支
        pattern('3\\.3|master|main') {
            transformations = []
        }
        
        // 开发分支（使用现有的 maven_to_gradle）
        pattern('maven_to_gradle|develop') {
            transformations = ['SNAPSHOT']
        }
        
        // 发布分支
        pattern('release/(.*)') {
            transformations = ['RC']
        }
        
        // 功能分支
        pattern('feature/(.*)') {
            transformations = ['SNAPSHOT', 'IGNORE']
        }
        
        // 修复分支
        pattern('hotfix/(.*)') {
            transformations = []
        }
    }
}
```

### 方案 2: Apache 风格（数字版本分支）

```gradle
jgitver {
    policy {
        // 主干分支
        pattern('master|main') {
            transformations = []
        }
        
        // 版本开发分支（3.3, 3.4 等）
        pattern('\\d+\\.\\d+') {
            transformations = ['SNAPSHOT']
        }
        
        // 发布分支
        pattern('release/(.*)') {
            transformations = ['RC']
        }
        
        // 功能和修复分支
        pattern('feature/(.*)|hotfix/(.*)') {
            transformations = ['SNAPSHOT', 'IGNORE']
        }
    }
}
```

---

## ✅ 验证配置

### 测试版本号生成

```bash
# 在当前分支测试
./gradlew properties | grep "^version:"

# 预期输出（maven_to_gradle 分支）
version: 3.3.7-SNAPSHOT

# 测试其他分支模式
git checkout -b test-branch
./gradlew properties | grep "^version:"
git checkout maven_to_gradle
git branch -D test-branch
```

---

## 📝 总结

### 核心要点

1. ✅ **JGitVer 可以指定任何分支代替 develop**
2. ✅ **使用正则表达式模式匹配分支名**
3. ✅ **可以配置多个分支使用相同的版本策略**
4. ✅ **无需遵循严格的 GitFlow 分支命名**
5. ✅ **完全可以根据团队习惯自定义**

### 你的配置（已更新）

```gradle
// ✅ 当前配置已包含 maven_to_gradle
pattern('develop|maven_to_gradle') {
    transformations = ['SNAPSHOT']
}
```

**结果**: 
- `maven_to_gradle` 分支现在会生成 `3.3.7-SNAPSHOT` 版本号
- 无需创建或切换到 develop 分支
- 可以继续在 maven_to_gradle 分支上开发

---

**生成时间**: 2025-11-18  
**配置文件**: build.gradle  
**状态**: ✅ 已更新并应用

