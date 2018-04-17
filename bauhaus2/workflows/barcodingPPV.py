from bauhaus2.experiment import LimaConditionTable2
from bauhaus2 import Workflow

from .subreads import subreadsPlan


def BarcodingPlan(ct, args):
    # test if consensusReadSet and do differently if so
    return ["barcodingppv.snake", 
            "collect-references.snake",
            "collect-zulu-params.snake"] + \
           subreadsPlan(ct, args)


class BarcodingPPVWorkflow(Workflow):
    """
    Push reads through lima and generate barcoding QC reports
    """
    WORKFLOW_NAME = "BarcodingPPV"
    CONDITION_TABLE_TYPE = LimaConditionTable2
    R_SCRIPTS = ("R/limaReport.R",
                 "R/ppv_zmw.R",
                 "R/Bauhaus2.R")
    PYTHON_SCRIPTS       = ("Python/generateJsonReport.py",)

    def plan(self):
        return ["barcodingppvQC.snake"] + \
               BarcodingPlan(self.conditionTable, self.cliArgs)
