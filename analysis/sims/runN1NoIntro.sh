#!/bin/bash

BASE=.
mkdir -p runN1NoIntro

for rep in {1..100}
do
	echo "dplus -b 50000 $BASE/simN1NoIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runN1NoIntro/d_rep$rep.tsv"
	echo "dstar -b 50000 $BASE/simN1NoIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3 > $BASE/runN1NoIntro/dstar_rep$rep.tsv"
done | parallel -j 20
