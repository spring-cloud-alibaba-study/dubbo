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

import org.gradle.api.DefaultTask;
import org.gradle.api.file.DirectoryProperty;
import org.gradle.api.provider.Property;
import org.gradle.api.tasks.Input;
import org.gradle.api.tasks.InputDirectory;
import org.gradle.api.tasks.OutputDirectory;
import org.gradle.api.tasks.TaskAction;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Stream;

/**
 * Task to generate Dubbo service stubs from IDL files
 */
public class GenerateDubboIdlTask extends DefaultTask {
    
    private final Property<DubboIdlExtension> extension;
    
    public GenerateDubboIdlTask() {
        this.extension = getProject().getObjects().property(DubboIdlExtension.class);
    }
    
    @Input
    public Property<DubboIdlExtension> getExtension() {
        return extension;
    }
    
    @InputDirectory
    public DirectoryProperty getProtoDir() {
        return extension.get().getProtoDir();
    }
    
    @OutputDirectory
    public DirectoryProperty getOutputDir() {
        return extension.get().getOutputDir();
    }
    
    @TaskAction
    public void generate() {
        DubboIdlExtension ext = extension.get();
        File protoDir = ext.getProtoDir().getAsFile().get();
        File outputDir = ext.getOutputDir().getAsFile().get();
        
        if (!protoDir.exists()) {
            getLogger().warn("Proto directory does not exist: {}", protoDir);
            return;
        }
        
        // Create output directory
        outputDir.mkdirs();
        
        // Find all .proto files
        List<File> protoFiles = findProtoFiles(protoDir);
        
        if (protoFiles.isEmpty()) {
            getLogger().info("No .proto files found in {}", protoDir);
            return;
        }
        
        getLogger().info("Found {} .proto files", protoFiles.size());
        
        // Generate code using protoc with Dubbo compiler plugin
        generateCode(protoFiles, protoDir, outputDir, ext);
    }
    
    private List<File> findProtoFiles(File dir) {
        List<File> protoFiles = new ArrayList<>();
        try (Stream<Path> paths = Files.walk(dir.toPath())) {
            paths.filter(Files::isRegularFile)
                 .filter(p -> p.toString().endsWith(".proto"))
                 .forEach(p -> protoFiles.add(p.toFile()));
        } catch (Exception e) {
            throw new RuntimeException("Error finding proto files", e);
        }
        return protoFiles;
    }
    
    private void generateCode(List<File> protoFiles, File protoDir, File outputDir, DubboIdlExtension ext) {
        getLogger().info("Generating Dubbo IDL code from {} proto files", protoFiles.size());
        getLogger().info("Proto directory: {}", protoDir);
        getLogger().info("Output directory: {}", outputDir);
        
        // Note: This is a simplified implementation
        // In production, you would:
        // 1. Integrate with com.google.protobuf plugin if available
        // 2. Or execute protoc with Dubbo compiler plugin
        // 3. Handle protoc download and platform detection
        
        getLogger().warn("Code generation implementation is simplified. " +
            "For production use, integrate with protobuf Gradle plugin or implement protoc execution.");
        
        // Create output directory structure
        File javaOutDir = new File(outputDir, "java");
        javaOutDir.mkdirs();
        
        getLogger().info("Output directory created: {}", javaOutDir);
    }
    
}

