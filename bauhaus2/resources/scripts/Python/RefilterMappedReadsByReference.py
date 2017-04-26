import argparse
import random
from pbcore.io import AlignmentSet


def parseArgs():
    """
    parse command-line arguments
    aset  -> path to alignmentset.xml
    arrow -> path to constantArrow output csv
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
    zmws = alignments.index['holeNumber']
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
