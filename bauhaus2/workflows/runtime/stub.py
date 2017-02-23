# ---------------------------------------------------------------------------------------------------
# stub.py : set up runtime/stdlib and initialize env for the snakemake workflow

from runtime import ct
from stdlib import *

shell.executable("/bin/bash")

# TODO: factor this out---let workflows declare modules needed
shell.prefix(\
    """
    source /mnt/software/Modules/current/init/bash
    module use /mnt/software/modulefiles
    module purge
    module add smrtanalysis/mainline

    # The export line here is a directive to the R module load: don't let
    # user's R environment interfere with our scripts.  Developers may
    # want to comment out these lines.
    unset R_LIBS
    export R_IGNORE_USER_LIBS=1
    module load R/3.2.3-internal

    set -euo pipefail
    """)
