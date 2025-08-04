#!/bin/bash

# Smart update script for EPIC-lab website
# Only renders changed files unless critical files are modified

# Configuration
SITE_DIR="/Users/joseph/GIT/epic-lab"
LAST_UPDATE_FILE="$SITE_DIR/.last-update"
CRITICAL_FILES=("index.qmd" "_quarto.yml" "styles.css")

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Change to site directory
cd "$SITE_DIR" || exit 1

echo -e "${BLUE}🔍 Checking for changes...${NC}"

# Get list of changed .qmd files
if [ -f "$LAST_UPDATE_FILE" ]; then
    # Find files modified since last update
    CHANGED_FILES=$(find . -name "*.qmd" -newer "$LAST_UPDATE_FILE" -type f | sed 's|^\./||' | grep -v "^docs/")
    CHANGED_CRITICAL=$(find . \( -name "index.qmd" -o -name "_quarto.yml" -o -name "styles.css" \) -newer "$LAST_UPDATE_FILE" -type f | sed 's|^\./||')
else
    # First run - consider all files changed
    CHANGED_FILES=$(find . -name "*.qmd" -type f | sed 's|^\./||' | grep -v "^docs/")
    CHANGED_CRITICAL="First run"
fi

# Check if any critical files changed
NEED_FULL_RENDER=false
if [ -n "$CHANGED_CRITICAL" ]; then
    NEED_FULL_RENDER=true
    echo -e "${YELLOW}📝 Critical files changed:${NC}"
    echo "$CHANGED_CRITICAL"
fi

# Perform appropriate render
if [ "$NEED_FULL_RENDER" = true ]; then
    echo -e "${YELLOW}🔄 Performing full site render...${NC}"
    quarto render
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Site fully updated!${NC}"
    else
        echo -e "${RED}❌ Error during render${NC}"
        exit 1
    fi
elif [ -n "$CHANGED_FILES" ]; then
    # Count changed files
    FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')
    
    echo -e "${BLUE}📝 Changed files ($FILE_COUNT):${NC}"
    echo "$CHANGED_FILES"
    echo -e "${YELLOW}⚡ Performing partial render...${NC}"
    
    # Render each changed file
    for file in $CHANGED_FILES; do
        echo -e "${BLUE}  Rendering: $file${NC}"
        quarto render "$file"
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ Error rendering $file${NC}"
            exit 1
        fi
    done
    
    echo -e "${GREEN}✅ Updated $FILE_COUNT files successfully!${NC}"
else
    echo -e "${GREEN}✨ No changes detected - site is up to date!${NC}"
fi

# Update timestamp
touch "$LAST_UPDATE_FILE"

# Show site location
echo -e "${BLUE}📁 Site location: $SITE_DIR/docs/${NC}"
echo -e "${BLUE}🌐 Preview: open $SITE_DIR/docs/index.html${NC}"