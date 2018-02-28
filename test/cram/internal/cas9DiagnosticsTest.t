Test execution of the BarcodingQC workflow on one very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../../

Generate heatmaps workflow, starting from subreads.

  $ bauhaus2 --no-smrtlink --noGrid generate -w Cas9Diagnostics -t ${BH_ROOT}test/data/two-tiny-movies-cas9.csv -o cas9
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
  |   |-- Cas9RestrictionSitePlots_MovieA
  |   |   |-- moviea.cut_sites.csv
  |   |   |-- moviea_re_counts.png
  |   |   |-- moviea_re_fractions.png
  |   |   `-- report.json
  |   |-- Cas9RestrictionSitePlots_MovieB
  |   |   |-- movieb.cut_sites.csv
  |   |   |-- movieb_re_counts.png
  |   |   |-- movieb_re_fractions.png
  |   |   `-- report.json
  |   |-- Cas9SequelLoadingPlots_MovieA
  |   |   |-- moviea.loading.csv
  |   |   |-- moviea_adapter_ontarget.png
  |   |   |-- moviea_adapter_pairs.png
  |   |   |-- moviea_insert_sizes.png
  |   |   |-- moviea_internal_ecoR1.png
  |   |   `-- report.json
  |   |-- Cas9SequelLoadingPlots_MovieB
  |   |   |-- movieb.loading.csv
  |   |   |-- movieb_adapter_ontarget.png
  |   |   |-- movieb_adapter_pairs.png
  |   |   |-- movieb_insert_sizes.png
  |   |   |-- movieb_internal_ecoR1.png
  |   |   `-- report.json
  |   |-- Cas9YieldDiagnosticPlots_MovieA
  |   |   |-- moviea_subread_coverage.png
  |   |   |-- moviea_target_table.png
  |   |   |-- moviea_zmw_coverage.png
  |   |   `-- report.json
  |   `-- Cas9YieldDiagnosticPlots_MovieB
  |       |-- movieb_subread_coverage.png
  |       |-- movieb_target_table.png
  |       |-- movieb_zmw_coverage.png
  |       `-- report.json
  |-- run.sh
  |-- scripts
  |-- snakemake.log
  `-- workflow
      `-- Snakefile
  
  17 directories, 40 files
 
