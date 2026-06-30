#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=5
#SBATCH --mem=50GB
#SBATCH --time=48:00:00
#SBATCH --account=zps5164_sc_default
#SBATCH --mail-user=tqs5778@psu.edu
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END

# File: simN1Intro.sh
# Date: 23 June 2025
# Author: T. Quinn Smith
# Principal Investigator: Zachary A. Szpiech
# Purpose: Use msprime to simulate introgression events.
# set -uex

BASE=/storage/home/tqs5778/lab/analysisDSTAR

mkdir -p simDen/noIntro
f=4
SEGMENT_LENGTH=20000000

for rep in {1..100}
do
	echo "python3 simDen.py --tree_sequence_file $BASE/simDen/noIntro/rep$rep --vcf_file $BASE/simDen/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
	echo "python3 simDen.py --tree_sequence_file $BASE/simDen/rep$rep --vcf_file $BASE/simDen/rep$rep -f $f --sequence_length $SEGMENT_LENGTH && python3 tractsDen.py $BASE/simDen/rep$rep.trees $BASE/simDen/rep$rep"
done | parallel -j 5

find "$BASE/simDen" -type f | egrep "vcf" | xargs gzip
