# ---------------------------------------------------------------------------------------------------
# stub.py : set up runtime/stdlib and initialize env for the snakemake workflow

from bauhaus2.runtime import *

sl_host = config["bh2.smrtlink.host"]
sl_host = sl_host.replace("-", "/", 1)

shell.executable("/bin/bash")
prefix = open("prefix.sh").read()
prefix = prefix.replace("smrtlink/internal", sl_host)
shell.prefix(prefix)
