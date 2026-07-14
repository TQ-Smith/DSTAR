#!/bin/bash
for rep in {1..100}
do
	hmmix create_ingroup -ind=individuals.json -vcf=./sims/intro/ingroup_rep${rep}.vcf.gz -weights=weights.bed -outgroup=./outgroup/outgroup_rep${rep}.txt -out=./obs/obs_rep${rep} -ancestral=./sims/intro/rep${rep}.fa
done

