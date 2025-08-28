#!/bin/bash

# Firebase dSYM Upload Fix Script
# This fixes the missing dSYM symbols for Firebase frameworks

echo "🔧 Fixing Firebase dSYM Upload Issues..."

# Navigate to project directory
cd "/Users/aaronkeen/Documents/My Apps/Inventry2/ios-app"

# Method 1: Add Firebase Crashlytics Run Script (if using Crashlytics)
echo "📱 Adding Firebase dSYM upload script to Xcode project..."

# Method 2: Download and upload dSYMs manually
echo "📥 You can also download dSYMs from App Store Connect:"
echo "1. Go to App Store Connect"
echo "2. Go to your app > TestFlight > Build"
echo "3. Click 'Download dSYM' button"
echo "4. Upload to Firebase using their upload tool"

# Method 3: Build Settings Fix
echo "🛠️  Recommended Build Settings:"
echo "- Debug Information Format: DWARF with dSYM File"
echo "- Strip Debug Symbols During Copy: NO (for Debug), YES (for Release)"

# Create the run script content
cat > dsym_upload_script.txt << 'EOF'
# Add this as a "Run Script" build phase in Xcode AFTER "Embed Frameworks"
# Name: "Upload dSYMs to Firebase"

"${PODS_ROOT}/FirebaseCrashlytics/upload-symbols" \
-gsp "${PROJECT_DIR}/Inventry/GoogleService-Info.plist" \
-p ios "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}"
EOF

echo "✅ Script created. Now apply these fixes:"
echo ""
echo "=== FIX 1: Xcode Build Settings ==="
echo "1. Select your project in Xcode"
echo "2. Select 'Inventry' target"
echo "3. Go to Build Settings"
echo "4. Search for 'Debug Information Format'"
echo "5. Set to 'DWARF with dSYM File' for both Debug and Release"
echo ""
echo "=== FIX 2: Add Run Script Phase ==="
echo "1. Select your target in Xcode"
echo "2. Go to Build Phases tab"
echo "3. Click '+' > New Run Script Phase"
echo "4. Name it 'Upload dSYMs to Firebase'"
echo "5. Copy the script from 'dsym_upload_script.txt'"
echo "6. Drag it AFTER 'Embed Frameworks' phase"
echo ""
echo "=== FIX 3: Clean and Archive ==="
echo "1. Product > Clean Build Folder"
echo "2. Product > Archive"
echo "3. Upload to App Store Connect"
echo ""
echo "=== Alternative: Skip dSYM Upload ==="
echo "In Xcode Organizer when uploading:"
echo "1. Uncheck 'Upload app's symbols for Apple to analyze'"
echo "2. This skips the dSYM requirement entirely"

chmod +x fix-dsym-upload.sh
echo "🎉 Fix script ready!"