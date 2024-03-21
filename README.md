# Scripts to Convert A Confluence Export to a File Tree


## High level description

This script allows you to export a space from confluence and make it into a
hierachal file structucture on disk.

This may be useful if you want to leave Confluence and use
- Gitlab wiki
- RTD
- Sphinx
- Jeckyll

Esentially the scripts apply the following logic:
1. Create the folder structure from the Confluence 'export key'
2. Rename all the folders and files to remove special char and spaces
3. Move the files into the correct position in the hierachy
4. Recursively fix all the links in all the files to satisfy new hierachy

## Usage

### Export Key Setup
We need to generate an 'export key'. The export key is simply the copy and pasted 
text from the export dialogue box in Confluence shown here:

Copy and paste this data into file called export_key.txt

[Howe to export - Screenshot](create_export_key.png)

Remove the extra linebreaks: `sed -i '/^$/d' export_key.txt`
IMPORTANT: Remove the additional space on the first line of the file!

We now have a key file who's line indentation defines the folder hierachy.


### Get the zip file and unpack it
From the confluence export where we obtained the key, export the zip file in html format.

Unzip it, and move export_key.txt into this directory.

### Create folder hierachy
Now we run the create_structure.py script to generate the structure. create_structure.py should
be placed in the root of thge export folder. 

Execute with `python3 create_structure.py`

The structure is reproduced. 

### Move the files

