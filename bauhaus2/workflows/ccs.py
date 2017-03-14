from bauhaus2.experiment import ResequencingConditionTable
from bauhaus2 import Workflow

from .subreads import subreadsPlan

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
        return [ "map-ccs.snake",
                 "ccs-subreads.snake",
                 "collect-references.snake",
                 "scatter-subreads.snake" ] + \
                 subreadsPlan(self.conditionTable, self.cliArgs)
