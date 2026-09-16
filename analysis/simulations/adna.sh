#!/bin/bash

mkdir -p adna
mkdir -p adna/no_error/intro
mkdir -p adna/no_error/noIntro
mkdir -p adna/pseudo_hap/intro
mkdir -p adna/pseudo_hap/noIntro
mkdir -p adna/missing/intro
mkdir -p adna/missing/noIntro
mkdir -p adna/deamin/intro
mkdir -p adna/deamin/noIntro
mkdir -p adna/all/intro
mkdir -p adna/all/noIntro

f=3
SEGMENT_LENGTH=20000000
for rep in {1..100}
do
        echo "python3 sim.py --p1_sample_size 12 --p2_sample_size 12 --p3_sample_size 2 --p4_sample_size 1 --ploidy 2 --tree_sequence_file adna/no_error/intro/rep$rep --vcf_file adna/no_error/intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH && python3 tracts.py adna/no_error/intro/rep$rep.trees adna/no_error/intro/rep$rep"
        echo "python3 sim.py --p1_sample_size 12 --p2_sample_size 12 --p3_sample_size 2 --p4_sample_size 1 --ploidy 2 --tree_sequence_file adna/no_error/noIntro/rep$rep --vcf_file adna/no_error/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
done | parallel -j 20

for rep in {1..100}
do
	echo "gzip adna/no_error/intro/rep${rep}.vcf"
	echo "gzip adna/no_error/noIntro/rep${rep}.vcf"
done | parallel -j 20

for rep in {1..100}
do
        echo "eggs -b 0.55,0.23 < adna/no_error/intro/rep$rep.vcf.gz > adna/missing/intro/rep$rep.vcf.gz"
        echo "eggs -b 0.55,0.23 < adna/no_error/noIntro/rep$rep.vcf.gz > adna/missing/noIntro/rep$rep.vcf.gz"

        echo "eggs -s < adna/no_error/intro/rep$rep.vcf.gz > adna/pseudo_hap/intro/rep$rep.vcf.gz"
        echo "eggs -s < adna/no_error/noIntro/rep$rep.vcf.gz > adna/pseudo_hap/noIntro/rep$rep.vcf.gz"

        echo "eggs -d 0.0776,0.05 < adna/no_error/intro/rep$rep.vcf.gz > adna/deamin/intro/rep$rep.vcf.gz"
        echo "eggs -d 0.0776,0.05 < adna/no_error/noIntro/rep$rep.vcf.gz > adna/deamin/noIntro/rep$rep.vcf.gz"

        echo "eggs -d 0.0776,0.05 -b 0.55,0.23 -s < adna/no_error/intro/rep$rep.vcf.gz > adna/all/intro/rep$rep.vcf.gz"
        echo "eggs -d 0.0776,0.05 -b 0.55,0.23 -s < adna/no_error/noIntro/rep$rep.vcf.gz > adna/all/noIntro/rep$rep.vcf.gz"
done | parallel -j 20

for j in pseudo_hap deamin missing all
do
	cp adna/no_error/intro/*.trees adna/${j}/intro
	cp adna/no_error/intro/*.csv.gz adna/${j}/intro
	cp adna/no_error/noIntro/*.trees adna/${j}/noIntro
done

# Map file for Sprime.
printf "1 . 0.0 0\n" > adna/map.txt
printf "1 . 1.0 20000000" >> adna/map.txt

# Weights for hmmix.
printf "1\t0\t20000000" > adna/weights.bed

# Initial guesses for hmmix parameters.
echo -e "{" > adna/Initialguesses.json
echo -e "\"state_names\": [\"Human\",\"Archaic\"]," >> adna/Initialguesses.json
echo -e "\"starting_probabilities\": [0.5,0.5]," >> adna/Initialguesses.json
echo -e "\"transitions\": [[0.99,0.01],[0.02,0.98]]," >> adna/Initialguesses.json
echo -e "\"emissions\": [0.03,0.3]" >> adna/Initialguesses.json
echo -e "}" >> adna/Initialguesses.json

# Mutation rates for hmmix.
printf "1\t0\t20000000\t1\n" > adna/mutrates.bed

# Labels for D stats.
P1=12
P2=12
seq 0 $((${P1}-1)) | awk '{print "P1_"$1"\tpop1"}' > adna/labels.tsv
seq 0 $((${P2}-1)) | awk '{print "P2_"$1"\tpop2"}' >> adna/labels.tsv
printf "P3_0\tpop3\nP3_1\tpop3\nP4_0\tpop4\n" >> adna/labels.tsv

# Groups for Sprime.
seq 0 $((${P1}-1)) | awk '{print "P1_"$1}' > adna/outgroup.txt
seq ${P1} 11 | awk '{print "P1_"$1}' > adna/exclude.txt
seq ${P2} 11 | awk '{print "P2_"$1}' >> adna/exclude.txt
printf "P3_0\nP3_1\nP4_0\n" >> adna/exclude.txt

# Labels for hmmix.
printf "{\n\"ingroup\":\n[\"P2_0\"" > adna/individuals.json
seq 0 $((${P2}-2)) | awk '{print ",\n\"P2_"($1+1)"\""}' >> adna/individuals.json
printf "],\n\"outgroup\":\n[\"P1_0\"" >> adna/individuals.json
seq 0 $((${P1}-2)) | awk '{print ",\n\"P1_"($1+1)"\""}' >> adna/individuals.json
printf "]}\n" >> adna/individuals.json

# Evaluate
for j in no_error pseudo_hap deamin missing all
do
        for rep in {1..100}
        do
                echo "dplus -z -r 1000 -b 50000 adna/${j}/intro/rep${rep}.vcf.gz adna/labels.tsv pop1,pop2,pop3,pop4 > adna/${j}/intro/d_rep${rep}.tsv"
                echo "dstar -z -r 1000 -b 50000 adna/${j}/intro/rep${rep}.vcf.gz adna/labels.tsv pop1,pop2,pop3 > adna/${j}/intro/dstar_rep${rep}.tsv"
                echo "dplus -b 50000 adna/${j}/noIntro/rep${rep}.vcf.gz adna/labels.tsv pop1,pop2,pop3,pop4 > adna/${j}/noIntro/d_rep${rep}.tsv"
                echo "dstar -b 50000 adna/${j}/noIntro/rep${rep}.vcf.gz adna/labels.tsv pop1,pop2,pop3 > adna/${j}/noIntro/dstar_rep${rep}.tsv"
                echo "java -jar ~/bin/sprime.jar minscore=0.01 mu=1.5e-8 gt=adna/${j}/intro/rep${rep}.vcf.gz outgroup=adna/outgroup.txt excludesamples=adna/exclude.txt map=adna/map.txt out=adna/${j}/intro/raw_sprime_rep${rep} && python3 average_sprime.py adna/${j}/intro/raw_sprime_rep${rep}.score > adna/${j}/intro/sprime_rep${rep}.tsv"
                echo "java -jar ~/bin/sprime.jar minscore=0.01 mu=1.5e-8 gt=adna/${j}/noIntro/rep${rep}.vcf.gz outgroup=adna/outgroup.txt excludesamples=adna/exclude.txt map=adna/map.txt out=adna/${j}/noIntro/raw_sprime_rep${rep} && python3 average_sprime.py adna/${j}/noIntro/raw_sprime_rep${rep}.score > adna/${j}/noIntro/sprime_rep${rep}.tsv"
        done
done | parallel -j 20

# Run hmmix.
for j in no_error pseudo_hap deamin missing all
do
        for rep in {1..100}
        do
                echo "hmmix create_outgroup -ind=adna/individuals.json -vcf=adna/${j}/intro/rep${rep}.vcf.gz -weights=adna/weights.bed -out=adna/${j}/intro/outgroup_rep${rep}.txt && hmmix create_ingroup -ind=adna/individuals.json -vcf=adna/${j}/intro/rep${rep}.vcf.gz -weights=adna/weights.bed -outgroup=adna/${j}/intro/outgroup_rep${rep}.txt -out=adna/${j}/intro/obs_rep${rep}"
                echo "hmmix create_outgroup -ind=adna/individuals.json -vcf=adna/${j}/noIntro/rep${rep}.vcf.gz -weights=adna/weights.bed -out=adna/${j}/noIntro/outgroup_rep${rep}.txt && hmmix create_ingroup -ind=adna/individuals.json -vcf=adna/${j}/noIntro/rep${rep}.vcf.gz -weights=adna/weights.bed -outgroup=adna/${j}/noIntro/outgroup_rep${rep}.txt -out=adna/${j}/noIntro/obs_rep${rep}"
        done
done | parallel -j 20

for j in no_error pseudo_hap deamin missing all
do
        for rep in {1..100}
        do
                for inGroup in $(seq 0 $(($P2-1)))
                do
                        echo "hmmix train -obs=adna/${j}/intro/obs_rep${rep}.P2_${inGroup}.txt -weights=adna/weights.bed -mutrates=adna/mutrates.bed -out=adna/${j}/intro/trained_rep${rep}.P2_${inGroup}.json && hmmix decode -posterior_probs=adna/${j}/intro/rep${rep}.P2_${inGroup}.posterior.txt -obs=adna/${j}/intro/obs_rep${rep}.P2_${inGroup}.txt -weights=adna/weights.bed -mutrates=adna/mutrates.bed -out=adna/${j}/intro/decoded_rep${rep}.P2_${inGroup} -param=adna/${j}/intro/trained_rep${rep}.P2_${inGroup}.json"
                        echo "hmmix train -obs=adna/${j}/noIntro/obs_rep${rep}.P2_${inGroup}.txt -weights=adna/weights.bed -mutrates=adna/mutrates.bed -out=adna/${j}/noIntro/trained_rep${rep}.P2_${inGroup}.json && hmmix decode -posterior_probs=adna/${j}/noIntro/rep${rep}.P2_${inGroup}.posterior.txt -obs=adna/${j}/noIntro/obs_rep${rep}.P2_${inGroup}.txt -weights=adna/weights.bed -mutrates=adna/mutrates.bed -out=adna/${j}/noIntro/decoded_rep${rep}.P2_${inGroup} -param=adna/${j}/noIntro/trained_rep${rep}.P2_${inGroup}.json"
                done
        done
done | parallel -j 20

for j in no_error pseudo_hap deamin missing all
do
        for rep in {1..100}
        do
                echo "python3 average_hmmix.py adna/${j}/intro/rep${rep} > adna/${j}/intro/hmmix_rep${rep}.tsv"
                echo "python3 average_hmmix.py adna/${j}/noIntro/rep${rep} > adna/${j}/noIntro/hmmix_rep${rep}.tsv"
        done
done | parallel -j 20

# Get null distributions and FPR.
for j in no_error pseudo_hap deamin missing all
do
        bash nullDStats.sh adna/${j}/noIntro/d 9 adna/${j}/noIntro/d
        bash nullDStats.sh adna/${j}/noIntro/d 10 adna/${j}/noIntro/dplus
        bash nullDStats.sh adna/${j}/noIntro/dstar 8 adna/${j}/noIntro/dstar
        bash nullSprime.sh adna/${j}/noIntro/sprime 3 adna/${j}/noIntro/sprime
        bash nullHmmix.sh adna/${j}/noIntro/hmmix 2 adna/${j}/noIntro/hmmix

        python3 calcFPR.py adna/${j}/noIntro/d_null.txt > adna/${j}/noIntro/d_fpr.csv
        python3 calcFPR.py adna/${j}/noIntro/dplus_null.txt > adna/${j}/noIntro/dplus_fpr.csv
        python3 calcFPR.py adna/${j}/noIntro/dstar_null.txt > adna/${j}/noIntro/dstar_fpr.csv
        python3 calcFPROneSided.py adna/${j}/noIntro/sprime_null.txt > adna/${j}/noIntro/sprime_fpr.csv
        python3 calcFPROneSided.py adna/${j}/noIntro/hmmix_null.txt > adna/${j}/noIntro/hmmix_fpr.csv
done

# Calculate overlap.
for j in no_error pseudo_hap deamin missing all
do
        for rep in {1..100}
        do
                echo "python3 calcOverlap.py adna/${j}/intro/rep${rep}.csv.gz adna/${j}/intro/d_rep${rep}.tsv 1 > adna/${j}/intro/rep${rep}_overlap.csv"
        done
done | parallel -j 20

# Calculate performance.
for j in no_error pseudo_hap deamin missing all
do
        for rep in {1..100}
        do
                echo "python3 calcPerformanceN1.py adna/${j}/noIntro adna/${j}/intro adna/${j}/intro ${rep} > adna/${j}/intro/rep${rep}_performance.csv"
        done
done | parallel -j 20

# Calculate genome-wide performance.
for j in no_error pseudo_hap deamin missing all
do
        bash calcGlobal.sh adna/${j}/intro
done
