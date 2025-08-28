#!/bin/bash

# Camera Setup Helper Script
# This script helps you add the camera to your Xcode project

echo ""
echo "======================================"
echo "    📸 CAMERA SETUP HELPER 📸"
echo "======================================"
echo ""
echo "This script will guide you through adding"
echo "the camera to your iOS app."
echo ""

# Check if WorkingCamera.swift exists
if [ -f "Inventry/Views/WorkingCamera.swift" ]; then
    echo "✅ WorkingCamera.swift found!"
    echo ""
else
    echo "❌ WorkingCamera.swift not found!"
    echo "Please run this script from the ios-app directory"
    exit 1
fi

echo "📋 STEP-BY-STEP INSTRUCTIONS:"
echo "=============================="
echo ""
echo "1️⃣  OPEN XCODE"
echo "   Open Inventry.xcodeproj"
echo ""
echo "2️⃣  ADD FILE TO PROJECT"
echo "   • Right-click on 'Views' folder"
echo "   • Select 'Add Files to Inventry...'"
echo "   • Choose: WorkingCamera.swift"
echo "   • UNCHECK 'Copy items if needed'"
echo "   • CHECK 'Inventry' target"
echo "   • Click 'Add'"
echo ""
echo "3️⃣  CLEAN AND BUILD"
echo "   • Press: Shift + Cmd + K (Clean)"
echo "   • Press: Cmd + B (Build)"
echo ""
echo "4️⃣  RUN THE APP"
echo "   • Press: Cmd + R"
echo "   • Test camera buttons!"
echo ""
echo "======================================"
echo ""

# Open Xcode if requested
read -p "📱 Open Xcode now? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open Inventry.xcodeproj
    echo "✅ Xcode opened!"
    echo ""
    echo "Now follow the steps above to add WorkingCamera.swift"
fi

echo ""
echo "📸 Camera Features:"
echo "  • Take multiple photos"
echo "  • Live preview"
echo "  • Works on iPhone & Simulator"
echo "  • Auto-optimized images"
echo ""
echo "Need help? Check CAMERA_WORKING_INSTRUCTIONS.md"
echo ""
