#!/bin/bash

# Script to sync APA-BIER presentation to epic-presentations repo  
# Usage: ./scripts/sync-presentation-to-dropbox.sh

# Use the generalised sync script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="/Users/joseph/GIT/epic-pubs/2025/talks/25-BULBULIA-APA-BIER.html"

exec "$SCRIPT_DIR/sync-presentation-to-dropbox-general.sh" "apa-bier" "$SOURCE_FILE" "index.html"