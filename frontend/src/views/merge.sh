#!/bin/bash

# Merge the split SettingsView files into the final file
cat SettingsView1.vue > SettingsView.vue
cat SettingsView2.vue | tail -n +1 >> SettingsView.vue

# Give execution permissions to this script
chmod +x merge.sh

echo "Merged SettingsView1.vue and SettingsView2.vue into SettingsView.vue successfully."
