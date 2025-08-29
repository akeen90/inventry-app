#!/usr/bin/env python3
"""
Temporarily remove LocalStorageService and SyncService from build 
so we can get a working app with just CoreDataStack
"""
import shutil

# Backup first
shutil.copy('Inventry.xcodeproj/project.pbxproj', 'Inventry.xcodeproj/project.pbxproj.backup3')

# Read the project file
with open('Inventry.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

print("=== Temporarily removing LocalStorageService and SyncService from build ===")

# Remove LocalStorageService references
content = content.replace('		984B9B75FD7C46B5AC4479CA /* LocalStorageService.swift in Sources */ = {isa = PBXBuildFile; fileRef = EB901A43C27C497CB4AD3A60 /* LocalStorageService.swift */; };', '')
content = content.replace('		EB901A43C27C497CB4AD3A60 /* LocalStorageService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LocalStorageService.swift; sourceTree = "<group>"; };', '')
content = content.replace('				EB901A43C27C497CB4AD3A60 /* LocalStorageService.swift */,', '')
content = content.replace('				984B9B75FD7C46B5AC4479CA /* LocalStorageService.swift in Sources */,', '')

# Remove SyncService references  
content = content.replace('		ABCD15188C944350BC0F2F4E /* SyncService.swift in Sources */ = {isa = PBXBuildFile; fileRef = 38AAFACE8DF04841A168BD2D /* SyncService.swift */; };', '')
content = content.replace('		38AAFACE8DF04841A168BD2D /* SyncService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SyncService.swift; sourceTree = "<group>"; };', '')
content = content.replace('				38AAFACE8DF04841A168BD2D /* SyncService.swift */,', '')
content = content.replace('				ABCD15188C944350BC0F2F4E /* SyncService.swift in Sources */,', '')

# Write the updated project file
with open('Inventry.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("✅ Temporarily removed LocalStorageService and SyncService from build")
print("✅ CoreDataStack remains in build")
print("Backup saved as: project.pbxproj.backup3")