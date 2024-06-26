# Scripts to Convert A Confluence Export to a File Tree


## High level description

This script allows you to export a space from confluence and make it into a
hierachal file structucture on disk.

This may be useful if you want to leave Confluence and use
- Gitlab wiki
- RTD
- Sphinx
- Jeckyll

Essentially the scripts apply the following logic:
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

The structure is reproduced. Be careful if you have folders with special names. Handling those is explained in the moving files section.

### Move the files

If you are happy with the hierachy created, it is time to move the files. 

If you have a lot of special characters in titles, confluence will export the
page id instead. You can convert these to a real title by getting the title
element using python bs4, then renaming the file to the normalized title.

If you have files without crazy names with % & and whatever other strange characters,
the move will be one shot. If you see some errors like can not find
directory %&#@() then you will need to rename the relevant directory and try
the move again. If you have a lot of such files, you may need to tweak the script
to either rename the file before move or to rename the folder.

You can also just ignore the errors, the problem pages will remain in top
directory.

To perform the move, from the top level directory execute:
```
python3 move_files.py
```

### Convert the files

Now we will convert to your chosen format. I am using gitlab so I choose gitlab markdown as the target and run
```bash
find ./ -name "*.html" -type f -exec sh -c '
      pandoc -f html-native_divs-native_spans -t gfm -o "${1%.*}.md" "$1"
   ' find-sh {} \;
```

Now let's get rid of t old html files we dont need any more:

```
find . -type f -iname "*.html" -delete
```

### Cleaning t filenames and folder names
This step is used because I use gitlab and gitlab expects dash instead of space in 
filenames in t wiki. 

warning tse commands can take a long time to execute and are disk intesive
t efficiency is really poor as for every file we may read every file!

#### Lets clean t file  and folder names.

```bash
for i in {1..`find . -type d -printf '%d\n' | sort -rn | ad -1`}
do
     find ./ -type d -execdir rename 's/ /-/g' '{}' \;
done
find ./ -type f -execdir rename 's/ /-/g' '{}' \;
find ./ -type f -execdir rename 's/\(//g' '{}' \;
find ./ -type f -execdir rename 's/\)//g' '{}' \;
find ./ -type f -execdir rename 's/\&//g' '{}' \;
```

#### Fix internal links
Very slow!
```
bash link_fix.sh
```
This operation scales with the square of the number of files, for a 20000 file space it took me nearly two hours. For a 200 file space it took mere seconds.

##### Optional:
If you have ugly filenames with an _and some number in them you can use the `prettify_filenames.sh` script to clean them and update the links. My codes are around 9 digits long but if yours are longer or shorter you may need to
change the `{7,9}` in the find command. You may wish to comment out the `mv` and `sed` command or `echo` them instead in order to see what the script will do first.

If you have many files with no filename and just the id, you can run the `update_numeric_names.sh` script. This will rename them with the name found in the title and remove any strange characters then update all the links. 


### Congrats!
You now have a file hierachy with your confluence files inside with all t links working. 

Now just upload it to your chosen service. Good luck!
