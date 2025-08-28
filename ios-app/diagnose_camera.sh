#!/bin/bash

# Quick diagnostic script to check if camera files are properly set up

echo "🔍 Camera Files Diagnostic"
echo "=========================="
echo ""

# Check if files exist
echo "Checking file existence..."
echo ""

files_to_check=(
    "Inventry/Views/UnifiedCameraView.swift"
    "Inventry/Views/PropertyDetailView.swift"
    "Inventry/Views/RoomDetailView.swift"
    "Inventry/Views/CameraTestView.swift"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
        # Check if UnifiedCameraButton is defined/used
        if grep -q "UnifiedCameraButton" "$file" 2>/dev/null; then
            echo "   └─ Contains UnifiedCameraButton reference"
        fi
    else
        echo "❌ $file not found"
    fi
done

echo ""
echo "Checking for camera button usage..."
echo ""

# Check where UnifiedCameraButton is used
echo "Files using UnifiedCameraButton:"
grep -l "UnifiedCameraButton" Inventry/Views/*.swift 2>/dev/null | while read file; do
    echo "  • $(basename $file)"
done

echo ""
echo "📝 Next Steps:"
echo "============="
echo ""
echo "1. Open Xcode"
echo "2. In the Project Navigator, check if UnifiedCameraView.swift is listed"
echo "3. If it's RED, it needs to be re-added"
echo "4. If it's MISSING, right-click Views folder → Add Files → Select UnifiedCameraView.swift"
echo "5. Make sure the Inventry target is checked when adding"
echo ""
echo "Quick Test Command:"
echo "  xcodebuild -project Inventry.xcodeproj -scheme Inventry -showBuildSettings | grep -E 'SWIFT_VERSION|PLATFORM_NAME'"
echo ""
