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
    parser.add_argument('--refs',
                        required=True,
                        nargs='+',
                        help='list of reference fastas')
    parser.add_argument('--output',
                        required=True,
                        help='output csv chunked condition table')
    args = parser.parse_args()

    return args.asets, args.condition_table, args.refs, args.output

def readOriginalConditionTable(condition_table):
    """
    
    """
    ct = {'Condition': [],
          'Genome': []}

    with open(condition_table, 'rb') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            ct['Condition'].append(row['Condition'])
            ct['Genome'].append(row['Genome'])

    return ct

def generateChunkedConditionTable(asets, ct, refs, output):
    """
    description of def goes here
    """
    cct = []

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
        # find ref name based on comparison to original condition table
        for r in refs:
            c = r.split(os.path.sep)[1]
            if condition == c:
                ref = r
                break
        cct.append({'Condition': condition + '_' + str(cnt),
                    'MappedSubreads': aset,
                    'Reference': ref})

    return cct

def writeContigChunkedConditionTable(cct, output):
    """
    description goes here
    """
    with open(output, 'wb') as csvfile:
        fieldnames = cct[0].keys()
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in cct:
            writer.writerow(row)

def main():
    asets, condition_table, refs, output = parseArgs()
    ct = readOriginalConditionTable(condition_table)
    cct = generateChunkedConditionTable(asets, ct, refs, output)
    writeContigChunkedConditionTable(cct, output)
    
    return None

if __name__ == '__main__':
    main()
