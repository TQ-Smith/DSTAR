import hail as hl

mt = hl.read_matrix_table(
	"gnomad.genomes.v3.1.2.hgdp_1kg_subset_dense.mt"
)

samples = []
with open("hsp.txt", 'r') as file:
	for line in file:
		samples.append(line.strip("\n"))

sample_list = hl.literal(samples)

mt_subset = mt.filter_cols(
    hl.literal(sample_list).contains(mt.s)
)

mt_gt = mt_subset.select_entries('GT').select_rows().select_cols()

hl.export_vcf(mt_gt, "hsp.vcf.bgz")
