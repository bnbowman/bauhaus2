from bauhaus2.experiment import ResequencingConditionTable
from bauhaus2 import Workflow

from .mapping import subreadsMappingPlan

class HGAPWorkflow(Workflow):
    """
  
    """
    WORKFLOW_NAME        = "HGAP"
    CONDITION_TABLE_TYPE = ResequencingConditionTable
    R_SCRIPTS            = ( )
    PYTHON_SCRIPTS       = ( )
    def plan(self):
        return ["hgap.snake",
                "collect-mappings.snake",
                "collect-references.snake",
                "collect-smrtlink-references-hgap.snake"]
