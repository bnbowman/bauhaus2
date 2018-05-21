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

if len(d) == 0:
  with open(args.csv, "w") as my_empty_csv:
    pass
else:
  df = json_normalize(d['attributes'])
  df['condition'] = args.condition
  df.to_csv(args.csv)
