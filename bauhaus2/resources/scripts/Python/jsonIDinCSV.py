import csv
import json
import argparse
import pandas as pd
import numpy as np
from pandas.io.json import json_normalize 

parser = argparse.ArgumentParser(description='Verify Plot IDs in Json Report exist in Conflunence CSV Index')
parser.add_argument('json', help='Input Json File')
parser.add_argument('csv', help='Input CSV File')
args = parser.parse_args()

with open(args.json) as f:
     d = json.load(f)
df = json_normalize(d['plots'])        
plotList = df['uid']

df1 = pd.read_csv(args.csv, dtype={'ID': object})
index = df1['ID']

# check if index contains all elements in plotList
index_diff = np.setdiff1d(plotList,index)

if len(index_diff) == 0:
    print("Yes, confluence plot index contains all plots in json report")    
else :
    print("No, confluence plot index does not contains all plots in json report, the missing plot uids are: ")
    print(index_diff)
