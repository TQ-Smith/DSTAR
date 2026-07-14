#!/bin/bash
for rep in {1..100}
do
	hmmix train -window_size 10000 -obs=obs/obs_rep${rep}.P2_0.txt -weights=weights.bed -mutrates=mutrates.bed -out=trained10/trained_rep${rep}.P2_0.json
done

bash decode.sh
