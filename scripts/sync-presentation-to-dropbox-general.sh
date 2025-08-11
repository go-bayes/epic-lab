#!/bin/bash

# Generalised script to sync presentations to epic-presentations repo
# Usage: ./scripts/sync-presentation-to-dropbox-general.sh <presentation-name> <source-file> [destination-filename]

# Function to show usage
show_usage() {
    echo "Usage: $0 <presentation-name> <source-file> [destination-filename]"
    echo ""
    echo "Examples:"
    echo "  $0 apa-bier /path/to/presentation.html index.html"
    echo "  $0 sparcc-day-2 /path/to/presentation.pdf presentation.pdf"
    echo ""
    echo "Arguments:"
    echo "  presentation-name: Folder name for the presentation (e.g., apa-bier, sparcc-day-2)"
    echo "  source-file: Full path to the source file"
    echo "  destination-filename: Optional. Name for the destination file (defaults to original filename)"
    exit 1
}

# Check if minimum arguments provided
if [ $# -lt 2 ]; then
    show_usage
fi

# Configuration from arguments
PRESENTATION_NAME="$1"
SOURCE_FILE="$2"
DEST_FILENAME="${3:-$(basename "$SOURCE_FILE")}"

# Base configuration
DROPBOX_BASE="/Users/joseph/v-project Dropbox/data/epic-lab-presentations/2025"
DROPBOX_DIR="$DROPBOX_BASE/$PRESENTATION_NAME"
DEST_FILE="$DROPBOX_DIR/$DEST_FILENAME"
PRESENTATIONS_REPO="/Users/joseph/GIT/epic-presentations"

# Colours for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "🔄 Syncing $PRESENTATION_NAME presentation..."

# Check if source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo -e "${RED}❌ Error: Source file not found at $SOURCE_FILE${NC}"
    exit 1
fi

# Create destination directory if it doesn't exist
echo "📁 Checking Dropbox directory..."
if ! mkdir -p "$DROPBOX_DIR" 2>/dev/null; then
    echo -e "${RED}❌ Error: Cannot create/access Dropbox directory${NC}"
    echo -e "${RED}   Path: $DROPBOX_DIR${NC}"
    echo -e "${YELLOW}💡 This could be a Dropbox Teams permissions issue${NC}"
    echo -e "${YELLOW}   Check your Teams admin settings or contact your admin${NC}"
    exit 1
fi

# Test write permissions
TEST_FILE="$DROPBOX_DIR/.write-test-$$"
if ! touch "$TEST_FILE" 2>/dev/null; then
    echo -e "${RED}❌ Error: No write permissions in Dropbox directory${NC}"
    echo -e "${RED}   Path: $DROPBOX_DIR${NC}"
    echo -e "${YELLOW}💡 Possible causes:${NC}"
    echo -e "${YELLOW}   - Dropbox Teams folder restrictions${NC}"
    echo -e "${YELLOW}   - macOS security permissions${NC}"
    echo -e "${YELLOW}   - Dropbox sync issues${NC}"
    exit 1
else
    rm -f "$TEST_FILE"
fi

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

# Create backup if destination exists
if [ -f "$DEST_FILE" ]; then
    BACKUP_FILE="${DEST_FILE}.backup"
    echo "🔒 Creating backup at $BACKUP_FILE"
    cp "$DEST_FILE" "$BACKUP_FILE"
fi

# Copy the file
echo "📋 Copying presentation..."
if cp "$SOURCE_FILE" "$DEST_FILE" 2>&1; then
    echo -e "${GREEN}✅ Presentation copied successfully${NC}"
    
    # Verify the file was copied correctly
    if [ -f "$DEST_FILE" ]; then
        NEW_HASH=$(shasum -a 256 "$DEST_FILE" | cut -d' ' -f1)
        SOURCE_HASH=$(shasum -a 256 "$SOURCE_FILE" | cut -d' ' -f1)
        
        if [ "$NEW_HASH" != "$SOURCE_HASH" ]; then
            echo -e "${RED}❌ Error: File integrity check failed!${NC}"
            # Restore backup if it exists
            if [ -f "${DEST_FILE}.backup" ]; then
                echo "🔄 Restoring from backup..."
                mv "${DEST_FILE}.backup" "$DEST_FILE"
            fi
            exit 1
        fi
        
        # Remove backup after successful verification
        if [ -f "${DEST_FILE}.backup" ]; then
            rm "${DEST_FILE}.backup"
        fi
    fi
    
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
    echo -e "${RED}❌ Error: Failed to copy file to Dropbox${NC}"
    echo -e "${RED}   This could be due to:${NC}"
    echo -e "${RED}   - Dropbox Teams folder permissions${NC}"
    echo -e "${RED}   - Dropbox sync issues${NC}"
    echo -e "${RED}   - Disk space limitations${NC}"
    echo -e "${YELLOW}💡 Try:${NC}"
    echo -e "${YELLOW}   1. Check Dropbox app is running and synced${NC}"
    echo -e "${YELLOW}   2. Verify you have write permissions in Teams admin console${NC}"
    echo -e "${YELLOW}   3. Check available disk space${NC}"
    exit 1
fi