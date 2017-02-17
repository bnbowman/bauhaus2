__all__ = [ "snakemakeFilePath",
            "configJsonPath",
            "runtimeFilePath",
            "snakemakeStdlibFiles" ]

from bauhaus2.utils import listConcat

from pkg_resources import Requirement, resource_filename
import os.path as op

def snakemakeFilePath(basename):
    path = resource_filename(Requirement.parse("bauhaus2"), op.join("bauhaus2/workflows/snakemake/", basename))
    if not op.exists(path):
        raise ValueError("Invalid resource: %s" % path)
    else:
        return path

def configJsonPath(basename):
    path = resource_filename(Requirement.parse("bauhaus2"), op.join("bauhaus2/workflows/config/", basename))
    if not op.exists(path):
        raise ValueError("Invalid resource: %s" % path)
    else:
        return path

def runtimeFilePath(basename):
    path = resource_filename(Requirement.parse("bauhaus2"), op.join("bauhaus2/workflows/runtime/", basename))
    if not op.exists(path):
        raise ValueError("Invalid resource: %s" % path)
    else:
        return path

def snakemakeStdlibFiles():
    return [ runtimeFilePath("stdlib.py"),
             runtimeFilePath("runtime.py") ]
