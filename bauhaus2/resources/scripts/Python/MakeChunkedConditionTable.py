import os
import csv
import argparse
import numpy as np
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
    parser.add_argument('--condition-table',
                        required=True,
                        help='list of conditions')
    parser.add_argument('--output',
                        required=True,
                        help='output csv chunked condition table')
    args = parser.parse_args()

    return args.asets, args.conditions, args.output

def generateChunkedConditionTable(asets, conditions, output):
    """
    description of def goes here
    """
    cct = {'Condition': [],
           'MappedRecord': [],
           'Genome': []}


    cnt = 0
    condition = asets[0].split(os.path.sep)[1]
    for aset in asets:
        # we need condition names to be unique for constant_arrow.R
        # we do it systematically, so it can be stripped away later
        if aset.split(os.path.sep)[1] == condition:
            cnt += 1
        else:
            cnt = 0
        condition = aset.split(os.path.sep)[1]
        mapped_record = aset
        alignments = AlignmentSet(mapped_record)


def main():
    asets, conditions, output = parseArgs()
    cct = generateChunkedConditionTable(asets, conditions, output)
    
    return None

if __name__ == '__main__':
    main()
