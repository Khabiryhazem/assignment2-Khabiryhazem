#!/bin/bash

#variables
filesdir="$1"
searchstr="$2"




#check arguments intake
if [ $# -ne 2 ]; then
	echo "Error: this script takes 2 arrguments" >&2
	echo "Usage: $0 <filesdir> <searchstr>" >&2
	exit 1
fi


#check if the directory exists
if [ ! -d "$filesdir" ]; then
	echo "Error: $filesdir is not a directory"
	exit 1
fi


#count the files inside the directory
file_count=$(find "$filesdir" -type f | wc -l)



#count the number of matching lines found
matching_lines=$(grep -r -F "$searchstr" "$filesdir" 2>/dev/null | wc -l)


#printing
echo "The number of files are $file_count and the number of matching lines are $matching_lines"



#hkk
