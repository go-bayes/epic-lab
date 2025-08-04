#!/bin/bash

# Create a placeholder image for team members without photos
# Requires ImageMagick

OUTPUT_DIR="/Users/joseph/GIT/epic-lab/images/team"
OUTPUT_FILE="$OUTPUT_DIR/placeholder.png"

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "❌ Error: ImageMagick not installed"
    echo "Install with: brew install imagemagick"
    exit 1
fi

echo "🎨 Creating placeholder image..."

# Create a 400x400 placeholder with a user icon
convert -size 400x400 xc:"#f7fafc" \
    -fill "#718096" \
    -draw "circle 200,200 200,100" \
    -draw "circle 200,140 200,110" \
    -draw "rectangle 120,220 280,320" \
    "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Placeholder created: $OUTPUT_FILE"
    echo ""
    echo "Usage in team.qmd:"
    echo "![Team Member](images/team/placeholder.png){.team-photo}"
else
    echo "❌ Error creating placeholder"
    exit 1
fi