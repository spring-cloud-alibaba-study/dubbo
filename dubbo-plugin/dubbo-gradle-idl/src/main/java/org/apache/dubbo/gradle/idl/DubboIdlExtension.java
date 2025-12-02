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

import org.gradle.api.Project;
import org.gradle.api.file.DirectoryProperty;
import org.gradle.api.provider.Property;

import java.io.File;

/**
 * Extension configuration for Dubbo IDL plugin
 */
public class DubboIdlExtension {
    
    private final DirectoryProperty protoDir;
    private final DirectoryProperty outputDir;
    private final Property<Boolean> generateGrpc;
    private final Property<String> protocVersion;
    private final Property<String> dubboCompilerVersion;
    
    public DubboIdlExtension(Project project) {
        this.protoDir = project.getObjects().directoryProperty();
        this.outputDir = project.getObjects().directoryProperty();
        this.generateGrpc = project.getObjects().property(Boolean.class);
        this.protocVersion = project.getObjects().property(String.class);
        this.dubboCompilerVersion = project.getObjects().property(String.class);
        
        // Default values
        this.protoDir.set(project.getLayout().getProjectDirectory().dir("src/main/proto"));
        this.outputDir.set(project.getLayout().getBuildDirectory().dir("generated/source/dubbo"));
        this.generateGrpc.set(true);
        this.protocVersion.set("3.22.3");
        this.dubboCompilerVersion.set(project.getVersion().toString());
    }
    
    /**
     * Directory containing .proto files
     */
    public DirectoryProperty getProtoDir() {
        return protoDir;
    }
    
    public void setProtoDir(File dir) {
        this.protoDir.set(dir);
    }
    
    /**
     * Output directory for generated Java files
     */
    public DirectoryProperty getOutputDir() {
        return outputDir;
    }
    
    public void setOutputDir(File dir) {
        this.outputDir.set(dir);
    }
    
    /**
     * Whether to generate gRPC stubs in addition to Dubbo stubs
     */
    public Property<Boolean> getGenerateGrpc() {
        return generateGrpc;
    }
    
    public void setGenerateGrpc(boolean generate) {
        this.generateGrpc.set(generate);
    }
    
    /**
     * Protocol Buffers compiler version
     */
    public Property<String> getProtocVersion() {
        return protocVersion;
    }
    
    public void setProtocVersion(String version) {
        this.protocVersion.set(version);
    }
    
    /**
     * Dubbo compiler version (usually matches project version)
     */
    public Property<String> getDubboCompilerVersion() {
        return dubboCompilerVersion;
    }
    
    public void setDubboCompilerVersion(String version) {
        this.dubboCompilerVersion.set(version);
    }
}

