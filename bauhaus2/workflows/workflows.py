from builtins import object
import shutil, json, os.path as op

from bauhaus2.experiment import *
from bauhaus2.utils import mkdirp

from bauhaus2.scripts import analysisScriptPath, runShScriptPath
from .snakemakeFiles import (chaseSnakemakeIncludes as chase,
                             snakemakeFilePath,
                             snakemakeStdlibFiles)

class Workflow(object):
    WORKFLOW_NAME        = None
    CONDITION_TABLE_TYPE = None
    SNAKEMAKE_FILES      = ()
    R_SCRIPTS            = ()
    PYTHON_SCRIPTS       = ()
    MATLAB_SCRIPTS       = ()

    @classmethod
    def conditionTableType(cls):
        return cls.CONDITION_TABLE_TYPE

    @staticmethod
    def name(cls):
        return cls.WORKFLOW_NAME

    def _bundleSnakemakeFiles(self, outputDir):
        sfDestDir = op.join(outputDir, "workflow")
        for sf in self.SNAKEMAKE_FILES:
            sfPath = snakemakeFilePath(sf)
            shutil.copy(sfPath, sfDestDir)

    def _bundleSnakemakeStdlib(self, outputDir):
        sfDestDir = op.join(outputDir, "workflow")
        for p in snakemakeStdlibFiles():
            shutil.copy(p, sfDestDir)

    def _bundleAnalysisScripts(self, outputDir):
        analysisScripts = self.R_SCRIPTS + self.PYTHON_SCRIPTS + self.MATLAB_SCRIPTS
        for analysisScript in analysisScripts:
            scriptType = op.dirname(analysisScript)
            destDir = op.join(outputDir, "scripts", scriptType)
            shutil.copy(analysisScriptPath(analysisScript), destDir)

    def _bundleConfigJson(self, outputDir):
        with open(op.join(outputDir, "config.json"), "w") as jsonOut:
            json.dump({"bh2_workflow_name": self.WORKFLOW_NAME}, jsonOut)

    def _bundleRunSh(self, outputDir):
        shutil.copy(runShScriptPath(), outputDir)


    def generate(self, conditionTableCSV, outputDir):
        # Generate workflow dir
        mkdirp(outputDir)
        shutil.copyfile(conditionTableCSV, op.join(outputDir, "condition-table.csv"))
        mkdirp(op.join(outputDir, "log"))
        mkdirp(op.join(outputDir, "workflow"))
        mkdirp(op.join(outputDir, "reports"))
        mkdirp(op.join(outputDir, "conditions"))
        mkdirp(op.join(outputDir, "scripts"))
        mkdirp(op.join(outputDir, "scripts/R"))
        mkdirp(op.join(outputDir, "scripts/Python"))
        mkdirp(op.join(outputDir, "scripts/MATLAB"))

        self._bundleSnakemakeFiles(outputDir)  # Output relevant snakemake files
        self._bundleSnakemakeStdlib(outputDir) # Output our python stdlib for snakemake files
        self._bundleAnalysisScripts(outputDir) # Output relevant scripts
        self._bundleConfigJson(outputDir)      # Generate snakemake config.json
        self._bundleRunSh(outputDir)           # Generate driver "run" script



# ---

# TODO: can we come up with a more intelligent way to determine scripts we need to bundle?

class MappingWorkflow(Workflow):
    WORKFLOW_NAME        = "Mapping"
    CONDITION_TABLE_TYPE = ResequencingConditionTable
    SNAKEMAKE_FILES      = chase("map-subreads.snake")

class MappingReportsWorkflow(Workflow):
    WORKFLOW_NAME        = "MappingReports"
    CONDITION_TABLE_TYPE = ResequencingConditionTable
    SNAKEMAKE_FILES      = chase("summarize-mappings.snake")
    R_SCRIPTS            = ( "R/PbiSampledPlots.R", "R/PbiPlots.R", "R/Bauhaus2.R" )

class CCSMappingReportsWorkflow(Workflow):
    WORKFLOW_NAME        = "CCSMappingReports"
    CONDITION_TABLE_TYPE = ResequencingConditionTable
    SNAKEMAKE_FILES      = chase("map-ccs.snake")

class CoverageTitrationWorkflow(Workflow):
    WORKFLOW_NAME        = "CoverageTitration"
    CONDITION_TABLE_TYPE = CoverageTitrationConditionTable
    SNAKEMAKE_FILES      = []


# ---

availableWorkflows = {}

for wfc in (MappingWorkflow,
            MappingReportsWorkflow,
            CCSMappingReportsWorkflow,
            CoverageTitrationWorkflow):
    assert wfc.WORKFLOW_NAME not in availableWorkflows, "Workflow name collision"
    availableWorkflows[wfc.WORKFLOW_NAME] = wfc
