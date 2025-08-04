#!/bin/bash

# Generate placeholder images for all team members
# Uses initials for each person

TEAM_DIR="/Users/joseph/GIT/epic-lab/images/team"

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "❌ Error: ImageMagick not installed"
    echo "Install with: brew install imagemagick"
    exit 1
fi

echo "🎨 Generating placeholder images for team members..."

# Array of team members (name, initials, color)
declare -a team=(
    "joseph-bulbulia:JB:#3182ce"
    "inkuk-kim:IK:#48bb78"
    "jake-ireland:JI:#ed8936"
    "jesse-auckerman:JA:#9f7aea"
    "boyang-cao:BC:#e53e3e"
    "hannah-robinson:HR:#38b2ac"
    "zahle-wisely:ZW:#d69e2e"
    "millie-rea:MR:#805ad5"
    "johnmark-kempthorn:JK:#2d3748"
    "bella-chong:BC:#dd6b20"
)

# Create each placeholder
for member in "${team[@]}"; do
    IFS=':' read -r filename initials color <<< "$member"
    
    echo "Creating placeholder for $filename..."
    
    convert -size 400x400 xc:"$color" \
        -fill white \
        -font Helvetica-Bold \
        -pointsize 120 \
        -gravity center \
        -annotate +0+0 "$initials" \
        "$TEAM_DIR/${filename}.jpg"
done

echo "✅ All placeholders created!"
echo ""
echo "To replace with real photos, use:"
echo "./scripts/optimize-photo.sh /path/to/photo.jpg firstname-lastname"