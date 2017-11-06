from bauhaus2.experiment import PrimaryResequencingConditionTable
from bauhaus2 import Workflow

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
    if not args.no_smrtlink:
        # Use SMRTLink for mapping
        return ["map-subreads-smrtlink.snake",
                "smrtlink-job-status.snake",
                "collect-references.snake"]
    elif args.chunks > 0:
        # Do our own mapping using scatter/gather
        return ["map-subreads.snake",
                "scatter-subreads.snake",
                "collect-references.snake"]
    else:
        # Do our own mapping, naively
        return ["map-subreads.snake",
                "collect-references.snake"]


class PrimaryRefarmWorkflow(Workflow):
    """
    Align subreads to the reference and generate comprehensive
    analysis plots and tables.
    """
    WORKFLOW_NAME        = "PrimaryRefarm"
    CONDITION_TABLE_TYPE = PrimaryResequencingConditionTable
    SMRTPIPE_PRESETS     = ("extras/pbsmrtpipe-mappings-preset.xml",
                            "extras/pbsmrtpipe-unrolled-mappings-preset.xml",
                            "extras/pbsmrtpipe-unrolled-nohq-mappings-preset.xml")
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
        return (["summarize-mappings.snake", "constant-arrow.snake", "constant-arrow-regular.snake", 
                 "heatmaps.snake", "locacc.snake", "uid-tag.snake", "primary-refarm.snake"]
                + subreadsMappingPlan(self.conditionTable, self.cliArgs))
