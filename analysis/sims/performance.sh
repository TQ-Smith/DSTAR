#!/bin/bash

BASE=.

# Calculate null distribution, false positive rate, recall, and power for all statistics.
mkdir -p $BASE/resultsN1NoIntro
mkdir -p $BASE/resultsN1Intro
mkdir -p $BASE/resultsNNoIntro
mkdir -p $BASE/resultsNIntro
mkdir -p $BASE/resultsAdmNoIntro
mkdir -p $BASE/resultsAdmIntro
mkdir -p $BASE/resultsMolClock/case1/noIntro
mkdir -p $BASE/resultsMolClock/case2/noIntro
mkdir -p $BASE/resultsMolClock/case3/noIntro
mkdir -p $BASE/resultsMolClock/case4/noIntro
mkdir -p $BASE/resultsMolClock/case5/noIntro
mkdir -p $BASE/resultsMolClock/case6/noIntro
mkdir -p $BASE/resultsMolClock/case7/noIntro
mkdir -p $BASE/resultsMolClock/case8/noIntro
mkdir -p $BASE/resultsMissing/noIntro
mkdir -p $BASE/resultsPseudoHap/noIntro
mkdir -p $BASE/resultsDeamin/noIntro
mkdir -p $BASE/resultsADNA/noIntro
mkdir -p $BASE/resultsDrift/case1/noIntro
mkdir -p $BASE/resultsDrift/case2/noIntro
mkdir -p $BASE/resultsDrift/case3/noIntro
mkdir -p $BASE/resultsDrift/case4/noIntro
mkdir -p $BASE/resultsDrift/case5/noIntro
mkdir -p $BASE/resultsDrift/case6/noIntro
mkdir -p $BASE/resultsDiploid/noIntro
mkdir -p $BASE/resultsDen/noIntro
mkdir -p $BASE/resultsPap/noIntro

# Calculate our null and FPR distribution.
getNullAndFPR() {
	inFile=$1
	col=$2
	out=$3
	# Create our null distribution.
	touch "$out"_null.txt
	for rep in {1..100}
	do
		head -n -1 "$inFile"_rep"$rep".tsv | egrep -v "^#" | cut -f "$col" | egrep -v "nan" >> "$out"_null.txt
	done
	# Calculate FPR.
	python3 calcFPR.py "$out"_null.txt > "$out"_fpr.csv
}

# Null and FPR for N=1
getNullAndFPR "$BASE"/runN1NoIntro/d 9 "$BASE"/resultsN1NoIntro/d
getNullAndFPR "$BASE"/runN1NoIntro/d 10 "$BASE"/resultsN1NoIntro/dplus
getNullAndFPR "$BASE"/runN1NoIntro/dstar 8 "$BASE"/resultsN1NoIntro/dstar


for mu in 0.75e-8 1.5e-8 3e-8
do 
    mkdir -p "resultsAdmNoIntro/mu$mu"
    for rho in 0.5e-8 1e-8 2e-8
    do
	mkdir -p "resultsAdmNoIntro/mu$mu/rho$rho"
	getNullAndFPR "$BASE"/runAdmNoIntro/mu"$mu"/rho"$rho"/d 9 "$BASE"/resultsAdmNoIntro/mu"$mu"/rho"$rho"/d
	getNullAndFPR "$BASE"/runAdmNoIntro/mu"$mu"/rho"$rho"/d 10 "$BASE"/resultsAdmNoIntro/mu"$mu"/rho"$rho"/dplus
	getNullAndFPR "$BASE"/runAdmNoIntro/mu"$mu"/rho"$rho"/dstar 8 "$BASE"/resultsAdmNoIntro/mu"$mu"/rho"$rho"/dstar
    done
done

# Null and FPR for N
for N in 2 5 10 25
do
	mkdir -p $BASE/resultsNNoIntro/N$N
	getNullAndFPR "$BASE"/runNNoIntro/N$N/d 9 "$BASE"/resultsNNoIntro/N$N/d
	getNullAndFPR "$BASE"/runNNoIntro/N$N/d 10 "$BASE"/resultsNNoIntro/N$N/dplus
	getNullAndFPR "$BASE"/runNNoIntro/N$N/dstar 8 "$BASE"/resultsNNoIntro/N$N/dstar
done

# Violations of the molecular clock.
for cases in 1 2 3 4 5 6 7 8
do
	getNullAndFPR "$BASE"/runMolClock/"case$cases"/noIntro/d 9 "$BASE"/resultsMolClock/"case$cases"/noIntro/d
	getNullAndFPR "$BASE"/runMolClock/"case$cases"/noIntro/d 10 "$BASE"/resultsMolClock/"case$cases"/noIntro/dplus
	getNullAndFPR "$BASE"/runMolClock/"case$cases"/noIntro/dstar 8 "$BASE"/resultsMolClock/"case$cases"/noIntro/dstar
done

# Drift.
for cases in 1 2 3 4 5 6
do
       getNullAndFPR "$BASE"/runDrift/"case$cases"/noIntro/d 9 "$BASE"/resultsDrift/"case$cases"/noIntro/d
       getNullAndFPR "$BASE"/runDrift/"case$cases"/noIntro/d 10 "$BASE"/resultsDrift/"case$cases"/noIntro/dplus
       getNullAndFPR "$BASE"/runDrift/"case$cases"/noIntro/dstar 8 "$BASE"/resultsDrift/"case$cases"/noIntro/dstar
done

# Diploid.
getNullAndFPR "$BASE"/runDiploid/noIntro/d 9 "$BASE"/resultsDiploid/noIntro/d
getNullAndFPR "$BASE"/runDiploid/noIntro/d 10 "$BASE"/resultsDiploid/noIntro/dplus
getNullAndFPR "$BASE"/runDiploid/noIntro/dstar 8 "$BASE"/resultsDiploid/noIntro/dstar

# Missing genotypes.
getNullAndFPR "$BASE"/runMissing/noIntro/d 9 "$BASE"/resultsMissing/noIntro/d
getNullAndFPR "$BASE"/runMissing/noIntro/d 10 "$BASE"/resultsMissing/noIntro/dplus
getNullAndFPR "$BASE"/runMissing/noIntro/dstar 8 "$BASE"/resultsMissing/noIntro/dstar

# Pseudohap
getNullAndFPR "$BASE"/runPseudoHap/noIntro/d 9 "$BASE"/resultsPseudoHap/noIntro/d
getNullAndFPR "$BASE"/runPseudoHap/noIntro/d 10 "$BASE"/resultsPseudoHap/noIntro/dplus
getNullAndFPR "$BASE"/runPseudoHap/noIntro/dstar 8 "$BASE"/resultsPseudoHap/noIntro/dstar

# Deamin
getNullAndFPR "$BASE"/runDeamin/noIntro/d 9 "$BASE"/resultsDeamin/noIntro/d
getNullAndFPR "$BASE"/runDeamin/noIntro/d 10 "$BASE"/resultsDeamin/noIntro/dplus
getNullAndFPR "$BASE"/runDeamin/noIntro/dstar 8 "$BASE"/resultsDeamin/noIntro/dstar

# aDNA simulations.
getNullAndFPR "$BASE"/runADNA/noIntro/d 9 "$BASE"/resultsADNA/noIntro/d
getNullAndFPR "$BASE"/runADNA/noIntro/d 10 "$BASE"/resultsADNA/noIntro/dplus
getNullAndFPR "$BASE"/runADNA/noIntro/dstar 8 "$BASE"/resultsADNA/noIntro/dstar

getNullAndFPR "$BASE"/runDen/noIntro/d 9 "$BASE"/resultsDen/noIntro/d
getNullAndFPR "$BASE"/runDen/noIntro/d 10 "$BASE"/resultsDen/noIntro/dplus
getNullAndFPR "$BASE"/runDen/noIntro/dstar 8 "$BASE"/resultsDen/noIntro/dstar

getNullAndFPR "$BASE"/runPap/noIntro/d 9 "$BASE"/resultsPap/noIntro/d
getNullAndFPR "$BASE"/runPap/noIntro/d 10 "$BASE"/resultsPap/noIntro/dplus
getNullAndFPR "$BASE"/runPap/noIntro/dstar 8 "$BASE"/resultsPap/noIntro/dstar

# Calculate Overlap.
calcOverlap() {
	tract=$1
	wind=$2
	minChromNum=$3
	out=$4
	for rep in {1..100}
	do 
		echo "python3 calcOverlap.py ${tract}/rep${rep}.csv.gz ${wind}_rep${rep}.tsv ${minChromNum} > ${out}/rep${rep}_overlap.csv"
	done | parallel -j 5
}

calcOverlap "$BASE"/simN1Intro "$BASE"/runN1Intro/d 1 "$BASE"/resultsN1Intro

for mu in 0.75e-8 1.5e-8 3e-8
do 
    mkdir -p "resultsAdmIntro/mu$mu"
    for rho in 0.5e-8 1e-8 2e-8
    do
	mkdir -p "resultsAdmIntro/mu$mu/rho$rho"
       for f in 3 5 10
       do
		mkdir -p "resultsAdmIntro/mu$mu/rho$rho/f$f"
		calcOverlap "$BASE"/simAdmIntro/mu"$mu"/rho"$rho"/f"$f" "$BASE"/runAdmIntro/mu"$mu"/rho"$rho"/f"$f"/d 1 "$BASE"/resultsAdmIntro/mu"$mu"/rho"$rho"/f"$f"
	done
    done
done

for N in 2 5 10 25
do
  	mkdir -p "$BASE"/resultsNIntro/N"$N"
	calcOverlap "$BASE"/simNIntro/N"$N" "$BASE"/runNIntro/N"$N"/d 1 "$BASE"/resultsNIntro/N"$N"
done

for cases in 1 2 3 4 5 6 7 8
do
	calcOverlap "$BASE"/simMolClock/"case$cases" "$BASE"/runMolClock/"case$cases"/d 1 "$BASE"/resultsMolClock/"case$cases"
done

for cases in 1 2 3 4 5 6
do
       calcOverlap "$BASE"/simDrift/"case$cases" "$BASE"/runDrift/"case$cases"/d 1 "$BASE"/resultsDrift/"case$cases"
done

calcOverlap "$BASE"/simDiploid "$BASE"/runDiploid/d 1 "$BASE"/resultsDiploid

calcOverlap "$BASE"/simMissing "$BASE"/runMissing/d 1 "$BASE"/resultsMissing

calcOverlap "$BASE"/simPseudoHap "$BASE"/runPseudoHap/d 1 "$BASE"/resultsPseudoHap

calcOverlap "$BASE"/simDeamin "$BASE"/runDeamin/d 1 "$BASE"/resultsDeamin

calcOverlap "$BASE"/simADNA "$BASE"/runADNA/d 1 "$BASE"/resultsADNA

# Calculate Performance.
calcPerformance() {
	nullDist=$1
	wind=$2
	overlap=$3
	for rep in {1..100}
	do 
		echo  "python3 calcPerformance.py ${nullDist} ${wind} ${overlap} ${rep} > ${overlap}/rep${rep}_performance.csv"
	done | parallel -j 5
}


calcPerformance "$BASE"/resultsN1NoIntro "$BASE"/runN1Intro "$BASE"/resultsN1Intro

for mu in 0.75e-8 1.5e-8 3e-8
do 
    for rho in 0.5e-8 1e-8 2e-8
    do
    for f in 3 5 10
	do
		calcPerformance "$BASE"/resultsAdmNoIntro/mu"$mu"/rho"$rho" "$BASE"/runAdmIntro/mu"$mu"/rho"$rho"/f"$f" "$BASE"/resultsAdmIntro/mu"$mu"/rho"$rho"/f"$f"
	done
    done
done

for N in 2 5 10 25
do
	calcPerformance "$BASE"/resultsNNoIntro/N"$N" "$BASE"/runNIntro/N"$N" "$BASE"/resultsNIntro/N"$N"
done

for cases in 1 2 3 4 5 6 7 8
do
	calcPerformance "$BASE"/resultsMolClock/"case$cases"/noIntro "$BASE"/runMolClock/"case$cases" "$BASE"/resultsMolClock/"case$cases"
done

for cases in 1 2 3 4 5 6
do
       calcPerformance "$BASE"/resultsDrift/"case$cases"/noIntro "$BASE"/runDrift/"case$cases" "$BASE"/resultsDrift/"case$cases"
done

calcPerformance "$BASE"/resultsDiploid/noIntro "$BASE"/runDiploid "$BASE"/resultsDiploid

calcPerformance "$BASE"/resultsMissing/noIntro "$BASE"/runMissing "$BASE"/resultsMissing

calcPerformance "$BASE"/resultsDeamin/noIntro "$BASE"/runDeamin "$BASE"/resultsDeamin

calcPerformance "$BASE"/resultsPseudoHap/noIntro "$BASE"/runMissing "$BASE"/resultsPseudoHap

calcPerformance "$BASE"/resultsADNA/noIntro "$BASE"/runADNA "$BASE"/resultsADNA

calcPerformance "$BASE"/resultsDen/noIntro "$BASE"/runDen "$BASE"/resultsDen

calcPerformance "$BASE"/resultsPap/noIntro "$BASE"/runPap "$BASE"/resultsPap

bash calcGlobal.sh runN1Intro

for N in 2 5 10 25
do
	bash calcGlobal.sh runNIntro/N"$N"
done
