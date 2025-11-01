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

# 验证 Gradle 迁移完整性
# 对比 pom.xml 和 build.gradle，确保所有依赖都已迁移

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

REPORT_FILE="gradle-migration-verification-report.md"
ISSUES_FILE="gradle-migration-issues.txt"
MISSING_DEPS_FILE="missing-dependencies.csv"

echo "==================================="
echo "Gradle 迁移验证工具"
echo "==================================="
echo ""

# 初始化报告文件
cat > "$REPORT_FILE" <<'EOF'
# Gradle 迁移验证报告

生成时间: $(date '+%Y-%m-%d %H:%M:%S')

## 验证目标

验证所有包含 pom.xml 的模块，其对应的 build.gradle 是否包含了所有必要的依赖。

---

## 验证统计

EOF

# 初始化问题文件
echo "# 发现的问题列表" > "$ISSUES_FILE"
echo "" >> "$ISSUES_FILE"

# 初始化缺失依赖CSV
echo "模块路径,Maven依赖,在Gradle中是否存在,备注" > "$MISSING_DEPS_FILE"

# 计数器
TOTAL_MODULES=0
MODULES_WITH_GRADLE=0
MODULES_WITHOUT_GRADLE=0
MODULES_WITH_ISSUES=0
AGGREGATION_MODULES=0

# 存储有问题的模块
declare -a PROBLEMATIC_MODULES

echo "开始扫描项目..."
echo ""

# 查找所有包含 pom.xml 的目录
while IFS= read -r POM_FILE; do
    MODULE_DIR=$(dirname "$POM_FILE")
    MODULE_NAME=$(basename "$MODULE_DIR")
    GRADLE_FILE="$MODULE_DIR/build.gradle"
    
    ((TOTAL_MODULES++))
    
    echo "检查模块: $MODULE_DIR"
    
    # 检查是否是聚合模块（packaging=pom）
    IS_AGGREGATION=$(grep -c "<packaging>pom</packaging>" "$POM_FILE" || echo "0")
    
    if [ "$IS_AGGREGATION" -gt 0 ]; then
        ((AGGREGATION_MODULES++))
        echo "  ✓ 聚合模块（可能不需要 build.gradle）"
        continue
    fi
    
    # 检查是否有 build.gradle
    if [ ! -f "$GRADLE_FILE" ]; then
        ((MODULES_WITHOUT_GRADLE++))
        echo "  ✗ 缺失 build.gradle 文件！"
        echo "$MODULE_DIR" >> "$ISSUES_FILE"
        PROBLEMATIC_MODULES+=("$MODULE_DIR: 缺失 build.gradle")
        continue
    fi
    
    ((MODULES_WITH_GRADLE++))
    
    # 提取 pom.xml 中的依赖（排除 parent, test scope, optional）
    MAVEN_DEPS=$(grep -A 2 "<dependency>" "$POM_FILE" | \
                 grep -E "<groupId>|<artifactId>" | \
                 sed 's/<[^>]*>//g' | \
                 sed 's/^[ \t]*//' | \
                 paste -d ':' - - | \
                 grep -v "dubbo-parent" | \
                 sort -u || echo "")
    
    if [ -z "$MAVEN_DEPS" ]; then
        echo "  ✓ 无依赖声明（可能使用父POM管理）"
        continue
    fi
    
    # 读取 build.gradle 内容
    GRADLE_CONTENT=$(cat "$GRADLE_FILE")
    
    # 检查每个 Maven 依赖是否在 Gradle 中
    HAS_ISSUES=false
    while IFS= read -r DEP; do
        if [ -z "$DEP" ]; then
            continue
        fi
        
        GROUP_ID=$(echo "$DEP" | cut -d':' -f1)
        ARTIFACT_ID=$(echo "$DEP" | cut -d':' -f2)
        
        # 检查是否是项目内部依赖
        if [ "$GROUP_ID" == "org.apache.dubbo" ]; then
            # 转换为 Gradle project 引用格式
            # 如: dubbo-common -> project(':dubbo-common')
            if echo "$GRADLE_CONTENT" | grep -q "project.*$ARTIFACT_ID" || \
               echo "$GRADLE_CONTENT" | grep -q "$ARTIFACT_ID"; then
                echo "  ✓ 内部依赖: $ARTIFACT_ID"
            else
                echo "  ✗ 缺失内部依赖: $ARTIFACT_ID"
                echo "$MODULE_DIR,$GROUP_ID:$ARTIFACT_ID,否,内部依赖" >> "$MISSING_DEPS_FILE"
                HAS_ISSUES=true
            fi
        else
            # 外部依赖
            if echo "$GRADLE_CONTENT" | grep -q "$GROUP_ID.*$ARTIFACT_ID" || \
               echo "$GRADLE_CONTENT" | grep -q "$ARTIFACT_ID"; then
                echo "  ✓ 外部依赖: $GROUP_ID:$ARTIFACT_ID"
            else
                echo "  ⚠ 可能缺失外部依赖: $GROUP_ID:$ARTIFACT_ID"
                echo "$MODULE_DIR,$GROUP_ID:$ARTIFACT_ID,可能缺失,外部依赖" >> "$MISSING_DEPS_FILE"
                HAS_ISSUES=true
            fi
        fi
    done <<< "$MAVEN_DEPS"
    
    if [ "$HAS_ISSUES" = true ]; then
        ((MODULES_WITH_ISSUES++))
        PROBLEMATIC_MODULES+=("$MODULE_DIR: 存在缺失的依赖")
        echo "  ✗ 该模块存在依赖缺失问题"
    else
        echo "  ✓ 所有依赖已迁移"
    fi
    
    echo ""
    
done < <(find . -name "pom.xml" -not -path "*/target/*" -not -path "*/.mvn/*")

# 生成报告
cat >> "$REPORT_FILE" <<EOF

| 指标 | 数量 |
|------|------|
| 总模块数（包含pom.xml） | $TOTAL_MODULES |
| 聚合模块（packaging=pom） | $AGGREGATION_MODULES |
| 有 build.gradle 的模块 | $MODULES_WITH_GRADLE |
| 缺失 build.gradle 的模块 | $MODULES_WITHOUT_GRADLE |
| 存在依赖问题的模块 | $MODULES_WITH_ISSUES |

---

## 详细问题

EOF

if [ "$MODULES_WITH_ISSUES" -gt 0 ] || [ "$MODULES_WITHOUT_GRADLE" -gt 0 ]; then
    echo "### 发现以下问题：" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    for ISSUE in "${PROBLEMATIC_MODULES[@]}"; do
        echo "- ❌ $ISSUE" >> "$REPORT_FILE"
    done
    
    echo "" >> "$REPORT_FILE"
    echo "详细的缺失依赖列表请查看: \`$MISSING_DEPS_FILE\`" >> "$REPORT_FILE"
else
    echo "### ✅ 所有模块验证通过！" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "所有非聚合模块的依赖都已正确迁移到 Gradle。" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" <<EOF

---

## 建议

EOF

if [ "$MODULES_WITH_ISSUES" -eq 0 ] && [ "$MODULES_WITHOUT_GRADLE" -eq 0 ]; then
    cat >> "$REPORT_FILE" <<'EOF'
### ✅ 可以安全删除 pom.xml 文件

所有模块的依赖都已完整迁移到 Gradle。可以执行以下步骤：

1. **备份当前状态**
   ```bash
   git add -A
   git commit -m "chore: 迁移到 Gradle 完成，准备删除 pom.xml"
   ```

2. **删除 pom.xml 文件**
   ```bash
   # 删除所有 pom.xml（保留根目录的作为参考）
   find . -name "pom.xml" -not -path "./pom.xml" -delete
   
   # 或者只删除子模块的 pom.xml
   find ./dubbo-* -name "pom.xml" -delete
   ```

3. **删除 Maven 相关文件**
   ```bash
   rm -f mvnw mvnw.cmd
   rm -rf .mvn
   ```

4. **验证构建**
   ```bash
   ./gradlew clean build -x test
   ```

5. **提交更改**
   ```bash
   git add -A
   git commit -m "chore: 移除 Maven pom.xml 文件，完全迁移到 Gradle"
   ```

EOF
else
    cat >> "$REPORT_FILE" <<'EOF'
### ⚠️ 暂时不要删除 pom.xml

发现以下问题需要先解决：

1. **补全缺失的 build.gradle**
   - 为缺失 build.gradle 的模块创建构建文件
   - 参考同类型模块的 build.gradle

2. **补全缺失的依赖**
   - 检查 `missing-dependencies.csv` 文件
   - 将缺失的依赖添加到对应的 build.gradle

3. **验证修复**
   - 修复后重新运行此脚本
   - 确保所有问题都已解决

4. **测试构建**
   ```bash
   ./gradlew clean build
   ```

EOF
fi

cat >> "$REPORT_FILE" <<EOF

---

## 附加检查项

### Maven 特有配置需要手动迁移

以下 Maven 特性需要手动检查是否已在 Gradle 中实现：

- [ ] `<build>` 插件配置
- [ ] `<profiles>` 配置文件
- [ ] `<properties>` 自定义属性
- [ ] `<resources>` 资源过滤
- [ ] `<repositories>` 自定义仓库
- [ ] `<dependencyManagement>` 依赖管理

### 推荐的后续步骤

1. 运行完整的测试套件：
   \`\`\`bash
   ./gradlew test
   \`\`\`

2. 检查所有模块是否可以正常发布：
   \`\`\`bash
   ./gradlew publishToMavenLocal
   \`\`\`

3. 更新 CI/CD 配置，移除对 Maven 的依赖

4. 更新项目文档，说明已切换到 Gradle

---

生成时间: $(date '+%Y-%m-%d %H:%M:%S')
EOF

# 输出总结
echo "==================================="
echo "验证完成！"
echo "==================================="
echo ""
echo "统计信息："
echo "  - 总模块数: $TOTAL_MODULES"
echo "  - 聚合模块: $AGGREGATION_MODULES"
echo "  - 有 build.gradle: $MODULES_WITH_GRADLE"
echo "  - 缺失 build.gradle: $MODULES_WITHOUT_GRADLE"
echo "  - 有依赖问题: $MODULES_WITH_ISSUES"
echo ""

if [ "$MODULES_WITH_ISSUES" -eq 0 ] && [ "$MODULES_WITHOUT_GRADLE" -eq 0 ]; then
    echo "✅ 验证通过！可以安全删除 pom.xml 文件。"
    echo ""
    echo "详细报告已生成: $REPORT_FILE"
    exit 0
else
    echo "⚠️  发现问题！请先解决以下问题："
    echo ""
    for ISSUE in "${PROBLEMATIC_MODULES[@]}"; do
        echo "  - $ISSUE"
    done
    echo ""
    echo "详细报告已生成:"
    echo "  - $REPORT_FILE"
    echo "  - $MISSING_DEPS_FILE"
    echo ""
    exit 1
fi

