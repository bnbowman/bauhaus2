__all__ = [
    "analysisScriptPath",
    "configJsonPath",
    "prefixShScriptPath",
    "runShScriptPath",
    "snakemakeFilePath",
    "stubFilePath"
]

from bauhaus2.utils import listConcat

from pkg_resources import Requirement, resource_filename
import os.path as op

def _resourcePath(fname):
    path = resource_filename(Requirement.parse("bauhaus2"), fname)
    if not op.exists(path):
        raise ValueError("Invalid resource: %s" % path)
    else:
        return path

def snakemakeFilePath(basename):
    return _resourcePath(op.join("bauhaus2/resources/snakemake/", basename))

def configJsonPath(basename):
    return _resourcePath(op.join("bauhaus2/resources/snakemake/", basename))

def stubFilePath():
    return _resourcePath("bauhaus2/resources/snakemake_support/stub.py")

def analysisScriptPath(scriptName):
    """
    expects names ~ "R/fooScript.R", "Python/fooScript.py"
    """
    return _resourcePath(op.join("bauhaus2/resources/scripts", scriptName))

def runShScriptPath():
    return _resourcePath("bauhaus2/resources/scripts/run.sh")

def prefixShScriptPath():
    return _resourcePath("bauhaus2/resources/scripts/prefix.sh")
