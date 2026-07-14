
# ADAPTED FROM FENG ET AL 2024
# https://github.com/LeslyLopezFang/Dplus/blob/main/supp_analyses/sim_intro_extract_tracts.py

import msprime
import tskit
import numpy as np
import pandas as pd
import sys

# Get cli options.
inputTreeSequence = sys.argv[1]
outputBaseName = sys.argv[2]

def extract_introgressed_segments(
    ts,
    introgression_time,
    intro_population,
    target_populations,
):
    ''' Returns a list of tuples in the following format:
        (start (inclusive), end (exclusive), dicc) where 
        the keys in dicc correspond to the target node
        where a value of 1 corresponds to introgressed and
        a value of 0 corresponds to not introgrssed.
    
        ts -- TreeSequence from a simulation with record migrations.
        introgression_time -- Time of gene flow.
        intro_population -- Population ID of the donor population.
        target_populations -- List of target population IDs.
    '''
    # Extract all information needed for computing introgressed segments from the migration table.
    migration_table        = ts.dump_tables().migrations # The entire migration table.
    migration_nodes        = migration_table.node # Array of ancestral nodes.
    migration_destinations = migration_table.dest # Donor nodes (dest -> source).
    migration_times        = migration_table.time # Recipient nodes (dest -> source).
    migration_left         = migration_table.left # Starting positions [left, right) for migrating segments.
    migration_right        = migration_table.right # Stop positions [left, right) for migrating segments.
    # Extract target haplotypes in the form of list.
    tar_haplotype = []
    for pop in target_populations:
        tar_haplotype.extend(ts.get_samples(pop))
    tar_haplotype = sorted(tar_haplotype)
    # Masks: Introgressing population and introgression time.
    introgression_mask = (migration_destinations == intro_population) # Nodes that belong to the donor population.
    # Donor nodes that correspond to the time of gene flow.
    within_time_mask   = (migration_times[introgression_mask] == introgression_time)
    # Extract the introgressing nodes for the given introgression time and tree coordinates.
    intro_nodes = migration_nodes[introgression_mask][within_time_mask]
    intro_left  = migration_left[introgression_mask][within_time_mask]
    intro_right = migration_right[introgression_mask][within_time_mask]
    # Intialize a list to store the results.
    results = []
    # For every tree with the specified haplotypes...
    for i, tree in enumerate(ts.trees(tracked_samples=tar_haplotype)):
        # Intialize an empty set to store introgressed tracts for this specific tree.
        tree_intro = set()
        # Intialize a set with the target haplotypes.
        tar_set = set(tar_haplotype)
        # For every introgressing node...
        for idx, node in enumerate(intro_nodes):
          # If the tree interval is covered, partially or fully, by the migrating node then it is introgressed...
          if ((tree.interval[0] < intro_right[idx] and intro_left[idx] < tree.interval[1])):
                # Extract the leaves of the introgressing node.
                leaves = set(tree.get_leaves(node))
                # If the introgressed tree has at least one of our target haplotypes...
                if tree.num_tracked_samples(node) > 0:
                    # Intialize a list of haplotypes to remove after determining they are introgressed.
                    to_remove = []
                    # For every target haplotype...
                    for target in tar_set:
                        # If the haplotype is one of our leaves...
                        if target in leaves:
                            # Add the haplotype to the introgressed set for this tree.
                            tree_intro.add(target)
                            # Append the haplotype to the remove list.
                            to_remove.append(target)
                    # For every introgressed haplotye. 
                    for x in to_remove:
                        # Remove it since we already found that it is introgressed.
                        tar_set.remove(x)
        # Intialize a dictionary for this tree.
        intro_dicc = {}
        # For every target haplotype...
        for i, hap in enumerate(tar_haplotype):
            # If the haplotype is introgressed...
            if hap in tree_intro:
                # Fill the dictionary.
                intro_dicc[hap] = 1
            # Else...
            else:
                # Fill the dictionary.
                intro_dicc[hap] = 0
        # Update the results.
        results.append((tree.interval.left, tree.interval.right, intro_dicc))
    return results

# Load our tree sequence
mts = tskit.load(inputTreeSequence)

# Extract the introgressed segments.
tracts = extract_introgressed_segments(
    ts=mts,
    introgression_time=1_600,
    intro_population=[2],
    target_populations=[1],
)

# Intialize a dataframe dictionary.
df_dicc = {
    'left': [],
    'right': [],
    'length': [],
    'n_intro': [],
}

# For every tract.
for tract in tracts:
    # Extract the tract information.
    left, right, is_intro = tract
    # Compute the number of introgressed lineages.
    n_intro = sum(i for i in is_intro.values())
    # Update the dictionary.
    df_dicc['left'].append(int(left))
    df_dicc['right'].append(int(right))
    df_dicc['length'].append(int(right - left))
    df_dicc['n_intro'].append(n_intro)

# Convert the dictionary to a dataframe.
tracts_df = pd.DataFrame(data=df_dicc)

# Export the the tract information
tracts_df.to_csv(f'{outputBaseName}.csv.gz', index=False)
