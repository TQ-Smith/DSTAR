#!/bin/bash

BASE=.

mkdir -p simNIntro
SEGMENT_LENGTH=20000000
f=3

for N in 2 5 10 25
do
	mkdir -p simNIntro/"N$N"
	for rep in {1..100}
	do
		echo "python3 sim.py --tree_sequence_file $BASE/simNIntro/N$N/rep$rep --vcf_file $BASE/simNIntro/N$N/rep$rep -f $f --sequence_length $SEGMENT_LENGTH --p1_sample_size 25 --p2_sample_size $N --p3_sample_size 2 --p4_sample_size 2 && python3 tracts.py $BASE/simNIntro/N$N/rep$rep.trees $BASE/simNIntro/N$N/rep$rep"
	done
done | parallel -j 20

find "$BASE/simNIntro" -type f | egrep "vcf" | xargs gzip
