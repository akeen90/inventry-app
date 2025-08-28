#!/bin/bash

# Build script for Inventry2 project
echo "Building Inventry2 Applications..."
echo "================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to build a project
build_project() {
    local project_name=$1
    local project_path=$2
    
    echo ""
    echo "Building $project_name..."
    echo "-------------------------"
    
    if [ -d "$project_path" ]; then
        cd "$project_path"
        
        # Check if node_modules exists, if not install dependencies
        if [ ! -d "node_modules" ]; then
            echo "Installing dependencies for $project_name..."
            npm install
        fi
        
        # Run the build
        npm run build
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ $project_name built successfully${NC}"
        else
            echo -e "${RED}✗ $project_name build failed${NC}"
            exit 1
        fi
    else
        echo -e "${RED}✗ $project_name directory not found at $project_path${NC}"
        exit 1
    fi
}

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Build client dashboard
build_project "Client Dashboard" "$SCRIPT_DIR/client-dashboard"

# Build company dashboard
build_project "Company Dashboard" "$SCRIPT_DIR/company-dashboard"

echo ""
echo "================================="
echo -e "${GREEN}All builds completed successfully!${NC}"
echo ""
echo "To deploy to Firebase:"
echo "  1. For Client Dashboard: cd client-dashboard && firebase deploy"
echo "  2. For Company Dashboard: cd company-dashboard && firebase deploy"
