import numpy as np
import sys

def calcFPR(nullDist):
	nullDist = np.sort(nullDist)
	print("alpha,lwr,upr,fpr")
	pvals = np.arange(0.01, 1.01, 0.01)
	for pval in pvals:
		upr = np.quantile(nullDist, 1 - (round(pval, 2) / 2))
		lwr = np.quantile(nullDist, (round(pval, 2) / 2))
		fpr = np.mean((nullDist >= upr) | (nullDist <= lwr))
		print(round(pval, 2), lwr, upr, fpr, sep=',')

inFile = open(sys.argv[1], 'r')
nullDist = [float(line) for line in inFile]
calcFPR(nullDist)
