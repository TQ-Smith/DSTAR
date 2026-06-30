#!/bin/bash

BASE=.

mkdir -p runDrift/case1/noIntro
mkdir -p runDrift/case2/noIntro
mkdir -p runDrift/case3/noIntro
mkdir -p runDrift/case4/noIntro
mkdir -p runDrift/case5/noIntro
mkdir -p runDrift/case6/noIntro

for rep in {1..100}
do
	for cases in 1 2 3 4 5 6
	do
		echo "dplus -b 50000 $BASE/simDrift/case$cases/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runDrift/case$cases/d_rep$rep.tsv"
		echo "dstar -b 50000 $BASE/simDrift/case$cases/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3 > $BASE/runDrift/case$cases/dstar_rep$rep.tsv"

		echo "dplus -b 50000 $BASE/simDrift/case$cases/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runDrift/case$cases/noIntro/d_rep$rep.tsv"
		echo "dstar -b 50000 $BASE/simDrift/case$cases/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3 > $BASE/runDrift/case$cases/noIntro/dstar_rep$rep.tsv"
	done
done | parallel -j 20


