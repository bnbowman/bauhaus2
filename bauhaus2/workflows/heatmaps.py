from bauhaus2.experiment import ResequencingConditionTable
from bauhaus2 import Workflow

from .mapping import subreadsMappingPlan

class HeatmapsWorkflow(Workflow):
    """
    Generate alignment based heatmaps.
    """
    WORKFLOW_NAME        = "Heatmaps"
    CONDITION_TABLE_TYPE = ResequencingConditionTable
    SMRTPIPE_PRESETS     = ("extras/pbsmrtpipe-mappings-preset.xml",)
    R_SCRIPTS            = ( "R/AlignmentBasedHeatmaps.R",
                             "R/ZMWstsPlots.R",
                             "R/Bauhaus2.R" )
    PYTHON_SCRIPTS       = ( "Python/CollectPpaBurstMetrics.py",
                             "Python/GetZiaTags.py")
    def plan(self):
        return ["heatmaps.snake",
                "uid-tag.snake",
                "collect-ppa-burst-metrics.snake"] + \
            subreadsMappingPlan(self.conditionTable, self.cliArgs)
