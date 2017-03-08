from bauhaus2.experiment import CoverageTitrationConditionTable
from bauhaus2 import Workflow

from .mapping import subreadsMappingPlan

class CoverageTitrationWorkflow(Workflow):
    """
    Map subreads to the reference and call consensus using arrow (or
    quiver, if selected) at different coverage cuts.  Masks regions
    known to be untrustworthy in the reference.  Generate plots and
    tables of these results.

    This workflow will only work for references that have been curated
    by the consensus team.
    """
    WORKFLOW_NAME        = "CoverageTitration"
    CONDITION_TABLE_TYPE = CoverageTitrationConditionTable
    R_SCRIPTS = ("R/coverageTitrationPlots.R", "R/Bauhaus2.R")

    def plan(self):
        return [ "consensus-coverage-titration.snake" ] + \
            subreadsMappingPlan(self.conditionTable, self.cliArgs)
