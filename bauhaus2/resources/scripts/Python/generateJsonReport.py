#!/usr/bin/env python

import os
import sys
import json
import argparse
import os.path as op
from pricompare.models.jsonreport import Report, Plot, Table

class generateJsonReport:
    def generate_json_report(self, plots, tables):
        zia_plots = []
        zia_tables = []
        if plots is not None:
            plot_list = plots
            for plot in plot_list:
                if op.isfile(plot + ".png"):
                    zia_plots.append(Plot(plot, plot + ".png",
                                  plot.replace("_", " "), plot.replace("_", " "),
                                  [plot, 'json', 'report', 'png']))
        if tables is not None:
            table_list = tables
            for table in table_list:
                if op.isfile(table + ".csv"):
                    zia_tables.append(Table(table, table + ".csv",
                                  table.replace("_", " "), table.replace("_", " "),
                                  [table, 'json', 'report', 'csv']))
        return Report(plots=zia_plots, tables=zia_tables).write("report.json")

parser = argparse.ArgumentParser(description='Generate Json Report for Zia')
parser.add_argument('-p','--plot', nargs='+', help='Input Plot Names', required=False)
parser.add_argument('-t','--table', nargs='+', help='Input Table Names', required=False)
args = parser.parse_args()

gjr = generateJsonReport()
gjr.generate_json_report(args.plot, args.table)
