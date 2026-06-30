#!/bin/bash

BASE=.
mkdir -p runN1Intro

for rep in {1..100}
do
	echo "dplus -z -r 1000 -b 50000 $BASE/simN1Intro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runN1Intro/d_rep$rep.tsv"
	echo "dstar -z -r 1000 -b 50000 $BASE/simN1Intro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3 > $BASE/runN1Intro/dstar_rep$rep.tsv"
done | parallel -j 20
