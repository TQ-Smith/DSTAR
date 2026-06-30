#!/bin/bash

BASE=.

mkdir -p runADNA
mkdir -p runADNA/noIntro
mkdir -p runPseudoHap
mkdir -p runPseudoHap/noIntro
mkdir -p runMissing
mkdir -p runMissing/noIntro
mkdir -p runDeamin
mkdir -p runDeamin/noIntro
f=3
SEGMENT_LENGTH=20000000


for rep in {1..100}
do
	echo "dplus -b 50000 $BASE/simMissing/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMissing/d_rep$rep.tsv"
	echo "dstar -b 50000 $BASE/simMissing/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3 > $BASE/runMissing/dstar_rep$rep.tsv"
	echo "dplus -b 50000 $BASE/simMissing/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runMissing/noIntro/d_rep$rep.tsv"
	echo "dstar -b 50000 $BASE/simMissing/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3 > $BASE/runMissing/noIntro/dstar_rep$rep.tsv"

	echo "dplus -b 50000 $BASE/simPseudoHap/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runPseudoHap/d_rep$rep.tsv"
	echo "dstar -b 50000 $BASE/simPseudoHap/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3 > $BASE/runPseudoHap/dstar_rep$rep.tsv"
	echo "dplus -b 50000 $BASE/simPseudoHap/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runPseudoHap/noIntro/d_rep$rep.tsv"
	echo "dstar -b 50000 $BASE/simPseudoHap/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3 > $BASE/runPseudoHap/noIntro/dstar_rep$rep.tsv"

	echo "dplus -b 50000 $BASE/simDeamin/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runDeamin/d_rep$rep.tsv"
	echo "dstar -b 50000 $BASE/simDeamin/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3 > $BASE/runDeamin/dstar_rep$rep.tsv"
	echo "dplus -b 50000 $BASE/simDeamin/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runDeamin/noIntro/d_rep$rep.tsv"
	echo "dstar -b 50000 $BASE/simDeamin/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3 > $BASE/runDeamin/noIntro/dstar_rep$rep.tsv"

	echo "dplus -b 50000 $BASE/simADNA/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runADNA/d_rep$rep.tsv"
	echo "dstar -b 50000 $BASE/simADNA/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3 > $BASE/runADNA/dstar_rep$rep.tsv"
	echo "dplus -b 50000 $BASE/simADNA/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runADNA/noIntro/d_rep$rep.tsv"
	echo "dstar -b 50000 $BASE/simADNA/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3 > $BASE/runADNA/noIntro/dstar_rep$rep.tsv"

done | parallel -j 20

