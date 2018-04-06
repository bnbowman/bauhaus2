#!/usr/bin/env python

import os
import sys
import json
import os.path as op
from pricompare.models.jsonreport import Report, Plot

plot_list = sys.argv
plot_list.pop(0)
zia_plots = []

for plot in plot_list:
    if op.isfile(plot + ".png"):
        zia_plots.append(Plot(plot, plot + ".png",
                                  plot.replace("_", " "), plot.replace("_", " "),
                                  [plot, 'json', 'report']))

Report(plots=zia_plots).write("report.json")
