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
    parser.add_argument('--asets',
                        required=True,
                        nargs='+',
                        help='alignmentset')
    parser.add_argument('--outputs',
                        required=True,
                        nargs='+',
                        help='output textfile ' + \
                        'for storing number of references/contigs')
    args = parser.parse_args()
    return args.asets, args.outputs

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
    aset_paths, output_paths = parse_args()
    for aset_path, output_path in zip(aset_paths, output_paths):
        num_contigs = retrieve_num_contigs(aset_path)
        write_output(num_contigs, output_path)
    return None

if __name__ == '__main__':
    main()
