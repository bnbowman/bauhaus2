Test execution of the BarcodingQC workflow on one very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../../

Generate heatmaps workflow, starting from subreads.

  $ bauhaus2 --no-smrtlink --noGrid generate -w Cas9Yield -t ${BH_ROOT}test/data/two-tiny-movies-cas9-yield.csv -o cas9
  Validation and input resolution succeeded.
  Generated runnable workflow to "cas9"

  $ (cd cas9 && ./run.sh >/dev/null 2>&1)

  $ tree -I __pycache__ cas9
  cas9
  |-- condition-table.csv
  |-- conditions
  |   |-- MovieA
  |   |   |-- mapped
  |   |   |   |-- OUTPUT_BAM
  |   |   |   `-- OUTPUT_BAM.pbi
  |   |   `-- subreads
  |   |       `-- input.subreadset.xml
  |   `-- MovieB
  |       |-- mapped
  |       |   |-- OUTPUT_BAM
  |       |   `-- OUTPUT_BAM.pbi
  |       `-- subreads
  |           `-- input.subreadset.xml
  |-- config.json
  |-- log
  |-- prefix.sh
  |-- reports
  |   |-- Cas9YieldDiagnosticPlots_MovieA
  |   |   |-- MovieA_subread_coverage.png
  |   |   |-- MovieA_target_table.png
  |   |   |-- MovieA_zmw_coverage.png
  |   |   `-- report.json
  |   `-- Cas9YieldDiagnosticPlots_MovieB
  |       |-- MovieB_subread_coverage.png
  |       |-- MovieB_target_table.png
  |       |-- MovieB_zmw_coverage.png
  |       `-- report.json
  |-- run.sh
  |-- scripts
  |-- snakemake.log
  `-- workflow
      `-- Snakefile
  
  13 directories, 20 files
 
