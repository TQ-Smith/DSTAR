#!/bin/bash
for rep in {1..100}
do
	python3 fake_ref.py intro/rep${rep}.vcf.gz
done

