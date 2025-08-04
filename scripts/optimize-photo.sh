#!/bin/bash

# Script to optimize team photos for web use
# Requires ImageMagick: brew install imagemagick

# Usage: ./scripts/optimize-photo.sh input.jpg firstname-lastname
# Example: ./scripts/optimize-photo.sh ~/Desktop/joe.jpg joseph-bulbulia

if [ $# -lt 2 ]; then
    echo "❌ Error: Please provide input file and output name"
    echo "Usage: $0 input.jpg firstname-lastname"
    echo "Example: $0 ~/Desktop/photo.jpg jane-doe"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_NAME="$2"
TEAM_DIR="/Users/joseph/GIT/epic-lab/images/team"
OUTPUT_FILE="$TEAM_DIR/${OUTPUT_NAME}.jpg"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: Input file not found: $INPUT_FILE"
    exit 1
fi

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "❌ Error: ImageMagick not installed"
    echo "Install with: brew install imagemagick"
    exit 1
fi

echo "🖼️  Optimizing photo..."

# Create square crop (400x400), optimize quality, and limit file size
convert "$INPUT_FILE" \
    -resize 400x400^ \
    -gravity center \
    -extent 400x400 \
    -quality 85 \
    -strip \
    -interlace Plane \
    -gaussian-blur 0.05 \
    -define jpeg:extent=200KB \
    "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    # Get file size
    SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    echo "✅ Photo optimized successfully!"
    echo "📁 Output: $OUTPUT_FILE"
    echo "📊 Size: $SIZE"
    echo ""
    echo "Add to team.qmd with:"
    echo "![${OUTPUT_NAME}](images/team/${OUTPUT_NAME}.jpg)"
else
    echo "❌ Error optimizing photo"
    exit 1
fi