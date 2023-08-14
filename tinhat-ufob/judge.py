import os
import difflib
from datetime import datetime

# Directory path
dir_path = 'master_list/ufob'
output_path = 'detected_changes/ufob'

# Get all files in the directory
files = [f for f in os.listdir(dir_path) if os.path.isfile(os.path.join(dir_path, f))]

# Ensure there are at least two files
if len(files) < 2:
    print("Not enough files to compare")
    exit(1)

# Sort files by modification date
files.sort(key=lambda x: os.path.getmtime(os.path.join(dir_path, x)))

# Get the two most recent files
file1 = os.path.join(dir_path, files[-1])
file2 = os.path.join(dir_path, files[-2])

# Read the files
with open(file1) as f1, open(file2) as f2:
    file1_lines = f1.readlines()
    file2_lines = f2.readlines()

# Get the diff in HTML
diff = difflib.HtmlDiff().make_file(file1_lines, file2_lines, fromdesc=file1, todesc=file2)

# Prepare output filename with timestamp
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
output_filename = f"file_diff_{timestamp}.html"
output_file_path = os.path.join(output_path, output_filename)

# Write the diff to the output file
with open(output_file_path, 'w') as outfile:
    outfile.write(diff)

print(f"Difference written to {output_file_path}")
