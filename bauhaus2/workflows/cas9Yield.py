from bauhaus2.experiment import Cas9ConditionTable
from bauhaus2 import Workflow

from .subreads import subreadsPlan

class Cas9YieldWorkflow(Workflow):
    """
    Input subreads.bam file, map with HG19 and generate Cas9 Yield Diagnostic reports
    """
    WORKFLOW_NAME        = "Cas9Yield"
    CONDITION_TABLE_TYPE = Cas9ConditionTable

    def plan(self):
        return [ "cas9-yield.snake" ] + \
                subreadsPlan(self.conditionTable, self.cliArgs)
