#!/usr/bin/env python3
"""
Add the Core Data model file only - minimal and safe approach
"""
import re
import uuid
import shutil

def generate_id():
    """Generate a unique 24-character hex ID matching Xcode's format"""
    return uuid.uuid4().hex[:24].upper()

# Backup first
shutil.copy('Inventry.xcodeproj/project.pbxproj', 'Inventry.xcodeproj/project.pbxproj.backup2')

# Only add the Core Data model file - don't add entity files yet
file_to_add = ('InventoryModel.xcdatamodeld', 'wrapper.xcdatamodel')

# Read the project file
with open('Inventry.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Generate unique ID
file_ref_id = generate_id()

print("=== Adding Core Data model file ===")

# 1. Add PBXFileReference entry (no build file needed for .xcdatamodeld)
file_ref_entry = f"\t\t{file_ref_id} /* {file_to_add[0]} */ = {{isa = PBXFileReference; lastKnownFileType = {file_to_add[1]}; path = {file_to_add[0]}; sourceTree = \"<group>\"; }};"

insert_pos = content.find('/* End PBXFileReference section */')
if insert_pos == -1:
    print("❌ Could not find PBXFileReference section")
    exit(1)

file_ref_text = "\n" + file_ref_entry + "\n"
content = content[:insert_pos] + file_ref_text + content[insert_pos:]

print(f"✅ Added {file_to_add[0]} file reference")

# Write the updated project file
with open('Inventry.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("\n🎉 Successfully added Core Data model file!")
print("Backup saved as: project.pbxproj.backup2")