#!/bin/bash

BASE=.
mkdir -p runDiploid/noIntro

for rep in {1..100}
do
	echo "dplus -b 50000 $BASE/simDiploid/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runDiploid/noIntro/d_rep$rep.tsv"
	echo "dstar -b 50000 $BASE/simDiploid/noIntro/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3 > $BASE/runDiploid/noIntro/dstar_rep$rep.tsv"

	echo "dplus -b 50000 $BASE/simDiploid/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3,pop4 > $BASE/runDiploid/d_rep$rep.tsv"
	echo "dstar -b 50000 $BASE/simDiploid/rep$rep.vcf.gz $BASE/popFiles/1pop12.2pop12.3pop2.4pop1.tsv pop1,pop2,pop3 > $BASE/runDiploid/dstar_rep$rep.tsv"
done | parallel -j 20
