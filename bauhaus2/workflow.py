
from builtins import object
import shutil, json, os.path as op

from bauhaus2.utils import *
from bauhaus2.resources import *

class Workflow(object):
    WORKFLOW_NAME        = None
    CONDITION_TABLE_TYPE = None
    R_SCRIPTS            = ()
    PYTHON_SCRIPTS       = ()
    MATLAB_SCRIPTS       = ()
    SMRTPIPE_PRESETS     = ()

    @classmethod
    def conditionTableType(cls):
        return cls.CONDITION_TABLE_TYPE

    @classmethod
    def name(cls):
        return cls.WORKFLOW_NAME

    def _bundleSnakemakeFiles(self, outputDir):
        """
        Simply *concatenate* the constituent scripts
        """
        outFname = op.join(outputDir, "workflow", "Snakefile")
        with open(outFname, "w") as outFile:
            outFile.write(readFile(stubFilePath()))
            for sf in self.plan():
                sfPath = snakemakeFilePath(sf)
                contents = readFile(sfPath)
                outFile.write(contents)

    def _bundleAnalysisScripts(self, outputDir):
        analysisScripts = self.R_SCRIPTS + self.PYTHON_SCRIPTS + self.MATLAB_SCRIPTS
        for analysisScript in analysisScripts:
            scriptType = op.dirname(analysisScript)
            destDir = op.join(outputDir, "scripts", scriptType)
            shutil.copy(analysisScriptPath(analysisScript), destDir)

    def _bundleConfigJson(self, outputDir):
        acc = { "bh2.workflow_name": self.WORKFLOW_NAME }
        if not self.cliArgs.no_smrtlink:
            acc["bh2.smrtlink.host"] = self.cliArgs.smrtlink_host
            acc["bh2.smrtlink.services_port"] = self.cliArgs.smrtlink_services_port
        for snakeFile in self.plan():
            jsonPath = configJsonPath(snakeFile.replace(".snake", ".json"))
            jsonData = json.load(open(jsonPath))
            acc.update(jsonData)
        with open(op.join(outputDir, "config.json"), "w") as jsonOut:
            json.dump(acc, jsonOut, sort_keys=True, indent=4, separators=(',', ': '))
            jsonOut.write("\n")

    def _bundleRunSh(self, outputDir):
        if self.cliArgs.noGrid:
            clusterOptions="-j 4"
        else:
            clusterOptions=('-j 128 --cluster-sync="qsub -cwd -q {sge_queue} -pe smp {{threads}} -sync y -e log/ -o log/" --latency-wait 60'
                            .format(sge_queue=self.cliArgs.sgeQueue))
        outputPath = op.join(outputDir, "run.sh")
        renderTemplate(runShScriptPath(), outputPath, cluster_options=clusterOptions)
        chmodPlusX(outputPath)

    def _bundlePrefixSh(self, outputDir):
        outputPath = op.join(outputDir, "prefix.sh")
        # TODO: a lot of possibilities... can specify modules separately?
        renderTemplate(prefixShScriptPath(), outputPath)
        chmodPlusX(outputPath)

    def _bundleSmrtpipePresets(self, outputDir):
        destDir = op.join(outputDir, "extras")
        mkdirp(destDir)
        for presetName in self.SMRTPIPE_PRESETS:
            shutil.copy(smrtpipePresetXmlPath(presetName), destDir)

    def plan(self):
        raise NotImplementedError

    def generate(self, conditionTableCSV, outputDir):
        # Generate workflow dir
        mkdirp(outputDir)
        shutil.copyfile(conditionTableCSV, op.join(outputDir, "condition-table.csv"))
        mkdirp(op.join(outputDir, "workflow"))
        mkdirp(op.join(outputDir, "scripts"))
        if self.R_SCRIPTS:      mkdirp(op.join(outputDir, "scripts/R"))
        if self.PYTHON_SCRIPTS: mkdirp(op.join(outputDir, "scripts/Python"))
        if self.MATLAB_SCRIPTS: mkdirp(op.join(outputDir, "scripts/MATLAB"))
        self._bundleSnakemakeFiles(outputDir)  # Output relevant snakemake files
        self._bundleAnalysisScripts(outputDir) # Output relevant scripts
        self._bundleConfigJson(outputDir)      # Generate snakemake config.json
        self._bundleRunSh(outputDir)           # Generate driver "run" script
        self._bundlePrefixSh(outputDir)        # Generate task prefix shell code

        if not self.cliArgs.no_smrtlink:
            self._bundleSmrtpipePresets(outputDir)

    def __init__(self, ct, args):
        self.conditionTable = ct
        self.cliArgs = args # TODO: we should have a real class for this...
