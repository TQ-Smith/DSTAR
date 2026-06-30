# TAKEN FROM FANG ET AL. 2024
# https://github.com/LeslyLopezFang/Dplus/blob/main/msprime_simulations/code/msprime_simulations.py

import numpy as np
import msprime
from collections import defaultdict
import os
import argparse

##Parameters
#Default parameters
default_mutation_rate=1.5e-8
default_sequence_length=2e7
default_recombination_rate=10e-8
default_ploidy=1

#Demography Parameters
default_Ne=10000
default_t_1234 = 20_000
default_t_123 = 16_000
default_t_12 = 4_000
default_t_gf = 1_600

default_donor_population = "P3"
default_recipient_population="P2"

parser = argparse.ArgumentParser()

# The population we are changing the ne of.
parser.add_argument("--pop", type=int, default=2, help="The population we are changing the Ne of. Default 2.")

#Specify file names
parser.add_argument("--tree_sequence_file",type=str,help="Path to tree sequence file to be output.")
parser.add_argument("--vcf_file",type=str,help="Path to vcf file to be output.")

parser.add_argument("-f",type=int,help="Admixture proportion f. Write as percentage. For example f = 0.03 is -f 3")
parser.add_argument("-s","--seed",type=int,help="Random seed number.")

parser.add_argument("--p1_sample_size",type=int,default=1,help="The number of samples for Population 1. Default: 1")
parser.add_argument("--p2_sample_size",type=int,default=1,help="The number of samples for Population 2. Default: 1")
parser.add_argument("--p3_sample_size",type=int,default=1,help="The number of samples for Population 3. Default: 1")
parser.add_argument("--p4_sample_size",type=int,default=1,help="The number of samples for Population 4. Default: 1")

parser.add_argument("--mutation_rate",type=float,nargs='?',default=default_mutation_rate,help="The mutation rate for each population. Default: 1.5e-8")
parser.add_argument("--sequence_length",type=int,nargs='?',default=default_sequence_length,help="The size of the sequence for each population. Default is 2 MB")
parser.add_argument("--recombination_rate",type=float,nargs='?',default=default_recombination_rate,help="The recombination rate. Default is 10e-8")
parser.add_argument("--ploidy",type=int,nargs='?',default=default_ploidy,help="The ploidy of the samples in the populations. Default is sampling 1 with a default ploidy of 2.")

parser.add_argument("--ne",type=int,dest="Ne",nargs='?',default=default_Ne,help="Ne for each population we are changing. Default is 10,000.")

parser.add_argument("--t_1234",type=int,nargs='?',default=default_t_1234,help="Time when P4 diverges from ancestral population of P1, P2 and P3. Default is 20 * 4 * Ne.")
parser.add_argument("--t_123",type=int,nargs='?',default=default_t_123,help="Time when P3 diverges from ancestral population of P1 and P2. Default is 0.5 * 4 * Ne.")
parser.add_argument("--t_12",type=int,nargs='?',default=default_t_12,help="Time when P1 and P2 diverge. Default is 0.25 * 4 * Ne.")
parser.add_argument("--t_gf",type=int,nargs='?',default=default_t_gf,help="Time of gene flow. Default is 0.1 * 4 * Ne.")

parser.add_argument("--donor_population",type=str,nargs='?',default=default_donor_population,help="Donor population of gene flow: 'p_1', 'p_2' or 'p_3'. Default is 'p_3'.")
parser.add_argument("--recipient_population",type=str,nargs='?',default=default_recipient_population,help="Recipient population of gene flow: 'p_1', 'p_2' or 'p_3'. Default is p_2.")

args=parser.parse_args()

demography = msprime.Demography()

if args.pop == 1:
	demography.add_population(name="P1",initial_size=args.Ne)
else:
	demography.add_population(name="P1",initial_size=default_Ne)

if args.pop == 2:
	demography.add_population(name="P2",initial_size=args.Ne)
else:
	demography.add_population(name="P2",initial_size=default_Ne)

demography.add_population(name="P3",initial_size=default_Ne)
demography.add_population(name="P4",initial_size=default_Ne)
demography.add_population(name="P12",initial_size=default_Ne)
demography.add_population(name="P123",initial_size=default_Ne)
demography.add_population(name="P1234",initial_size=default_Ne)

if args.f>0:
  demography.add_mass_migration(
    time=args.t_gf, source = args.recipient_population, dest=args.donor_population,proportion = float(args.f/100))

demography.add_population_split(
	time=args.t_12, derived=['P1', 'P2'], ancestral='P12',
)

demography.add_population_split(
        time=args.t_123, derived=['P12', 'P3'], ancestral='P123',
)

demography.add_population_split(
        time=args.t_1234, derived=['P123', 'P4'], ancestral='P1234',
)

#Simulate ancestry
ts = msprime.sim_ancestry(
        samples=[
            msprime.SampleSet(args.p1_sample_size, ploidy=args.ploidy, population='P1'),
            msprime.SampleSet(args.p2_sample_size, ploidy=args.ploidy, population='P2'),
            msprime.SampleSet(args.p3_sample_size, ploidy=args.ploidy, population='P3'),
	    msprime.SampleSet(args.p4_sample_size, ploidy=args.ploidy, population='P4'),
        ],
        demography=demography,
        record_migrations=True,
        sequence_length=args.sequence_length,
	recombination_rate=args.recombination_rate
)

mts=msprime.sim_mutations(ts,rate=args.mutation_rate,model='jc69',discrete_genome=False)

#Store Tree Sequence
mts.dump(args.tree_sequence_file + ".trees")

pop_ids=defaultdict()
for pop in ts.populations():
  pop_ids[pop.metadata['name']]=pop.id

ids_pop=defaultdict()
for pop in ts.populations():
  ids_pop[pop.id]=pop.metadata["name"]

#Get the population of every individual
sample_id_counter=defaultdict(int)
sample_ids=[]
for individual in ts.individuals():
  pop=ts.population(ts.node(individual.nodes[0]).population).metadata["name"]
  sample_ids.append("{}_{}".format(pop.replace("_",""),sample_id_counter[pop]))
  sample_id_counter[pop]+=1

#Write VCF file
with open(args.vcf_file + ".vcf", "w") as vcf_file:
  mts.write_vcf(vcf_file,individual_names=sample_ids, position_transform = lambda x: 1 + np.array(x))
