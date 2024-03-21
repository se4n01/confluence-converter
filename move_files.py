import os
import shutil
from bs4 import BeautifulSoup

def find_directory(search_root, directory_name):
    for root, dirs, _ in os.walk(search_root):
        if directory_name in dirs:
            return os.path.join(root, directory_name)
    return None

def move_html_files_to_correct_directory(html_files_directory, search_root):
    for filename in os.listdir(html_files_directory):
        if filename.endswith(".html"):
            file_path = os.path.join(html_files_directory, filename)
            with open(file_path, 'r') as file:
                soup = BeautifulSoup(file, 'html.parser')
                breadcrumbs = soup.find(id="breadcrumbs")
                if breadcrumbs:
                    last_crumb = breadcrumbs.find_all("li")[-1]
                    last_crumb_link = last_crumb.find("a")  # Target the <a> tag specifically
                    if last_crumb_link:
                        directory_name = last_crumb_link.text.strip()
                        target_directory = find_directory(search_root, directory_name)
                        if target_directory:
                            shutil.move(file_path, target_directory)
                            print(f"Moved {filename} to {target_directory}")
                        else:
                            print(f"Directory not found for {directory_name}")
                    else:
                        print(f"No link found in the last breadcrumb for {filename}")

# Adjust these paths as necessary
html_files_directory = "./"  # The directory containing your HTML files
search_root = "./"  # The root directory to search for matching directories

move_html_files_to_correct_directory(html_files_directory, search_root)

