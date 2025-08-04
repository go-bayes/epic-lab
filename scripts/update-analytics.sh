#!/bin/bash

# Script to update Google Analytics ID in _quarto.yml
# Usage: ./scripts/update-analytics.sh G-YOUR_ACTUAL_ID

if [ $# -eq 0 ]; then
    echo "❌ Error: Please provide your Google Analytics ID"
    echo "Usage: $0 G-YOUR_ACTUAL_ID"
    echo "Example: $0 G-ABC123XYZ"
    exit 1
fi

GA_ID=$1
CONFIG_FILE="/Users/joseph/GIT/epic-lab/_quarto.yml"

# Validate GA ID format
if [[ ! $GA_ID =~ ^G-[A-Z0-9]+$ ]]; then
    echo "❌ Error: Invalid Google Analytics ID format"
    echo "ID should start with 'G-' followed by alphanumeric characters"
    echo "Example: G-ABC123XYZ"
    exit 1
fi

# Update the config file
sed -i.bak "s/google-analytics: \"G-XXXXXXXXXX\"/google-analytics: \"$GA_ID\"/" "$CONFIG_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Successfully updated Google Analytics ID to: $GA_ID"
    echo "📝 Backup saved as: ${CONFIG_FILE}.bak"
    echo ""
    echo "Next steps:"
    echo "1. Run: quarto render"
    echo "2. Commit and push changes"
    echo "3. Analytics will be active on the live site"
else
    echo "❌ Error updating the config file"
    exit 1
fi