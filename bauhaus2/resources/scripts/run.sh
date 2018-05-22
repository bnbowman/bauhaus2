#!/bin/bash
set -e
set -o pipefail
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $THISDIR

mkdir -p log conditions reports
snakemake {{ cluster_options }} --restart-times 2 -p -s workflow/Snakefile --configfile config.json 2>&1 | tee snakemake.log
