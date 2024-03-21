#!/bin/bash

# Store the path of the directory containing the .md files
DIRECTORY='./'

# Find .md files in the specified directory with names that are 7 to 9 digits long
find "$DIRECTORY" -regextype egrep -regex ".*/[0-9]{7,9}\.md$" -not -path "./attachments/*" -print0 | while IFS= read -r -d $'\0' file; do
    # Extract the original filename without the path
    original_filename=$(basename "$file")
    
    # Extract the first line (title) from the file
    title=$(head -n 1 "$file" | sed 's/^# //')
    
    # Clean the title by keeping only A-Z, a-z, 0-9, dash, underscore, and replacing spaces with dashes
    clean_title=$(echo "$title" | tr ' ' '-' | sed 's/[^A-Za-z0-9_-]//g')
    
    # Append .md to the clean title to form the new filename
    new_filename="${clean_title}.md"
    
    # Prepare the full path for the new filename within the same directory
    file_dir=$(dirname "$file")
    new_file_path="${file_dir}/${new_filename}"
    
    # Rename the file with its full path to maintain its directory location
    mv "$file" "$new_file_path"
    
    # After renaming, replace occurrences of the original filename in all .md files
    find "$DIRECTORY" -type f -name '*.md' -not -path "./attachments/*" -print0 | while IFS= read -r -d $'\0' target_file; do

            rep1=`echo -n "${original_filename%.*}"`
            rep2=`echo -n "${new_filename%.*}"`
            sed -i "s/$rep1/$rep2/g" "$target_file"

    done
done

find ./*  -type f -execdir sed -i -E 's/_[0-9]{7,9}\)/\)/g' '{}' \;

