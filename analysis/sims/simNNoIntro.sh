#!/bin/bash

BASE=.

mkdir -p simNNoIntro
SEGMENT_LENGTH=20000000

for N in 2 5 10 25
do
	mkdir -p simNNoIntro/"N$N"
	for rep in {1..100}
	do
		echo "python3 sim.py --tree_sequence_file $BASE/simNNoIntro/N$N/rep$rep --vcf_file $BASE/simNNoIntro/N$N/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH --p1_sample_size 25 --p2_sample_size $N --p3_sample_size 2 --p4_sample_size 2"
	done
done | parallel -j 20

find "$BASE/simNNoIntro" -type f | egrep "vcf" | xargs gzip
