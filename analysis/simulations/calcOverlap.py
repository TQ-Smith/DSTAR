import numpy as np
import pandas as pd
import sys

# Load the introgressed tracts.
tract_df = pd.read_csv(sys.argv[1])

# Load the windowed D and D+ results.
wind_df = pd.read_csv(sys.argv[2], header=None, engine='python', comment='#', sep='\t', skipfooter=1)

minNumChrom = int(sys.argv[3])

# Filter for introgressed tracts.
intro_df = tract_df[tract_df['n_intro'] >= minNumChrom]
# Intialize the left window positions.
wind_lefts = wind_df.iloc[:,3]
# Intialize the left and right introgressed tract positions.
intro_lefts = intro_df.left.values
intro_rights = intro_df.right.values
# Intialize the overlap.
overlaps = np.zeros(wind_lefts.size)

# For every left window position.
for i, wind_left in enumerate(wind_lefts):
    # Intialize the right position.
    wind_right = wind_left + 50_000
    # Intialize the overlap.
    overlap = 0
    # For every introgressed tract.
    for j in range(intro_lefts.size):
        # Update the amount of overlap.
        overlap += max(0, min(wind_right, intro_rights[j]) - max(wind_left, intro_lefts[j]))
    # Update the overlap.
    overlaps[i] = overlap

# Update the dataframe.
overlap_df = {}
overlap_df['overlap_bp'] = overlaps.astype('int')
overlap_df['overlap_pc'] = overlaps / 50_000

# Export the window information.
print(pd.DataFrame(overlap_df).to_csv())
