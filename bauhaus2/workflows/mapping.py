from bauhaus2.experiment import ResequencingConditionTable
from bauhaus2 import Workflow

from .subreads import subreadsPlan

# ---

# A *plan* is a list of snakemake files that will be assembled to make
# the overall workflow.  The main entry point comes first in the list.
# A plan is in general generated dynamically depending on the input
# type, workflow type, and options provided to bauhaus2.
#
# For example: the *plan* to get mapped data depends on:
#   - whether the input already specifies mapped data (in which case
#     we just "link" to it) or if it specifies subreadsets, in which
#     case we must perform the mapping ourself;
#   - whether the bauhaus user has explicitly specified not to use
#     scatter/gather, in which case we will use naive unchunked
#     mapping

def subreadsMappingPlan(ct, args):
    if ct.inputsAreMapped:
        # Mapping already happened, link it.
        return [ "collect-smrtlink-subreads.snake",
                 "collect-smrtlink-references.snake",
                 "mapping-alignmentset.snake",
                 "collect-mappings.snake" ]
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



class MappingReportsWorkflow(Workflow):
    """
    Align subreads to the reference and generate comprehensive
    analysis plots and tables.
    """
    WORKFLOW_NAME        = "MappingReports"
    CONDITION_TABLE_TYPE = ResequencingConditionTable
    SMRTPIPE_PRESETS     = ("extras/pbsmrtpipe-mappings-preset.xml",)
    R_SCRIPTS            = ( "R/PbiSampledPlots.R",
                             "R/PbiPlots.R",
                             "R/LibDiagnosticPlots.R",
                             "R/ReadPlots.R",
                             "R/constant_arrow.R",
                             "R/FishbonePlots.R",
                             "R/ZMWstsPlots.R",
                             "R/AlignmentBasedHeatmaps.R",
                             "R/Bauhaus2.R" )
    PYTHON_SCRIPTS       = ( "Python/MakeMappingMetricsCsv.py",
                             "Python/GetZiaTags.py")

    def plan(self):
        return ["summarize-mappings.snake", 
                "constant-arrow.snake", 
                "constant-arrow-regular.snake",
                "heatmaps.snake",
                "locacc.snake",
                "uid-tag.snake"] + \
            subreadsMappingPlan(self.conditionTable, self.cliArgs)
