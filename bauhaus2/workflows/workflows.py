__all__ = [ "availableWorkflows" ]

from builtins import object
import shutil, json, os.path as op

from bauhaus2.experiment import *
from bauhaus2.utils import mkdirp, readFile

from bauhaus2.scripts import analysisScriptPath, runShScriptPath
from .snakemakeFiles import (snakemakeFilePath,
                             snakemakeStdlibFiles,
                             runtimeFilePath)

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
        """
        Simply *concatenate* the constituent scripts
        """
        outFname = op.join(outputDir, "workflow", "Snakefile")
        with open(outFname, "w") as outFile:
            outFile.write(readFile(runtimeFilePath("stub.py")))
            for sf in self.SNAKEMAKE_FILES:
                sfPath = snakemakeFilePath(sf)
                contents = readFile(sfPath)
                outFile.write(contents)

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
    """
    Align subreads to the reference.
    """
    WORKFLOW_NAME        = "Mapping"
    CONDITION_TABLE_TYPE = ResequencingConditionTable
    SNAKEMAKE_FILES      = [ "map-subreads.snake",
                             "collect-references.snake",
                             "scatter-subreads.snake",
                             "collect-subreads.snake" ]


class MappingReportsWorkflow(Workflow):
    """
    Align subreads to the reference and generate comprehensive
    analysis plots and tables.
    """
    WORKFLOW_NAME        = "MappingReports"
    CONDITION_TABLE_TYPE = ResequencingConditionTable
    SNAKEMAKE_FILES      = ["summarize-mappings.snake"]  + MappingWorkflow.SNAKEMAKE_FILES
    R_SCRIPTS            = ( "R/PbiSampledPlots.R", "R/PbiPlots.R", "R/Bauhaus2.R" )


class CCSMappingReportsWorkflow(Workflow):
    """
    Map CCS reads to the reference and generate comprehensive analysis
    plots and tables, including analysis of consensus accuracy by
    numpasses and yield of CCS reads by quality.
    """
    WORKFLOW_NAME        = "CCSMappingReports"
    CONDITION_TABLE_TYPE = ResequencingConditionTable
    SNAKEMAKE_FILES      = [ "map-ccs.snake",
                             "collect-references.snake",
                             "scatter-subreads.snake",
                             "collect-subreads.snake" ]



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
    SNAKEMAKE_FILES      = []


# ---

availableWorkflows = {}

for wfc in (MappingWorkflow,
            MappingReportsWorkflow,
            CCSMappingReportsWorkflow,
            CoverageTitrationWorkflow):
    assert wfc.WORKFLOW_NAME not in availableWorkflows, "Workflow name collision"
    assert wfc.__doc__ is not None, "All workflows require descriptive docstrings"
    availableWorkflows[wfc.WORKFLOW_NAME] = wfc
