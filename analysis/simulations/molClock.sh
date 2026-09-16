#!/bin/bash

for j in {1..8}
do
	mkdir -p molClock/scenario${j}/intro
	mkdir -p molClock/scenario${j}/noIntro
done

f=3
SEGMENT_LENGTH=20000000
for rep in {1..100}
do
	echo "python3 simMolClock.py --pop 1 --scale 1.2 --tree_sequence_file molClock/scenario1/noIntro/rep$rep --vcf_file molClock/scenario1/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
    echo "python3 simMolClock.py --pop 1 --scale 1.5 --tree_sequence_file molClock/scenario2/noIntro/rep$rep --vcf_file molClock/scenario2/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
    echo "python3 simMolClock.py --pop 1 --scale 2 --tree_sequence_file molClock/scenario3/noIntro/rep$rep --vcf_file molClock/scenario3/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
    echo "python3 simMolClock.py --pop 1 --scale 5 --tree_sequence_file molClock/scenario4/noIntro/rep$rep --vcf_file molClock/scenario4/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"       echo "python3 simMolClock.py --pop 2 --scale 1.2 --tree_sequence_file molClock/scenario5/noIntro/rep$rep --vcf_file molClock/scenario5/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
    echo "python3 simMolClock.py --pop 2 --scale 1.5 --tree_sequence_file molClock/scenario6/noIntro/rep$rep --vcf_file molClock/scenario6/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
	echo "python3 simMolClock.py --pop 2 --scale 2 --tree_sequence_file molClock/scenario7/noIntro/rep$rep --vcf_file molClock/scenario7/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"
    echo "python3 simMolClock.py --pop 2 --scale 5 --tree_sequence_file molClock/scenario8/noIntro/rep$rep --vcf_file molClock/scenario8/noIntro/rep$rep -f 0 --sequence_length $SEGMENT_LENGTH"

	echo "python3 simMolClock.py --pop 1 --scale 1.2 --tree_sequence_file molClock/scenario1/intro/rep$rep --vcf_file molClock/scenario1/intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tractsMolClock.py molClock/scenario1/intro/rep$rep.trees molClock/scenario1/intro/rep$rep 1.2"
    echo "python3 simMolClock.py --pop 1 --scale 1.5 --tree_sequence_file molClock/scenario2/intro/rep$rep --vcf_file molClock/scenario2/intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tractsMolClock.py molClock/scenario2/intro/rep$rep.trees molClock/scenario2/intro/rep$rep 1.5"
    echo "python3 simMolClock.py --pop 1 --scale 2 --tree_sequence_file molClock/scenario3/intro/rep$rep --vcf_file molClock/scenario3/intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tractsMolClock.py molClock/scenario3/intro/rep$rep.trees molClock/scenario3/intro/rep$rep 2"
    echo "python3 simMolClock.py --pop 1 --scale 5 --tree_sequence_file molClock/scenario4/intro/rep$rep --vcf_file molClock/scenario4/intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH && python3 tractsMolClock.py molClock/scenario4/intro/rep$rep.trees molClock/scenario4/intro/rep$rep 5"
	echo "python3 simMolClock.py --pop 2 --scale 1.2 --tree_sequence_file molClock/scenario5/intro/rep$rep --vcf_file molClock/scenario5/intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tractsMolClock.py molClock/scenario5/intro/rep$rep.trees molClock/scenario5/intro/rep$rep 1.2"
    echo "python3 simMolClock.py --pop 2 --scale 1.5 --tree_sequence_file molClock/scenario6/intro/rep$rep --vcf_file molClock/scenario6/intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tractsMolClock.py molClock/scenario6/intro/rep$rep.trees molClock/scenario6/intro/rep$rep 1.5"
    echo "python3 simMolClock.py --pop 2 --scale 2 --tree_sequence_file molClock/scenario7/intro/rep$rep --vcf_file molClock/scenario7/intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH  && python3 tractsMolClock.py molClock/scenario7/intro/rep$rep.trees molClock/scenario7/intro/rep$rep 2"
    echo "python3 simMolClock.py --pop 2 --scale 5 --tree_sequence_file molClock/scenario8/intro/rep$rep --vcf_file molClock/scenario8/intro/rep$rep -f $f --sequence_length $SEGMENT_LENGTH && python3 tractsMolClock.py molClock/scenario8/intro/rep$rep.trees molClock/scenario8/intro/rep$rep 5"
done | parallel -j 20

for j in {1..8}
do
	for rep in {1..100}
	do
		echo "gzip molClock/scenario${j}/intro/rep${rep}.vcf"
		echo "gzip molClock/scenario${j}/noIntro/rep${rep}.vcf"
	done
done | parallel -j 20

# Map file for Sprime.
printf "1 . 0.0 0\n" > molClock/map.txt
printf "1 . 1.0 20000000" >> molClock/map.txt

# Weights for hmmix.
printf "1\t0\t20000000" > molClock/weights.bed

# Initial guesses for hmmix parameters.
echo -e "{" > molClock/Initialguesses.json
echo -e "\"state_names\": [\"Human\",\"Archaic\"]," >> molClock/Initialguesses.json
echo -e "\"starting_probabilities\": [0.5,0.5]," >> molClock/Initialguesses.json
echo -e "\"transitions\": [[0.99,0.01],[0.02,0.98]]," >> molClock/Initialguesses.json
echo -e "\"emissions\": [0.03,0.3]" >> molClock/Initialguesses.json
echo -e "}" >> molClock/Initialguesses.json

# Mutation rates for hmmix.
printf "1\t0\t20000000\t1\n" > molClock/mutrates.bed

# Labels for D stats.
P1=1
P2=1
seq 0 $((${P1}-1)) | awk '{print "P1_"$1"\tpop1"}' > molClock/labels.tsv
seq 0 $((${P2}-1)) | awk '{print "P2_"$1"\tpop2"}' >> molClock/labels.tsv
printf "P3_0\tpop3\nP4_0\tpop4\n" >> molClock/labels.tsv

# Groups for Sprime.
seq 0 $((${P1}-1)) | awk '{print "P1_"$1}' > molClock/outgroup.txt
seq ${P1} 11 | awk '{print "P1_"$1}' > molClock/exclude.txt
seq ${P2} 11 | awk '{print "P2_"$1}' >> molClock/exclude.txt
printf "P3_0\nP4_0\n" >> molClock/exclude.txt

# Labels for hmmix.
printf "{\n\"ingroup\":\n[\"P2_0\"" > molClock/individuals.json
seq 0 $((${P2}-2)) | awk '{print ",\n\"P2_"($1+1)"\""}' >> molClock/individuals.json
printf "],\n\"outgroup\":\n[\"P1_0\"" >> molClock/individuals.json
seq 0 $((${P1}-2)) | awk '{print ",\n\"P1_"($1+1)"\""}' >> molClock/individuals.json
printf "]}\n" >> molClock/individuals.json

# Evaluate
for j in {1..8}
do
	mkdir -p molClock/scenario${j}/intro/g1
	for rep in {1..100}
	do
		echo "dplus -z -r 1000 -b 50000 molClock/scenario${j}/intro/rep${rep}.vcf.gz molClock/labels.tsv pop1,pop2,pop3,pop4 > molClock/scenario${j}/intro/d_rep${rep}.tsv"
        echo "dstar -z -r 1000 -b 50000 molClock/scenario${j}/intro/rep${rep}.vcf.gz molClock/labels.tsv pop1,pop2,pop3 > molClock/scenario${j}/intro/dstar_rep${rep}.tsv"
		echo "dstar -g 1 -z -r 1000 -b 50000 molClock/scenario${j}/intro/rep${rep}.vcf.gz molClock/labels.tsv pop1,pop2,pop3 > molClock/scenario${j}/intro/g1/dstar_rep${rep}.tsv"
		echo "dplus -b 50000 molClock/scenario${j}/noIntro/rep${rep}.vcf.gz molClock/labels.tsv pop1,pop2,pop3,pop4 > molClock/scenario${j}/noIntro/d_rep${rep}.tsv"
		echo "dstar -b 50000 molClock/scenario${j}/noIntro/rep${rep}.vcf.gz molClock/labels.tsv pop1,pop2,pop3 > molClock/scenario${j}/noIntro/dstar_rep${rep}.tsv"
		echo "java -jar ~/bin/sprime.jar minscore=0.01 mu=1.5e-8 gt=molClock/scenario${j}/intro/rep${rep}.vcf.gz outgroup=molClock/outgroup.txt excludesamples=molClock/exclude.txt map=molClock/map.txt out=molClock/scenario${j}/intro/raw_sprime_rep${rep} && python3 average_sprime.py molClock/scenario${j}/intro/raw_sprime_rep${rep}.score > molClock/scenario${j}/intro/sprime_rep${rep}.tsv"
		echo "java -jar ~/bin/sprime.jar minscore=0.01 mu=1.5e-8 gt=molClock/scenario${j}/noIntro/rep${rep}.vcf.gz outgroup=molClock/outgroup.txt excludesamples=molClock/exclude.txt map=molClock/map.txt out=molClock/scenario${j}/noIntro/raw_sprime_rep${rep} && python3 average_sprime.py molClock/scenario${j}/noIntro/raw_sprime_rep${rep}.score > molClock/scenario${j}/noIntro/sprime_rep${rep}.tsv"
	done
done | parallel -j 20

for j in {1..8}
do
	cp molClock/scenario${j}/intro/d_rep* molClock/scenario${j}/intro/g1
done

# Run hmmix.
for j in {1..8}
do
	for rep in {1..100}
    do
		echo "hmmix create_outgroup -ind=molClock/individuals.json -vcf=molClock/scenario${j}/intro/rep${rep}.vcf.gz -weights=molClock/weights.bed -out=molClock/scenario${j}/intro/outgroup_rep${rep}.txt && hmmix create_ingroup -ind=molClock/individuals.json -vcf=molClock/scenario${j}/intro/rep${rep}.vcf.gz -weights=molClock/weights.bed -outgroup=molClock/scenario${j}/intro/outgroup_rep${rep}.txt -out=molClock/scenario${j}/intro/obs_rep${rep}"
        echo "hmmix create_outgroup -ind=molClock/individuals.json -vcf=molClock/scenario${j}/noIntro/rep${rep}.vcf.gz -weights=molClock/weights.bed -out=molClock/scenario${j}/noIntro/outgroup_rep${rep}.txt && hmmix create_ingroup -ind=molClock/individuals.json -vcf=molClock/scenario${j}/noIntro/rep${rep}.vcf.gz -weights=molClock/weights.bed -outgroup=molClock/scenario${j}/noIntro/outgroup_rep${rep}.txt -out=molClock/scenario${j}/noIntro/obs_rep${rep}"
	done
done | parallel -j 20

for j in {1..8}
do
	for rep in {1..100}
	do
		for inGroup in $(seq 0 $(($P2-1)))
		do
			echo "hmmix train -obs=molClock/scenario${j}/intro/obs_rep${rep}.P2_${inGroup}.txt -weights=molClock/weights.bed -mutrates=molClock/mutrates.bed -out=molClock/scenario${j}/intro/trained_rep${rep}.P2_${inGroup}.json && hmmix decode -posterior_probs=molClock/scenario${j}/intro/rep${rep}.P2_${inGroup}.posterior.txt -obs=molClock/scenario${j}/intro/obs_rep${rep}.P2_${inGroup}.txt -weights=molClock/weights.bed -mutrates=molClock/mutrates.bed -out=molClock/scenario${j}/intro/decoded_rep${rep}.P2_${inGroup} -param=molClock/scenario${j}/intro/trained_rep${rep}.P2_${inGroup}.json"
			echo "hmmix train -obs=molClock/scenario${j}/noIntro/obs_rep${rep}.P2_${inGroup}.txt -weights=n/weights.bed -mutrates=n/mutrates.bed -out=molClock/scenario${j}/noIntro/trained_rep${rep}.P2_${inGroup}.json && hmmix decode -posterior_probs=molClock/scenario${j}/noIntro/rep${rep}.P2_${inGroup}.posterior.txt -obs=molClock/scenario${j}/noIntro/obs_rep${rep}.P2_${inGroup}.txt -weights=n/weights.bed -mutrates=n/mutrates.bed -out=molClock/scenario${j}/noIntro/decoded_rep${rep}.P2_${inGroup} -param=molClock/scenario${j}/noIntro/trained_rep${rep}.P2_${inGroup}.json"
		done
	done
done | parallel -j 20

for j in {1..8}
do
	for rep in {1..100}
	do
		echo "python3 average_hmmix.py molClock/scenario${j}/intro/rep${rep} > molClock/scenario${j}/intro/hmmix_rep${rep}.tsv"
		echo "python3 average_hmmix.py molClock/scenario${j}/noIntro/rep${rep} > molClock/scenario${j}/noIntro/hmmix_rep${rep}.tsv"
        done
done | parallel -j 20

# Get null distributions and FPR.
for j in {1..8}
do
	bash nullDStats.sh molClock/scenario${j}/noIntro/d 9 molClock/scenario${j}/noIntro/d
	bash nullDStats.sh molClock/scenario${j}/noIntro/d 10 molClock/scenario${j}/noIntro/dplus
	bash nullDStats.sh molClock/scenario${j}/noIntro/dstar 8 molClock/scenario${j}/noIntro/dstar
	bash nullSprime.sh molClock/scenario${j}/noIntro/sprime 3 molClock/scenario${j}/noIntro/sprime
	bash nullHmmix.sh molClock/scenario${j}/noIntro/hmmix 2 molClock/scenario${j}/noIntro/hmmix

	python3 calcFPR.py molClock/scenario${j}/noIntro/d_null.txt > molClock/scenario${j}/noIntro/d_fpr.csv
	python3 calcFPR.py molClock/scenario${j}/noIntro/dplus_null.txt > molClock/scenario${j}/noIntro/dplus_fpr.csv
	python3 calcFPR.py molClock/scenario${j}/noIntro/dstar_null.txt > molClock/scenario${j}/noIntro/dstar_fpr.csv
	python3 calcFPROneSided.py molClock/scenario${j}/noIntro/sprime_null.txt > molClock/scenario${j}/noIntro/sprime_fpr.csv
	python3 calcFPROneSided.py molClock/scenario${j}/noIntro/hmmix_null.txt > molClock/scenario${j}/noIntro/hmmix_fpr.csv
done

# Calculate overlap.
for j in {1..8}
do
	for rep in {1..100}
    do
		echo "python3 calcOverlap.py molClock/scenario${j}/intro/rep${rep}.csv.gz molClock/scenario${j}/intro/d_rep${rep}.tsv 1 > molClock/scenario${j}/intro/rep${rep}_overlap.csv"
    done
done | parallel -j 20

# Calculate performance.
for j in {1..8}
do
	for rep in {1..100}
	do
		echo "python3 calcPerformance.py molClock/scenario${j}/noIntro molClock/scenario${j}/intro molClock/scenario${j}/intro ${rep} > molClock/scenario${j}/intro/rep${rep}_performance.csv"
	done
done | parallel -j 20

# Calculate genome-wide performance.
for j in {1..8}
do
	bash calcGlobal.sh molClock/scenario${j}/intro
	bash calcGlobal.sh molClock/scenario${j}/intro/g1
done
