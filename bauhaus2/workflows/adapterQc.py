from bauhaus2.experiment import AdapterQcConditionTable
from bauhaus2 import Workflow
from bauhaus2.workflows.adapterEvaluation import genomeCollectingPlan

class AdapterQCWorkflow(Workflow):
    """
    Run pbqctools pbQcAdapters
    """
    WORKFLOW_NAME        = "AdapterQC"
    CONDITION_TABLE_TYPE = AdapterQcConditionTable

    def plan(self):
        return (["bam2bam_adpqc.snake",
                 "adapterQC.snake",
                 "uid-tag.snake"] +
                genomeCollectingPlan(self.conditionTable, self.cliArgs))
