#!/usr/bin/env python3
"""
Re-add LocalStorageService and SyncService to the build now that Core Data entities are available
"""
import uuid
import shutil

def generate_id():
    """Generate a unique 24-character hex ID matching Xcode's format"""
    return uuid.uuid4().hex[:24].upper()

# Backup first
shutil.copy('Inventry.xcodeproj/project.pbxproj', 'Inventry.xcodeproj/project.pbxproj.backup5')

# Read the project file
with open('Inventry.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Generate new IDs for LocalStorageService and SyncService
local_storage_file_ref = generate_id()
local_storage_build_file = generate_id()
sync_service_file_ref = generate_id()
sync_service_build_file = generate_id()

print("=== Re-adding LocalStorageService and SyncService ===")

# 1. Add PBXBuildFile entries
build_entries = [
    f"\t\t{local_storage_build_file} /* LocalStorageService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {local_storage_file_ref} /* LocalStorageService.swift */; }};",
    f"\t\t{sync_service_build_file} /* SyncService.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {sync_service_file_ref} /* SyncService.swift */; }};"
]

# Insert before End PBXBuildFile section  
insert_pos = content.find('/* End PBXBuildFile section */')
if insert_pos != -1:
    build_text = "\n" + "\n".join(build_entries) + "\n"
    content = content[:insert_pos] + build_text + content[insert_pos:]

# 2. Add PBXFileReference entries
file_ref_entries = [
    f"\t\t{local_storage_file_ref} /* LocalStorageService.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LocalStorageService.swift; sourceTree = \"<group>\"; }};",
    f"\t\t{sync_service_file_ref} /* SyncService.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SyncService.swift; sourceTree = \"<group>\"; }};"
]

insert_pos = content.find('/* End PBXFileReference section */')
if insert_pos != -1:
    file_ref_text = "\n" + "\n".join(file_ref_entries) + "\n"
    content = content[:insert_pos] + file_ref_text + content[insert_pos:]

# 3. Add to Services group
services_group_pattern = r"(08BC41183DA34F51912D1FFC /\* CoreDataStack\.swift \*/,\s*)([\s\n]*\);)"
services_addition = f"\\1\n\t\t\t\t{local_storage_file_ref} /* LocalStorageService.swift */,\n\t\t\t\t{sync_service_file_ref} /* SyncService.swift */,\\2"
content = content.replace('				08BC41183DA34F51912D1FFC /* CoreDataStack.swift */,\n			);', f'				08BC41183DA34F51912D1FFC /* CoreDataStack.swift */,\n				{local_storage_file_ref} /* LocalStorageService.swift */,\n				{sync_service_file_ref} /* SyncService.swift */,\n			);')

# 4. Add to PBXSourcesBuildPhase
sources_addition = f"\n\t\t\t\t{local_storage_build_file} /* LocalStorageService.swift in Sources */,\n\t\t\t\t{sync_service_build_file} /* SyncService.swift in Sources */,"
content = content.replace('				87EC2B8A74CF473A9ACE10CA /* InventoryItemEntity+CoreDataProperties.swift in Sources */,\n\n			);', f'				87EC2B8A74CF473A9ACE10CA /* InventoryItemEntity+CoreDataProperties.swift in Sources */,{sources_addition}\n\n			);')

# Write the updated project file
with open('Inventry.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("✅ Re-added LocalStorageService and SyncService to build")
print("Backup saved as: project.pbxproj.backup5")
print("\n🎉 Full offline-first system is now ready to activate!")