#!/bin/bash

BASE=.

mkdir -p simADNA
mkdir -p simADNA/noIntro
mkdir -p simDiploid
mkdir -p simDiploid/noIntro
mkdir -p simPseudoHap
mkdir -p simPseudoHap/noIntro
mkdir -p simMissing
mkdir -p simMissing/noIntro
mkdir -p simDeamin
mkdir -p simDeamin/noIntro

f=3
SEGMENT_LENGTH=20000000

for rep in {1..100}
do
	echo "python3 sim.py --p1_sample_size 12 --p2_sample_size 12 --p3_sample_size 2 --p4_sample_size 1 --ploidy 2 --tree_sequence_file $BASE/simDiploid/rep$rep --vcf_file $BASE/simDiploid/rep$rep -f $f --sequence_length $SEGMENT_LENGTH && python3 tracts.py $BASE/simDiploid/rep$rep.trees $BASE/simDiploid/rep$rep"
	echo "python3 sim.py --p1_sample_size 12 --p2_sample_size 12 --p3_sample_size 2 --p4_sample_size 1 --ploidy 2 --tree_sequence_file $BASE/simDiploid/noIntro/rep$rep --vcf_file $BASE/simDiploid/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
done | parallel -j 20

find "$BASE/simDiploid" -type f | egrep "vcf" | xargs gzip

for rep in {1..100}
do
	echo "eggs -b 0.55,0.23 < $BASE/simDiploid/rep$rep.vcf.gz > simMissing/rep$rep.vcf.gz"
	echo "eggs -b 0.55,0.23 < $BASE/simDiploid/noIntro/rep$rep.vcf.gz > simMissing/noIntro/rep$rep.vcf.gz"

	echo "eggs -s < $BASE/simDiploid/rep$rep.vcf.gz > simPseudoHap/rep$rep.vcf.gz"
        echo "eggs -s < $BASE/simDiploid/noIntro/rep$rep.vcf.gz > simPseudoHap/noIntro/rep$rep.vcf.gz"

	echo "eggs -d 0.0776,0.05 < $BASE/simDiploid/rep$rep.vcf.gz > simDeamin/rep$rep.vcf.gz"
        echo "eggs -d 0.0776,0.05 < $BASE/simDiploid/noIntro/rep$rep.vcf.gz > simDeamin/noIntro/rep$rep.vcf.gz"

	echo "eggs -d 0.0776,0.05 -b 0.55,0.23 -s < $BASE/simDiploid/rep$rep.vcf.gz > simADNA/rep$rep.vcf.gz"
        echo "eggs -d 0.0776,0.05 -b 0.55,0.23 -s < $BASE/simDiploid/noIntro/rep$rep.vcf.gz > simADNA/noIntro/rep$rep.vcf.gz"
done | parallel -j 20

cp simDiploid/*.csv.gz simMissing
cp simDiploid/*.csv.gz simDeamin
cp simDiploid/*.csv.gz simPseudoHap
cp simDiploid/*.csv.gz simADNA
