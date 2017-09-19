#!/user/bin/python3
'''
Created on Sep 1, 2017

@author: deasmith
'''

if __name__ == '__main__':
    pass

import argparse
import requests
import pandas as pd
from bs4 import BeautifulSoup

class GetZiaTags:
    
    def parse_url_for_tagtable(self, url):
            response = requests.get(url,auth=('itg', 'E6zT2YbX'))
            soup = BeautifulSoup(response.text, 'lxml')
            tables = soup.find_all('table')
            
            tagtable=pd.DataFrame(columns=['ID', 'Tags'])
            for i in range(len(tables)):
                df = self.parse_html_table(tables[i])
                tagtable = pd.concat([tagtable, df[['ID','Tags']]])
            return tagtable
    
    def parse_html_table(self, table):
        n_columns = 0
        n_rows=0
        column_names = []
    
        # Find number of rows and columns
        # we also find the column titles if we can
        for row in table.find_all('tr'):
            
            # Determine the number of rows in the table
            td_tags = row.find_all('td')
            if len(td_tags) > 0:
                n_rows+=1
                if n_columns == 0:
                    # Set the number of columns for our table
                    n_columns = len(td_tags)
                    
            # Handle column names if we find them
            th_tags = row.find_all('th') 
            if len(th_tags) > 0 and len(column_names) == 0:
                for th in th_tags:
                    column_names.append(th.get_text())
    
        # Safeguard on Column Titles
        if len(column_names) > 0 and len(column_names) != n_columns:
            raise Exception("Column titles do not match the number of columns")
    
        columns = column_names if len(column_names) > 0 else range(0,n_columns)
        df = pd.DataFrame(columns = columns,
                          index= range(0,n_rows))
        row_marker = 0
        for row in table.find_all('tr'):
            column_marker = 0
            columns = row.find_all('td')
            for column in columns:
                df.iat[row_marker,column_marker] = column.get_text()
                column_marker += 1
            if len(columns) > 0:
                row_marker += 1
                
        # Convert to float if possible
        # for col in df:
        #     try:
        #         df[col] = df[col].astype(float)
        #     except ValueError:
        #         pass
        
        return df


parser = argparse.ArgumentParser(description='Find list of Zia tags')
parser.add_argument('uri', metavar='uri',help='URI for the Zia Plot Index confluence page')
parser.add_argument('path', metavar='path',help='Path for the output CSV file containing Plot IDs and lists of tags for each Zia plot')
args = parser.parse_args()

gzt = GetZiaTags()
tagtable = gzt.parse_url_for_tagtable(args.uri)

tagtable.to_csv(args.path, index=False, encoding = 'utf-8')


    
