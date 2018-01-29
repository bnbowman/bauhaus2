from bauhaus2.experiment import MaskedResequencingConditionTable
from bauhaus2 import Workflow

from .mapping import subreadsMappingPlan

class MaskedArrowTrainingWorkflow(Workflow):
    """
    Map subreads to the reference and train an arrow model from the
    resulting alignments, filtering out reads that overlap with
    masked regions.
    """
    WORKFLOW_NAME        = "MaskedArrowTraining"
    CONDITION_TABLE_TYPE = MaskedResequencingConditionTable
    SMRTPIPE_PRESETS     = ("extras/pbsmrtpipe-mappings-preset.xml",)
    R_SCRIPTS = ("R/arrowTraining.R", "R/Bauhaus2.R")

    def plan(self):
        return [ "masked-arrow-training.snake" ] + \
            subreadsMappingPlan(self.conditionTable, self.cliArgs)
