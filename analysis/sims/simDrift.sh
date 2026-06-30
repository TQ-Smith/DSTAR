#!/bin/bash

BASE=.

mkdir -p simDrift/case1/noIntro
mkdir -p simDrift/case2/noIntro
mkdir -p simDrift/case3/noIntro
mkdir -p simDrift/case4/noIntro
mkdir -p simDrift/case5/noIntro
mkdir -p simDrift/case6/noIntro

f=3
SEGMENT_LENGTH=20000000

for rep in {1..100}
do
	echo "python3 simDrift.py --pop 1 --ne 2500 --tree_sequence_file $BASE/simDrift/case1/noIntro/rep$rep --vcf_file $BASE/simDrift/case1/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
	echo "python3 simDrift.py --pop 1 --ne 5000 --tree_sequence_file $BASE/simDrift/case2/noIntro/rep$rep --vcf_file $BASE/simDrift/case2/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
	echo "python3 simDrift.py --pop 1 --ne 25000 --tree_sequence_file $BASE/simDrift/case3/noIntro/rep$rep --vcf_file $BASE/simDrift/case3/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
	
	echo "python3 simDrift.py --pop 2 --ne 2500 --tree_sequence_file $BASE/simDrift/case4/noIntro/rep$rep --vcf_file $BASE/simDrift/case4/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
	echo "python3 simDrift.py --pop 2 --ne 5000 --tree_sequence_file $BASE/simDrift/case5/noIntro/rep$rep --vcf_file $BASE/simDrift/case5/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
	echo "python3 simDrift.py --pop 2 --ne 25000 --tree_sequence_file $BASE/simDrift/case6/noIntro/rep$rep --vcf_file $BASE/simDrift/case6/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"

	echo "python3 simDrift.py --pop 1 --ne 2500 --tree_sequence_file $BASE/simDrift/case1/rep$rep --vcf_file $BASE/simDrift/case1/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tracts.py $BASE/simDrift/case1/rep$rep.trees $BASE/simDrift/case1/rep$rep"
	echo "python3 simDrift.py --pop 1 --ne 5000 --tree_sequence_file $BASE/simDrift/case2/rep$rep --vcf_file $BASE/simDrift/case2/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tracts.py $BASE/simDrift/case2/rep$rep.trees $BASE/simDrift/case2/rep$rep"
	echo "python3 simDrift.py --pop 1 --ne 25000 --tree_sequence_file $BASE/simDrift/case3/rep$rep --vcf_file $BASE/simDrift/case3/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tracts.py $BASE/simDrift/case3/rep$rep.trees $BASE/simDrift/case3/rep$rep"
	
	echo "python3 simDrift.py --pop 2 --ne 2500 --tree_sequence_file $BASE/simDrift/case4/rep$rep --vcf_file $BASE/simDrift/case4/rep$rep -f $f --sequence_length $SEGMENT_LENGTH && python3 tracts.py $BASE/simDrift/case4/rep$rep.trees $BASE/simDrift/case4/rep$rep"
	echo "python3 simDrift.py --pop 2 --ne 5000 --tree_sequence_file $BASE/simDrift/case5/rep$rep --vcf_file $BASE/simDrift/case5/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tracts.py $BASE/simDrift/case5/rep$rep.trees $BASE/simDrift/case5/rep$rep"
	echo "python3 simDrift.py --pop 2 --ne 25000 --tree_sequence_file $BASE/simDrift/case6/rep$rep --vcf_file $BASE/simDrift/case6/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tracts.py $BASE/simDrift/case6/rep$rep.trees $BASE/simDrift/case6/rep$rep"
done | parallel -j 20

find "$BASE/simDrift" -type f | egrep "vcf" | xargs gzip
