#!/bin/bash
set -euo pipefail

source /mnt/software/Modules/current/init/bash
module load python/3.5.1
module load virtualenv/15.1.0
rm -rf VE

virtualenv -p python3.5 ./VE
source ./VE/bin/activate

pip install -U wheel pip
pip install setuptools==33.1.1
pip install -r requirements.txt
pip install -r requirements-test.txt
pip install snakemake
python setup.py install

echo General tests:
cram test/cram/*.t
echo MappingReport tests:
cram test/cram/internal/executionTest.t
echo CCS Mapping:
cram test/cram/internal/ccsTest.t
echo Cas9 Yield:
cram test/cram/internal/cas9YieldTest.t
echo Unrolled test:
cram test/cram/internal/unrolledExecutionTest.t
echo Unrolled by reference test:
cram test/cram/internal/unrolledMultipleContigsExecutionTest.t
echo Arrow Training:
cram test/cram/internal/arrowTrainExecutionTest.t
echo Heatmaps:
cram test/cram/internal/heatmaps.t
echo BarcodingQC:
cram test/cram/internal/barcodingQCTest.t
echo Coverage Titration:
cram test/cram/internal/coveragetitrationExecutionTest.t
echo IsoSeq:
cram test/cram/internal/isoseqExecutionTest.t
echo Constant arrow:
cram test/cram/internal/constantarrowTest.t
