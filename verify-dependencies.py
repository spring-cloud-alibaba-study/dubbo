#!/usr/bin/env python3
# -*- coding: utf-8 -*-
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

"""
Gradle 迁移依赖验证工具（Python 版）
精确对比 pom.xml 和 build.gradle 中的依赖声明
"""

import os
import re
import xml.etree.ElementTree as ET
from pathlib import Path
from collections import defaultdict
from typing import List, Dict, Set, Tuple

# Maven 命名空间
MAVEN_NS = {'mvn': 'http://maven.apache.org/POM/4.0.0'}

class Dependency:
    def __init__(self, group_id: str, artifact_id: str, version: str = None, scope: str = 'compile'):
        self.group_id = group_id
        self.artifact_id = artifact_id
        self.version = version
        self.scope = scope
    
    def __repr__(self):
        return f"{self.group_id}:{self.artifact_id}" + (f":{self.scope}" if self.scope != 'compile' else "")
    
    def __eq__(self, other):
        return self.group_id == other.group_id and self.artifact_id == other.artifact_id
    
    def __hash__(self):
        return hash((self.group_id, self.artifact_id))

class ModuleAnalysis:
    def __init__(self, path: str):
        self.path = path
        self.name = os.path.basename(path)
        self.has_pom = False
        self.has_gradle = False
        self.is_aggregation = False
        self.maven_deps: Set[Dependency] = set()
        self.gradle_deps: Set[Dependency] = set()
        self.missing_deps: Set[Dependency] = set()
        self.issues: List[str] = []

def parse_pom_dependencies(pom_path: str) -> Tuple[Set[Dependency], bool]:
    """解析 pom.xml 中的依赖"""
    dependencies = set()
    is_aggregation = False
    
    try:
        tree = ET.parse(pom_path)
        root = tree.getroot()
        
        # 检查是否是聚合模块
        packaging = root.find('.//mvn:packaging', MAVEN_NS)
        if packaging is not None and packaging.text == 'pom':
            is_aggregation = True
            return dependencies, is_aggregation
        
        # 解析依赖
        deps_section = root.find('.//mvn:dependencies', MAVEN_NS)
        if deps_section is not None:
            for dep in deps_section.findall('mvn:dependency', MAVEN_NS):
                group_id = dep.find('mvn:groupId', MAVEN_NS)
                artifact_id = dep.find('mvn:artifactId', MAVEN_NS)
                version = dep.find('mvn:version', MAVEN_NS)
                scope = dep.find('mvn:scope', MAVEN_NS)
                optional = dep.find('mvn:optional', MAVEN_NS)
                
                # 跳过 test 和 optional 依赖
                if scope is not None and scope.text == 'test':
                    continue
                if optional is not None and optional.text == 'true':
                    continue
                
                if group_id is not None and artifact_id is not None:
                    dep_obj = Dependency(
                        group_id.text,
                        artifact_id.text,
                        version.text if version is not None else None,
                        scope.text if scope is not None else 'compile'
                    )
                    dependencies.add(dep_obj)
        
    except ET.ParseError as e:
        print(f"  ⚠️  解析 pom.xml 失败: {e}")
    except Exception as e:
        print(f"  ⚠️  读取 pom.xml 出错: {e}")
    
    return dependencies, is_aggregation

def parse_gradle_dependencies(gradle_path: str) -> Set[Dependency]:
    """解析 build.gradle 中的依赖"""
    dependencies = set()
    
    try:
        with open(gradle_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 匹配各种 Gradle 依赖格式
        patterns = [
            # implementation 'group:artifact:version'
            r'(implementation|api|compileOnly|runtimeOnly)\s+["\']([^:"\']+):([^:"\']+)(?::([^"\']+))?["\']',
            # implementation group: 'x', name: 'y', version: 'z'
            r'(implementation|api|compileOnly|runtimeOnly)\s+group:\s*["\']([^"\']+)["\'],\s*name:\s*["\']([^"\']+)["\']',
            # project(':module-name') - 提取模块名
            r'(implementation|api|compileOnly|runtimeOnly)\s+project\(["\']:([^"\']+)["\']',
        ]
        
        for pattern in patterns:
            matches = re.finditer(pattern, content)
            for match in matches:
                if 'project' in match.group(0):
                    # 项目内部依赖
                    module_path = match.group(2)
                    artifact_id = module_path.split(':')[-1]
                    dep = Dependency('org.apache.dubbo', artifact_id)
                    dependencies.add(dep)
                else:
                    # 外部依赖
                    group_id = match.group(2)
                    artifact_id = match.group(3)
                    dep = Dependency(group_id, artifact_id)
                    dependencies.add(dep)
        
    except Exception as e:
        print(f"  ⚠️  读取 build.gradle 出错: {e}")
    
    return dependencies

def analyze_module(module_path: str) -> ModuleAnalysis:
    """分析单个模块"""
    analysis = ModuleAnalysis(module_path)
    
    pom_path = os.path.join(module_path, 'pom.xml')
    gradle_path = os.path.join(module_path, 'build.gradle')
    
    analysis.has_pom = os.path.exists(pom_path)
    analysis.has_gradle = os.path.exists(gradle_path)
    
    if not analysis.has_pom:
        return analysis
    
    # 解析 pom.xml
    analysis.maven_deps, analysis.is_aggregation = parse_pom_dependencies(pom_path)
    
    # 聚合模块不需要 build.gradle
    if analysis.is_aggregation:
        return analysis
    
    # 检查 build.gradle
    if not analysis.has_gradle:
        analysis.issues.append("缺失 build.gradle 文件")
        analysis.missing_deps = analysis.maven_deps
        return analysis
    
    # 解析 build.gradle
    analysis.gradle_deps = parse_gradle_dependencies(gradle_path)
    
    # 对比依赖
    for maven_dep in analysis.maven_deps:
        found = False
        for gradle_dep in analysis.gradle_deps:
            if maven_dep.artifact_id == gradle_dep.artifact_id:
                found = True
                # 检查 groupId 是否匹配
                if maven_dep.group_id != gradle_dep.group_id and \
                   not (maven_dep.group_id == 'org.apache.dubbo' and gradle_dep.group_id == 'org.apache.dubbo'):
                    analysis.issues.append(f"依赖 {maven_dep.artifact_id} 的 groupId 不匹配: Maven={maven_dep.group_id}, Gradle={gradle_dep.group_id}")
                break
        
        if not found:
            analysis.missing_deps.add(maven_dep)
            analysis.issues.append(f"缺失依赖: {maven_dep}")
    
    return analysis

def generate_report(analyses: List[ModuleAnalysis], output_file: str):
    """生成验证报告"""
    
    total = len(analyses)
    aggregation_count = sum(1 for a in analyses if a.is_aggregation)
    with_gradle = sum(1 for a in analyses if a.has_gradle and not a.is_aggregation)
    without_gradle = sum(1 for a in analyses if not a.has_gradle and not a.is_aggregation)
    with_issues = sum(1 for a in analyses if a.issues and not a.is_aggregation)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("# Gradle 迁移依赖验证报告\n\n")
        f.write(f"生成时间: {import_datetime()}\n\n")
        
        f.write("## 📊 统计信息\n\n")
        f.write("| 指标 | 数量 |\n")
        f.write("|------|------|\n")
        f.write(f"| 总模块数 | {total} |\n")
        f.write(f"| 聚合模块（可忽略） | {aggregation_count} |\n")
        f.write(f"| 有 build.gradle 的模块 | {with_gradle} |\n")
        f.write(f"| 缺失 build.gradle 的模块 | {without_gradle} |\n")
        f.write(f"| 存在依赖问题的模块 | {with_issues} |\n\n")
        
        if with_issues > 0 or without_gradle > 0:
            f.write("## ❌ 发现的问题\n\n")
            
            for analysis in analyses:
                if analysis.is_aggregation:
                    continue
                if analysis.issues:
                    f.write(f"### {analysis.path}\n\n")
                    for issue in analysis.issues:
                        f.write(f"- ❌ {issue}\n")
                    f.write("\n")
                    
                    if analysis.missing_deps:
                        f.write("**缺失的依赖:**\n\n")
                        for dep in sorted(analysis.missing_deps, key=lambda d: d.artifact_id):
                            f.write(f"- `{dep.group_id}:{dep.artifact_id}`\n")
                        f.write("\n")
            
            f.write("## 🔧 修复建议\n\n")
            f.write("1. 为缺失 build.gradle 的模块创建构建文件\n")
            f.write("2. 将缺失的依赖添加到对应的 build.gradle 中\n")
            f.write("3. 运行测试验证: `./gradlew test`\n")
            f.write("4. 重新运行此验证脚本确认修复\n\n")
            
        else:
            f.write("## ✅ 验证通过！\n\n")
            f.write("所有模块的依赖都已正确迁移到 Gradle。\n\n")
            
            f.write("## 🗑️ 可以安全删除 pom.xml\n\n")
            f.write("### 方案 1: 保留根 pom.xml，删除子模块的\n\n")
            f.write("```bash\n")
            f.write("# 删除子模块的 pom.xml\n")
            f.write("find ./dubbo-* -name 'pom.xml' -type f -delete\n")
            f.write("find ./buildSrc -name 'pom.xml' -type f -delete\n")
            f.write("```\n\n")
            
            f.write("### 方案 2: 删除所有 pom.xml\n\n")
            f.write("```bash\n")
            f.write("# 删除所有 pom.xml（不推荐，保留根 pom.xml 有助于参考）\n")
            f.write("find . -name 'pom.xml' -not -path './target/*' -delete\n")
            f.write("```\n\n")
            
            f.write("### 方案 3: 移动到归档目录（最保险）\n\n")
            f.write("```bash\n")
            f.write("# 创建归档目录\n")
            f.write("mkdir -p .archive/maven-poms\n\n")
            f.write("# 移动所有 pom.xml 到归档\n")
            f.write("find . -name 'pom.xml' -not -path './target/*' -not -path './.archive/*' -exec sh -c '\n")
            f.write("  mkdir -p .archive/maven-poms/$(dirname {})\n")
            f.write("  mv {} .archive/maven-poms/{}\n")
            f.write("' \\;\n")
            f.write("```\n\n")
            
            f.write("### 同时可以删除的 Maven 相关文件\n\n")
            f.write("```bash\n")
            f.write("# Maven wrapper\n")
            f.write("rm -f mvnw mvnw.cmd\n")
            f.write("rm -rf .mvn\n\n")
            f.write("# Maven 本地构建产物\n")
            f.write("find . -name 'target' -type d -exec rm -rf {} + 2>/dev/null || true\n")
            f.write("```\n\n")
        
        f.write("## 📝 详细模块列表\n\n")
        
        # 按类别分组
        categories = defaultdict(list)
        for analysis in analyses:
            if analysis.is_aggregation:
                categories['聚合模块'].append(analysis)
            elif analysis.issues:
                categories['有问题的模块'].append(analysis)
            else:
                categories['正常模块'].append(analysis)
        
        for category, items in sorted(categories.items()):
            f.write(f"### {category} ({len(items)})\n\n")
            for analysis in sorted(items, key=lambda a: a.path):
                status = "✅" if not analysis.issues else "❌"
                f.write(f"- {status} `{analysis.path}`")
                if analysis.maven_deps:
                    f.write(f" ({len(analysis.maven_deps)} 个依赖)")
                f.write("\n")
            f.write("\n")
        
        f.write("---\n\n")
        f.write(f"*报告生成时间: {import_datetime()}*\n")

def import_datetime():
    from datetime import datetime
    return datetime.now().strftime('%Y-%m-%d %H:%M:%S')

def main():
    print("=" * 60)
    print("Gradle 迁移依赖验证工具 (Python 版)")
    print("=" * 60)
    print()
    
    # 获取项目根目录
    project_root = Path(__file__).parent
    os.chdir(project_root)
    
    print(f"项目根目录: {project_root}")
    print()
    print("正在扫描模块...")
    print()
    
    # 查找所有包含 pom.xml 的目录
    analyses = []
    pom_files = list(project_root.glob('**/pom.xml'))
    
    # 排除 target 目录和 .mvn 目录
    pom_files = [p for p in pom_files if 'target' not in str(p) and '.mvn' not in str(p)]
    
    total = len(pom_files)
    for i, pom_file in enumerate(pom_files, 1):
        module_dir = pom_file.parent
        rel_path = module_dir.relative_to(project_root)
        
        print(f"[{i}/{total}] 分析: {rel_path}")
        analysis = analyze_module(str(module_dir))
        analyses.append(analysis)
        
        if analysis.is_aggregation:
            print(f"  📦 聚合模块")
        elif not analysis.has_gradle:
            print(f"  ❌ 缺失 build.gradle")
        elif analysis.issues:
            print(f"  ⚠️  发现 {len(analysis.issues)} 个问题")
        else:
            print(f"  ✅ 正常 ({len(analysis.maven_deps)} 个依赖)")
    
    print()
    print("生成报告...")
    
    report_file = 'gradle-migration-verification.md'
    generate_report(analyses, report_file)
    
    print()
    print("=" * 60)
    print("验证完成！")
    print("=" * 60)
    print()
    
    aggregation_count = sum(1 for a in analyses if a.is_aggregation)
    with_issues = sum(1 for a in analyses if a.issues and not a.is_aggregation)
    
    print(f"📊 统计:")
    print(f"   总模块数: {len(analyses)}")
    print(f"   聚合模块: {aggregation_count}")
    print(f"   有问题的模块: {with_issues}")
    print()
    
    if with_issues == 0:
        print("✅ 所有模块验证通过！可以安全删除 pom.xml 文件。")
        print()
        print(f"📄 详细报告已生成: {report_file}")
        return 0
    else:
        print("❌ 发现问题！请先解决后再删除 pom.xml。")
        print()
        print(f"📄 详细报告已生成: {report_file}")
        return 1

if __name__ == '__main__':
    exit(main())

