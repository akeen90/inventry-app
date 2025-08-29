#!/usr/bin/env python3
"""
Safely add only the 3 core service files to Xcode project
This is a minimal, safe approach that only adds what's absolutely necessary
"""
import re
import uuid
import shutil

def generate_id():
    """Generate a unique 24-character hex ID matching Xcode's format"""
    return uuid.uuid4().hex[:24].upper()

# Backup first
shutil.copy('Inventry.xcodeproj/project.pbxproj', 'Inventry.xcodeproj/project.pbxproj.backup')

# Only add these 3 essential files
files_to_add = [
    ('CoreDataStack.swift', 'Services'),
    ('LocalStorageService.swift', 'Services'), 
    ('SyncService.swift', 'Services')
]

# Read the project file
with open('Inventry.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Generate unique IDs
file_refs = {}
build_files = {}
for filename, folder in files_to_add:
    file_refs[filename] = generate_id()
    build_files[filename] = generate_id()

print("=== Adding 3 service files safely ===")

# 1. Add PBXBuildFile entries
build_entries = []
for filename, folder in files_to_add:
    build_entries.append(f"\t\t{build_files[filename]} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[filename]} /* {filename} */; }};")

# Insert before End PBXBuildFile section  
insert_pos = content.find('/* End PBXBuildFile section */')
if insert_pos == -1:
    print("❌ Could not find PBXBuildFile section")
    exit(1)

build_text = "\n" + "\n".join(build_entries) + "\n"
content = content[:insert_pos] + build_text + content[insert_pos:]

# 2. Add PBXFileReference entries
file_ref_entries = []
for filename, folder in files_to_add:
    file_ref_entries.append(f"\t\t{file_refs[filename]} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {filename}; sourceTree = \"<group>\"; }};")

insert_pos = content.find('/* End PBXFileReference section */')
if insert_pos == -1:
    print("❌ Could not find PBXFileReference section")
    exit(1)

file_ref_text = "\n" + "\n".join(file_ref_entries) + "\n"
content = content[:insert_pos] + file_ref_text + content[insert_pos:]

# 3. Add to Services group (find existing Services group)
services_pattern = r"(C8A1B3022C9A1234 /\* Services \*/ = \{[^}]+children = \([^)]*?)((\s*\);.+?sourceTree = \"<group>\";))"

service_file_entries = []
for filename, folder in files_to_add:
    service_file_entries.append(f"\t\t\t\t{file_refs[filename]} /* {filename} */,")

def services_replacement(match):
    existing = match.group(1)
    ending = match.group(2)
    return existing + "\n" + "\n".join(service_file_entries) + "\n" + ending

if re.search(services_pattern, content, re.DOTALL):
    content = re.sub(services_pattern, services_replacement, content, flags=re.DOTALL)
    print("✅ Added files to Services group")
else:
    print("⚠️ Could not find Services group - files added but not grouped")

# 4. Add to PBXSourcesBuildPhase
sources_pattern = r"(C8A1B2E12C9A1234 /\* Sources \*/ = \{[^}]+files = \([^)]*?)((\s*\);.+?runOnlyForDeploymentPostprocessing = 0;))"

source_file_entries = []
for filename, folder in files_to_add:
    source_file_entries.append(f"\t\t\t\t{build_files[filename]} /* {filename} in Sources */,")

def sources_replacement(match):
    existing = match.group(1)
    ending = match.group(2)
    return existing + "\n" + "\n".join(source_file_entries) + "\n" + ending

if re.search(sources_pattern, content, re.DOTALL):
    content = re.sub(sources_pattern, sources_replacement, content, flags=re.DOTALL)
    print("✅ Added files to build sources")
else:
    print("⚠️ Could not find Sources build phase")

# Write the updated project file
with open('Inventry.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("\n🎉 Successfully added service files!")
print("Files added:")
for filename, folder in files_to_add:
    print(f"  ✅ {filename}")

print("\nBackup saved as: project.pbxproj.backup")