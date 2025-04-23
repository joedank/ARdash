#!/bin/bash

# Script to combine part1.vue and part2.vue files into the final WorkTypesList.vue

COMPONENT_DIR="/Volumes/4TB/Users/josephmcmyne/myProjects/management/frontend/src/components/work-types"
PART1="$COMPONENT_DIR/part1.vue"
PART2="$COMPONENT_DIR/part2.vue"
PART2_CONTINUED="$COMPONENT_DIR/part2_continued.vue"
OUTPUT="$COMPONENT_DIR/WorkTypesList.vue"

# Check if all required files exist
if [ ! -f "$PART1" ] || [ ! -f "$PART2" ] || [ ! -f "$PART2_CONTINUED" ]; then
  echo "Error: One or more source files are missing!"
  exit 1
fi

# Create a temporary file for the combined content
TMP_FILE=$(mktemp)

# Extract the content from part1.vue
cat "$PART1" > "$TMP_FILE"

# Extract content from part2.vue except for the first and last line (which are closing div and template tags)
# and append to the temporary file, skipping duplicate lines
cat "$PART2" | sed '1d' >> "$TMP_FILE"

# Extract content from part2_continued.vue and append to the script part
cat "$PART2_CONTINUED" >> "$TMP_FILE"

# Move the temporary file to the final destination
mv "$TMP_FILE" "$OUTPUT"

echo "Successfully combined files into $OUTPUT"

# Clean up temporary part files (optional)
# rm "$PART1" "$PART2" "$PART2_CONTINUED"

exit 0
