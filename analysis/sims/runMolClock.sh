#!/bin/bash

BASE=.

mkdir -p runMolClock
mkdir -p runMolClock/case1
mkdir -p runMolClock/case2
mkdir -p runMolClock/case3
mkdir -p runMolClock/case4
mkdir -p runMolClock/case5
mkdir -p runMolClock/case6
mkdir -p runMolClock/case7
mkdir -p runMolClock/case8
mkdir -p runMolClock/case1/noIntro
mkdir -p runMolClock/case2/noIntro
mkdir -p runMolClock/case3/noIntro
mkdir -p runMolClock/case4/noIntro
mkdir -p runMolClock/case5/noIntro
mkdir -p runMolClock/case6/noIntro
mkdir -p runMolClock/case7/noIntro
mkdir -p runMolClock/case8/noIntro

for rep in {1..100}
do
	for cases in 1 2 3 4 5 6 7 8
	do
		echo "dplus -b 50000 $BASE/simMolClock/case$cases/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case$cases/d_rep$rep.tsv"
		echo "dstar -b 50000 $BASE/simMolClock/case$cases/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3 > $BASE/runMolClock/case$cases/dstar_rep$rep.tsv"

		echo "dplus -b 50000 $BASE/simMolClock/case$cases/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case$cases/noIntro/d_rep$rep.tsv"
		echo "dstar -b 50000 $BASE/simMolClock/case$cases/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3 > $BASE/runMolClock/case$cases/noIntro/dstar_rep$rep.tsv"
	done
	#echo "dplus -b 50000 $BASE/simMolClock/case1/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case1/noIntro/d_rep$rep.tsv"
	#echo "dstar -b 50000 $BASE/simMolClock/case1/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3 > $BASE/runMolClock/case1/noIntro/dstar_rep$rep.tsv"
	#echo "dstar -z -b 50000 $BASE/simMolClock/case1/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case1/noIntro/fourPop_dstar_rep$rep.tsv"

	#echo "dplus -b 50000 $BASE/simMolClock/case1/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case1/d_rep$rep.tsv"
	#echo "dstar -b 50000 $BASE/simMolClock/case1/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3 > $BASE/runMolClock/case1/dstar_rep$rep.tsv"
	#echo "dstar -z -b 50000 $BASE/simMolClock/case1/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case1/fourPop_dstar_rep$rep.tsv"

	#echo "dplus -b 50000 $BASE/simMolClock/case2/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case2/noIntro/d_rep$rep.tsv"
	#echo "dstar -b 50000 $BASE/simMolClock/case2/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3 > $BASE/runMolClock/case2/noIntro/dstar_rep$rep.tsv"
	#echo "dstar -z -b 50000 $BASE/simMolClock/case2/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case2/noIntro/fourPop_dstar_rep$rep.tsv"

	#echo "dplus -b 50000 $BASE/simMolClock/case2/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case2/d_rep$rep.tsv"
	#echo "dstar -b 50000 $BASE/simMolClock/case2/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3 > $BASE/runMolClock/case2/dstar_rep$rep.tsv"
	#echo "dstar -z -b 50000 $BASE/simMolClock/case2/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case2/fourPop_dstar_rep$rep.tsv"

	#echo "dplus -b 50000 $BASE/simMolClock/case3/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case3/noIntro/d_rep$rep.tsv"
	#echo "dstar -b 50000 $BASE/simMolClock/case3/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3 > $BASE/runMolClock/case3/noIntro/dstar_rep$rep.tsv"
	#echo "dstar -z -b 50000 $BASE/simMolClock/case3/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case3/noIntro/fourPop_dstar_rep$rep.tsv"

	#echo "dplus -b 50000 $BASE/simMolClock/case3/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case3/d_rep$rep.tsv"
	#echo "dstar -b 50000 $BASE/simMolClock/case3/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3 > $BASE/runMolClock/case3/dstar_rep$rep.tsv"
	#echo "dstar -z -b 50000 $BASE/simMolClock/case3/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case3/fourPop_dstar_rep$rep.tsv"

	#echo "dplus -b 50000 $BASE/simMolClock/case4/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case4/noIntro/d_rep$rep.tsv"
	#echo "dstar -b 50000 $BASE/simMolClock/case4/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3 > $BASE/runMolClock/case4/noIntro/dstar_rep$rep.tsv"
	#echo "dstar -z -b 50000 $BASE/simMolClock/case4/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case4/noIntro/fourPop_dstar_rep$rep.tsv"

	#echo "dplus -b 50000 $BASE/simMolClock/case4/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case4/d_rep$rep.tsv"
	#echo "dstar -b 50000 $BASE/simMolClock/case4/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3 > $BASE/runMolClock/case4/dstar_rep$rep.tsv"
	#echo "dstar -z -b 50000 $BASE/simMolClock/case4/rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMolClock/case4/fourPop_dstar_rep$rep.tsv"
done | parallel -j 20


