#!/bin/sh
# Tester script for assignment 1 and assignment 2
# Author: Siddhant Jajoo

set -e
set -u

NUMFILES=10
WRITESTR=AELD_IS_FUN
WRITEDIR=/tmp/aeld-data

# Make username path robust (works whether script runs from repo root or finder-app)
if [ -f ../conf/username.txt ]; then
    username=$(cat ../conf/username.txt)
elif [ -f conf/username.txt ]; then
    username=$(cat conf/username.txt)
else
    echo "ERROR: username.txt not found (looked in ../conf and conf)"
    exit 1
fi

if [ $# -lt 3 ]
then
    echo "Using default value ${WRITESTR} for string to write"
    if [ $# -lt 1 ]
    then
        echo "Using default value ${NUMFILES} for number of files to write"
    else
        NUMFILES=$1
    fi
else
    NUMFILES=$1
    WRITESTR=$2
    WRITEDIR=/tmp/aeld-data/$3
fi

MATCHSTR="The number of files are ${NUMFILES} and the number of matching lines are ${NUMFILES}"

echo "Writing ${NUMFILES} files containing string ${WRITESTR} to ${WRITEDIR}"

rm -rf "${WRITEDIR}"

# Make assignment path robust too
if [ -f ../conf/assignment.txt ]; then
    assignment=$(cat ../conf/assignment.txt)
elif [ -f conf/assignment.txt ]; then
    assignment=$(cat conf/assignment.txt)
else
    echo "ERROR: assignment.txt not found (looked in ../conf and conf)"
    exit 1
fi

# For assignment2+: build native writer executable
if [ "$assignment" != "assignment1" ]
then
    mkdir -p "$WRITEDIR"
    if [ -d "$WRITEDIR" ]
    then
        echo "$WRITEDIR created"
    else
        exit 1
    fi

    echo "Building writer executable..."
    make clean
    make
    WRITER=./writer
else
    WRITER=./writer.sh
fi

for i in $( seq 1 "$NUMFILES" )
do
    $WRITER "$WRITEDIR/${username}${i}.txt" "$WRITESTR"
done

OUTPUTSTRING=$(./finder.sh "$WRITEDIR" "$WRITESTR")

# remove temporary directories
rm -rf /tmp/aeld-data

set +e
echo "${OUTPUTSTRING}" | grep "${MATCHSTR}"
if [ $? -eq 0 ]; then
    echo "success"
    exit 0
else
    echo "failed: expected ${MATCHSTR} in ${OUTPUTSTRING} but instead found"
    exit 1
fi
