#!/bin/bash
for rep in {1..100}
do
	hmmix decode -window_size 10000 -obs=obs/obs_rep${rep}.P2_0.txt -weights=weights.bed -mutrates=mutrates.bed -out=decoded10/decoded_rep${rep}.P2_0 -param=trained10/trained_rep${rep}.P2_0.json
done

