"""Workflows analyzing HQRF performance"""

from bauhaus2 import Workflow
from bauhaus2.workflows import UnrolledNoHQMappingWorkflow
from bauhaus2.experiment import ResequencingConditionTable

class EvaluateHQRFWorkflow(Workflow):
    """
    Use unrolled-align subreads to the reference and evaluate HQRF quality
    against an HQR-GT algorithm.
    """
    WORKFLOW_NAME        = "EvaluateHQRF"
    CONDITION_TABLE_TYPE = ResequencingConditionTable
    R_SCRIPTS            = ()

    def plan(self):
        # change this to the UnrolledHQMappingWorkflow once blasr is fixed
        return ["hqrgt.snake"] + \
            UnrolledNoHQMappingWorkflow(self.conditionTable,
                                        self.cliArgs).plan()
