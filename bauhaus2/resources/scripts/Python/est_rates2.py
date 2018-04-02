#! /usr/bin/env python

import sys
import operator
from collections import defaultdict

fn = sys.argv[1]

MIN_ACC_DIFF = 0.01
MIN_FLANK_DIFF = 5

MIN_ALIGN_LEN = 5000
MAX_ALIGN_GAP = 50
MIN_ALIGN_ACC = 0.70

def parse_header( line ):
    parts = line.strip().split(',')
    pos = {p:i for i,p in enumerate(parts)}
    return pos

def parse_bool( var ):
    if var.lower() in ["1", "t", "true"]:
        return True
    return False

def parse_file( fn ):
    realCts = defaultdict(int)
    fakeCts = defaultdict(int)
    with open(fn) as handle:
        positions = parse_header( handle.next() )
        #alnLenIdx = positions["AlignmentLength"]
        zmwAccIdx = positions["ZmwAccuracy"]
        maxGapIdx = positions["MaximumAlignGap"]
        isRealIdx = positions["isReal"]
        accIdx = positions["CallAccuracy"]
        flankIdx = positions["CallFlankingScore"]
        for line in handle:
            parts  = line.strip().split(',')
            #alnLen = int(parts[alnLenIdx])
            zmwAcc = float(parts[zmwAccIdx])
            maxGap = int(parts[maxGapIdx])
            if zmwAcc < MIN_ALIGN_ACC or maxGap > MAX_ALIGN_GAP:
                continue
            #if alnLen < MIN_ALIGN_LEN or zmwAcc < MIN_ALIGN_ACC or maxGap > MAX_ALIGN_GAP:
            #    continue
            isReal = parse_bool(parts[isRealIdx])
            acc    = round(float(parts[accIdx]), 2)
            flank  = int(parts[flankIdx])
            if acc == -1.0:
                continue
            if isReal:
                realCts[(acc, flank)] += 1
            else:
                fakeCts[(acc, flank)] += 1

    # Combine the results and return
    keys = list(set(realCts.keys() + fakeCts.keys()))
    results = {}
    for key in keys:
        results[key] = (realCts[key], fakeCts[key])
    return results

def apply_params( data, hardAcc, softAcc, minFlank ):
    TP, TN, FP, FN = 0, 0, 0, 0
    for (acc, flank), (trueCt, falseCt) in data.iteritems():
        if acc >= hardAcc or (acc >= softAcc and flank >= minFlank):
            TP += trueCt
            FP += falseCt
        else:
            TN += falseCt
            FN += trueCt
    return (TP, TN, FP, FN)

def test_params( data, hardAcc, softAcc, minFlank ):
    TP, TN, FP, FN = apply_params( data, hardAcc, softAcc, minFlank )
    sens = round(TP / float(TP + FN), 4)
    spec = round(TN / float(TN + FP), 4)
    prec = round(TP / float(TP + FP), 4)
    fdr  = round(FP / float(TP + FP), 4)
    fnr  = round(FN / float(TP + FN), 4)
    acc  = round((TP + TN) / float(TP + TN + FP + FN), 4)
    f1   = round(2 / ((1/sens) + (1/prec)), 4)
    return (hardAcc, softAcc, minFlank, TP, TN, FP, FN, sens, spec, prec, fdr, fnr, acc, f1)

def frange(start, stop, step):
    while start < stop:
        yield start
        start += step

def test_param_range( data, minAcc, maxAcc, flankRange ):
    results = []
    for hardAcc in frange(minAcc + MIN_ACC_DIFF, maxAcc, MIN_ACC_DIFF):
        for softAcc in frange(minAcc, hardAcc, MIN_ACC_DIFF):
            for minFlank in flankRange:
                res = test_params( data, hardAcc, softAcc, minFlank )
                results.append( res )

    results.sort(key=operator.itemgetter(13), reverse=True)
    results.sort(key=operator.itemgetter(12), reverse=True)
    return results

counts = parse_file( fn )
flankRange = range(0, 101, MIN_FLANK_DIFF)
results = test_param_range( counts, 0.55, 0.81, flankRange )
print "HardAcc,SoftAcc,MinFlank,TP,TN,FP,FN,Sensitivity,Specificity,Precision,FDR,FNR,Accuracy,F1Score"
for res in results:
    print ",".join(str(r) for r in res)
