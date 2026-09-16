#!/bin/bash

# Simulate segments.
SEGMENT_LENGTH=20000000
f=3
for P1 in 1 2 6 12
do
  	for P2 in 1 2 6 12
    do
        mkdir -p n/P1_${P1}_P2_${P2}/intro
        mkdir -p n/P1_${P1}_P2_${P2}/noIntro
		for rep in {1..100}
		do
			echo "python3 sim.py --p1_sample_size ${P1} --p2_sample_size ${P2} --p3_sample_size 1 --p4_sample_size 1 --ploidy 2 --tree_sequence_file n/P1_${P1}_P2_${P2}/noIntro/rep$rep --vcf_file n/P1_${P1}_P2_${P2}/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
     		echo "python3 sim.py --p1_sample_size ${P1} --p2_sample_size ${P2} --p3_sample_size 1 --p4_sample_size 1 --ploidy 2 --tree_sequence_file n/P1_${P1}_P2_${P2}/intro/rep$rep --vcf_file n/P1_${P1}_P2_${P2}/intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH && python3 tracts.py n/P1_${P1}_P2_${P2}/intro/rep$rep.trees n/P1_${P1}_P2_${P2}/intro/rep$rep"
		done
	done
done | parallel -j 20

for P1 in 1 2 6 12
do
    for P2 in 1 2 6 12
    do
		echo -e "find \"n/P1_${P1}_P2_${P2}/intro\" -type f | egrep \"vcf\" | xargs gzip"
		echo -e "find \"n/P1_${P1}_P2_${P2}/noIntro\" -type f | egrep \"vcf\" | xargs gzip"
	done
done | parallel -j 20

# Map file for Sprime.
printf "1 . 0.0 0\n" > n/map.txt
printf "1 . 1.0 20000000" >> n/map.txt

# Weights for hmmix.
printf "1\t0\t20000000" > n/weights.bed

# Initial guesses for hmmix parameters.
echo -e "{" > n/Initialguesses.json
echo -e "\"state_names\": [\"Human\",\"Archaic\"]," >> n/Initialguesses.json
echo -e "\"starting_probabilities\": [0.5,0.5]," >> n/Initialguesses.json
echo -e "\"transitions\": [[0.99,0.01],[0.02,0.98]]," >> n/Initialguesses.json
echo -e "\"emissions\": [0.03,0.3]" >> n/Initialguesses.json
echo -c "}" >> n/Initialguesses.json

# Mutation rates for hmmix.
printf "1\t0\t20000000\t1\n" > n/mutrates.bed

for P1 in 1 2 6 12
do
	for P2 in 1 2 6 12
	do
		# Labels for D stats.
		seq 0 $((${P1}-1)) | awk '{print "P1_"$1"\tpop1"}' > n/P1_${P1}_P2_${P2}/labels.tsv
   		seq 0 $((${P2}-1)) | awk '{print "P2_"$1"\tpop2"}' >> n/P1_${P1}_P2_${P2}/labels.tsv
		printf "P3_0\tpop3\nP4_0\tpop4\n" >> n/P1_${P1}_P2_${P2}/labels.tsv
		
		# Groups for Sprime.
		seq 0 $((${P1}-1)) | awk '{print "P1_"$1}' > n/P1_${P1}_P2_${P2}/outgroup.txt
		seq ${P1} 11 | awk '{print "P1_"$1}' > n/P1_${P1}_P2_${P2}/exclude.txt
		seq ${P2} 11 | awk '{print "P2_"$1}' >> n/P1_${P1}_P2_${P2}/exclude.txt
		printf "P3_0\nP4_0\n" >> n/P1_${P1}_P2_${P2}/exclude_P1_${P1}_P2_${P2}.txt

		# Labels for hmmix.
		printf "{\n\"ingroup\":\n[\"P2_0\"" > n/P1_${P1}_P2_${P2}/individuals.json
		seq 0 $((${P2}-2)) | awk '{print ",\n\"P2_"($1+1)"\""}' >> n/P1_${P1}_P2_${P2}/individuals.json
		printf "],\n\"outgroup\":\n[\"P1_0\"" >> n/P1_${P1}_P2_${P2}/individuals.json
		seq 0 $((${P1}-2)) | awk '{print ",\n\"P1_"($1+1)"\""}' >> n/P1_${P1}_P2_${P2}/individuals.json
		printf "]}\n" >> n/P1_${P1}_P2_${P2}/individuals.json
 		for rep in {1..100}
 		do
 			echo "dplus -z -r 1000 -b 50000 n/P1_${P1}_P2_${P2}/intro/rep${rep}.vcf.gz n/P1_${P1}_P2_${P2}/labels.tsv pop1,pop2,pop3,pop4 > n/P1_${P1}_P2_${P2}/intro/d_rep${rep}.tsv"
			echo "dstar -z -r 1000 -b 50000 n/P1_${P1}_P2_${P2}/intro/rep${rep}.vcf.gz n/P1_${P1}_P2_${P2}/labels.tsv pop1,pop2,pop3 > n/P1_${P1}_P2_${P2}/intro/dstar_rep${rep}.tsv"
			echo "dplus -b 50000 n/P1_${P1}_P2_${P2}/noIntro/rep${rep}.vcf.gz n/P1_${P1}_P2_${P2}/labels.tsv pop1,pop2,pop3,pop4 > n/P1_${P1}_P2_${P2}/noIntro/d_rep${rep}.tsv"
			echo "dstar -b 50000 n/P1_${P1}_P2_${P2}/noIntro/rep${rep}.vcf.gz n/P1_${P1}_P2_${P2}/labels.tsv pop1,pop2,pop3 > n/P1_${P1}_P2_${P2}/noIntro/dstar_rep${rep}.tsv"
			echo "java -jar ~/bin/sprime.jar minscore=0.01 mu=1.5e-8 gt=n/P1_${P1}_P2_${P2}/intro/rep${rep}.vcf.gz outgroup=n/P1_${P1}_P2_${P2}/outgroup.txt excludesamples=n/P1_${P1}_P2_${P2}/exclude.txt map=n/map.txt out=n/P1_${P1}_P2_${P2}/intro/raw_sprime_rep${rep} && python3 average_sprime.py n/P1_${P1}_P2_${P2}/intro/raw_sprime_rep${rep}.score > n/P1_${P1}_P2_${P2}/intro/sprime_rep${rep}.tsv"
			echo "java -jar ~/bin/sprime.jar minscore=0.01 mu=1.5e-8 gt=n/P1_${P1}_P2_${P2}/noIntro/rep${rep}.vcf.gz outgroup=n/P1_${P1}_P2_${P2}/outgroup.txt excludesamples=n/P1_${P1}_P2_${P2}/exclude.txt map=n/map.txt out=n/P1_${P1}_P2_${P2}/noIntro/raw_sprime_rep${rep} && python3 average_sprime.py n/P1_${P1}_P2_${P2}/noIntro/raw_sprime_rep${rep}.score > n/P1_${P1}_P2_${P2}/noIntro/sprime_rep${rep}.tsv"
 		done
 	done
done | parallel -j 20

# Run hmmix.
for P1 in 1 2 6 12
do
  	for P2 in 1 2 6 12
    do
		for rep in {1..100}
		do
			echo "hmmix create_outgroup -ind=n/P1_${P1}_P2_${P2}/individuals.json -vcf=n/P1_${P1}_P2_${P2}/intro/rep${rep}.vcf.gz -weights=n/weights.bed -out=n/P1_${P1}_P2_${P2}/intro/outgroup_rep${rep}.txt && hmmix create_ingroup -ind=n/P1_${P1}_P2_${P2}/individuals.json -vcf=n/P1_${P1}_P2_${P2}/intro/rep${rep}.vcf.gz -weights=n/weights.bed -outgroup=n/P1_${P1}_P2_${P2}/intro/outgroup_rep${rep}.txt -out=n/P1_${P1}_P2_${P2}/intro/obs_rep${rep}"
			echo "hmmix create_outgroup -ind=n/P1_${P1}_P2_${P2}/individuals.json -vcf=n/P1_${P1}_P2_${P2}/noIntro/rep${rep}.vcf.gz -weights=n/weights.bed -out=n/P1_${P1}_P2_${P2}/noIntro/outgroup_rep${rep}.txt && hmmix create_ingroup -ind=n/P1_${P1}_P2_${P2}/individuals.json -vcf=n/P1_${P1}_P2_${P2}/noIntro/rep${rep}.vcf.gz -weights=n/weights.bed -outgroup=n/P1_${P1}_P2_${P2}/noIntro/outgroup_rep${rep}.txt -out=n/P1_${P1}_P2_${P2}/noIntro/obs_rep${rep}"
		done
	done
done | parallel -j 20

for P1 in 1 2 6 12
do
	for P2 in 1 2 6 12
	do
		for rep in {1..100}
		do
			for inGroup in $(seq 0 $(($P2-1)))
			do
				echo "hmmix train -obs=n/P1_${P1}_P2_${P2}/intro/obs_rep${rep}.P2_${inGroup}.txt -weights=n/weights.bed -mutrates=n/mutrates.bed -out=n/P1_${P1}_P2_${P2}/intro/trained_rep${rep}.P2_${inGroup}.json && hmmix decode -posterior_probs=n/P1_${P1}_P2_${P2}/intro/rep${rep}.P2_${inGroup}.posterior.txt -obs=n/P1_${P1}_P2_${P2}/intro/obs_rep${rep}.P2_${inGroup}.txt -weights=n/weights.bed -mutrates=n/mutrates.bed -out=n/P1_${P1}_P2_${P2}/intro/decoded_rep${rep}.P2_${inGroup} -param=n/P1_${P1}_P2_${P2}/intro/trained_rep${rep}.P2_${inGroup}.json"
				echo "hmmix train -obs=n/P1_${P1}_P2_${P2}/noIntro/obs_rep${rep}.P2_${inGroup}.txt -weights=n/weights.bed -mutrates=n/mutrates.bed -out=n/P1_${P1}_P2_${P2}/noIntro/trained_rep${rep}.P2_${inGroup}.json && hmmix decode -posterior_probs=n/P1_${P1}_P2_${P2}/noIntro/rep${rep}.P2_${inGroup}.posterior.txt -obs=n/P1_${P1}_P2_${P2}/noIntro/obs_rep${rep}.P2_${inGroup}.txt -weights=n/weights.bed -mutrates=n/mutrates.bed -out=n/P1_${P1}_P2_${P2}/noIntro/decoded_rep${rep}.P2_${inGroup} -param=n/P1_${P1}_P2_${P2}/noIntro/trained_rep${rep}.P2_${inGroup}.json"
			done
		done
	done
done | parallel -j 20

for P1 in 1 2 6 12
do
    for P2 in 1 2 6 12
    do
		for rep in {1..100}
		do
			echo "python3 average_hmmix.py n/P1_${P1}_P2_${P2}/intro/rep${rep} > n/P1_${P1}_P2_${P2}/intro/hmmix_rep${rep}.tsv"
			echo "python3 average_hmmix.py n/P1_${P1}_P2_${P2}/noIntro/rep${rep} > n/P1_${P1}_P2_${P2}/noIntro/hmmix_rep${rep}.tsv"
		done
	done
done | parallel -j 20

# Get null distributions and FPR.
for P1 in 1 2 6 12
do
	for P2 in 1 2 6 12
	do
		bash nullDStats.sh n/P1_${P1}_P2_${P2}/noIntro/d 9 n/P1_${P1}_P2_${P2}/noIntro/d
		bash nullDStats.sh n/P1_${P1}_P2_${P2}/noIntro/d 10 n/P1_${P1}_P2_${P2}/noIntro/dplus
		bash nullDStats.sh n/P1_${P1}_P2_${P2}/noIntro/dstar 8 n/P1_${P1}_P2_${P2}/noIntro/dstar
		bash nullSprime.sh n/P1_${P1}_P2_${P2}/noIntro/sprime 3 n/P1_${P1}_P2_${P2}/noIntro/sprime
		bash nullHmmix.sh n/P1_${P1}_P2_${P2}/noIntro/hmmix 2 n/P1_${P1}_P2_${P2}/noIntro/hmmix

		python3 calcFPR.py n/P1_${P1}_P2_${P2}/noIntro/d_null.txt > n/P1_${P1}_P2_${P2}/noIntro/d_fpr.csv
		python3 calcFPR.py n/P1_${P1}_P2_${P2}/noIntro/dplus_null.txt > n/P1_${P1}_P2_${P2}/noIntro/dplus_fpr.csv
		python3 calcFPR.py n/P1_${P1}_P2_${P2}/noIntro/dstar_null.txt > n/P1_${P1}_P2_${P2}/noIntro/dstar_fpr.csv
		python3 calcFPROneSided.py n/P1_${P1}_P2_${P2}/noIntro/sprime_null.txt > n/P1_${P1}_P2_${P2}/noIntro/sprime_fpr.csv
		python3 calcFPROneSided.py n/P1_${P1}_P2_${P2}/noIntro/hmmix_null.txt > n/P1_${P1}_P2_${P2}/noIntro/hmmix_fpr.csv
	done
done

# Calculate overlap.
for P1 in 1 2 6 12
do
        for P2 in 1 2 6 12
        do
		for rep in {1..100}
		do
			echo "python3 calcOverlap.py n/P1_${P1}_P2_${P2}/intro/rep${rep}.csv.gz n/P1_${P1}_P2_${P2}/intro/d_rep${rep}.tsv 1 > n/P1_${P1}_P2_${P2}/intro/rep${rep}_overlap.csv"
		done
	done
done | parallel -j 20

# Calculate performance.
for P1 in 1 2 6 12
do
	for P2 in 1 2 6 12
	do
		for rep in {1..100}
		do
			echo "python3 calcPerformance.py n/P1_${P1}_P2_${P2}/noIntro n/P1_${P1}_P2_${P2}/intro n/P1_${P1}_P2_${P2}/intro ${rep} > n/P1_${P1}_P2_${P2}/intro/rep${rep}_performance.csv"
		done
	done
done | parallel -j 20

# Calculate genome-wide performance.
for P1 in 1 2 6 12
do
	for P2 in 1 2 6 12
	do
		bash calcGlobal.sh n/P1_${P1}_P2_${P2}/intro
	done
done
