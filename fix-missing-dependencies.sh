#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# 修复缺失的依赖

set -e

echo "==================================="
echo "修复缺失的 Gradle 依赖"
echo "==================================="
echo ""

# 1. dubbo-compatible
echo "[1/12] 修复 dubbo-compatible..."
cat >> dubbo-compatible/build.gradle <<'EOF'

    // 补全缺失的依赖
    compileOnly "javax.ws.rs:javax.ws.rs-api:${rsApiVersion}"
EOF
echo "✓ 已添加 javax.ws.rs:javax.ws.rs-api"

# 2. dubbo-config-spring6
echo "[2/12] 修复 dubbo-config/dubbo-config-spring6..."
cat >> dubbo-config/dubbo-config-spring6/build.gradle <<'EOF'

    // 补全缺失的依赖
    compileOnly "jakarta.servlet:jakarta.servlet-api:${jakartaServletApiVersion}"
EOF
echo "✓ 已添加 jakarta.servlet:jakarta.servlet-api"

# 3. dubbo-compiler
echo "[3/12] 修复 dubbo-plugin/dubbo-compiler..."
cat >> dubbo-plugin/dubbo-compiler/build.gradle <<'EOF'

    // 补全缺失的依赖
    implementation "com.salesforce.servicelibs:grpc-contrib:${grpcContribVersion}"
EOF
echo "✓ 已添加 com.salesforce.servicelibs:grpc-contrib"

# 4. dubbo-reactive
echo "[4/12] 修复 dubbo-plugin/dubbo-reactive..."
cat >> dubbo-plugin/dubbo-reactive/build.gradle <<'EOF'

    // 补全缺失的依赖
    compileOnly "io.projectreactor:reactor-core:${reactorVersion}"
EOF
echo "✓ 已添加 io.projectreactor:reactor-core"

# 5. dubbo-triple-servlet
echo "[5/12] 修复 dubbo-plugin/dubbo-triple-servlet..."
cat >> dubbo-plugin/dubbo-triple-servlet/build.gradle <<'EOF'

    // 补全缺失的依赖 (已有 jakarta，补充 javax)
    compileOnly "javax.servlet:javax.servlet-api:${javaxServletApiVersion}"
EOF
echo "✓ 已添加 javax.servlet:javax.servlet-api"

# 6. dubbo-metrics-prometheus
echo "[6/12] 修复 dubbo-metrics/dubbo-metrics-prometheus..."
cat >> dubbo-metrics/dubbo-metrics-prometheus/build.gradle <<'EOF'

    // 补全缺失的依赖
    implementation "io.micrometer:micrometer-registry-prometheus-simpleclient:${micrometerRegistryPrometheusSimpleclientVersion}"
EOF
echo "✓ 已添加 io.micrometer:micrometer-registry-prometheus-simpleclient"

# 7. dubbo-remoting-netty4
echo "[7/12] 修复 dubbo-remoting/dubbo-remoting-netty4..."
cat >> dubbo-remoting/dubbo-remoting-netty4/build.gradle <<'EOF'

    // 补全缺失的依赖
    compileOnly "io.netty:netty-transport-classes-epoll:${nettyVersion}"
    runtimeOnly "io.netty:netty-transport-native-epoll:${nettyVersion}:linux-x86_64"
    implementation "io.netty:netty-codec-http2:${nettyCodecHttp2Version}"
    implementation "io.netty:netty-handler-proxy:${nettyVersion}"
EOF
echo "✓ 已添加 netty 相关依赖"

# 8. dubbo-remoting-http3
echo "[8/12] 修复 dubbo-remoting/dubbo-remoting-http3..."
cat >> dubbo-remoting/dubbo-remoting-http3/build.gradle <<'EOF'

    // 补全缺失的依赖
    implementation "io.netty.incubator:netty-incubator-codec-http3:${nettyCodecHttp3Version}"
EOF
echo "✓ 已添加 io.netty.incubator:netty-incubator-codec-http3"

# 9. dubbo-dependencies-all
echo "[9/12] 修复 dubbo-test/dubbo-dependencies-all..."
cat >> dubbo-test/dubbo-dependencies-all/build.gradle <<'EOF'

    // 补全缺失的内部模块依赖 (Spring Boot 1.x 兼容模块)
    api project(':dubbo-spring-boot-project:dubbo-spring-boot-compatible:dubbo-spring-boot-actuator-autoconfigure-compatible')
    api project(':dubbo-spring-boot-project:dubbo-spring-boot-compatible:dubbo-spring-boot-autoconfigure-compatible')
EOF
echo "✓ 已添加 Spring Boot 兼容模块"

# 10. dubbo-test-spring
echo "[10/12] 修复 dubbo-test/dubbo-test-spring..."
# 这个模块使用 BOM（import），在 Gradle 中不需要显式声明
echo "✓ 跳过 (BOM 依赖，Gradle 自动处理)"

# 11. dubbo-spring-boot-3-autoconfigure
echo "[11/12] 修复 dubbo-spring-boot-project/dubbo-spring-boot-3-autoconfigure..."
# 这个也是 BOM 依赖，不需要显式声明
echo "✓ 跳过 (BOM 依赖，Gradle 自动处理)"

# 12. dubbo-rpc-api
echo "[12/12] 修复 dubbo-rpc/dubbo-rpc-api..."
cat >> dubbo-rpc/dubbo-rpc-api/build.gradle <<'EOF'

    // 补全缺失的依赖
    api project(':dubbo-common')
EOF
echo "✓ 已添加 dubbo-common 依赖"

echo ""
echo "==================================="
echo "修复完成！"
echo "==================================="
echo ""
echo "下一步："
echo "1. 重新运行验证: python3 verify-dependencies.py"
echo "2. 测试构建: ./gradlew clean build -x test"
echo "3. 如果一切正常，可以安全删除 pom.xml"
echo ""

