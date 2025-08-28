#!/bin/bash

# Camera Cleanup Script
# This script removes old camera implementations that have been replaced by UnifiedCameraView

echo "🧹 Camera Cleanup Script"
echo "========================"
echo ""
echo "This script will remove deprecated camera view files that have been replaced"
echo "by the new UnifiedCameraView implementation."
echo ""

# List of deprecated camera files to remove
declare -a deprecated_files=(
    "AdvancedCameraView.swift"
    "ModernCameraView.swift"
    "SafeCameraView.swift"
    "SimpleCameraView.swift"
    "WorkingCameraView.swift"
    "iPhone16ProCameraView.swift"
)

# Base path for camera views
base_path="/Users/aaronkeen/Documents/My Apps/Inventry2/ios-app/Inventry/Views"

echo "Files to be removed:"
echo "-------------------"
for file in "${deprecated_files[@]}"; do
    echo "  • $file"
done
echo ""

# Ask for confirmation
read -p "⚠️  Are you sure you want to remove these deprecated camera files? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Removing deprecated files..."
    
    for file in "${deprecated_files[@]}"; do
        file_path="$base_path/$file"
        if [ -f "$file_path" ]; then
            rm "$file_path"
            echo "  ✅ Removed: $file"
        else
            echo "  ⏭️  Skipped (not found): $file"
        fi
    done
    
    echo ""
    echo "✨ Cleanup complete!"
    echo ""
    echo "The following files remain:"
    echo "  • UnifiedCameraView.swift (main implementation)"
    echo "  • CameraTestView.swift (testing suite)"
    echo ""
    echo "📝 Next steps:"
    echo "  1. Remove these files from Xcode project navigator"
    echo "  2. Clean build folder (Shift+Cmd+K)"
    echo "  3. Build and test the app"
    
else
    echo "❌ Cleanup cancelled. No files were removed."
fi
