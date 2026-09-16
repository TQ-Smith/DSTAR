#!/bin/bash

mkdir -p n1/intro
mkdir -p n1/noIntro

# Simulate segments.
SEGMENT_LENGTH=20000000
f=3
for rep in {1..100}
do
        echo "python3 sim.py --tree_sequence_file n1/noIntro/rep$rep --vcf_file n1/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
	echo "python3 sim.py --tree_sequence_file n1/intro/rep$rep --vcf_file n1/intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH && python3 tracts.py n1/intro/rep$rep.trees n1/intro/rep$rep"
done | parallel -j 20

find "n1/intro" -type f | egrep "vcf" | xargs gzip
find "n1/noIntro" -type f | egrep "vcf" | xargs gzip

# Create sample to population labels.
seq 1 4 | awk '{print "P"$1"_0\tpop"$1}' > n1/labels.tsv

# Run statistics.
for rep in {1..100}
do
        dplus -z -r 1000 -b 50000 n1/intro/rep${rep}.vcf.gz n1/labels.tsv pop1,pop2,pop3,pop4 > n1/intro/d_rep${rep}.tsv
        dstar -z -r 1000 -b 50000 n1/intro/rep${rep}.vcf.gz n1/labels.tsv pop1,pop2,pop3 > n1/intro/dstar_rep${rep}.tsv
	dplus -b 50000 n1/noIntro/rep${rep}.vcf.gz n1/labels.tsv pop1,pop2,pop3,pop4 > n1/noIntro/d_rep${rep}.tsv
        dstar -b 50000 n1/noIntro/rep${rep}.vcf.gz n1/labels.tsv pop1,pop2,pop3 > n1/noIntro/dstar_rep${rep}.tsv
done

# Get null distribution.
bash nullDStats.sh n1/noIntro/d 9 n1/noIntro/d
bash nullDStats.sh n1/noIntro/d 10 n1/noIntro/dplus
bash nullDStats.sh n1/noIntro/dstar 8 n1/noIntro/dstar

# Calculate FPR.
python3 calcFPR.py n1/noIntro/d_null.txt > n1/noIntro/d_fpr.csv
python3 calcFPR.py n1/noIntro/dplus_null.txt > n1/noIntro/dplus_fpr.csv
python3 calcFPR.py n1/noIntro/dstar_null.txt > n1/noIntro/dstar_fpr.csv

# Calculate overlap.
for rep in {1..100}
do
	echo "python3 calcOverlap.py n1/intro/rep${rep}.csv.gz n1/intro/d_rep${rep}.tsv 1 > n1/intro/rep${rep}_overlap.csv"
done | parallel -j 20

# Calculate performance.
for rep in {1..100}
do
	echo  "python3 calcPerformanceN1.py n1/noIntro n1/intro n1/intro ${rep} > n1/intro/rep${rep}_performance.csv"
done | parallel -j 20

# Calculate genome-wide power.
bash calcGlobal.sh n1/intro
