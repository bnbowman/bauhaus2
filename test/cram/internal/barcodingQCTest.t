Test execution of the BarcodingQC workflow on one very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../../

Generate heatmaps workflow, starting from subreads.

  $ bauhaus2 --no-smrtlink --noGrid generate -w BarcodingQC -t ${BH_ROOT}test/data/one-tiny-lima-asymmetric-barcode.csv -o lima
  Validation and input resolution succeeded.
  Generated runnable workflow to "lima"

  $ (cd lima && ./run.sh >/dev/null 2>&1)

  $ tree -I __pycache__ lima
  lima
  |-- condition-table.csv
  |-- conditions
  |   `-- A
  |       |-- barcodeset.fasta -> /pbi/dept/secondary/siv/barcodes/Sequel_RSII_384_barcodes_v1/Sequel_RSII_384_barcodes_v1.fasta
  |       |-- lima
  |       |   |-- barcoded.bam
  |       |   |-- barcoded.bam.pbi
  |       |   |-- barcoded.lima.counts
  |       |   |-- barcoded.lima.report
  |       |   |-- barcoded.lima.summary
  |       |   `-- barcoded.subreadset.xml
  |       `-- subreads
  |           `-- input.subreadset.xml
  |-- config.json
  |-- log
  |-- prefix.sh
  |-- reports
  |   `-- BarcodingQC
  |       |-- report.Rd
  |       |-- report.json
  |       |-- summary_score_hist.png
  |       `-- summary_yield_zmw.png
  |-- run.sh
  |-- scripts
  |   `-- R
  |       |-- Bauhaus2.R
  |       |-- limaReportDetail.R
  |       `-- limaReportSummary.R
  |-- snakemake.log
  `-- workflow
      `-- Snakefile
  
  10 directories, 21 files
 
