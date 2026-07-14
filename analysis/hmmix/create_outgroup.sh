#!/bin/bash
for rep in {1..100}
do
	hmmix create_outgroup -ind=individuals.json -vcf=./sims/intro/outgroup_rep${rep}.vcf.gz -weights=weights.bed -out=./outgroup/outgroup_rep${rep}.txt -ancestral=./sims/intro/rep${rep}.fa -refgenome=./sims/intro/rep${rep}.fa
done

