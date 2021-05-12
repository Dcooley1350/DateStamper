#!/bin/bash

#
#  Created by Devin Cooley(devincooley.dev@gmail.com, Dcooley1350@github.com) on 5/12/2021
#  Licensed under a Creative Commons Attribution 4.0 International License.
#

# Help text
IFS='' read -r -d '' helptext <<"EOF"
USAGE: dateStamper [options] DIRECTORY FILE_PATTERN

Time stamps files in the supplied directory that match the given
pattern. Files are renamed <name>.<date>.<extension>.
Default date pattern is YYYY-MM-DD.

  -h       : prints this help text
  -d [ARG] : supply a custom date pattern to bash's date function.
  -r       : rename all files in current and child directories
EOF

# Collect opts and process
while getopts "hrd:" opt; do
    case $opt in
        h)
            echo "$helptext"
            exit 2
            ;;
        d)
            DATE_PATTERN=$OPTARG
            echo "Using date pattern: $OPTARG ."
            ;;
        r)
            echo "-r set, recursively naming files in current and subdirectories."
            RECURSIVE=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            echo "$helptext"
            exit 1
            ;;
    esac
done

shift $(($#-2)) # Remove all options and leave last two params, which should be pattern and directory

# Collect args and process
DIRECTORY=$1
FILE_PATTERN=$2
shift 2

if [[ -z "${DIRECTORY}" ]]; then
    echo "DIRECTORY variable needs to be set! Exiting..."
    echo "$helptext"
    exit 1
fi

if [[ -z "${FILE_PATTERN}" ]]; then
    echo "FILE_PATTERN variable needs to be set! Exiting..."
    echo "$helptext"
    exit 1
fi

# Set DATE_PATTERN to default if user did not provide an alternative
if [[ -z "${DATE_PATTERN}" ]]; then
echo "Using default date pattern YYYY-MM-DD."
    DATE_PATTERN="%Y-%m-%d"
fi

# Set up for recursive stamping of all subdirectories
if [ "$RECURSIVE" = true ]; then
    shopt -s globstar #Set globstar so child directories are searched for files that match pattern
    FILE_PATTERN="**/$FILE_PATTERN"
fi

# Move to directory provided
cd $DIRECTORY

# Rename every file matching FILE_PATTERN
for file in $FILE_PATTERN; do
    dirName=$(dirname "$file")
    baseName=$(basename -- "$file")
    extension="${baseName##*.}"
    fileName="${baseName%.*}"
    stampedFileName=$fileName.$(date +"$DATE_PATTERN").$extension
    mv "$file" "$dirName/$stampedFileName"
    echo "Renamed: $dirName/$file -> $dirName/$stampedFileName"
done

exit 0