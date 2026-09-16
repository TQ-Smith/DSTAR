import pandas as pd
import numpy as np
import glob
import os
import sys

window_size = 50_000
chrom_length = 20_000_000

# Find all input files
files = glob.glob(sys.argv[1] + "*.posterior.txt")

samples = []

for filename in files:

#    print("Processing:", filename)

    df = pd.read_csv(filename, sep=r"\s+")

    # Convert columns to numeric
    df["start"] = pd.to_numeric(df["start"])
    df["Archaic"] = pd.to_numeric(df["Archaic"])

    # Assign each row to a 50 kb window
    df["window_start"] = (df["start"] // window_size) * window_size + 1

    # Compute mean Archaic probability within each window
    means = (
        df.groupby("window_start")["Archaic"]
        .mean()
        .reset_index(name="mean_score")
    )

    # Create all 50 kb windows
    windows = pd.DataFrame({
        "window_start": np.arange(1, chrom_length + 1, window_size)
    })

    # Merge observed windows onto all possible windows
    result = windows.merge(
        means,
        on="window_start",
        how="left"
    )

    # Keep track of the individual
    result["individual"] = os.path.basename(filename)

    samples.append(result)


# Combine all individuals
samples = pd.concat(samples, ignore_index=True)


# Average across individuals
result = (
    samples
    .groupby("window_start")["mean_score"]
    .mean()
    .reset_index(name="hmmix")
)


# Write output
print("#", end='')
print(result.to_csv(sep="\t", index=False))
