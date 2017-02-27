

from pkg_resources import Requirement, resource_filename
import os.path as op

def analysisScriptPath(scriptName):
    """
    expects names ~ "R/fooScript.R", "Python/fooScript.py"
    """
    path = resource_filename(Requirement.parse("bauhaus2"), op.join("bauhaus2/scripts/", scriptName))
    if not op.exists(path):
        raise ValueError("Invalid resource: %s" % path)
    else:
        return path

def runShScriptPath():
    return resource_filename(Requirement.parse("bauhaus2"), "bauhaus2/scripts/run.sh")

def prefixShScriptPath():
    return resource_filename(Requirement.parse("bauhaus2"), "bauhaus2/scripts/prefix.sh")
