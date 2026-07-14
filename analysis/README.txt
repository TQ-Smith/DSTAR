Directory contains all analysis files used in the paper.

- analysis.ipynb
    Jupyter notebook that generates figures and tables.

NOTE: Many of these scripts are redundant.

- sims
    All simulation and evaluation scripts for comparing D/D+/D*.
    I seperated the scripts to generate the null (noIntro) and with geneflow (Intro).
    - sim.py -> The standard simulation script.
    - simDrift.py -> Change the effective population sizes.
    - simMolClock.py -> Change the molecular clock.
    - tract.py -> Extract introgressed tracks.
    - tractsMolClock.py -> Extract introgressed tracks for molecular clock violations.
    - calcFPR.py -> Calculate the FPR from null dist.
    - calcOverlap.py -> Calculate block overlap with introgressed tracts.
    - calcPerformance.py -> Create dataframe of performance metrics.
    - sim*.sh -> Generate simulated replicates.
    - run*.sh -> Run D/D+/D* on simulated replicates.
    - calcGlobal.sh -> Get the genome-wide results
    - popFiles.sh -> Create sample to population labels.
    - performance.sh -> Calculate precision/recall for all scenarios.
    - analysis.sh -> Run everything from simulation to performance.

- hmmix 
    All simulation and evaluation scripts for comparing D/D+/D* to hmmix.
    For lower sample size, we alter scripts to accomodate a single outgroup sample.
    - sims/sim.py -> Same as above.
    - sim/sim.sh -> Create replicates.
    - sim/tracts.py -> Same as above.
    - sim/split.sh -> Split VCF files to ingroup and outgroup for hmmix.
    - sim/fake_ref.py -> Create a fake reference sequence for hmmix.
    - sim/create_refs.sh -> Create fake reference sequence for all replicates.
    - calc*.py -> Same as above.
    - create_ingroup.sh -> Create ingroup for hmmix on all replicates.
    - create_outgroup.sh -> Create outgroup for hmmix on all replicates.
    - train.sh -> Train hmmix on all replicates.
    - decode.sh -> decode the one ingroup sample for all replicates.
    - pop_labels.tsv -> Sample to population labels for D statistics.
    - dstats.sh -> Run D/D+/D* on all replicates.
    - individuals.json -> Ingroup/outgroup labels for hmmix.
    - mutrates.bed -> Constant for simulated segment.
    - weights.bed -> We can use the whole simulated segment.
    - Initialguesses.json -> Initial guesses for hmm parameters.


- ancient
    Scripts for running D/D+/D* on empirical ancient DNA.
    - extract.py -> Extract samples from hail table.
    - extract_samples.sh -> Extract Sardinians and Papuans from hail.
    - ancient.sh -> Extract Denisovan from AADR and liftover.
    - normalize.sh -> Normalize HGDP genotypes.
    - merge.sh -> Merge modern and ancient samples.
    - subsample.sh -> Subsample modern samples.
    - run.sh -> Run whole analysis.