__all__ = [
    "analysisScriptPath",
    "configJsonPath",
    "prefixShScriptPath",
    "runShScriptPath",
    "runtimeFilePath",
    "snakemakeFilePath",
    "snakemakeStdlibFiles"
]

from bauhaus2.utils import listConcat

from pkg_resources import Requirement, resource_filename
import os.path as op

def snakemakeFilePath(basename):
    path = resource_filename(Requirement.parse("bauhaus2"),
                             op.join("bauhaus2/resources/snakemake/", basename))
    if not op.exists(path):
        raise ValueError("Invalid resource: %s" % path)
    else:
        return path

def configJsonPath(basename):
    path = resource_filename(Requirement.parse("bauhaus2"),
                             op.join("bauhaus2/resources/snakemake/", basename))
    if not op.exists(path):
        raise ValueError("Invalid resource: %s" % path)
    else:
        return path

def runtimeFilePath(basename):
    path = resource_filename(Requirement.parse("bauhaus2"),
                             op.join("bauhaus2/resources/runtime/", basename))
    if not op.exists(path):
        raise ValueError("Invalid resource: %s" % path)
    else:
        return path

def snakemakeStdlibFiles():
    return [ runtimeFilePath("stdlib.py"),
             runtimeFilePath("runtime.py") ]

def analysisScriptPath(scriptName):
    """
    expects names ~ "R/fooScript.R", "Python/fooScript.py"
    """
    path = resource_filename(Requirement.parse("bauhaus2"),
                             op.join("bauhaus2/resources/scripts", scriptName))
    if not op.exists(path):
        raise ValueError("Invalid resource: %s" % path)
    else:
        return path

def runShScriptPath():
    return resource_filename(Requirement.parse("bauhaus2"),
                             "bauhaus2/resources/scripts/run.sh")

def prefixShScriptPath():
    return resource_filename(Requirement.parse("bauhaus2"),
                             "bauhaus2/resources/scripts/prefix.sh")
