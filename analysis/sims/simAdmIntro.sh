#!/bin/bash

BASE=.

SEGMENT_LENGTH=20000000

mkdir -p simAdmIntro
for mu in 0.75e-8 1.5e-8 3e-8
do 
    mkdir -p "simAdmIntro/mu$mu"
    for rho in 0.5e-8 1e-8 2e-8
    do
        mkdir -p "simAdmIntro/mu$mu/rho$rho"
        for f in 3 5 10
        do 
            mkdir -p "simAdmIntro/mu$mu/rho$rho/f$f"
            for rep in {1..100}
	    do
		echo "python3 sim.py --tree_sequence_file $BASE/simAdmIntro/mu$mu/rho$rho/f$f/rep$rep --vcf_file $BASE/simAdmIntro/mu$mu/rho$rho/f$f/rep$rep --mutation_rate $mu --recombination_rate $rho --sequence_length $SEGMENT_LENGTH -f $f && python3 tracts.py $BASE/simAdmIntro/mu$mu/rho$rho/f$f/rep$rep.trees $BASE/simAdmIntro/mu$mu/rho$rho/f$f/rep$rep"
	    done
        done
    done
done | parallel -j 20

find "$BASE/simAdmIntro" -type f | egrep "vcf" | xargs gzip

