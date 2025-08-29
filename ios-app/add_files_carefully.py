#!/usr/bin/env python3
import re
import uuid

def generate_id():
    """Generate a unique 24-character hex ID matching Xcode's format"""
    return uuid.uuid4().hex[:24].upper()

# Read the project file
with open('Inventry.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Files to add with their proper paths
files_to_add = [
    ('CoreDataStack.swift', 'Services', 'sourcecode.swift'),
    ('LocalStorageService.swift', 'Services', 'sourcecode.swift'),
    ('SyncService.swift', 'Services', 'sourcecode.swift'),
    ('InventoryModel.xcdatamodeld', 'Data', 'wrapper.xcdatamodel'),
    ('PropertyEntity+CoreDataClass.swift', 'Data', 'sourcecode.swift'),
    ('PropertyEntity+CoreDataProperties.swift', 'Data', 'sourcecode.swift'),
    ('InventoryReportEntity+CoreDataClass.swift', 'Data', 'sourcecode.swift'),
    ('InventoryReportEntity+CoreDataProperties.swift', 'Data', 'sourcecode.swift'),
    ('RoomEntity+CoreDataClass.swift', 'Data', 'sourcecode.swift'),
    ('RoomEntity+CoreDataProperties.swift', 'Data', 'sourcecode.swift'),
    ('InventoryItemEntity+CoreDataClass.swift', 'Data', 'sourcecode.swift'),
    ('InventoryItemEntity+CoreDataProperties.swift', 'Data', 'sourcecode.swift')
]

# Generate unique IDs
file_refs = {}
build_files = {}
for filename, folder, filetype in files_to_add:
    file_refs[filename] = generate_id()
    build_files[filename] = generate_id()

print("=== Step 1: Adding PBXBuildFile entries ===")
build_file_section = "/* Begin PBXBuildFile section */"
new_build_entries = []
for filename, folder, filetype in files_to_add:
    if not filename.endswith('.xcdatamodeld'):  # Don't add .xcdatamodeld to build files
        new_build_entries.append(f"\t\t{build_files[filename]} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[filename]} /* {filename} */; }};")

# Insert after existing build files
insert_pos = content.find('/* End PBXBuildFile section */')
if insert_pos == -1:
    print("❌ Could not find PBXBuildFile section")
    exit(1)

build_entries_text = "\n" + "\n".join(new_build_entries) + "\n"
content = content[:insert_pos] + build_entries_text + content[insert_pos:]
print(f"✅ Added {len(new_build_entries)} build file entries")

print("=== Step 2: Adding PBXFileReference entries ===")
file_ref_section = "/* Begin PBXFileReference section */"
new_file_refs = []
for filename, folder, filetype in files_to_add:
    new_file_refs.append(f"\t\t{file_refs[filename]} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = {filetype}; path = {filename}; sourceTree = \"<group>\"; }};")

# Insert after existing file references
insert_pos = content.find('/* End PBXFileReference section */')
if insert_pos == -1:
    print("❌ Could not find PBXFileReference section")
    exit(1)

file_refs_text = "\n" + "\n".join(new_file_refs) + "\n"
content = content[:insert_pos] + file_refs_text + content[insert_pos:]
print(f"✅ Added {len(new_file_refs)} file reference entries")

print("=== Step 3: Adding to Services group ===")
services_pattern = r"(C8A1B3022C9A1234 /\* Services \*/ = \{[^}]+children = \(\s*[^)]*?)(\s*\);\s*path = Services;)"
service_files = []
for filename, folder, filetype in files_to_add:
    if folder == 'Services':
        service_files.append(f"\t\t\t\t{file_refs[filename]} /* {filename} */,")

def services_replacement(match):
    existing = match.group(1)
    ending = match.group(2)
    return existing + "\n" + "\n".join(service_files) + ending

content = re.sub(services_pattern, services_replacement, content, flags=re.DOTALL)
print(f"✅ Added {len(service_files)} files to Services group")

print("=== Step 4: Adding Data group ===")
# Check if we need to add Data group to main Inventry group
if "/* Data */" not in content:
    data_group_id = generate_id()
    
    # Add Data group to main Inventry group
    inventry_pattern = r"(C8A1B2E72C9A1234 /\* Inventry \*/ = \{[^}]+children = \(\s*[^)]*?)(\s*\);\s*path = Inventry;)"
    def inventry_replacement(match):
        existing = match.group(1)
        ending = match.group(2)
        return existing + f"\n\t\t\t\t{data_group_id} /* Data */," + ending
    
    content = re.sub(inventry_pattern, inventry_replacement, content, flags=re.DOTALL)
    
    # Create Data group definition
    data_files = []
    for filename, folder, filetype in files_to_add:
        if folder == 'Data':
            data_files.append(f"\t\t\t\t{file_refs[filename]} /* {filename} */,")
    
    data_group_def = f"""
\t\t{data_group_id} /* Data */ = {{
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
{chr(10).join(data_files)}
\t\t\t);
\t\t\tpath = Data;
\t\t\tsourceTree = "<group>";
\t\t}};"""
    
    # Insert Data group after Services group
    services_group_end = content.find('path = Services;\n\t\t\tsourceTree = "<group>";\n\t\t};')
    if services_group_end != -1:
        insert_pos = content.find('\n', services_group_end + 50)
        content = content[:insert_pos] + data_group_def + content[insert_pos:]
        print(f"✅ Created Data group with {len(data_files)} files")

print("=== Step 5: Adding to PBXSourcesBuildPhase ===")
sources_pattern = r"(C8A1B2E12C9A1234 /\* Sources \*/ = \{[^}]+files = \(\s*[^)]*?)(\s*\);\s*runOnlyForDeploymentPostprocessing = 0;)"
source_files = []
for filename, folder, filetype in files_to_add:
    if not filename.endswith('.xcdatamodeld'):  # Don't add .xcdatamodeld to sources
        source_files.append(f"\t\t\t\t{build_files[filename]} /* {filename} in Sources */,")

def sources_replacement(match):
    existing = match.group(1)
    ending = match.group(2)
    return existing + "\n" + "\n".join(source_files) + ending

content = re.sub(sources_pattern, sources_replacement, content, flags=re.DOTALL)
print(f"✅ Added {len(source_files)} files to build sources")

# Write the updated project file
with open('Inventry.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("\n🎉 Successfully added all files to Xcode project!")
print("Files added:")
for filename, folder, filetype in files_to_add:
    print(f"  ✅ {filename} ({folder}/)")