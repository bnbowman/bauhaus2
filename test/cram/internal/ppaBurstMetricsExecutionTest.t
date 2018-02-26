Test execution of the burst metrics workflow on some very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../../

Generate mapping reports workflow, starting from subreads.

  $ bauhaus2 --no-smrtlink --noGrid generate -w PpaBurstMetrics -t ${BH_ROOT}test/data/two-tiny-movies-unrolled-bursts.csv -o ppa-burst-metrics
  Validation and input resolution succeeded.
  Generated runnable workflow to "ppa-burst-metrics"

  $ (cd ppa-burst-metrics && ./run.sh >/dev/null 2>&1)


  $ tree -I __pycache__ ppa-burst-metrics
  ppa-burst-metrics
  |-- Rplots.pdf
  |-- condition-table.csv
  |-- conditions
  |   |-- MovieA
  |   |   `-- subreads
  |   |       |-- input.subreadset.xml
  |   |       |-- ppa_burst_metrics.csv
  |   |       `-- read_metrics.csv
  |   `-- MovieB
  |       `-- subreads
  |           |-- input.subreadset.xml
  |           |-- ppa_burst_metrics.csv
  |           `-- read_metrics.csv
  |-- config.json
  |-- log
  |-- prefix.sh
  |-- reports
  |   `-- BurstPlots
  |       |-- BurstLength_CDF.png
  |       |-- Burst_Duration_CDF.png
  |       |-- Density_over_component.png
  |       |-- PairwiseDDensity.png
  |       |-- burstdenvsRL.png
  |       |-- cumsum_burst_duration.png
  |       |-- cumsum_burst_length.png
  |       |-- inverse_burstdenvsRL.png
  |       |-- log_burst_starttime.png
  |       |-- previous_basecall_count.png
  |       |-- previousbasecallfreq.png
  |       |-- report.Rd
  |       |-- report.json
  |       |-- typeofburst.png
  |       |-- typeofburstRorG.png
  |       |-- typeofburstRorGcount.png
  |       `-- typeofburstcount.png
  |-- run.sh
  |-- scripts
  |   |-- Python
  |   |   `-- CollectPpaBurstMetrics.py
  |   `-- R
  |       |-- Bauhaus2.R
  |       `-- BurstPlots.R
  |-- snakemake.log
  `-- workflow
      `-- Snakefile
  
  12 directories, 33 files


