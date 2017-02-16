
  $ BH_ROOT=$TESTDIR/../../

  $ bauhaus2 -m generate -w MappingReports -t ${BH_ROOT}test/data/two-tiny-movies.csv -o mapping-reports
  Validation and input resolution succeeded.
  Generated runnable workflow to "mapping-reports"

  $ tree mapping-reports
  mapping-reports
  |-- condition-table.csv
  |-- conditions
  |-- config.json
  |-- log
  |-- reports
  |-- run.sh
  |-- scripts
  |   |-- MATLAB
  |   |-- Python
  |   `-- R
  |       |-- Bauhaus2.R
  |       |-- PbiPlots.R
  |       `-- PbiSampledPlots.R
  `-- workflow
      |-- Snakefile
      |-- runtime.py
      `-- stdlib.py
  
  8 directories, 9 files
