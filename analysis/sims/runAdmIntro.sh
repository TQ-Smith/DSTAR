#!/bin/bash

BASE=.

run_reps() {
	mu=$1
	rho=$2
	f=$3
	out=$4
	BASE=/storage/home/tqs5778/lab/analysisDSTAR
	for rep in {1..100}
	do
		dplus -b 50000 "${BASE}"/simAdmIntro/mu"$mu/rho$rho/f${f}/"rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > "$BASE/${out}"/d_rep$rep.tsv
		dstar -b 50000 "${BASE}"/simAdmIntro/mu"$mu/rho$rho/f${f}/"rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3 > "$BASE/${out}"/dstar_rep$rep.tsv
		#dstar -z -b 50000 "${BASE}"/simAdmIntro/mu"$mu/rho$rho/f${f}/"rep$rep.vcf.gz $BASE/popFiles/1pop1.2pop1.3pop1.tsv pop1,pop2,pop3,pop4 > "$BASE/${out}"/fourPop_dstar_rep$rep.tsv
	done
}
export -f run_reps

mkdir -p "$BASE/runAdmIntro"
for mu in 0.75e-8 1.5e-8 3e-8
do 
    mkdir -p "$BASE/runAdmIntro/mu$mu"
    for rho in 0.5e-8 1e-8 2e-8
    do
        mkdir -p "$BASE/runAdmIntro/mu$mu/rho$rho"
        for f in 3 5 10
        do 
            mkdir -p "$BASE/runAdmIntro/mu$mu/rho$rho/f$f"
            out="runAdmIntro/mu$mu/rho$rho/f${f}"
	    echo "run_reps $mu $rho $f $out"
        done
    done
done | parallel -j 20
