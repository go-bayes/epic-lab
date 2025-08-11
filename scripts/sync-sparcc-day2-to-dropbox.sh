#!/bin/bash

# Script to sync SPARCC Day 2 ATE presentation to epic-presentations repo
# Usage: ./scripts/sync-sparcc-day2-to-dropbox.sh

# Use the generalised sync script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="/Users/joseph/GIT/epic-pubs/2025/talks/sparcc-day-2/25-BULBULIA-SPARCC-DAY-2-ATE-CHURCH-COOP.pdf"

exec "$SCRIPT_DIR/sync-presentation-to-dropbox-general.sh" "sparcc-day-2-ate" "$SOURCE_FILE" "presentation.pdf"