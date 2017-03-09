__all__ = [
    "analysisScriptPath",
    "configJsonPath",
    "prefixShScriptPath",
    "runShScriptPath",
    "snakemakeFilePath",
    "stubFilePath",
    "smrtpipePresetXmlPath"
]

from bauhaus2.utils import listConcat

from pkg_resources import Requirement, resource_filename
import os.path as op

def _resourcePath(fname):
    path = resource_filename(Requirement.parse("bauhaus2"), op.join("bauhaus2/resources/", fname))
    if not op.exists(path):
        raise ValueError("Invalid resource: %s" % path)
    else:
        return path

def snakemakeFilePath(basename):
    return _resourcePath(op.join("snakemake/", basename))

def configJsonPath(basename):
    return _resourcePath(op.join("snakemake/", basename))

def stubFilePath():
    return _resourcePath("snakemake_support/stub.py")

def analysisScriptPath(scriptName):
    """
    expects names ~ "R/fooScript.R", "Python/fooScript.py"
    """
    return _resourcePath(op.join("scripts", scriptName))

def runShScriptPath():
    return _resourcePath("scripts/run.sh")

def prefixShScriptPath():
    return _resourcePath("scripts/prefix.sh")

def smrtpipePresetXmlPath(extraName):
    return _resourcePath(extraName)
