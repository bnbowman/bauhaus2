# This module provides a few utility functions for the snakemake workflows

def flatten(lst):
    v = []
    for l in lst:
        v.extend(l)
    return v
