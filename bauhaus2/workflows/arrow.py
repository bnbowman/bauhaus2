from bauhaus2.experiment import ResequencingConditionTable
from bauhaus2 import Workflow

from .mapping import subreadsMappingPlan

class ArrowTrainingWorkflow(Workflow):
    """
    Map subreads to the reference and train an arrow model from the
    resulting alignments.
    """
    WORKFLOW_NAME        = "ArrowTraining"
    CONDITION_TABLE_TYPE = ResequencingConditionTable
    SMRTPIPE_PRESETS     = ("extras/pbsmrtpipe-mappings-preset.xml",)
    R_SCRIPTS = ("R/arrowTraining.R", "R/Bauhaus2.R")

    def plan(self):
        return [ "arrow-training.snake" ] + \
            subreadsMappingPlan(self.conditionTable, self.cliArgs)
