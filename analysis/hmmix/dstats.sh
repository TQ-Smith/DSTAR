#!/bin/bash

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

for rep in {1..100}
do
	echo "Ran rep${rep}"
	dplus -b 50000 sims/noIntro/rep$rep.vcf.gz pop_labels.tsv pop1,pop2,pop3,pop4 > runDStats/noIntro_d_rep$rep.tsv
        dstar -b 50000 sims/noIntro/rep$rep.vcf.gz pop_labels.tsv pop1,pop2,pop3 > runDStats/noIntro_dstar_rep$rep.tsv

	dplus -b 50000 sims/intro/rep$rep.vcf.gz pop_labels.tsv pop1,pop2,pop3,pop4 > runDStats/d_rep$rep.tsv
	dstar -b 50000 sims/intro/rep$rep.vcf.gz pop_labels.tsv pop1,pop2,pop3 > runDStats/dstar_rep$rep.tsv
done

getNullAndFPR runDStats/d 9 resultsDStats/d
getNullAndFPR runDStats/d 10 resultsDStats/dplus
getNullAndFPR runDStats/dstar 8 resultsDStats/dstar

# Calculate Overlap.
calcOverlap() {
        tract=$1
        wind=$2
        minChromNum=$3
        out=$4
        for rep in {1..100}
        do 
               python3 calcOverlap.py ${tract}/rep${rep}.csv.gz ${wind}_rep${rep}.tsv ${minChromNum} > ${out}/rep${rep}_overlap.csv
        done
}

calcOverlap sims/intro runDStats/d 1 resultsDStats

# Calculate Performance.
calcPerformance() {
        nullDist=$1
        wind=$2
        overlap=$3
        for rep in {1..100}
        do 
               python3 calcPerformance.py ${nullDist} ${wind} ${overlap} ${rep} > ${overlap}/rep${rep}_performance.csv
        done
}

calcPerformance resultsDStats runDStats resultsDStats
