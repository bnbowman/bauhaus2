from pbcore.io import AlignmentSet
import argparse
import csv

def parse_args():
    """
    parse command-line arguments
    aset   -> path to alignmentset.xml
    output -> path to output textfile
    """
    parser = argparse.ArgumentParser(description= \
                                     'Retrieve number of references/contigs')
    parser.add_argument('--aset',
                        required=True,
                        help='alignmentset')
    parser.add_argument('--output',
                        required=True,
                        help='output textfile ' + \
                        'for storing number of references/contigs')
    args = parser.parse_args()
    return args.aset, args.output

def retrieve_num_contigs(aset_path):
    """
    retrieve the number of references/contigs from aset
    """
    aset = AlignmentSet(aset_path)
    num_contigs = len(aset.refIds)
    return num_contigs

def write_output(num_contigs, output_path):
    """
    write to output textfile
    """
    with open(output_path, 'wb') as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow([num_contigs])

def main():
    """
    perform above tasks
    """
    aset_path, output_path = parse_args()
    num_contigs = retrieve_num_contigs(aset_path)
    write_output(num_contigs, output_path)
    return None

if __name__ == '__main__':
    main()
