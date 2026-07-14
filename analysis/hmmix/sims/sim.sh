#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --mem=64GB
#SBATCH --time=24:00:00
#SBATCH --account="zps5164_cr_default"
#SBATCH --partition=basic
#SBATCH --mail-user=tqs5778@psu.edu
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END

mkdir -p intro
mkdir -p noIntro

f=3
SEGMENT_LENGTH=20000000

for rep in {1..100}
do
	echo "python3 sim.py --p1_sample_size 12 --p2_sample_size 1 --p3_sample_size 1 --p4_sample_size 1 --ploidy 2 --tree_sequence_file intro/rep$rep --vcf_file intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH && python3 tracts.py intro/rep$rep.trees intro/rep$rep"
	echo "python3 sim.py --p1_sample_size 12 --p2_sample_size 1 --p3_sample_size 1 --p4_sample_size 1 --ploidy 2 --tree_sequence_file noIntro/rep$rep --vcf_file noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
done | parallel -j 20

find "./intro" -type f | egrep "vcf" | xargs gzip
find "./noIntro" -type f | egrep "vcf" | xargs gzip
