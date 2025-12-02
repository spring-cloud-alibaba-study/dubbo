/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.dubbo.gradle.idl;

import org.gradle.api.Plugin;
import org.gradle.api.Project;
import org.gradle.api.plugins.JavaPlugin;
import org.gradle.api.tasks.SourceSet;

/**
 * Dubbo IDL Gradle Plugin
 * 
 * This plugin generates Dubbo service stubs from Protocol Buffers IDL files.
 * 
 * Usage:
 * <pre>
 * plugins {
 *     id 'org.apache.dubbo.idl'
 * }
 * 
 * dubboIdl {
 *     protoDir = file('src/main/proto')
 *     outputDir = file('build/generated/source/dubbo')
 *     generateGrpc = true
 * }
 * </pre>
 */
public class DubboIdlPlugin implements Plugin<Project> {
    
    public static final String EXTENSION_NAME = "dubboIdl";
    public static final String TASK_GROUP = "dubbo";
    
    @Override
    public void apply(Project project) {
        // Ensure Java plugin is applied
        project.getPlugins().apply(JavaPlugin.class);
        
        // Create extension
        DubboIdlExtension extension = project.getExtensions()
            .create(EXTENSION_NAME, DubboIdlExtension.class, project);
        
        // Register generate task
        project.getTasks().register("generateDubboIdl", GenerateDubboIdlTask.class, task -> {
            task.setGroup(TASK_GROUP);
            task.setDescription("Generates Dubbo service stubs from IDL files");
            task.getExtension().set(extension);
        });
        
        // Configure source sets after evaluation
        project.afterEvaluate(p -> {
            SourceSet mainSourceSet = p.getExtensions()
                .getByType(org.gradle.api.plugins.JavaPluginExtension.class)
                .getSourceSets()
                .getByName("main");
            
            // Add generated sources to main source set
            mainSourceSet.getJava().srcDir(extension.getOutputDir());
            
            // Make compileJava depend on generateDubboIdl
            p.getTasks().named("compileJava", task -> {
                task.dependsOn("generateDubboIdl");
            });
        });
    }
}

