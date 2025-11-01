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

# 修复缺失的依赖 - 正确插入到 dependencies 块中

set -e

echo "==================================="
echo "修复缺失的 Gradle 依赖 (v2)"
echo "==================================="
echo ""

# 辅助函数：在 dependencies 块的最后一个依赖之前插入新依赖
add_dependency() {
    local file="$1"
    local dep="$2"
    local comment="$3"
    
    # 查找最后一个 } 之前插入
    if grep -q "^}" "$file"; then
        # 使用 sed 在最后一个 } 之前插入
        sed -i.bak "/^}$/i\\
    $dep  // $comment
" "$file"
        rm -f "${file}.bak"
        echo "  ✓ 添加: $dep"
    else
        echo "  ✗ 无法找到 dependencies 块结束位置"
    fi
}

# 1. 清理之前错误添加的内容
echo "[0/12] 清理之前的错误添加..."

for file in \
    dubbo-compatible/build.gradle \
    dubbo-config/dubbo-config-spring6/build.gradle \
    dubbo-plugin/dubbo-compiler/build.gradle \
    dubbo-plugin/dubbo-reactive/build.gradle \
    dubbo-plugin/dubbo-triple-servlet/build.gradle \
    dubbo-metrics/dubbo-metrics-prometheus/build.gradle \
    dubbo-remoting/dubbo-remoting-netty4/build.gradle \
    dubbo-remoting/dubbo-remoting-http3/build.gradle \
    dubbo-test/dubbo-dependencies-all/build.gradle \
    dubbo-rpc/dubbo-rpc-api/build.gradle; do
    if [ -f "$file" ]; then
        # 删除之前添加的注释行和之后的内容
        sed -i.bak '/\/\/ 补全缺失的依赖/,$d' "$file"
        rm -f "${file}.bak"
    fi
done
echo "✓ 清理完成"

# 2. 重新添加依赖（使用Python脚本更可靠）
echo ""
echo "使用 Python 脚本精确添加依赖..."

cat > /tmp/fix_gradle_deps.py <<'PYTHON_SCRIPT'
#!/usr/bin/env python3
import re

def add_dependency_to_gradle(file_path, new_deps, comment=""):
    """在 dependencies 块的最后添加新依赖"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 找到 dependencies 块
    pattern = r'(dependencies\s*\{)(.*?)(\n\})'
    
    def replacer(match):
        deps_block = match.group(2)
        # 在最后一个依赖后添加新依赖
        new_content = deps_block.rstrip()
        if comment:
            new_content += f"\n\n    // {comment}"
        for dep in new_deps:
            new_content += f"\n    {dep}"
        return match.group(1) + new_content + match.group(3)
    
    new_content = re.sub(pattern, replacer, content, flags=re.DOTALL)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

# 修复各个模块
fixes = [
    ('dubbo-compatible/build.gradle', 
     ['compileOnly "javax.ws.rs:javax.ws.rs-api:${rsApiVersion}"'],
     '补全缺失的依赖'),
    
    ('dubbo-config/dubbo-config-spring6/build.gradle',
     ['compileOnly "jakarta.servlet:jakarta.servlet-api:${jakartaServletApiVersion}"',
      'compileOnly "javax.servlet:javax.servlet-api:${javaxServletApiVersion}"'],
     '补全缺失的依赖（同时支持 javax 和 jakarta）'),
    
    ('dubbo-plugin/dubbo-compiler/build.gradle',
     ['implementation "com.salesforce.servicelibs:grpc-contrib:${grpcContribVersion}"'],
     '补全缺失的依赖'),
    
    ('dubbo-plugin/dubbo-reactive/build.gradle',
     ['compileOnly "io.projectreactor:reactor-core:${reactorVersion}"'],
     '补全缺失的依赖'),
    
    ('dubbo-plugin/dubbo-triple-servlet/build.gradle',
     ['compileOnly "javax.servlet:javax.servlet-api:${javaxServletApiVersion}"'],
     '补全缺失的依赖'),
    
    ('dubbo-metrics/dubbo-metrics-prometheus/build.gradle',
     ['implementation "io.micrometer:micrometer-registry-prometheus-simpleclient:${micrometerRegistryPrometheusSimpleclientVersion}"'],
     '补全缺失的依赖'),
    
    ('dubbo-remoting/dubbo-remoting-netty4/build.gradle',
     ['compileOnly "io.netty:netty-transport-classes-epoll:${nettyVersion}"',
      'runtimeOnly "io.netty:netty-transport-native-epoll:${nettyVersion}:linux-x86_64"',
      'implementation "io.netty:netty-codec-http2:${nettyCodecHttp2Version}"',
      'implementation "io.netty:netty-handler-proxy:${nettyHandlerVersion}"'],
     '补全缺失的依赖'),
    
    ('dubbo-remoting/dubbo-remoting-http3/build.gradle',
     ['implementation "io.netty.incubator:netty-incubator-codec-http3:${nettyCodecHttp3Version}"'],
     '补全缺失的依赖'),
    
    ('dubbo-test/dubbo-dependencies-all/build.gradle',
     ['api project(\':dubbo-spring-boot-project:dubbo-spring-boot-compatible:dubbo-spring-boot-actuator-autoconfigure-compatible\')',
      'api project(\':dubbo-spring-boot-project:dubbo-spring-boot-compatible:dubbo-spring-boot-autoconfigure-compatible\')'],
     '补全缺失的内部模块依赖'),
    
    ('dubbo-rpc/dubbo-rpc-api/build.gradle',
     ['api project(\':dubbo-common\')'],
     '补全缺失的依赖'),
]

for file_path, deps, comment in fixes:
    try:
        add_dependency_to_gradle(file_path, deps, comment)
        print(f"✓ {file_path}")
    except Exception as e:
        print(f"✗ {file_path}: {e}")

print("\n所有依赖已添加！")
PYTHON_SCRIPT

cd /Users/admin/IdeaProjects/dubbo
python3 /tmp/fix_gradle_deps.py

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

