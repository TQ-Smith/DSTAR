import numpy as np
import pandas as pd
import sys

# Read file
print("Converting", sys.argv[1], file=sys.stderr)
df = pd.read_csv(sys.argv[1], sep="\t")

window_size = 50000
chrom_length = 20_000_000  # Total chromosome length

# Assign each variant to a window
df["WINDOW_START"] = ((df["POS"] - 1) // window_size) * window_size + 1

# Compute mean SCORE per window
means = (
    df.groupby("WINDOW_START")["SCORE"]
      .mean()
      .reset_index(name="MEAN_SCORE")
)

# Create all 50 kb windows
windows = pd.DataFrame({
    "WINDOW_START": np.arange(1, chrom_length + 1, window_size)
})
windows["WINDOW_END"] = windows["WINDOW_START"] + window_size - 1
windows.loc[windows["WINDOW_END"] > chrom_length, "WINDOW_END"] = chrom_length

# Merge with the calculated means
result = windows.merge(means, on="WINDOW_START", how="left")

# Replace missing values with "NA"
result["MEAN_SCORE"] = result["MEAN_SCORE"].fillna("nan")

# Save
print("#", end='')
print(result.to_csv(sep="\t", index=False))
