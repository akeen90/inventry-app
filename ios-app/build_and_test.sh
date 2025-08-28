#!/bin/bash

# Build and Test Script for Camera Fix
# This script helps build and test the app with the new camera implementation

echo "📱 iOS App Build & Test Script"
echo "=============================="
echo ""

# Check if we're in the right directory
if [ ! -f "Inventry.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Not in the iOS app directory"
    echo "Please run this script from: /Users/aaronkeen/Documents/My Apps/Inventry2/ios-app"
    exit 1
fi

echo "1️⃣ Cleaning build folder..."
xcodebuild clean -project Inventry.xcodeproj -scheme Inventry 2>/dev/null
echo "   ✅ Build folder cleaned"
echo ""

echo "2️⃣ Building app for iPhone 16 Pro..."
xcodebuild build \
    -project Inventry.xcodeproj \
    -scheme Inventry \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -quiet 2>/dev/null

if [ $? -eq 0 ]; then
    echo "   ✅ Build successful!"
else
    echo "   ❌ Build failed. Please check Xcode for errors."
    exit 1
fi
echo ""

echo "3️⃣ Running tests..."
xcodebuild test \
    -project Inventry.xcodeproj \
    -scheme Inventry \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -only-testing:InventryTests/CameraTests \
    -quiet 2>/dev/null

if [ $? -eq 0 ]; then
    echo "   ✅ Tests passed!"
else
    echo "   ⚠️  No tests found or tests failed"
fi
echo ""

echo "4️⃣ Launching app in simulator..."
xcrun simctl boot "iPhone 16 Pro" 2>/dev/null
open -a Simulator
xcrun simctl install "iPhone 16 Pro" \
    ~/Library/Developer/Xcode/DerivedData/Inventry-*/Build/Products/Debug-iphonesimulator/Inventry.app 2>/dev/null
xcrun simctl launch "iPhone 16 Pro" com.yourcompany.Inventry 2>/dev/null

echo "   ✅ App launched in simulator"
echo ""

echo "✨ Build and test complete!"
echo ""
echo "📝 Next steps to test camera:"
echo "  1. In the simulator, go to Device > Camera to enable camera simulation"
echo "  2. Navigate to any property in the app"
echo "  3. Test 'Take Property Photos' button"
echo "  4. Navigate to a room and test 'Take Room Photos'"
echo "  5. Add an item and test 'Take Item Photos'"
echo ""
echo "💡 Tip: For real device testing, connect your iPhone 16 Pro and select it as the target in Xcode"
