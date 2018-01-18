"""
Created on or around Jan 17, 2018

@author: knyquist
"""

import argparse
import csv

def parseArgs():
    parser = argparse.ArgumentParser(
    	description='Generate PPA Burst Metrics CSV')
    parser.add_argument('subreadset',
    					help='Path to subreadset XML')
    parser.add_argument('output',
    					help='Path to output CSV')
    args = parser.parse_args()
    return args

def main():
	args = parseArgs()
	with open(args.output, 'wb') as csvfile:
		writer = csv.writer(csvfile)
		writer.writerow(['hello world!'])

if __name__ == '__main__':
    main()