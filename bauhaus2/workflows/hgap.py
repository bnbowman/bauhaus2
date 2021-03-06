from bauhaus2.experiment import ResequencingConditionTable
from bauhaus2 import Workflow

from .mapping import subreadsMappingPlan

class HGAPWorkflow(Workflow):
    """
  
    """
    WORKFLOW_NAME        = "HGAP"
    CONDITION_TABLE_TYPE = ResequencingConditionTable
    R_SCRIPTS            = ("R/mummerOneCondition.R", "R/Bauhaus2.R","R/combined_hgap.R" )
    PYTHON_SCRIPTS       = ("Python/generateJsonReport.py",
                            "Python/convertJsonToCSV.py")

    def plan(self):
        return ["hgap.snake",
                "collect-mappings.snake",
                "collect-references.snake",
                "collect-smrtlink-references-hgap.snake",
                "collect-assembly-stats.snake"]
