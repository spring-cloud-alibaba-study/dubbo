# Gradle 迁移依赖验证报告

生成时间: 2025-11-01 12:53:27

## 📊 统计信息

| 指标 | 数量 |
|------|------|
| 总模块数 | 118 |
| 聚合模块（可忽略） | 18 |
| 有 build.gradle 的模块 | 100 |
| 缺失 build.gradle 的模块 | 0 |
| 存在依赖问题的模块 | 4 |

## ❌ 发现的问题

### /Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-reactive

- ❌ 缺失依赖: io.projectreactor:reactor-core

**缺失的依赖:**

- `io.projectreactor:reactor-core`

### /Users/admin/IdeaProjects/dubbo/dubbo-remoting/dubbo-remoting-http3

- ❌ 缺失依赖: io.netty:netty-codec-http3

**缺失的依赖:**

- `io.netty:netty-codec-http3`

### /Users/admin/IdeaProjects/dubbo/dubbo-test/dubbo-test-spring

- ❌ 缺失依赖: org.springframework:spring-framework-bom:import

**缺失的依赖:**

- `org.springframework:spring-framework-bom`

### /Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-3-autoconfigure

- ❌ 缺失依赖: org.springframework.boot:spring-boot-dependencies:import

**缺失的依赖:**

- `org.springframework.boot:spring-boot-dependencies`

## 🔧 修复建议

1. 为缺失 build.gradle 的模块创建构建文件
2. 将缺失的依赖添加到对应的 build.gradle 中
3. 运行测试验证: `./gradlew test`
4. 重新运行此验证脚本确认修复

## 📝 详细模块列表

### 有问题的模块 (4)

- ❌ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-reactive` (3 个依赖)
- ❌ `/Users/admin/IdeaProjects/dubbo/dubbo-remoting/dubbo-remoting-http3` (3 个依赖)
- ❌ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-3-autoconfigure` (1 个依赖)
- ❌ `/Users/admin/IdeaProjects/dubbo/dubbo-test/dubbo-test-spring` (1 个依赖)

### 正常模块 (96)

- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-cluster` (3 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-common` (9 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-compatible` (7 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-config/dubbo-config-api` (11 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-config/dubbo-config-spring` (5 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-config/dubbo-config-spring6` (7 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-configcenter/dubbo-configcenter-apollo` (6 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-configcenter/dubbo-configcenter-file` (5 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-configcenter/dubbo-configcenter-nacos` (6 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-configcenter/dubbo-configcenter-zookeeper` (7 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-demo/dubbo-demo-api/dubbo-demo-api-consumer` (9 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-demo/dubbo-demo-api/dubbo-demo-api-interface`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-demo/dubbo-demo-api/dubbo-demo-api-provider` (9 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-demo/dubbo-demo-mcp-server` (12 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-demo/dubbo-demo-spring-boot-idl/dubbo-demo-spring-boot-idl-consumer`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-demo/dubbo-demo-spring-boot-idl/dubbo-demo-spring-boot-idl-provider`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-demo/dubbo-demo-spring-boot/dubbo-demo-spring-boot-consumer` (10 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-demo/dubbo-demo-spring-boot/dubbo-demo-spring-boot-interface`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-demo/dubbo-demo-spring-boot/dubbo-demo-spring-boot-provider` (10 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-demo/dubbo-demo-spring-boot/dubbo-demo-spring-boot-servlet` (11 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-distribution/dubbo-all` (6 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-distribution/dubbo-all-shaded` (6 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-distribution/dubbo-core-spi`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-maven-plugin` (8 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-metadata/dubbo-metadata-api` (7 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-metadata/dubbo-metadata-definition-protobuf` (3 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-metadata/dubbo-metadata-processor` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-metadata/dubbo-metadata-report-nacos` (2 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-metadata/dubbo-metadata-report-zookeeper` (3 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-metrics/dubbo-metrics-api` (5 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-metrics/dubbo-metrics-config-center` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-metrics/dubbo-metrics-default` (2 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-metrics/dubbo-metrics-event` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-metrics/dubbo-metrics-metadata` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-metrics/dubbo-metrics-netty` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-metrics/dubbo-metrics-prometheus` (5 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-metrics/dubbo-metrics-registry` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-metrics/dubbo-tracing` (6 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-auth` (2 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-compiler` (6 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-filter-cache` (2 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-filter-validation` (3 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-mcp` (5 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-mutiny` (2 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-native` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-plugin-loom`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-qos` (11 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-qos-api` (2 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-rest-jaxrs` (3 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-rest-openapi` (6 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-rest-spring` (6 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-security` (10 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-spring-security` (7 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-spring6-security` (12 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-triple-servlet` (3 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-plugin/dubbo-triple-websocket` (7 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-registry/dubbo-registry-api` (8 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-registry/dubbo-registry-multicast` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-registry/dubbo-registry-multiple` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-registry/dubbo-registry-nacos` (3 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-registry/dubbo-registry-zookeeper` (3 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-remoting/dubbo-remoting-api` (2 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-remoting/dubbo-remoting-http12` (9 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-remoting/dubbo-remoting-netty` (2 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-remoting/dubbo-remoting-netty4` (8 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-remoting/dubbo-remoting-websocket` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-remoting/dubbo-remoting-zookeeper-curator5` (5 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-rpc/dubbo-rpc-api` (4 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-rpc/dubbo-rpc-dubbo` (3 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-rpc/dubbo-rpc-injvm` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-rpc/dubbo-rpc-triple` (3 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-serialization/dubbo-serialization-api` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-serialization/dubbo-serialization-fastjson2` (2 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-serialization/dubbo-serialization-hessian2` (3 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-actuator` (3 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-actuator-autoconfigure` (4 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-autoconfigure` (13 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-compatible/dubbo-spring-boot-actuator-autoconfigure-compatible` (3 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-compatible/dubbo-spring-boot-autoconfigure-compatible` (3 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-starters/dubbo-nacos-spring-boot-starter` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-starters/dubbo-observability-spring-boot-starter` (2 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-starters/dubbo-seata-spring-boot-starter` (3 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-starters/dubbo-sentinel-spring-boot-starter` (2 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-starters/dubbo-spring-boot-starter` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-starters/dubbo-tracing-brave-zipkin-spring-boot-starter` (5 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-starters/dubbo-tracing-otel-otlp-spring-boot-starter` (3 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-starters/dubbo-tracing-otel-zipkin-spring-boot-starter` (3 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-starters/dubbo-zookeeper-curator5-spring-boot-starter` (2 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-test/dubbo-dependencies-all` (81 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-test/dubbo-test-check` (9 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-test/dubbo-test-common` (6 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-test/dubbo-test-modules` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-test/dubbo-test-spring3.2` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-test/dubbo-test-spring4.1` (1 个依赖)
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-test/dubbo-test-spring4.2` (1 个依赖)

### 聚合模块 (18)

- ✅ `/Users/admin/IdeaProjects/dubbo`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-config`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-configcenter`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-demo/dubbo-demo-api`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-demo/dubbo-demo-spring-boot`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-demo/dubbo-demo-spring-boot-idl`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-dependencies-bom`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-distribution/dubbo-apache-release`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-distribution/dubbo-bom`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-metadata`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-metrics`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-registry`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-remoting`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-rpc`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-serialization`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-compatible`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-spring-boot-project/dubbo-spring-boot-starters`
- ✅ `/Users/admin/IdeaProjects/dubbo/dubbo-test`

---

*报告生成时间: 2025-11-01 12:53:27*
