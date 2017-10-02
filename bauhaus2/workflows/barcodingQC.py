from bauhaus2.experiment import LimaConditionTable
from bauhaus2 import Workflow

from .subreads import subreadsPlan

def BarcodingPlan(ct, args):
    # test if consensusReadSet and do differently if so
    return [ "barcoding.snake",
             "scatter-subreads.snake" ] + \
             subreadsPlan(ct, args)

class BarcodingQCWorkflow(Workflow):
    """
    Push reads through lima and generate barcoding QC reports
    """
    WORKFLOW_NAME        = "BarcodingQC"
    CONDITION_TABLE_TYPE = LimaConditionTable
    R_SCRIPTS = ("R/limaReportDetail.R", "R/limaReportSummary.R", "R/Bauhaus2.R")

    def plan(self):
        return [ "barcodingQC.snake" ] + \
            BarcodingPlan(self.conditionTable, self.cliArgs)
