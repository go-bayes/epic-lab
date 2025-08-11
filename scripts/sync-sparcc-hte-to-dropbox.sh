#!/bin/bash

# Script to sync SPARCC Day 2 HTE presentation to epic-presentations repo
# Usage: ./scripts/sync-sparcc-hte-to-dropbox.sh

# Use the generalised sync script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_FILE="/Users/joseph/GIT/epic-pubs/2025/talks/sparcc-day-2/25-BULBULIA-SPARCC-DAY-2-HTE-CHURCH-COOP.pdf"

exec "$SCRIPT_DIR/sync-presentation-to-dropbox-general.sh" "sparcc-day-2-hte" "$SOURCE_FILE" "presentation.pdf"