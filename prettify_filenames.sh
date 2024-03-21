#!/bin/bash

# Store the path of the directory containing the .md files
DIRECTORY='./'

# Find all .md files in the specified directory
find "$DIRECTORY" -type f -name '*.md' -print0 | while IFS= read -r -d $'\0' file; do
    # Extract the full path directory of the current file
    file_dir=$(dirname "$file")

    # Extract the original filename without the path
    original_filename=$(basename "$file")
    
    # Generate the new filename by removing the _NUMBER part
    new_filename=$(echo "$original_filename" | sed -E 's/_[0-9]+(\.md)$/\1/')
    
    # Prepare the full path for the new filename within the same directory
    new_file_path="${file_dir}/${new_filename}"

    # If the new filename is different from the original
    if [ "$original_filename" != "$new_filename" ]; then
        # Rename the file with its full path to maintain its directory location
       mv "$file" "$new_file_path"
        
        # After renaming, replace occurrences of the original filename in all .md files
        # This loop goes through each .md file for replacing the filename
        find "$DIRECTORY" -type f -name '*.md' -print0 | while IFS= read -r -d $'\0' target_file; do
            # Using sed to replace the original filename with the new filename within each file
            # Note: GNU sed's -i for in-place editing, macOS users may need to add '' after -i
            rep1=`echo -n "${original_filename%.*}"`
            rep2=`echo -n "${new_filename%.*}"`
            sed -i "s/$rep1/$rep2/g" "$target_file"
        done
    fi
done

find ./*  -type f -execdir sed -i -E 's/_[0-9]{7,9}\)/\)/g' '{}' \;
