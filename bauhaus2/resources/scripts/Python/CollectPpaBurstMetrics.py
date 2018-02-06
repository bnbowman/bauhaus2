"""
Created on or around Jan 17, 2018

This script calls the BurstMetrics library in the
biochemistry-toolkit, collecting PPA-classified burst
metrics if they are available. Otherwise (i.e. for
customer-facing data), this script writes 'SubreadSet
does not contain PPA burst info' into the output CSVs

@author: knyquist
"""

import argparse
import pandas
import csv
import biotk.libs.BurstMetrics as bm

def parseArgs():
    parser = argparse.ArgumentParser(
        description='Generate PPA Burst Metrics CSV')
    parser.add_argument('subreadset',
                        help='Path to subreadset XML')
    parser.add_argument('output_bursts',
                        help='Path to bursts output CSV')
    parser.add_argument('output_reads',
                        help='Path to reads output CSV')
    args = parser.parse_args()
    return args

def main():
    args = parseArgs()
    ppa_bursts = bm.PpaBurstMetrics(args.subreadset)

    # load the reads info into pandas dataframe and save to csv
    if hasattr(ppa_bursts, 'reads'):
        reads_summary = pandas.DataFrame.from_records(ppa_bursts.reads)
        reads_summary.to_csv(args.output_reads)
    else:
        with open(args.output_reads, 'wb') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow([label[0] for label in ppa_bursts.reads_dtypes])
            writer.writerow(["'SubreadSet does not contain PPA burst info'"])

    # load the bursts info into pandas dataframe and save to csv
    if hasattr(ppa_bursts, 'ppa_bursts'):
        bursts_summary = pandas.DataFrame.from_records(ppa_bursts.ppa_bursts)
        bursts_summary.to_csv(args.output_bursts)
    else:
        with open(args.output_bursts, 'wb') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow([label[0] for label in ppa_bursts.ppa_burst_dtypes])
            writer.writerow(["'SubreadSet does not contain PPA burst info'"])

if __name__ == '__main__':
    main()
