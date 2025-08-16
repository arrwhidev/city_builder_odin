#!/bin/bash

# Watch the game/ directory for changes and automatically build the DLL
# This script will continuously monitor the game/ directory and run build_dll.sh
# whenever any file changes are detected.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting file watcher for game/ directory...${NC}"
echo -e "${BLUE}Press Ctrl+C to stop watching${NC}\n\n"

# Check if fswatch is available (macOS/Linux)
if command -v fswatch &> /dev/null; then
    echo -e "${GREEN}Using fswatch for file watching${NC}"
    
    # Watch the game/ directory recursively
    fswatch -o game/ | while read f; do
        echo -e "${YELLOW}Change detected in game/ directory at $(date)${NC}"
        echo -e "${BLUE}Running build_dll.sh...${NC}"
        
        # Run the build script
        if ./build_dll.sh; then
            echo -e "${GREEN}Build completed successfully!${NC}"
        else
            echo -e "${RED}Build failed!${NC}"
        fi
        
        echo ""
    done
fi
