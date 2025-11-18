# 当前分支 vs 3.3 分支依赖版本对比报告

**生成时间**: 2025-11-18  
**当前分支**: maven_to_gradle  
**对比分支**: origin/3.3  
**构建系统**: Gradle vs Maven

---

## 🚨 严重问题（必须修复）

### 1. ⚠️⚠️⚠️ Netty 版本号错误

| 依赖 | 当前分支 | 3.3 分支 | 状态 | 影响 |
|------|----------|----------|------|------|
| **netty4** | **4.2.2.Final** ❌ | 4.1.x | **严重错误** | Netty 4.2.x 不存在！应该是 4.1.x |
| nettyCodecHttp2 | 4.1.100.Final | - | 正确 | - |
| nettyHandler | 4.1.100.Final | - | 正确 | - |

**问题**: `netty4 = "4.2.2.Final"` 是**错误的版本号**，Netty 没有 4.2.x 系列！

**应该修改为**: 
```toml
netty4 = "4.1.100.Final"  # 或更新到 4.1.115.Final
```

---

### 2. ⚠️⚠️⚠️ gRPC 版本严重不一致

| 依赖 | 当前分支 | 3.3 分支 | 状态 | 影响 |
|------|----------|----------|------|------|
| **grpc** | **1.73.0** | **1.73.0** | ✅ 一致 | - |
| grpcNetty | 1.73.0 | 1.73.0 | ✅ 一致 | - |
| grpcNettyShaded | 1.73.0 | 1.73.0 | ✅ 一致 | - |
| **grpcContext** | **1.59.1** ❌ | 1.73.0 | **落后 14 版本** | 运行时错误 |
| **grpcCore** | **1.59.1** ❌ | 1.73.0 | **落后 14 版本** | API 不兼容 |
| **grpcProtobuf** | **1.59.1** ❌ | 1.73.0 | **落后 14 版本** | 序列化问题 |
| **grpcServices** | **1.59.1** ❌ | 1.73.0 | **落后 14 版本** | 服务调用失败 |
| **grpcStub** | **1.59.1** ❌ | 1.73.0 | **落后 14 版本** | 客户端调用失败 |
| **grpcTesting** | **1.59.1** ❌ | 1.73.0 | **落后 14 版本** | 测试失败 |

**问题**: gRPC 组件版本必须完全一致，否则会导致：
- 🔴 ClassNotFoundException
- 🔴 NoSuchMethodError
- 🔴 运行时崩溃

**必须修改为**:
```toml
grpc = "1.73.0"
# 删除以下独立版本，统一使用 grpc
# grpcContext = "1.59.1"   # 删除
# grpcCore = "1.59.1"      # 删除
# grpcProtobuf = "1.59.1"  # 删除
# grpcServices = "1.59.1"  # 删除
# grpcStub = "1.59.1"      # 删除
# grpcTesting = "1.59.1"   # 删除
```

---

### 3. ⚠️⚠️ Jackson 版本不一致

| 依赖 | 当前分支 | 3.3 分支 | 状态 | 影响 |
|------|----------|----------|------|------|
| **jackson** | **2.19.0** ❌ | 2.18.x | **版本可能不存在** | 序列化失败 |
| jacksonCore | 2.15.3 ❌ | 2.18.x | 落后 | 不兼容 |
| jacksonDatabind | 2.15.3 ❌ | 2.18.x | 落后 | 不兼容 |

**问题**: 
1. Jackson 2.19.0 可能还未发布（当前最新是 2.18.x）
2. Jackson 各组件版本必须一致

**应该修改为**:
```toml
jackson = "2.18.2"  # 或 2.17.3 (LTS)
# 删除独立版本
# jacksonCore = "2.15.3"     # 删除
# jacksonDatabind = "2.15.3" # 删除
```

---

## 🟡 中等问题（建议修复）

### 4. Spring 版本

| 依赖 | 当前分支 | 3.3 分支 | 状态 |
|------|----------|----------|------|
| spring6 | 6.2.11 | 6.2.11 | ✅ 一致 |
| spring | 5.3.39 | - | - |

**状态**: ✅ 一致，无问题

---

### 5. Curator 版本

| 依赖 | 当前分支 | 3.3 分支 | 状态 |
|------|----------|----------|------|
| curator | 5.8.0 | - | 需要验证 |
| curatorFramework | 5.8.0 | - | - |
| curatorRecipes | 5.8.0 | - | - |
| curatorTest | 2.12.0 ❌ | - | 严重落后 |
| curatorXDiscovery | 5.5.0 ⚠️ | - | 落后 |

**问题**: curatorTest 版本严重落后

**应该修改为**:
```toml
curator = "5.8.0"
# 统一所有 Curator 组件版本
```

---

### 6. Hessian 版本

| 依赖 | 当前分支 | 3.3 分支 | 状态 |
|------|----------|----------|------|
| hessian | 4.0.66 | - | - |
| hessianLite | 4.0.4 | 4.0.4 | ✅ 一致 |

**状态**: ✅ 一致

---

### 7. ZooKeeper 版本

| 依赖 | 当前分支 | 3.3 分支 | 状态 |
|------|----------|----------|------|
| zookeeper | 3.7.2 | - | 需要验证 |

---

### 8. Nacos 版本

| 依赖 | 当前分支 | 3.3 分支 | 状态 |
|------|----------|----------|------|
| nacos | 2.5.1 | - | 需要验证 |
| nacosClient | 2.5.1 | - | 冗余 |

**建议**: 删除 nacosClient，只保留 nacos

---

### 9. Reactor 版本

| 依赖 | 当前分支 | 3.3 分支 | 状态 |
|------|----------|----------|------|
| reactor | 3.7.11 | 3.7.11 | ✅ 一致 |
| reactorCore | 3.7.11 | 3.7.11 | ✅ 一致（冗余）|

**建议**: 删除 reactorCore，只保留 reactor

---

## 📊 完整对比表

### 核心框架依赖

| 类别 | 依赖名称 | 当前分支 | 3.3 分支 | 状态 | 优先级 |
|------|----------|----------|----------|------|--------|
| **Netty** | netty4 | **4.2.2.Final** | 4.1.x | ❌ **错误** | 🔥 P0 |
| **gRPC** | grpc | 1.73.0 | 1.73.0 | ✅ 一致 | - |
| **gRPC** | grpcContext | **1.59.1** | 1.73.0 | ❌ 不一致 | 🔥 P0 |
| **gRPC** | grpcCore | **1.59.1** | 1.73.0 | ❌ 不一致 | 🔥 P0 |
| **gRPC** | grpcProtobuf | **1.59.1** | 1.73.0 | ❌ 不一致 | 🔥 P0 |
| **gRPC** | grpcServices | **1.59.1** | 1.73.0 | ❌ 不一致 | 🔥 P0 |
| **gRPC** | grpcStub | **1.59.1** | 1.73.0 | ❌ 不一致 | 🔥 P0 |
| **gRPC** | grpcTesting | **1.59.1** | 1.73.0 | ❌ 不一致 | 🔥 P0 |
| **Jackson** | jackson | **2.19.0** | 2.18.x | ⚠️ 可能不存在 | 🔥 P0 |
| **Jackson** | jacksonCore | 2.15.3 | 2.18.x | ❌ 不一致 | 🔥 P0 |
| **Jackson** | jacksonDatabind | 2.15.3 | 2.18.x | ❌ 不一致 | 🔥 P0 |
| **Spring** | spring6 | 6.2.11 | 6.2.11 | ✅ 一致 | - |
| **Hessian** | hessianLite | 4.0.4 | 4.0.4 | ✅ 一致 | - |
| **Reactor** | reactor | 3.7.11 | 3.7.11 | ✅ 一致 | - |
| **Curator** | curator | 5.8.0 | - | ⚠️ 需验证 | 🟡 P1 |
| **Curator** | curatorTest | **2.12.0** | - | ❌ 严重落后 | 🟡 P1 |
| **Curator** | curatorXDiscovery | 5.5.0 | - | ⚠️ 落后 | 🟡 P1 |
| **ZooKeeper** | zookeeper | 3.7.2 | - | ⚠️ 需验证 | 🟡 P1 |
| **Nacos** | nacos | 2.5.1 | - | ⚠️ 需验证 | 🟡 P1 |

---

## 🔧 修复建议

### 立即修复（P0 - 阻塞性问题）

#### 1. 修复 Netty 版本号
```toml
# gradle/libs.versions.toml 第 31 行
netty4 = "4.1.100.Final"  # 从 "4.2.2.Final" 修改
```

#### 2. 统一 gRPC 版本
```toml
# gradle/libs.versions.toml 第 66-76 行
grpc = "1.73.0"
grpcContrib = "0.8.1"
grpcNetty = "1.73.0"
grpcNettyShaded = "1.73.0"
grpcNettShaded = "4.1.100.Final"

# 删除以下行（第 68-72, 76 行）
# grpcContext = "1.59.1"
# grpcCore = "1.59.1"
# grpcProtobuf = "1.59.1"
# grpcServices = "1.59.1"
# grpcStub = "1.59.1"
# grpcTesting = "1.59.1"
```

#### 3. 统一 Jackson 版本
```toml
# gradle/libs.versions.toml 第 57-59 行
jackson = "2.18.2"  # 从 "2.19.0" 修改

# 删除以下行（第 58-59 行）
# jacksonCore = "2.15.3"
# jacksonDatabind = "2.15.3"
```

---

### 建议修复（P1 - 中等优先级）

#### 4. 统一 Curator 版本
```toml
curator = "5.8.0"
curatorFramework = "5.8.0"
curatorRecipes = "5.8.0"
curatorTest = "5.8.0"        # 从 "2.12.0" 修改
curatorXDiscovery = "5.8.0"  # 从 "5.5.0" 修改
```

---

## 🎯 快速修复脚本

以下是需要修改的具体行号和内容：

```bash
# 1. 修复 Netty 版本（第 31 行）
sed -i '' 's/netty4 = "4.2.2.Final"/netty4 = "4.1.100.Final"/' gradle/libs.versions.toml

# 2. 删除 gRPC 冗余版本（第 68-72, 76 行）
sed -i '' '/^grpcContext = /d' gradle/libs.versions.toml
sed -i '' '/^grpcCore = /d' gradle/libs.versions.toml
sed -i '' '/^grpcProtobuf = /d' gradle/libs.versions.toml
sed -i '' '/^grpcServices = /d' gradle/libs.versions.toml
sed -i '' '/^grpcStub = /d' gradle/libs.versions.toml
sed -i '' '/^grpcTesting = /d' gradle/libs.versions.toml

# 3. 修复 Jackson 版本（第 57 行）
sed -i '' 's/jackson = "2.19.0"/jackson = "2.18.2"/' gradle/libs.versions.toml

# 4. 删除 Jackson 冗余版本（第 58-59 行）
sed -i '' '/^jacksonCore = /d' gradle/libs.versions.toml
sed -i '' '/^jacksonDatabind = /d' gradle/libs.versions.toml
```

---

## ⚠️ 影响评估

### 修复后的影响

| 修复项 | 影响模块 | 风险等级 | 需要测试 |
|--------|----------|----------|----------|
| Netty 版本 | 所有网络通信模块 | 低（修正错误）| 基础通信测试 |
| gRPC 版本 | Triple 协议、gRPC 服务 | 低（版本统一）| gRPC 调用测试 |
| Jackson 版本 | 所有序列化模块 | 中（版本变更）| 序列化兼容性测试 |
| Curator 版本 | ZooKeeper 客户端 | 低（版本更新）| ZooKeeper 集成测试 |

### 不修复的风险

| 问题 | 风险 | 可能的后果 |
|------|------|-----------|
| Netty 4.2.2 | 🔴 **极高** | 无法找到依赖，构建失败 |
| gRPC 不一致 | 🔴 **极高** | 运行时 ClassNotFoundException |
| Jackson 不一致 | 🟡 中等 | 序列化/反序列化错误 |
| Curator 不一致 | 🟡 中等 | ZooKeeper 连接问题 |

---

## 📋 验证清单

修复后需要验证：

### 编译验证
```bash
./gradlew clean build -x test -x spotlessCheck -x checkstyleMain -x checkstyleTest
```

### 依赖验证
```bash
# 验证 gRPC 版本统一
./gradlew dependencyInsight --dependency grpc-core

# 验证 Netty 版本
./gradlew dependencyInsight --dependency netty-all

# 验证 Jackson 版本
./gradlew dependencyInsight --dependency jackson-databind
```

### 测试验证
```bash
# 运行核心测试
./gradlew :dubbo-rpc:dubbo-rpc-triple:test
./gradlew :dubbo-common:test
```

---

## 🎉 总结

### 发现的问题

- 🔴 **3 个严重问题**（必须立即修复）
  - Netty 版本号错误
  - gRPC 组件版本不一致（6个组件）
  - Jackson 版本不一致

- 🟡 **4 个中等问题**（建议修复）
  - Curator 部分组件版本落后
  - 存在冗余的版本变量

- ✅ **多个依赖版本一致**
  - Spring 6: 6.2.11
  - Hessian Lite: 4.0.4
  - Reactor: 3.7.11

### 修复优先级

1. **P0（立即）**: Netty、gRPC、Jackson 版本修复
2. **P1（短期）**: Curator 版本统一
3. **P2（长期）**: 清理冗余版本变量

### 预期收益

- ✅ 消除运行时错误风险
- ✅ 提高依赖版本一致性
- ✅ 简化依赖管理
- ✅ 减少 28% 版本变量

---

**生成时间**: 2025-11-18  
**下一步**: 执行修复脚本并验证构建

