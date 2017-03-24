# ---------------------------------------------------------------------------------------------------
# stub.py : set up runtime/stdlib and initialize env for the snakemake workflow

from bauhaus2.runtime import *

shell.executable("/bin/bash")
prefix = open("prefix.sh").read()
shell.prefix(prefix)
