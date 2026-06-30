#!/bin/bash

BASE=.

mkdir -p simN1NoIntro
SEGMENT_LENGTH=20000000

for rep in {1..100}
do
	echo "python3 sim.py --tree_sequence_file $BASE/simN1NoIntro/rep$rep --vcf_file $BASE/simN1NoIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
done | parallel -j 20

find "$BASE/simN1NoIntro" -type f | egrep "vcf" | xargs gzip
