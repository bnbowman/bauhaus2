#!/bin/bash
source /mnt/software/Modules/current/init/bash

module load smrtanalysis/mainline

# The latter line here is a directive to the R module load: don't let
# user's R environment interfere with our scripts.  Developers may
# want to comment out these lines.
unset R_LIBS
export R_IGNORE_USER_LIBS=1
module load R/3.2.3-internal

## FIXME: need to configurify this..
snakemake -p -s workflow/summarize-mappings.snake --configfile config.json
