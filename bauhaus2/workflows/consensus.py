from bauhaus2.experiment import CoverageTitrationConditionTable
from bauhaus2 import Workflow

from .subreads import subreadsPlan

def subreadsMappingPlan(ct, args):
    if ct.inputsAreMapped:
        # Extract the subreads set, do mapping.
        if not args.no_smrtlink:
            # Use SMRTLink for mapping
            return [ "map-subreads-smrtlink.snake",
                     "smrtlink-job-status.snake",
                     "collect-references.snake",
                     "collect-smrtlink-subreads.snake" ]
        elif args.chunks > 0:
            # Do our own mapping using scatter/gather
            return [ "map-subreads.snake",
                     "scatter-subreads.snake",
                     "collect-references.snake",
                     "collect-smrtlink-subreads.snake" ]
        else:
            # Do our own mapping, naively
            return [ "map-subreads.snake",
                     "collect-references.snake",
                     "collect-smrtlink-subreads.snake" ]
    elif not args.no_smrtlink:
        # Use SMRTLink for mapping
        return [ "map-subreads-smrtlink.snake",
                 "smrtlink-job-status.snake",
                 "collect-references.snake" ] + \
                 subreadsPlan(ct, args)
    elif args.chunks > 0:
        # Do our own mapping using scatter/gather
        return [ "map-subreads.snake",
                 "scatter-subreads.snake",
                 "collect-references.snake" ] + \
                subreadsPlan(ct, args)
    else:
        # Do our own mapping, naively
        return [ "map-subreads.snake",
                 "collect-references.snake" ] + \
                subreadsPlan(ct, args)

class CoverageTitrationWorkflow(Workflow):
    """
    Map subreads to the reference and call consensus using arrow (or
    quiver, if selected) at different coverage cuts.  Masks regions
    known to be untrustworthy in the reference.  Generate plots and
    tables of these results.

    This workflow will only work for references that have been curated
    by the consensus team.
    """
    WORKFLOW_NAME        = "CoverageTitration"
    CONDITION_TABLE_TYPE = CoverageTitrationConditionTable
    SMRTPIPE_PRESETS     = ("extras/pbsmrtpipe-mappings-preset.xml",)
    R_SCRIPTS = ("R/coverageTitrationPlots.R", "R/Bauhaus2.R")

    def plan(self):
        return [ "consensus-coverage-titration.snake" ] + \
            subreadsMappingPlan(self.conditionTable, self.cliArgs)
