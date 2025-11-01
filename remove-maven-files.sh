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

# Maven 文件清理脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "============================================="
echo "Dubbo Maven 文件清理工具"
echo "============================================="
echo ""

# 显示菜单
echo "请选择清理方案："
echo ""
echo "1. 保守方案 - 保留根 pom.xml，删除子模块的 pom.xml"
echo "2. 归档方案 - 将所有 Maven 文件移动到 .archive/maven/"
echo "3. 完全删除 - 删除所有 Maven 相关文件（不可恢复）"
echo "4. 仅删除 target 目录"
echo "5. 取消"
echo ""
read -p "请输入选项 (1-5): " choice

case $choice in
    1)
        echo ""
        echo "============================================="
        echo "方案 1: 保守删除"
        echo "============================================="
        echo ""
        echo "将删除："
        echo "  - 所有子模块的 pom.xml"
        echo "  - mvnw, mvnw.cmd"
        echo "  - .mvn 目录"
        echo "  - 所有 target 目录"
        echo ""
        echo "将保留："
        echo "  - 根目录的 pom.xml"
        echo ""
        read -p "确认继续？ (y/n): " confirm
        
        if [ "$confirm" != "y" ]; then
            echo "已取消"
            exit 0
        fi
        
        echo ""
        echo "正在删除子模块的 pom.xml..."
        find . -name "pom.xml" -not -path "./pom.xml" -not -path "./target/*" -not -path "./.mvn/*" -delete
        echo "✓ 已删除子模块 pom.xml"
        
        echo "正在删除 Maven Wrapper..."
        rm -f mvnw mvnw.cmd
        rm -rf .mvn
        echo "✓ 已删除 Maven Wrapper"
        
        echo "正在删除 target 目录..."
        find . -type d -name "target" -exec rm -rf {} + 2>/dev/null || true
        echo "✓ 已删除 target 目录"
        
        echo ""
        echo "✅ 完成！根目录的 pom.xml 已保留。"
        ;;
        
    2)
        echo ""
        echo "============================================="
        echo "方案 2: 归档到 .archive/maven/"
        echo "============================================="
        echo ""
        read -p "确认继续？ (y/n): " confirm
        
        if [ "$confirm" != "y" ]; then
            echo "已取消"
            exit 0
        fi
        
        echo ""
        echo "创建归档目录..."
        mkdir -p .archive/maven
        
        echo "归档 pom.xml 文件..."
        find . -name "pom.xml" -not -path "./.archive/*" -not -path "./target/*" | while read file; do
            rel_path="${file#./}"
            target_dir=".archive/maven/$(dirname "$rel_path")"
            mkdir -p "$target_dir"
            mv "$file" "$target_dir/"
            echo "  归档: $rel_path"
        done
        
        echo "归档 Maven Wrapper..."
        if [ -f "mvnw" ]; then mv mvnw .archive/maven/; fi
        if [ -f "mvnw.cmd" ]; then mv mvnw.cmd .archive/maven/; fi
        if [ -d ".mvn" ]; then mv .mvn .archive/maven/; fi
        
        echo "归档 target 目录..."
        find . -type d -name "target" -not -path "./.archive/*" | while read dir; do
            rel_path="${dir#./}"
            target_dir=".archive/maven/$(dirname "$rel_path")"
            mkdir -p "$target_dir"
            mv "$dir" "$target_dir/" 2>/dev/null || true
            echo "  归档: $rel_path"
        done
        
        echo ""
        echo "✅ 完成！所有 Maven 文件已归档到 .archive/maven/"
        echo ""
        echo "如需恢复，可以从归档目录中复制回来。"
        ;;
        
    3)
        echo ""
        echo "============================================="
        echo "方案 3: 完全删除"
        echo "============================================="
        echo ""
        echo "⚠️  警告：这将永久删除所有 Maven 文件！"
        echo ""
        read -p "确认继续？ (yes/no): " confirm
        
        if [ "$confirm" != "yes" ]; then
            echo "已取消"
            exit 0
        fi
        
        echo ""
        echo "正在删除所有 pom.xml..."
        find . -name "pom.xml" -not -path "./target/*" -not -path "./.mvn/*" -delete
        echo "✓ 已删除所有 pom.xml"
        
        echo "正在删除 Maven Wrapper..."
        rm -f mvnw mvnw.cmd
        rm -rf .mvn
        echo "✓ 已删除 Maven Wrapper"
        
        echo "正在删除 target 目录..."
        find . -type d -name "target" -exec rm -rf {} + 2>/dev/null || true
        echo "✓ 已删除 target 目录"
        
        echo ""
        echo "✅ 完成！所有 Maven 文件已删除。"
        ;;
        
    4)
        echo ""
        echo "============================================="
        echo "方案 4: 仅删除 target 目录"
        echo "============================================="
        echo ""
        read -p "确认继续？ (y/n): " confirm
        
        if [ "$confirm" != "y" ]; then
            echo "已取消"
            exit 0
        fi
        
        echo ""
        echo "正在删除 target 目录..."
        find . -type d -name "target" -exec rm -rf {} + 2>/dev/null || true
        echo "✓ 已删除 target 目录"
        
        echo ""
        echo "✅ 完成！"
        ;;
        
    5)
        echo "已取消"
        exit 0
        ;;
        
    *)
        echo "无效选项"
        exit 1
        ;;
esac

echo ""
echo "============================================="
echo "下一步建议"
echo "============================================="
echo ""
echo "1. 验证 Gradle 构建："
echo "   ./gradlew clean build -x test"
echo ""
echo "2. 运行测试："
echo "   ./gradlew test"
echo ""
echo "3. 提交更改："
echo "   git add -A"
echo "   git commit -m 'chore: remove Maven files, fully migrated to Gradle'"
echo ""

