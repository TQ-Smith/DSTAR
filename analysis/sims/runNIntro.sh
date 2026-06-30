#!/bin/bash

BASE=.
mkdir -p runNIntro

for N in 2 5 10 25
do
	mkdir -p runNIntro/N"$N"
	for rep in {1..100}
	do
		echo "dplus -z -r 1000 -b 50000 $BASE/simNIntro/N$N/rep$rep.vcf.gz $BASE/popFiles/1pop25.2pop$N.3pop2.4pop2.tsv pop1,pop2,pop3,pop4 > $BASE/runNIntro/N$N/d_rep$rep.tsv"
		echo "dstar -z -r 1000 -b 50000 $BASE/simNIntro/N$N/rep$rep.vcf.gz $BASE/popFiles/1pop25.2pop$N.3pop2.4pop2.tsv pop1,pop2,pop3 > $BASE/runNIntro/N$N/dstar_rep$rep.tsv"
	done
done | parallel -j 20
