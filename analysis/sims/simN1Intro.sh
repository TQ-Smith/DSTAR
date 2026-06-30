#!/bin/bash

BASE=.

mkdir -p simN1Intro
f=3
SEGMENT_LENGTH=20000000

for rep in {1..100}
do
	echo "python3 sim.py --tree_sequence_file $BASE/simN1Intro/rep$rep --vcf_file $BASE/simN1Intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH && python3 tracts.py $BASE/simN1Intro/rep$rep.trees $BASE/simN1Intro/rep$rep"
done | parallel -j 20

find "$BASE/simN1Intro" -type f | egrep "vcf" | xargs gzip
