#!/bin/bash

# Simulate segments.
SEGMENT_LENGTH=20000000
f=3
for P1 in 1 2 6 12
do
  	for P2 in 1 2 6 12
    do
        mkdir -p depolar_n/P1_${P1}_P2_${P2}/intro 
		mkdir -p depolar_n/P1_${P1}_P2_${P2}/noIntro
		cp n/P1_${P1}_P2_${P2}/intro/*.trees depolar_n/P1_${P1}_P2_${P2}/intro
		cp n/P1_${P1}_P2_${P2}/intro/*.csv.gz depolar_n/P1_${P1}_P2_${P2}/intro
		cp n/P1_${P1}_P2_${P2}/noIntro/*.trees depolar_n/P1_${P1}_P2_${P2}/noIntro
		for rep in {1..100}
		do
			eggs -p 0.5 < n/P1_${P1}_P2_${P2}/intro/rep${rep}.vcf.gz > depolar_n/P1_${P1}_P2_${P2}/intro/rep${rep}.vcf.gz
			eggs -p 0.5 < n/P1_${P1}_P2_${P2}/noIntro/rep${rep}.vcf.gz > depolar_n/P1_${P1}_P2_${P2}/noIntro/rep${rep}.vcf.gz
		done
	done
done

# Map file for Sprime.
printf "1 . 0.0 0\n" > depolar_n/map.txt
printf "1 . 1.0 20000000" >> depolar_n/map.txt

# Weights for hmmix.
printf "1\t0\t20000000" > depolar_n/weights.bed

# Initial guesses for hmmix parameters.
echo -e "{" > depolar_n/Initialguesses.json
echo -e "\"state_names\": [\"Human\",\"Archaic\"]," >> depolar_n/Initialguesses.json
echo -e "\"starting_probabilities\": [0.5,0.5]," >> depolar_n/Initialguesses.json
echo -e "\"transitions\": [[0.99,0.01],[0.02,0.98]]," >> depolar_n/Initialguesses.json
echo -e "\"emissions\": [0.03,0.3]" >> depolar_n/Initialguesses.json
echo -e "}" >> depolar_n/Initialguesses.json

# Mutation rates for hmmix.
printf "1\t0\t20000000\t1\n" > depolar_n/mutrates.bed

for P1 in 1 2 6 12
do
	for P2 in 1 2 6 12
	do
		# Labels for D stats.
		seq 0 $((${P1}-1)) | awk '{print "P1_"$1"\tpop1"}' > depolar_n/P1_${P1}_P2_${P2}/labels.tsv
   		seq 0 $((${P2}-1)) | awk '{print "P2_"$1"\tpop2"}' >> depolar_n/P1_${P1}_P2_${P2}/labels.tsv
		printf "P3_0\tpop3\nP4_0\tpop4\n" >> depolar_n/P1_${P1}_P2_${P2}/labels.tsv
		
		# Groups for Sprime.
		seq 0 $((${P1}-1)) | awk '{print "P1_"$1}' > depolar_n/P1_${P1}_P2_${P2}/outgroup.txt		
		seq ${P1} 11 | awk '{print "P1_"$1}' > depolar_n/P1_${P1}_P2_${P2}/exclude.txt
		seq ${P2} 11 | awk '{print "P2_"$1}' >> depolar_n/P1_${P1}_P2_${P2}/exclude.txt
		printf "P3_0\nP4_0\n" >> depolar_n/P1_${P1}_P2_${P2}/exclude_P1_${P1}_P2_${P2}.txt

		# Labels for hmmix.
		printf "{\n\"ingroup\":\n[\"P2_0\"" > depolar_n/P1_${P1}_P2_${P2}/individuals.json
		seq 0 $((${P2}-2)) | awk '{print ",\n\"P2_"($1+1)"\""}' >> depolar_n/P1_${P1}_P2_${P2}/individuals.json
		printf "],\n\"outgroup\":\n[\"P1_0\"" >> depolar_n/P1_${P1}_P2_${P2}/individuals.json
		seq 0 $((${P1}-2)) | awk '{print ",\n\"P1_"($1+1)"\""}' >> depolar_n/P1_${P1}_P2_${P2}/individuals.json
		printf "]}\n" >> depolar_n/P1_${P1}_P2_${P2}/individuals.json
		for rep in {1..100}
		do
			echo "dplus -z -r 1000 -b 50000 depolar_n/P1_${P1}_P2_${P2}/intro/rep${rep}.vcf.gz depolar_n/P1_${P1}_P2_${P2}/labels.tsv pop1,pop2,pop3,pop4 > depolar_n/P1_${P1}_P2_${P2}/intro/d_rep${rep}.tsv"
			echo "dstar -z -r 1000 -b 50000 depolar_n/P1_${P1}_P2_${P2}/intro/rep${rep}.vcf.gz depolar_n/P1_${P1}_P2_${P2}/labels.tsv pop1,pop2,pop3 > depolar_n/P1_${P1}_P2_${P2}/intro/dstar_rep${rep}.tsv"
			echo "dplus -b 50000 depolar_n/P1_${P1}_P2_${P2}/noIntro/rep${rep}.vcf.gz depolar_n/P1_${P1}_P2_${P2}/labels.tsv pop1,pop2,pop3,pop4 > depolar_n/P1_${P1}_P2_${P2}/noIntro/d_rep${rep}.tsv"
			echo "dstar -b 50000 depolar_n/P1_${P1}_P2_${P2}/noIntro/rep${rep}.vcf.gz depolar_n/P1_${P1}_P2_${P2}/labels.tsv pop1,pop2,pop3 > depolar_n/P1_${P1}_P2_${P2}/noIntro/dstar_rep${rep}.tsv"
			echo "java -jar ~/bin/sprime.jar minscore=0.01 mu=1.5e-8 gt=depolar_n/P1_${P1}_P2_${P2}/intro/rep${rep}.vcf.gz outgroup=depolar_n/P1_${P1}_P2_${P2}/outgroup.txt excludesamples=depolar_n/P1_${P1}_P2_${P2}/exclude.txt map=depolar_n/map.txt out=depolar_n/P1_${P1}_P2_${P2}/intro/raw_sprime_rep${rep} && python3 average_sprime.py depolar_n/P1_${P1}_P2_${P2}/intro/raw_sprime_rep${rep}.score > depolar_n/P1_${P1}_P2_${P2}/intro/sprime_rep${rep}.tsv"
			echo "java -jar ~/bin/sprime.jar minscore=0.01 mu=1.5e-8 gt=depolar_n/P1_${P1}_P2_${P2}/noIntro/rep${rep}.vcf.gz outgroup=depolar_n/P1_${P1}_P2_${P2}/outgroup.txt excludesamples=depolar_n/P1_${P1}_P2_${P2}/exclude.txt map=depolar_n/map.txt out=depolar_n/P1_${P1}_P2_${P2}/noIntro/raw_sprime_rep${rep} && python3 average_sprime.py depolar_n/P1_${P1}_P2_${P2}/noIntro/raw_sprime_rep${rep}.score > depolar_n/P1_${P1}_P2_${P2}/noIntro/sprime_rep${rep}.tsv"
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
			echo "hmmix create_outgroup -ind=depolar_n/P1_${P1}_P2_${P2}/individuals.json -vcf=depolar_n/P1_${P1}_P2_${P2}/intro/rep${rep}.vcf.gz -weights=depolar_n/weights.bed -out=depolar_n/P1_${P1}_P2_${P2}/intro/outgroup_rep${rep}.txt && hmmix create_ingroup -ind=depolar_n/P1_${P1}_P2_${P2}/individuals.json -vcf=depolar_n/P1_${P1}_P2_${P2}/intro/rep${rep}.vcf.gz -weights=depolar_n/weights.bed -outgroup=depolar_n/P1_${P1}_P2_${P2}/intro/outgroup_rep${rep}.txt -out=depolar_n/P1_${P1}_P2_${P2}/intro/obs_rep${rep}"
			echo "hmmix create_outgroup -ind=depolar_n/P1_${P1}_P2_${P2}/individuals.json -vcf=depolar_n/P1_${P1}_P2_${P2}/noIntro/rep${rep}.vcf.gz -weights=depolar_n/weights.bed -out=depolar_n/P1_${P1}_P2_${P2}/noIntro/outgroup_rep${rep}.txt && hmmix create_ingroup -ind=depolar_n/P1_${P1}_P2_${P2}/individuals.json -vcf=depolar_n/P1_${P1}_P2_${P2}/noIntro/rep${rep}.vcf.gz -weights=depolar_n/weights.bed -outgroup=depolar_n/P1_${P1}_P2_${P2}/noIntro/outgroup_rep${rep}.txt -out=depolar_n/P1_${P1}_P2_${P2}/noIntro/obs_rep${rep}"
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
				echo "hmmix train -obs=depolar_n/P1_${P1}_P2_${P2}/intro/obs_rep${rep}.P2_${inGroup}.txt -weights=depolar_n/weights.bed -mutrates=depolar_n/mutrates.bed -out=depolar_n/P1_${P1}_P2_${P2}/intro/trained_rep${rep}.P2_${inGroup}.json && hmmix decode -posterior_probs=depolar_n/P1_${P1}_P2_${P2}/intro/rep${rep}.P2_${inGroup}.posterior.txt -obs=depolar_n/P1_${P1}_P2_${P2}/intro/obs_rep${rep}.P2_${inGroup}.txt -weights=depolar_n/weights.bed -mutrates=depolar_n/mutrates.bed -out=depolar_n/P1_${P1}_P2_${P2}/intro/decoded_rep${rep}.P2_${inGroup} -param=depolar_n/P1_${P1}_P2_${P2}/intro/trained_rep${rep}.P2_${inGroup}.json"
				echo "hmmix train -obs=depolar_n/P1_${P1}_P2_${P2}/noIntro/obs_rep${rep}.P2_${inGroup}.txt -weights=depolar_n/weights.bed -mutrates=depolar_n/mutrates.bed -out=depolar_n/P1_${P1}_P2_${P2}/noIntro/trained_rep${rep}.P2_${inGroup}.json && hmmix decode -posterior_probs=depolar_n/P1_${P1}_P2_${P2}/noIntro/rep${rep}.P2_${inGroup}.posterior.txt -obs=depolar_n/P1_${P1}_P2_${P2}/noIntro/obs_rep${rep}.P2_${inGroup}.txt -weights=depolar_n/weights.bed -mutrates=depolar_n/mutrates.bed -out=depolar_n/P1_${P1}_P2_${P2}/noIntro/decoded_rep${rep}.P2_${inGroup} -param=depolar_n/P1_${P1}_P2_${P2}/noIntro/trained_rep${rep}.P2_${inGroup}.json"
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
			echo "python3 average_hmmix.py depolar_n/P1_${P1}_P2_${P2}/intro/rep${rep} > depolar_n/P1_${P1}_P2_${P2}/intro/hmmix_rep${rep}.tsv"
			echo "python3 average_hmmix.py depolar_n/P1_${P1}_P2_${P2}/noIntro/rep${rep} > depolar_n/P1_${P1}_P2_${P2}/noIntro/hmmix_rep${rep}.tsv"
		done
	done
done | parallel -j 20

# Get null distributions and FPR.
for P1 in 1 2 6 12
do
	for P2 in 1 2 6 12
	do
		bash nullDStats.sh depolar_n/P1_${P1}_P2_${P2}/noIntro/d 9 depolar_n/P1_${P1}_P2_${P2}/noIntro/d
		bash nullDStats.sh depolar_n/P1_${P1}_P2_${P2}/noIntro/d 10 depolar_n/P1_${P1}_P2_${P2}/noIntro/dplus
		bash nullDStats.sh depolar_n/P1_${P1}_P2_${P2}/noIntro/dstar 8 depolar_n/P1_${P1}_P2_${P2}/noIntro/dstar
		bash nullSprime.sh depolar_n/P1_${P1}_P2_${P2}/noIntro/sprime 3 depolar_n/P1_${P1}_P2_${P2}/noIntro/sprime
		bash nullHmmix.sh depolar_n/P1_${P1}_P2_${P2}/noIntro/hmmix 2 depolar_n/P1_${P1}_P2_${P2}/noIntro/hmmix

		python3 calcFPR.py depolar_n/P1_${P1}_P2_${P2}/noIntro/d_null.txt > depolar_n/P1_${P1}_P2_${P2}/noIntro/d_fpr.csv
		python3 calcFPR.py depolar_n/P1_${P1}_P2_${P2}/noIntro/dplus_null.txt > depolar_n/P1_${P1}_P2_${P2}/noIntro/dplus_fpr.csv
		python3 calcFPR.py depolar_n/P1_${P1}_P2_${P2}/noIntro/dstar_null.txt > depolar_n/P1_${P1}_P2_${P2}/noIntro/dstar_fpr.csv
		python3 calcFPROneSided.py depolar_n/P1_${P1}_P2_${P2}/noIntro/sprime_null.txt > depolar_n/P1_${P1}_P2_${P2}/noIntro/sprime_fpr.csv
		python3 calcFPROneSided.py depolar_n/P1_${P1}_P2_${P2}/noIntro/hmmix_null.txt > depolar_n/P1_${P1}_P2_${P2}/noIntro/hmmix_fpr.csv
	done
done

# Calculate overlap.
for P1 in 1 2 6 12
do
        for P2 in 1 2 6 12
        do
		for rep in {1..100}
		do
			echo "python3 calcOverlap.py depolar_n/P1_${P1}_P2_${P2}/intro/rep${rep}.csv.gz depolar_n/P1_${P1}_P2_${P2}/intro/d_rep${rep}.tsv 1 > depolar_n/P1_${P1}_P2_${P2}/intro/rep${rep}_overlap.csv"
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
			echo "python3 calcPerformance.py depolar_n/P1_${P1}_P2_${P2}/noIntro depolar_n/P1_${P1}_P2_${P2}/intro depolar_n/P1_${P1}_P2_${P2}/intro ${rep} > depolar_n/P1_${P1}_P2_${P2}/intro/rep${rep}_performance.csv"
		done
	done
done | parallel -j 20

# Calculate genome-wide performance.
for P1 in 1 2 6 12
do
	for P2 in 1 2 6 12
	do
		bash calcGlobal.sh depolar_n/P1_${P1}_P2_${P2}/intro
	done
done
