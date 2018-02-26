from bauhaus2.experiment import ResequencingConditionTable
from bauhaus2 import Workflow

from .subreads import subreadsPlan

class UnrolledNoHQMappingWorkflow(Workflow):
    """
    Grab PPA-classified burst information from subreadset.

    Save summary metrics to file and generate plots
    """
    WORKFLOW_NAME        = "PpaBurstMetrics"
    CONDITION_TABLE_TYPE = ResequencingConditionTable
    R_SCRIPTS            = ("R/BurstPlots.R",
                            "R/Bauhaus2.R")
    PYTHON_SCRIPTS       = ("Python/CollectPpaBurstMetrics.py", )

    def plan(self):
        return ["collect-ppa-burst-metrics.snake"] + \
            subreadsPlan(self.conditionTable, self.cliArgs)
