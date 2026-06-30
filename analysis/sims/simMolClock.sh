#!/bin/bash

BASE=.

mkdir -p simMolClock
mkdir -p simMolClock/case1
mkdir -p simMolClock/case2
mkdir -p simMolClock/case3
mkdir -p simMolClock/case4
mkdir -p simMolClock/case5
mkdir -p simMolClock/case6
mkdir -p simMolClock/case7
mkdir -p simMolClock/case8
mkdir -p simMolClock/case1/noIntro
mkdir -p simMolClock/case2/noIntro
mkdir -p simMolClock/case3/noIntro
mkdir -p simMolClock/case4/noIntro
mkdir -p simMolClock/case5/noIntro
mkdir -p simMolClock/case6/noIntro
mkdir -p simMolClock/case7/noIntro
mkdir -p simMolClock/case8/noIntro

f=3
SEGMENT_LENGTH=20000000

for rep in {1..100}
do
	echo "python3 simMolClock.py --pop 1 --scale 1.2 --tree_sequence_file $BASE/simMolClock/case1/noIntro/rep$rep --vcf_file $BASE/simMolClock/case1/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
	echo "python3 simMolClock.py --pop 1 --scale 1.5 --tree_sequence_file $BASE/simMolClock/case2/noIntro/rep$rep --vcf_file $BASE/simMolClock/case2/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
	echo "python3 simMolClock.py --pop 1 --scale 2 --tree_sequence_file $BASE/simMolClock/case3/noIntro/rep$rep --vcf_file $BASE/simMolClock/case3/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
	echo "python3 simMolClock.py --pop 1 --scale 5 --tree_sequence_file $BASE/simMolClock/case4/noIntro/rep$rep --vcf_file $BASE/simMolClock/case4/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
	echo "python3 simMolClock.py --pop 2 --scale 1.2 --tree_sequence_file $BASE/simMolClock/case5/noIntro/rep$rep --vcf_file $BASE/simMolClock/case5/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
	echo "python3 simMolClock.py --pop 2 --scale 1.5 --tree_sequence_file $BASE/simMolClock/case6/noIntro/rep$rep --vcf_file $BASE/simMolClock/case6/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
	echo "python3 simMolClock.py --pop 2 --scale 2 --tree_sequence_file $BASE/simMolClock/case7/noIntro/rep$rep --vcf_file $BASE/simMolClock/case7/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
	echo "python3 simMolClock.py --pop 2 --scale 5 --tree_sequence_file $BASE/simMolClock/case8/noIntro/rep$rep --vcf_file $BASE/simMolClock/case8/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"

	echo "python3 simMolClock.py --pop 1 --scale 1.2 --tree_sequence_file $BASE/simMolClock/case1/rep$rep --vcf_file $BASE/simMolClock/case1/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tractsMolClock.py $BASE/simMolClock/case1/rep$rep.trees $BASE/simMolClock/case1/rep$rep 1.2"
	echo "python3 simMolClock.py --pop 1 --scale 1.5 --tree_sequence_file $BASE/simMolClock/case2/rep$rep --vcf_file $BASE/simMolClock/case2/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tractsMolClock.py $BASE/simMolClock/case2/rep$rep.trees $BASE/simMolClock/case2/rep$rep 1.5"
	echo "python3 simMolClock.py --pop 1 --scale 2 --tree_sequence_file $BASE/simMolClock/case3/rep$rep --vcf_file $BASE/simMolClock/case3/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tractsMolClock.py $BASE/simMolClock/case3/rep$rep.trees $BASE/simMolClock/case3/rep$rep 2"
	echo "python3 simMolClock.py --pop 1 --scale 5 --tree_sequence_file $BASE/simMolClock/case4/rep$rep --vcf_file $BASE/simMolClock/case4/rep$rep -f $f --sequence_length $SEGMENT_LENGTH && python3 tractsMolClock.py $BASE/simMolClock/case4/rep$rep.trees $BASE/simMolClock/case4/rep$rep 5"
	echo "python3 simMolClock.py --pop 2 --scale 1.2 --tree_sequence_file $BASE/simMolClock/case5/rep$rep --vcf_file $BASE/simMolClock/case5/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tractsMolClock.py $BASE/simMolClock/case5/rep$rep.trees $BASE/simMolClock/case5/rep$rep 1.2"
	echo "python3 simMolClock.py --pop 2 --scale 1.5 --tree_sequence_file $BASE/simMolClock/case6/rep$rep --vcf_file $BASE/simMolClock/case6/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tractsMolClock.py $BASE/simMolClock/case6/rep$rep.trees $BASE/simMolClock/case6/rep$rep 1.5"
	echo "python3 simMolClock.py --pop 2 --scale 2 --tree_sequence_file $BASE/simMolClock/case7/rep$rep --vcf_file $BASE/simMolClock/case7/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tractsMolClock.py $BASE/simMolClock/case7/rep$rep.trees $BASE/simMolClock/case7/rep$rep 2"
	echo "python3 simMolClock.py --pop 2 --scale 5 --tree_sequence_file $BASE/simMolClock/case8/rep$rep --vcf_file $BASE/simMolClock/case8/rep$rep -f $f --sequence_length $SEGMENT_LENGTH && python3 tractsMolClock.py $BASE/simMolClock/case8/rep$rep.trees $BASE/simMolClock/case8/rep$rep 5"

done | parallel -j 20

find "$BASE/simMolClock" -type f | egrep "vcf" | xargs gzip
