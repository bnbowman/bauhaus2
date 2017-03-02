#!/bin/bash
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $THISDIR

mkdir -p log conditions reports
snakemake {{ cluster_options }} -p -s workflow/Snakefile --configfile config.json 2>&1 | tee snakemake.log
