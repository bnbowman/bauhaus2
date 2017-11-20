from bauhaus2.experiment import IsoSeqConditionTable
from bauhaus2 import Workflow


def sv_hg00733_plan(ct, args):
    """Only support input=exsiting SMRTLink Structural Variants jobs of HG00733 data"""
    return [ "sv-hg00733.snake" ]


def sv_fy1679_plan(ct, args):
    """Only support input=exsiting SMRTLink Structural Variants jobs of HG00733 data"""
    return [ "sv-fy1679.snake" ]


class SVHG00733Workflow(Workflow):
    """
    Workflow for analyzing SMRTLink Structural Variants jobs of HG00733 data.
    """
    WORKFLOW_NAME        = "SV-HG00733"
    CONDITION_TABLE_TYPE = IsoSeqConditionTable
    R_SCRIPTS            = ("R/Bauhaus2.R", "R/SV.R")

    def plan(self):
        return sv_hg00733_plan(self.conditionTable, self.cliArgs)


class SVFY1679Workflow(Workflow):
    """
    Workflow for analyzing SMRTLink Structural Variants jobs of FY1679 data.
    """
    WORKFLOW_NAME        = "SV-FY1679"
    CONDITION_TABLE_TYPE = IsoSeqConditionTable
    R_SCRIPTS            = ("R/Bauhaus2.R", "R/SV.R")

    def plan(self):
        return sv_fy1679_plan(self.conditionTable, self.cliArgs)
