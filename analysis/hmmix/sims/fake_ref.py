import sys
import gzip
from collections import defaultdict
import random

BASES = ("A", "C", "G", "T")

variants = []
max_pos = []

with gzip.open(sys.argv[1], "rt") as f:
	for line in f:
		if line[0] == "#":
             		continue
		fields = line.split('\t')
		chrom = fields[0]
		pos = int(fields[1])        # 1-based
		ref = fields[3]
		variants.append((pos, ref))

length = 20000000
# Fill with random bases
seq = [random.choice(BASES) for _ in range(length)]

# Replace with REF alleles
for pos, ref in variants:
	start = pos - 1
	seq[start] = ref

with open(sys.argv[1][0:sys.argv[1].index(".")] + ".fa", "w") as out:
	out.write(f">1\n")
	for s in seq:
		print(s, end='', file=out)
	print("\n", file=out)
