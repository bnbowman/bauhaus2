from bauhaus2.experiment import ResequencingConditionTable
from bauhaus2 import Workflow

from .mapping import subreadsMappingPlan

class ConstantArrowForShortMovieWorkflow(Workflow):
    """
    Align subreads to the reference and run constant arrow model,
    generate csv file of errormode.
    """
    WORKFLOW_NAME        = "ConstantArrowForShortMovie"
    CONDITION_TABLE_TYPE = ResequencingConditionTable
    SMRTPIPE_PRESETS     = ("extras/pbsmrtpipe-mappings-preset.xml",)
    R_SCRIPTS            = ( "R/constant_arrow.R",
                             "R/FishbonePlots.R",
                             "R/Bauhaus2.R" )
    PYTHON_SCRIPTS       = ( "Python/MakeMappingMetricsCsv.py",
                             "Python/GetZiaTags.py",
                             "Python/jsonIDinCSV.py",)

    def plan(self):
        return ["constant-arrow.snake",
                "constant-arrow-short-movie.snake",
                "uid-tag.snake"] + \
            subreadsMappingPlan(self.conditionTable, self.cliArgs)
