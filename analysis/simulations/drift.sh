#!/bin/bash

for j in {1..6}
do
	mkdir -p drift/scenario${j}/intro
	mkdir -p drift/scenario${j}/noIntro
done

f=3
SEGMENT_LENGTH=20000000
for rep in {1..100}
do
	echo "python3 simDrift.py --pop 1 --ne 2500 --tree_sequence_file drift/scenario1/noIntro/rep$rep --vcf_file drift/scenario1/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
        echo "python3 simDrift.py --pop 1 --ne 5000 --tree_sequence_file drift/scenario2/noIntro/rep$rep --vcf_file drift/scenario2/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
        echo "python3 simDrift.py --pop 1 --ne 25000 --tree_sequence_file drift/scenario3/noIntro/rep$rep --vcf_file drift/scenario3/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
        echo "python3 simDrift.py --pop 2 --ne 2500 --tree_sequence_file drift/scenario4/noIntro/rep$rep --vcf_file drift/scenario4/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
        echo "python3 simDrift.py --pop 2 --ne 5000 --tree_sequence_file drift/scenario5/noIntro/rep$rep --vcf_file drift/scenario5/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
        echo "python3 simDrift.py --pop 2 --ne 25000 --tree_sequence_file drift/scenario6/noIntro/rep$rep --vcf_file drift/scenario6/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
	echo "python3 simDrift.py --pop 1 --ne 2500 --tree_sequence_file drift/scenario1/intro/rep$rep --vcf_file drift/scenario1/intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tracts.py drift/scenario1/intro/rep$rep.trees drift/scenario1/intro/rep$rep"
        echo "python3 simDrift.py --pop 1 --ne 5000 --tree_sequence_file drift/scenario2/intro/rep$rep --vcf_file drift/scenario2/intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tracts.py drift/scenario2/intro/rep$rep.trees drift/scenario2/intro/rep$rep"
        echo "python3 simDrift.py --pop 1 --ne 25000 --tree_sequence_file drift/scenario3/intro/rep$rep --vcf_file drift/scenario3/intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tracts.py drift/scenario3/intro/rep$rep.trees drift/scenario3/intro/rep$rep"
        echo "python3 simDrift.py --pop 2 --ne 2500 --tree_sequence_file drift/scenario4/intro/rep$rep --vcf_file drift/scenario4/intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH && python3 tracts.py drift/scenario4/intro/rep$rep.trees drift/scenario4/intro/rep$rep"
        echo "python3 simDrift.py --pop 2 --ne 5000 --tree_sequence_file drift/scenario5/intro/rep$rep --vcf_file drift/scenario5/intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tracts.py drift/scenario5/intro/rep$rep.trees drift/scenario5/intro/rep$rep"
        echo "python3 simDrift.py --pop 2 --ne 25000 --tree_sequence_file drift/scenario6/intro/rep$rep --vcf_file drift/scenario6/intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tracts.py drift/scenario6/intro/rep$rep.trees drift/scenario6/intro/rep$rep"
done | parallel -j 20

for j in {1..6}
do
	for rep in {1..100}
	do
		echo "gzip drift/scenario${j}/intro/rep${rep}.vcf"
		echo "gzip drift/scenario${j}/noIntro/rep${rep}.vcf"
	done
done | parallel -j 20

# Map file for Sprime.
printf "1 . 0.0 0\n" > drift/map.txt
printf "1 . 1.0 20000000" >> drift/map.txt

# Weights for hmmix.
printf "1\t0\t20000000" > drift/weights.bed

# Initial guesses for hmmix parameters.
echo -e "{" > drift/Initialguesses.json
echo -e "\"state_names\": [\"Human\",\"Archaic\"]," >> drift/Initialguesses.json
echo -e "\"starting_probabilities\": [0.5,0.5]," >> drift/Initialguesses.json
echo -e "\"transitions\": [[0.99,0.01],[0.02,0.98]]," >> drift/Initialguesses.json
echo -e "\"emissions\": [0.03,0.3]" >> drift/Initialguesses.json
echo -c "}" >> drift/Initialguesses.json

# Mutation rates for hmmix.
printf "1\t0\t20000000\t1\n" > drift/mutrates.bed

# Labels for D stats.
P1=1
P2=1
seq 0 $((${P1}-1)) | awk '{print "P1_"$1"\tpop1"}' > drift/labels.tsv
seq 0 $((${P2}-1)) | awk '{print "P2_"$1"\tpop2"}' >> drift/labels.tsv
printf "P3_0\tpop3\nP4_0\tpop4\n" >> drift/labels.tsv

# Groups for Sprime.
seq 0 $((${P1}-1)) | awk '{print "P1_"$1}' > drift/outgroup.txt
seq ${P1} 11 | awk '{print "P1_"$1}' > drift/exclude.txt
seq ${P2} 11 | awk '{print "P2_"$1}' >> drift/exclude.txt
printf "P3_0\nP4_0\n" >> drift/exclude.txt

# Labels for hmmix.
printf "{\n\"ingroup\":\n[\"P2_0\"" > drift/individuals.json
seq 0 $((${P2}-2)) | awk '{print ",\n\"P2_"($1+1)"\""}' >> drift/individuals.json
printf "],\n\"outgroup\":\n[\"P1_0\"" >> drift/individuals.json
seq 0 $((${P1}-2)) | awk '{print ",\n\"P1_"($1+1)"\""}' >> drift/individuals.json
printf "]}\n" >> drift/individuals.json

# Evaluate
for j in {1..6}
do
	mkdir -p drift/scenario${j}/intro/g1
	for rep in {1..100}
	do
		echo "dplus -z -r 1000 -b 50000 drift/scenario${j}/intro/rep${rep}.vcf.gz drift/labels.tsv pop1,pop2,pop3,pop4 > drift/scenario${j}/intro/d_rep${rep}.tsv"
                echo "dstar -z -r 1000 -b 50000 drift/scenario${j}/intro/rep${rep}.vcf.gz drift/labels.tsv pop1,pop2,pop3 > drift/scenario${j}/intro/dstar_rep${rep}.tsv"
                echo "dstar -g 1 -z -r 1000 -b 50000 drift/scenario${j}/intro/rep${rep}.vcf.gz drift/labels.tsv pop1,pop2,pop3 > drift/scenario${j}/intro/g1/dstar_rep${rep}.tsv"
		echo "dplus -b 50000 drift/scenario${j}/noIntro/rep${rep}.vcf.gz drift/labels.tsv pop1,pop2,pop3,pop4 > drift/scenario${j}/noIntro/d_rep${rep}.tsv"
                echo "dstar -b 50000 drift/scenario${j}/noIntro/rep${rep}.vcf.gz drift/labels.tsv pop1,pop2,pop3 > drift/scenario${j}/noIntro/dstar_rep${rep}.tsv"
#                echo "java -jar ~/bin/sprime.jar minscore=0.01 mu=1.5e-8 gt=drift/scenario${j}/intro/rep${rep}.vcf.gz outgroup=drift/outgroup.txt excludesamples=drift/exclude.txt map=drift/map.txt out=drift/scenario${j}/intro/raw_sprime_rep${rep} && python3 average_sprime.py drift/scenario${j}/intro/raw_sprime_rep${rep}.score > drift/scenario${j}/intro/sprime_rep${rep}.tsv"
#                echo "java -jar ~/bin/sprime.jar minscore=0.01 mu=1.5e-8 gt=drift/scenario${j}/noIntro/rep${rep}.vcf.gz outgroup=drift/outgroup.txt excludesamples=drift/exclude.txt map=drift/map.txt out=drift/scenario${j}/noIntro/raw_sprime_rep${rep} && python3 average_sprime.py drift/scenario${j}/noIntro/raw_sprime_rep${rep}.score > drift/scenario${j}/noIntro/sprime_rep${rep}.tsv"
	done
done | parallel -j 20

for j in {1..6}
do
        cp drift/scenario${j}/intro/d_rep* drift/scenario${j}/intro/g1
done

# Run hmmix.
for j in {1..6}
do
	for rep in {1..100}
        do
		echo "hmmix create_outgroup -ind=drift/individuals.json -vcf=drift/scenario${j}/intro/rep${rep}.vcf.gz -weights=drift/weights.bed -out=drift/scenario${j}/intro/outgroup_rep${rep}.txt && hmmix create_ingroup -ind=drift/individuals.json -vcf=drift/scenario${j}/intro/rep${rep}.vcf.gz -weights=drift/weights.bed -outgroup=drift/scenario${j}/intro/outgroup_rep${rep}.txt -out=drift/scenario${j}/intro/obs_rep${rep}"
                echo "hmmix create_outgroup -ind=drift/individuals.json -vcf=drift/scenario${j}/noIntro/rep${rep}.vcf.gz -weights=drift/weights.bed -out=drift/scenario${j}/noIntro/outgroup_rep${rep}.txt && hmmix create_ingroup -ind=drift/individuals.json -vcf=drift/scenario${j}/noIntro/rep${rep}.vcf.gz -weights=drift/weights.bed -outgroup=drift/scenario${j}/noIntro/outgroup_rep${rep}.txt -out=drift/scenario${j}/noIntro/obs_rep${rep}"
	done
done | parallel -j 20

for j in {1..6}
do
	for rep in {1..100}
	do
		for inGroup in $(seq 0 $(($P2-1)))
		do
			echo "hmmix train -obs=drift/scenario${j}/intro/obs_rep${rep}.P2_${inGroup}.txt -weights=drift/weights.bed -mutrates=drift/mutrates.bed -out=drift/scenario${j}/intro/trained_rep${rep}.P2_${inGroup}.json && hmmix decode -posterior_probs=drift/scenario${j}/intro/rep${rep}.P2_${inGroup}.posterior.txt -obs=drift/scenario${j}/intro/obs_rep${rep}.P2_${inGroup}.txt -weights=drift/weights.bed -mutrates=drift/mutrates.bed -out=drift/scenario${j}/intro/decoded_rep${rep}.P2_${inGroup} -param=drift/scenario${j}/intro/trained_rep${rep}.P2_${inGroup}.json"
			echo "hmmix train -obs=drift/scenario${j}/noIntro/obs_rep${rep}.P2_${inGroup}.txt -weights=drift/weights.bed -mutrates=drift/mutrates.bed -out=drift/scenario${j}/noIntro/trained_rep${rep}.P2_${inGroup}.json && hmmix decode -posterior_probs=drift/scenario${j}/noIntro/rep${rep}.P2_${inGroup}.posterior.txt -obs=drift/scenario${j}/noIntro/obs_rep${rep}.P2_${inGroup}.txt -weights=drift/weights.bed -mutrates=drift/mutrates.bed -out=drift/scenario${j}/noIntro/decoded_rep${rep}.P2_${inGroup} -param=drift/scenario${j}/noIntro/trained_rep${rep}.P2_${inGroup}.json"
		done
	done
done | parallel -j 20

for j in {1..6}
do
	for rep in {1..100}
	do
		echo "python3 average_hmmix.py drift/scenario${j}/intro/rep${rep} > drift/scenario${j}/intro/hmmix_rep${rep}.tsv"
		echo "python3 average_hmmix.py drift/scenario${j}/noIntro/rep${rep} > drift/scenario${j}/noIntro/hmmix_rep${rep}.tsv"
       done
done | parallel -j 20

# Get null distributions and FPR.
for j in {1..6}
do
	bash nullDStats.sh drift/scenario${j}/noIntro/d 9 drift/scenario${j}/noIntro/d
        bash nullDStats.sh drift/scenario${j}/noIntro/d 10 drift/scenario${j}/noIntro/dplus
        bash nullDStats.sh drift/scenario${j}/noIntro/dstar 8 drift/scenario${j}/noIntro/dstar
        bash nullSprime.sh drift/scenario${j}/noIntro/sprime 3 drift/scenario${j}/noIntro/sprime
        bash nullHmmix.sh drift/scenario${j}/noIntro/hmmix 2 drift/scenario${j}/noIntro/hmmix

        python3 calcFPR.py drift/scenario${j}/noIntro/d_null.txt > drift/scenario${j}/noIntro/d_fpr.csv
        python3 calcFPR.py drift/scenario${j}/noIntro/dplus_null.txt > drift/scenario${j}/noIntro/dplus_fpr.csv
        python3 calcFPR.py drift/scenario${j}/noIntro/dstar_null.txt > drift/scenario${j}/noIntro/dstar_fpr.csv
        python3 calcFPROneSided.py drift/scenario${j}/noIntro/sprime_null.txt > drift/scenario${j}/noIntro/sprime_fpr.csv
        python3 calcFPROneSided.py drift/scenario${j}/noIntro/hmmix_null.txt > drift/scenario${j}/noIntro/hmmix_fpr.csv
done

# Calculate overlap.
for j in {1..6}
do
	for rep in {1..100}
        do
		echo "python3 calcOverlap.py drift/scenario${j}/intro/rep${rep}.csv.gz drift/scenario${j}/intro/d_rep${rep}.tsv 1 > drift/scenario${j}/intro/rep${rep}_overlap.csv"
        done
done | parallel -j 20

# Calculate performance.
for j in {1..6}
do
	for rep in {1..100}
	do
		echo "python3 calcPerformance.py drift/scenario${j}/noIntro drift/scenario${j}/intro drift/scenario${j}/intro ${rep} > drift/scenario${j}/intro/rep${rep}_performance.csv"
	done
done | parallel -j 20

# Calculate genome-wide performance.
for j in {1..6}
do
	bash calcGlobal.sh drift/scenario${j}/intro
	bash calcGlobal.sh drift/scenario${j}/intro/g1
done
