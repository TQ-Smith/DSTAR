
import numpy as np
import pandas as pd
import sys
import os

nullBase = sys.argv[1]
statBase = sys.argv[2]
overlapBase = sys.argv[3]
rep = sys.argv[4]

def performance(nullFile, overlapFile, statFile, column, statName, perf_df):
	null_df = pd.read_csv(nullFile)
	stat_vals = pd.read_csv(statFile, header=None, engine='python', comment='#', sep='\t', skipfooter=1).iloc[:, column - 1]

	pvals = np.arange(0.01, 1.01, 0.01)
	lwr = null_df['lwr'].values
	upr = null_df['upr'].values

	overlap_df = pd.read_csv(overlapFile)
	percent_overlap = overlap_df['overlap_pc'].values

	# For every p-value.
	for i, pval in enumerate(pvals):
		# For every threshold.
		for threshold in [0.05, 0.1, 0.25]:
			sig = (stat_vals >= upr[i])
			intro_winds = (percent_overlap >= threshold)
			results = sig.astype(object)
			# results = np.array(object)
			results = np.where((sig == True) & (intro_winds == True), 'TP', results)
			results = np.where((sig == False) & (intro_winds == False), 'TN', results)
			results = np.where((sig == True) & (intro_winds == False), 'FP', results)
			results = np.where((sig == False) & (intro_winds == True), 'FN', results)
			results = np.where(np.isnan(stat_vals), np.nan, results)
			results = np.where(((percent_overlap < threshold) & (percent_overlap != 0)), np.nan, results)
			perf_df[f'{statName}-{round(pval, 2)}-{threshold}'] = results

perf_df = pd.DataFrame()
#if os.path.exists('{nullBase}/fd_fpr.csv'):
#	performance(f'{nullBase}/fd_fpr.csv', f'{overlapBase}/rep{rep}_overlap.csv', f'{statBase}/d_rep{rep}.tsv', 7, 'f_d', perf_df)
#performance(f'{nullBase}/df_fpr.csv', f'{overlapBase}/rep{rep}_overlap.csv', f'{statBase}/d_rep{rep}.tsv', 8, 'd_f', perf_df)
performance(f'{nullBase}/d_fpr.csv', f'{overlapBase}/rep{rep}_overlap.csv', f'{statBase}/d_rep{rep}.tsv', 9, 'd', perf_df)
performance(f'{nullBase}/dplus_fpr.csv', f'{overlapBase}/rep{rep}_overlap.csv', f'{statBase}/d_rep{rep}.tsv', 10, 'dplus', perf_df)
performance(f'{nullBase}/dstar_fpr.csv', f'{overlapBase}/rep{rep}_overlap.csv', f'{statBase}/dstar_rep{rep}.tsv', 8, 'dstar', perf_df)
#performance(f'{nullBase}/fourPop_dstar_fpr.csv', f'{overlapBase}/rep{rep}_overlap.csv', f'{statBase}/fourPop_dstar_rep{rep}.tsv', 8, 'fourPop_dstar', perf_df)

print(perf_df.to_csv(index = False))
