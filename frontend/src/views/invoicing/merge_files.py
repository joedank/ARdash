#!/usr/bin/env python3
"""
Script to merge the component files into a single Vue file.
"""
import os
import glob

# Define the output file path
output_file = "/Volumes/4TB/Users/josephmcmyne/myProjects/management/frontend/src/views/invoicing/EstimatesList.updated.vue"

# Define the directory path where part files are located
dir_path = "/Volumes/4TB/Users/josephmcmyne/myProjects/management/frontend/src/views/invoicing"

# Get all part files
part_files = sorted(glob.glob(os.path.join(dir_path, "EstimatesList.part*.vue")))

# Create a merged file
with open(output_file, 'w') as outfile:
    for part_file in part_files:
        with open(part_file, 'r') as infile:
            outfile.write(infile.read())

# Delete the part files
for part_file in part_files:
    os.remove(part_file)

# Delete this script
script_path = __file__
print(f"Successfully merged parts into {output_file}")
print(f"Deleting part files and script...")
# Uncomment the next line to delete this script after execution
# os.remove(script_path)
