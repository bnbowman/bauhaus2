#!/usr/bin/env bash
set -euo pipefail

source /mnt/software/Modules/current/init/bash
module load python/3.5.1
module load virtualenv/15.1.0
if [[ -v PS1 ]]; then
  : # noop
else
  PS1='> '
fi

virtualenv -p python3.5 ./VE
source ./VE/bin/activate

pip install -U wheel pip
pip install setuptools==33.1.1
pip install -r requirements.txt
pip install -r requirements-test.txt
pip install snakemake
python setup.py install

echo "#################"
echo "# Running tests #"
echo "#################"
make -j8 all-tests
