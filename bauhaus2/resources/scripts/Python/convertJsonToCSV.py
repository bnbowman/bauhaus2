import csv
import json
import argparse
import pandas as pd
from pandas.io.json import json_normalize 

parser = argparse.ArgumentParser(description='Convert Json Report to CSV')
parser.add_argument('json', help='Input Json File')
parser.add_argument('csv', help='Output CSV File')
parser.add_argument('condition', help='Condition Name')
args = parser.parse_args()

with open(args.json) as f:
     d = json.load(f)

nycphil = json_normalize(d['attributes'])
nycphil['condition'] = args.condition
nycphil.to_csv(args.csv)
