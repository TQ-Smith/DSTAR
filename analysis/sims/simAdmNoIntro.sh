#!/bin/bash

BASE=.

SEGMENT_LENGTH=20000000

mkdir -p simAdmNoIntro
for mu in 0.75e-8 1.5e-8 3e-8
do 
    mkdir -p "simAdmNoIntro/mu$mu"
    for rho in 0.5e-8 1e-8 2e-8
    do
        mkdir -p "simAdmNoIntro/mu$mu/rho$rho"
        for rep in {1..100}
        do 
		echo "python3 sim.py --tree_sequence_file $BASE/simAdmNoIntro/mu$mu/rho$rho/rep$rep --vcf_file $BASE/simAdmNoIntro/mu$mu/rho$rho/rep$rep --mutation_rate $mu --recombination_rate $rho --sequence_length $SEGMENT_LENGTH -f 0 && python3 tracts.py $BASE/simAdmNoIntro/mu$mu/rho$rho/rep$rep.trees $BASE/simAdmNoIntro/mu$mu/rho$rho/rep$rep"
        done
    done
done | parallel -j 20

find "$BASE/simAdmNoIntro" -type f | egrep "vcf" | xargs gzip

