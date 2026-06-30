#!/bin/bash

BASE=.

run_reps() {
	mu=$1
	rho=$2
	out=$3
	BASE=/storage/home/tqs5778/lab/analysisDSTAR
	for rep in {1..100}
	do
		dplus -b 50000 "${BASE}"/simAdmNoIntro/mu"${mu}/rho${rho}/"rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > "$BASE/${out}"/d_rep$rep.tsv
		dstar -b 50000 "${BASE}"/simAdmNoIntro/mu"${mu}/rho${rho}/"rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3 > "$BASE/${out}"/dstar_rep$rep.tsv
		#dstar -z -b 50000 "${BASE}"/simAdmNoIntro/mu"${mu}/rho${rho}/"rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > "$BASE/${out}"/fourPop_dstar_rep$rep.tsv
	done
}
export -f run_reps

mkdir -p "$BASE/runAdmNoIntro"
for mu in 0.75e-8 1.5e-8 3e-8
do 
    mkdir -p "$BASE/runAdmNoIntro/mu$mu"
    for rho in 0.5e-8 1e-8 2e-8
    do
	mkdir -p "$BASE/runAdmNoIntro/mu$mu/rho$rho"
	out="runAdmNoIntro/mu$mu/rho${rho}"
	echo "run_reps $mu $rho $out"
    done
done | parallel -j 20
