#!/usr/bin/env python3
import re
import uuid

# Read the project file
with open('Inventry.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

def generate_id():
    """Generate a unique 24-character hex ID matching Xcode's format"""
    return ''.join([format(ord(c), 'X') for c in str(uuid.uuid4())[:24].replace('-', '')])[:24]

# Files to add
files_to_add = [
    ('CoreDataStack.swift', 'Services/CoreDataStack.swift'),
    ('LocalStorageService.swift', 'Services/LocalStorageService.swift'), 
    ('SyncService.swift', 'Services/SyncService.swift'),
    ('InventoryModel.xcdatamodeld', 'Data/InventoryModel.xcdatamodeld'),
    ('PropertyEntity+CoreDataClass.swift', 'Data/PropertyEntity+CoreDataClass.swift'),
    ('PropertyEntity+CoreDataProperties.swift', 'Data/PropertyEntity+CoreDataProperties.swift'),
    ('InventoryReportEntity+CoreDataClass.swift', 'Data/InventoryReportEntity+CoreDataClass.swift'),
    ('InventoryReportEntity+CoreDataProperties.swift', 'Data/InventoryReportEntity+CoreDataProperties.swift'),
    ('RoomEntity+CoreDataClass.swift', 'Data/RoomEntity+CoreDataClass.swift'),
    ('RoomEntity+CoreDataProperties.swift', 'Data/RoomEntity+CoreDataProperties.swift'),
    ('InventoryItemEntity+CoreDataClass.swift', 'Data/InventoryItemEntity+CoreDataClass.swift'),
    ('InventoryItemEntity+CoreDataProperties.swift', 'Data/InventoryItemEntity+CoreDataProperties.swift')
]

# Generate IDs for all files
file_refs = {}
build_files = {}
for filename, path in files_to_add:
    file_refs[filename] = generate_id()
    build_files[filename] = generate_id()

# 1. Add PBXBuildFile entries
build_file_section = "/* Begin PBXBuildFile section */"
new_build_files = []
for filename, path in files_to_add:
    new_build_files.append(f"\t\t{build_files[filename]} /* {filename} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[filename]} /* {filename} */; }};")

build_file_insert = build_file_section + "\n" + "\n".join(new_build_files)
content = content.replace(build_file_section, build_file_insert)

# 2. Add PBXFileReference entries  
file_ref_section = "/* Begin PBXFileReference section */"
new_file_refs = []
for filename, path in files_to_add:
    if filename.endswith('.xcdatamodeld'):
        file_type = "wrapper.xcdatamodel"
    else:
        file_type = "sourcecode.swift"
    new_file_refs.append(f"\t\t{file_refs[filename]} /* {filename} */ = {{isa = PBXFileReference; lastKnownFileType = {file_type}; path = {filename}; sourceTree = \"<group>\"; }};")

file_ref_insert = file_ref_section + "\n" + "\n".join(new_file_refs)  
content = content.replace(file_ref_section, file_ref_insert)

# 3. Add to Services group (for service files)
services_group_pattern = r"(C8A1B3022C9A1234 /\* Services \*/ = \{[^}]*children = \(\s*)(.*?)(\s*\);)"
def services_replacement(match):
    prefix = match.group(1)
    existing = match.group(2)
    suffix = match.group(3)
    
    service_files = []
    for filename, path in files_to_add:
        if 'Services/' in path:
            service_files.append(f"\t\t\t\t{file_refs[filename]} /* {filename} */,")
    
    return prefix + existing + "\n" + "\n".join(service_files) + suffix

content = re.sub(services_group_pattern, services_replacement, content, flags=re.DOTALL)

# 4. Add Data group if it doesn't exist and add data files
# First check if Data group exists
if "/* Data */" not in content:
    # Add Data group to main Inventry group
    inventry_group_pattern = r"(C8A1B2E72C9A1234 /\* Inventry \*/ = \{[^}]*children = \(\s*)(.*?)(\s*\);)"
    data_group_id = generate_id()
    
    def inventry_replacement(match):
        prefix = match.group(1)
        existing = match.group(2)
        suffix = match.group(3)
        return prefix + existing + f"\n\t\t\t\t{data_group_id} /* Data */," + suffix
    
    content = re.sub(inventry_group_pattern, inventry_replacement, content, flags=re.DOTALL)
    
    # Add the Data group definition
    data_files = []
    for filename, path in files_to_add:
        if 'Data/' in path:
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
    
    # Insert after Services group
    services_end = content.find('path = Services;\n\t\t\tsourceTree = "<group>";\n\t\t};')
    if services_end != -1:
        insert_pos = content.find('\n', services_end + len('path = Services;\n\t\t\tsourceTree = "<group>";\n\t\t};'))
        content = content[:insert_pos] + data_group_def + content[insert_pos:]

# 5. Add to PBXSourcesBuildPhase
sources_build_pattern = r"(C8A1B2E12C9A1234 /\* Sources \*/ = \{[^}]*files = \(\s*)(.*?)(\s*\);)"
def sources_replacement(match):
    prefix = match.group(1)
    existing = match.group(2)
    suffix = match.group(3)
    
    new_sources = []
    for filename, path in files_to_add:
        if not filename.endswith('.xcdatamodeld'):  # Don't add .xcdatamodeld to sources
            new_sources.append(f"\t\t\t\t{build_files[filename]} /* {filename} in Sources */,")
    
    return prefix + existing + "\n" + "\n".join(new_sources) + suffix

content = re.sub(sources_build_pattern, sources_replacement, content, flags=re.DOTALL)

# Write back to file
with open('Inventry.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("✅ Successfully added files to Xcode project!")
print("Added files:")
for filename, path in files_to_add:
    print(f"  - {filename} ({path})")