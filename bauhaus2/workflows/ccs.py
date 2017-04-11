from bauhaus2.experiment import ResequencingConditionTable
from bauhaus2 import Workflow

from .subreads import subreadsPlan

def CCSMappingReportsPlan(ct, args):
    if ct.inputsAreMapped:
        # Mapping already happened, link it.
        return [ "collect-smrtlink-references.snake",
                 "collect-ccs-mappings.snake",
                 "scatter-subreads.snake" ]
    else:
        # Do our own ccs mapping
        return [ "map-ccs.snake",
                "ccs-subreads.snake",
                "collect-references.snake",
                "scatter-subreads.snake" ] + \
                subreadsPlan(ct, args)

class CCSMappingReportsWorkflow(Workflow):
    """
    Map CCS reads to the reference and generate comprehensive analysis
    plots and tables, including analysis of consensus accuracy by
    numpasses and yield of CCS reads by quality.
    """
    WORKFLOW_NAME        = "CCSMappingReports"
    CONDITION_TABLE_TYPE = ResequencingConditionTable
    R_SCRIPTS = ("R/ccsMappingPlots.R", "R/Bauhaus2.R")

    def plan(self):
        return CCSMappingReportsPlan(self.conditionTable, self.cliArgs)
