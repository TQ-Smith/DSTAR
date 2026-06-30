#!/bin/bash

BASE=.
mkdir -p runNNoIntro

for N in 2 5 10 25
do
	for rep in {1..100}
	do
		mkdir -p runNNoIntro/N"$N"
		echo "dplus -b 50000 $BASE/simNNoIntro/N$N/rep$rep.vcf.gz $BASE/popFiles/1pop25.2pop$N.3pop2.4pop2.tsv pop1,pop2,pop3,pop4 > $BASE/runNNoIntro/N$N/d_rep$rep.tsv"
		echo "dstar -b 50000 $BASE/simNNoIntro/N$N/rep$rep.vcf.gz $BASE/popFiles/1pop25.2pop$N.3pop2.4pop2.tsv pop1,pop2,pop3 > $BASE/runNNoIntro/N$N/dstar_rep$rep.tsv"
	done
done | parallel -j 20
