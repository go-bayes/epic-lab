#!/bin/bash

# Script to sync APA-BIER presentation to epic-presentations repo
# Usage: ./scripts/sync-presentation.sh

# Configuration
SOURCE_FILE="/Users/joseph/GIT/epic-pubs/2025/talks/25-BULBULIA-APA-BIER.html"
DROPBOX_DIR="/Users/joseph/v-project Dropbox/data/epic-lab-presentations/2025/apa-bier"
DEST_FILE="$DROPBOX_DIR/index.html"
# Keep git repo path for potential redirect file
PRESENTATIONS_REPO="/Users/joseph/GIT/epic-presentations"

# Colours for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🔄 Syncing APA-BIER presentation..."

# Check if source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo -e "${RED}❌ Error: Source file not found at $SOURCE_FILE${NC}"
    exit 1
fi

# Create destination directory if it doesn't exist
mkdir -p "$DROPBOX_DIR"

# Get file sizes for comparison
if [ -f "$DEST_FILE" ]; then
    SOURCE_SIZE=$(stat -f%z "$SOURCE_FILE" 2>/dev/null || stat -c%s "$SOURCE_FILE" 2>/dev/null)
    DEST_SIZE=$(stat -f%z "$DEST_FILE" 2>/dev/null || stat -c%s "$DEST_FILE" 2>/dev/null)
    
    if [ "$SOURCE_SIZE" = "$DEST_SIZE" ]; then
        SOURCE_HASH=$(shasum -a 256 "$SOURCE_FILE" | cut -d' ' -f1)
        DEST_HASH=$(shasum -a 256 "$DEST_FILE" | cut -d' ' -f1)
        
        if [ "$SOURCE_HASH" = "$DEST_HASH" ]; then
            echo -e "${YELLOW}⚡ Files are identical, no update needed${NC}"
            exit 0
        fi
    fi
fi

# Copy the file
echo "📋 Copying presentation..."
cp "$SOURCE_FILE" "$DEST_FILE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Presentation copied successfully${NC}"
    
    # Show file size
    SIZE=$(du -h "$DEST_FILE" | cut -f1)
    echo "📊 File size: $SIZE"
    
    echo ""
    echo -e "${GREEN}✅ Presentation synced to Dropbox!${NC}"
    echo "📁 Location: $DROPBOX_DIR"
    echo ""
    
    # Update the website
    echo "🔄 Updating website..."
    cd "/Users/joseph/GIT/epic-lab"
    
    # Render the presentations page
    if command -v quarto &> /dev/null; then
        quarto render presentations.qmd
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Website updated successfully${NC}"
        else
            echo -e "${YELLOW}⚠️  Website update failed. Run 'quarto render presentations.qmd' manually${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Quarto not found. Please update the website manually${NC}"
    fi
    
    echo ""
    echo "📤 All done! Your presentation is:"
    echo "1. ✅ Synced to Dropbox"
    echo "2. ✅ Website updated (if Quarto is installed)"
    echo ""
    echo "🌐 View your presentation at:"
    echo "   https://go-bayes.github.io/epic-lab/presentations.html"
else
    echo -e "${RED}❌ Error: Failed to copy presentation${NC}"
    exit 1
fi