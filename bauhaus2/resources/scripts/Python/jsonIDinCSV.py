import csv
import json
import argparse

parser = argparse.ArgumentParser(description='Verify Plot IDs in Json Report exist in Conflunence CSV Index')
parser.add_argument('json', help='Input Json File')
parser.add_argument('csv', help='Input CSV File')
args = parser.parse_args()

input_file = open (args.json)
json_array = json.load(input_file)
plotList = [item['uid'] for item in json_array['plots']]

with open(args.csv, 'r+', encoding="utf-8") as index_f:
    data_iter = csv.reader(index_f, 
                           delimiter = ',', 
                           quotechar = '"')
    data = [data for data in data_iter]  
index = [item[0] for item in data]

# check if index contains all elements in plotList
def diff(first, second):
    second = set(second)
    return [item for item in first if item not in second]

index_diff = diff(plotList,index)

if len(index_diff) == 0:
    print("Yes, confluence plot index contains all plots in json report")    
else :
    print("No, confluence plot index does not contains all plots in json report, the missing plot uids are: ")
    print(index_diff)

