import os
import re
from bs4 import BeautifulSoup

export_key_path = 'export_key.txt'
base_path = '.'  # Base directory for the structure
html_files_path = '.'  # Directory containing the HTML files

def clean_title(title):
    title = title.replace('Support : ', '')
    replacements = {"'": "", "%": "percent", ":": "-", "?": "", "&": "and", "\\": "-", "|": "-", "<": "", ">": "", "\"": ""}
    for old, new in replacements.items():
        title = title.replace(old, new)
    return title.strip()

def extract_title(file_path):
    with open(file_path, 'r') as file:
        soup = BeautifulSoup(file, 'html.parser')
        title_tag = soup.find('title')
        if title_tag:
            return clean_title(title_tag.text.strip())
    return None


def apply_structure():
    with open(export_key_path, 'r') as file:
        lines = file.readlines()

    title_to_file = {extract_title(os.path.join(html_files_path, f)): f for f in os.listdir(html_files_path) if f.endswith('.html')}

    current_path = [base_path]
    for i, line in enumerate(lines):
        clean_line = clean_title(line)
        if not clean_line:  # Skip empty lines
            continue

        depth = line.count('    ')  # Correct depth based on indentation
        while len(current_path) > depth + 1:  # Adjust current_path to current depth
            current_path.pop()
        if len(current_path) == depth + 1:
            current_path.pop()
        current_path.append(clean_line)  # Update or set the current level's name

        # Determine if this entry is followed by a sub-item
        next_depth = lines[i + 1].count('    ') if i + 1 < len(lines) else 0
        is_directory = next_depth > depth

        if is_directory:
            dir_path = os.path.join(*current_path)
            if not os.path.exists(dir_path):
                os.makedirs(dir_path, exist_ok=True)
                print(f"Created directory: {dir_path}")
        else:
            # Adjust the handling of files here
            pass  # This part remains for clarity; actual file handling logic will follow

    # After potentially creating directories, handle file moving
    for title, filename in title_to_file.items():
        file_path = title.split('/')
        target_dir_path = os.path.join(base_path, *file_path[:-1])
        target_path = os.path.join(target_dir_path, file_path[-1] + ".html")

apply_structure()
