import pandas as pd
import numpy as np
import glob
import os
import sys

window_size = 50_000

# Find all input files
files = glob.glob(sys.argv[1] + "*.posterior.txt")

samples = []
all_sites = []

for filename in files:

    df = pd.read_csv(filename, sep=r"\s+")

    # Convert columns to numeric
    df["start"] = pd.to_numeric(df["start"])
    df["Archaic"] = pd.to_numeric(df["Archaic"])

    # Last column contains comma-separated site positions
    site_col = df.columns[-1]

    # Assign each row to a 50-kb window
    df["window_start"] = (
        (df["start"] // window_size) * window_size + 1
    )

    # Calculate mean HMMix score per individual/window
    stats = (
        df.groupby(["chrom", "window_start"])
        .agg(
            mean_score=("Archaic", "mean")
        )
        .reset_index()
    )

    # ---------------------------------------------------------
    # Create windows through the maximum observed start
    # position for each chromosome
    # ---------------------------------------------------------
    chromosomes = df["chrom"].unique()

    windows_list = []

    for chrom in chromosomes:

        chrom_max = df.loc[
            df["chrom"] == chrom, "start"
        ].max()

        windows_list.append(
            pd.DataFrame({
                "chrom": chrom,
                "window_start": np.arange(
                    1,
                    chrom_max + 1,
                    window_size
                )
            })
        )

    windows = pd.concat(
        windows_list,
        ignore_index=True
    )

    result = windows.merge(
        stats,
        on=["chrom", "window_start"],
        how="left"
    )

    result["individual"] = os.path.basename(filename)

    samples.append(result)

    # ---------------------------------------------------------
    # Extract individual site positions
    # ---------------------------------------------------------
    for _, row in df[
        ["chrom", "window_start", site_col]
    ].iterrows():

        value = row[site_col]

        if pd.isna(value) or str(value) in ("", "nan"):
            continue

        for site in str(value).split(","):

            site = site.strip()

            if site == "":
                continue

            all_sites.append({
                "chrom": row["chrom"],
                "window_start": row["window_start"],
                "site": site
            })


# -------------------------------------------------------------
# Combine all individuals
# -------------------------------------------------------------
samples = pd.concat(samples, ignore_index=True)


# -------------------------------------------------------------
# Count UNIQUE genomic sites across ALL individuals
# -------------------------------------------------------------
all_sites = pd.DataFrame(all_sites)

if len(all_sites) > 0:

    unique_sites = (
        all_sites
        .drop_duplicates(
            ["chrom", "window_start", "site"]
        )
        .groupby(
            ["chrom", "window_start"]
        )
        .size()
        .reset_index(name="n_sites")
    )

else:

    unique_sites = pd.DataFrame(
        columns=[
            "chrom",
            "window_start",
            "n_sites"
        ]
    )


# -------------------------------------------------------------
# Average HMMix across individuals
# -------------------------------------------------------------
result = (
    samples
    .groupby(["chrom", "window_start"])
    .agg(
        hmmix=("mean_score", "mean")
    )
    .reset_index()
)


# Add number of unique sites
result = result.merge(
    unique_sites,
    on=["chrom", "window_start"],
    how="left"
)

result["n_sites"] = (
    result["n_sites"]
    .fillna(0)
    .astype(int)
)

result["#Block_Num"] = range(
    1,
    len(result) + 1
)

result = result.rename(columns={
    "window_start": "Start_Position",
    "chrom": "Chromosome",
    "n_sites": "Num_Loci"
})

result["End_Position"] = (
    result["Start_Position"] + 49999
)

col = "#Block_Num"

result = result[
    [col] +
    [c for c in result.columns if c != col]
]


# -------------------------------------------------------------
# Write output
# -------------------------------------------------------------
print(result.to_csv(
    sep="\t",
    index=False
))

