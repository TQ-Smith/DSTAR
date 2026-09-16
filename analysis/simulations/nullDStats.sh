#!/bin/bash

inFile=$1
col=$2
out=$3
# Create our null distribution.
rm "$out"_null.txt
for rep in {1..100}
do
	head -n -1 "$inFile"_rep"$rep".tsv | egrep -v "^#" | cut -f "$col" | egrep -v "nan" >> "$out"_null.txt
done

