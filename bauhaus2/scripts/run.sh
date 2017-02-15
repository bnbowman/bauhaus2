#!/bin/bash
source /mnt/software/Modules/current/init/bash

module load smrtanalysis/mainline
module load R/3.2.3-internal

## FIXME: need to configurify this..
snakemake -p -s workflow/summarize-mappings.snake --configfile config.json
