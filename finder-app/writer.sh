#!/bin/bash
#Varibles for arguments
writefile="$1"
writestr="$2"

#Validate arguments
if [ $# -ne 2 ]; then
	echo "Error: Missing arguments" >&2
	echo "Usage: $0 <writefile> <writestr>" >&2
	exit 1
fi

#if needed create directory path
dirpath=$(dirname "$writefile")
mkdir -p "$dirpath"
if [ $? -ne 0 ]; then
	echo "Error: could not create directory path $dirpath" >&2
	exit 1
fi


echo "$writestr" > "$writefile"
if [ $? -ne 0 ]; then
	echo "Error: could not create/write to file $writefile" >&2
	exit 1
fi

