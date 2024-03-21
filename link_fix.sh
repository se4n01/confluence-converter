#!/bin/bash

# Base directory of your .md files
BASE_DIR="./"

# Find all .md files and loop through them
find "$BASE_DIR" -type f -name '*.md' | while read -r file; do
    # Preprocess the file: concatenate lines that are part of the same breadcrumb entry
    # This uses a temporary file to hold the preprocessed contents
    awk 'BEGIN{RS="";FS="\n"}{gsub(/\n([0-9]+\.)/, " \\1"); gsub(/\n/, " "); print}' "$file" > /tmp/preprocessed.md
    
    # Extract the last breadcrumb link by selecting the highest-numbered item
    # Now working with the preprocessed file where line breaks in breadcrumbs have been removed
    internal_filename=$(grep -oP '^\d+\.\s+\[.*?\]\((.*?)\.html\)' /tmp/preprocessed.md | tail -1 | sed -n 's/.*\((.*\.html)\)/\1/p' | tr -d '()')
    
    # Skip files without an internal_filename
    if [ -z "$internal_filename" ]; then
        # Check the next line in case the grep missed due to line break issues
        internal_filename=$(tail -n +8 /tmp/preprocessed.md | grep -oP '^\d+\.\s+\[.*?\]\((.*?)\.html\)' | tail -1 | sed -n 's/.*\((.*\.html)\)/\1/p' | tr -d '()')
        if [ -z "$internal_filename" ]; then
            continue
        fi
    fi

    # Prepare the new link format
    new_link=$(echo "$file" | sed "s|^$BASE_DIR||;s|\.md$||")
    new_link="/${new_link}"

    # Replace all occurrences of the old link with the new link format in all .md files
    find "$BASE_DIR" -type f -name '*.md' | while read -r target_file; do
        # I use gitlab so I need to rename index.html to 'home'
        # Use sed to replace the old link with the new link, modifying files in-place
        if [[ $internal_filename != "index.html"  ]]; then
          sed -i "s|$internal_filename|$new_link|g" "$target_file"
        else
          sed -i "s|index.html|home|g" "$target_file"
        fi
    done
done

# Clean up the temporary file
rm /tmp/preprocessed.md
