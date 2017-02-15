
from bauhaus2.utils import listConcat

from pkg_resources import Requirement, resource_filename
import os.path as op

def snakemakeFilePath(basename):
    path = resource_filename(Requirement.parse("bauhaus2"), op.join("bauhaus2/workflows/snakemake/", basename))
    if not op.exists(path):
        raise ValueError("Invalid resource: %s" % path)
    else:
        return path

def snakemakeStdlibFiles():
    return [ snakemakeFilePath("stdlib.py"),
             snakemakeFilePath("runtime.py") ]

def chaseSnakemakeIncludes(entryPoint):
    """
    Find the transitive closure of snakemake files included
    by the entry point snakemake file

    This function is only as robust as it currently needs to be.

    Argument is just the basename of the snakemake file.
    """
    entryPointPath = snakemakeFilePath(entryPoint)

    def includes(basename):
        file = snakemakeFilePath(basename)
        incs = []
        for line in open(file).readlines():
            if line.startswith("include:"):
                incFile = line.split()[-1][1:-1] # strip surrounding quotes
                incs.append(op.basename(incFile))
        return incs

    files = [ entryPoint ] + listConcat([chaseSnakemakeIncludes(inc) for inc in includes(entryPoint)])
    return files
