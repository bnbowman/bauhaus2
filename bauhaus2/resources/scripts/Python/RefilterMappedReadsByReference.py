import argparse
import random
import numpy as np
from pbcore.io import AlignmentSet


def parseArgs():
    """
    parse command-line arguments
    asets -> chunked-by-reference asets

    Recasts rname filter in terms of whitelist zmw filter
    for pbbam compatibility
    """
    parser = argparse.ArgumentParser(description = \
                                     'Generate mapping metrics CSV')
    parser.add_argument('--asets',
                        required=True,
                        nargs='+',
                        help='list of chunked AlignmentSets')
    args = parser.parse_args()

    return args.asets

def reDefineFilter(aset):
    """
    pbbam can't handle reference filters.
    so I have to recast a reference filter
    into a list of zmws
    """
    alignments = AlignmentSet(aset)
    zmws = np.unique(alignments.index['holeNumber'])
    if len(zmws) > 1000:
        zmws = random.sample(zmws, 1000)
    alignments.filters.addRequirement(zm=[('=', zmws)])
    alignments.filters.removeRequirement('rname')
    alignments.write(aset)

def main():
    asets = parseArgs()
    for aset in asets:
        reDefineFilter(aset)
    
    return None

if __name__ == '__main__':
    main()
