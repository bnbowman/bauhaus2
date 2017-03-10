from bauhaus2.experiment import UnrolledMappingConditionTable
from bauhaus2 import Workflow

from .subreads import subreadsPlan

class UnrolledNoHQMappingWorkflow(Workflow):
    """
    Map "unrolled" ZMW reads to an unrolled reference.

    Note that this implies that the HQ region designation is
    *ignored*, and the entire read sequence from the ZMW is used as a
    mapping query.  (We will add an unrolled mapping workflow which
    maps just the HQ region, as soon as BLASR supports it directly).
    """
    WORKFLOW_NAME        = "UnrolledNoHQMapping"
    CONDITION_TABLE_TYPE = UnrolledMappingConditionTable

    def plan(self):
        return [ "map-unrolledNoHQ.snake",
                 "collect-references.snake",
                 "scatter-subreads.snake" ] + \
                 subreadsPlan(self.conditionTable, self.cliArgs)
