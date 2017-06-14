from bauhaus2.experiment import IsoSeqConditionTable
from bauhaus2 import Workflow


def isoseq_rc0_plan(ct, args):
    """Only support input=exsiting SMRTLink IsoSeq jobs"""
    return [ "isoseq_rc0.snake" ]


class IsoSeqRC0Workflow(Workflow):
    """
    Workflow for analyzing SMRTLink IsoSeq RC0 jobs.
    """
    WORKFLOW_NAME        = "IsoSeqRC0"
    CONDITION_TABLE_TYPE = IsoSeqConditionTable
    R_SCRIPTS            = ("R/Bauhaus2.R", "R/IsoSeqRC0Plots.R")

    def plan(self):
        return isoseq_rc0_plan(self.conditionTable, self.cliArgs)
