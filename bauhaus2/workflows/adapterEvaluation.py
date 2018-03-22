from bauhaus2.experiment import AdapterConditionTable
from bauhaus2 import Workflow

from .subreads import subreadsPlan

def genomeCollectingPlan(ct, args):
    return [ "collect-references.snake" ] + \
                subreadsPlan(ct, args)

class AdapterEvaluationWorkflow(Workflow):
    """
    Push reads through lima and generate barcoding QC reports
    """
    WORKFLOW_NAME = "AdapterEvaluation"
    CONDITION_TABLE_TYPE = AdapterConditionTable
    R_SCRIPTS = ("Python/WriteUnrolledReference.py",
                 "Python/AdpFromAlignments.py")

    def plan(self):
        return ["adapterEvaluation.snake"] + \
            genomeCollectingPlan(self.conditionTable, self.cliArgs)
