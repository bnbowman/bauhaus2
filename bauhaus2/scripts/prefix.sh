# --
# prefix.sh
# --
# This file gets *sourced* by every shell subtask run by snakemake

set -euo pipefail

source /mnt/software/Modules/current/init/bash
module use /mnt/software/modulefiles
module purge
module add smrtanalysis/mainline

# The export line here is a directive to the R module load: don't let
# user's R environment interfere with our scripts.  Developers may
# want to comment out these lines.
unset R_LIBS
export R_IGNORE_USER_LIBS=1

# Note: DO NOT REMOVE THE TRAILING SEMICOLON
module load R/3.2.3-internal;
