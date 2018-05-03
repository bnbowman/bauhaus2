#! /usr/bin/env python

import sys
import json

import numpy as np

from collections import defaultdict

import matplotlib; matplotlib.use('agg')
import matplotlib.pyplot as plt
import matplotlib.cm as cm

import pandas as pd

import seaborn as sns

callfn = sys.argv[1]
zmwfn = sys.argv[2]

def CallAccuracyPlots( name, df ):
    ax = sns.factorplot(x="AdapterType", y="CallAccuracy", col="Condition", hue="AdapterClass", kind="box", data=df)
    plt.subplots_adjust(top=0.9)
    ax.fig.suptitle("Adapter Call Accuracy by Type and Classification")

    plt.ylim(0.4, 1.05)
    pltFilename = "{0}_call_accuracy_box.png".format(name)
    plt.savefig(pltFilename)
    plt.close()

    p1 = {"caption": "Adapter Call Accuracy Box Plots For Adapter Types",
          "image": pltFilename,
          "tags": [],
          "id": "{0} - Adapter Call Accuracy Box Plots".format(name),
          "title": "{0} - Adapter Call Accuracy Box Plots".format(name),
          "uid": "0510001"}

    return [p1]

def ZmwAccuracyPlots( name, df ):
    ax = sns.factorplot(x="AdapterType", y="ZmwAccuracy", col="Condition", hue="AdapterClass", kind="box", data=df)
    plt.subplots_adjust(top=0.9)
    ax.fig.suptitle("ZMW Accuracy for Adapter Calls\nby Type and Classification")

    plt.ylim(0.4, 1.05)
    pltFilename = "{0}_zmw_accuracy_box.png".format(name)
    plt.savefig(pltFilename)
    plt.close()

    p1 = {"caption": "ZMW Accuracy Box Plots For Adapter Types",
          "image": pltFilename,
          "tags": [],
          "id": "{0} - ZMW Accuracy Box Plots".format(name),
          "title": "{0} - ZMW Accuracy Box Plots".format(name),
          "uid": "0510002"}

    return [p1]

def WriteReportJson( plotList=[], tableList=[] ):
    reportDict = {"plots":plotList, "tables":tableList}
    reportStr = json.dumps(reportDict, indent=1)
    with open("report.json", 'w') as handle:
        handle.write(reportStr)

callData = pd.read_csv(callfn)
zmwData = pd.read_csv(zmwfn)
call_plots = CallAccuracyPlots( "combined", callData )
zmw_plots = ZmwAccuracyPlots( "combined", zmwData )
WriteReportJson( call_plots + zmw_plots )
