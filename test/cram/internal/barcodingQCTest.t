Test execution of the BarcodingQC workflow on one very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../../

Generate heatmaps workflow, starting from subreads.

  $ bauhaus2 --no-smrtlink --noGrid generate -w BarcodingQC -t ${BH_ROOT}test/data/barcode2test.csv -o lima
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
  |       |   |-- barcoded.lima.guess
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
  |       |-- counts.csv
  |       |-- detail_hq_length_hist_barcoded_or_not.png
  |       |-- detail_hq_length_hist_group_free_y.png
  |       |-- detail_hq_length_hist_group_same_y.png
  |       |-- detail_hq_length_linehist_nogroup.png
  |       |-- detail_hq_length_vs_score.png
  |       |-- detail_num_adapters.png
  |       |-- detail_read_length_hist_barcoded_or_not.png
  |       |-- detail_read_length_hist_group_free_y.png
  |       |-- detail_read_length_hist_group_same_y.png
  |       |-- detail_read_length_linehist_nogroup.png
  |       |-- detail_read_length_vs_score.png
  |       |-- detail_score_lead.png
  |       |-- detail_score_vs_yield.png
  |       |-- detail_scores_per_adapter.png
  |       |-- detail_signal_increase.png
  |       |-- detail_yield_base.png
  |       |-- detail_yield_read.png
  |       |-- detail_yield_zmw.png
  |       |-- guess.csv
  |       |-- report.Rd
  |       |-- report.json
  |       |-- summary.csv
  |       |-- summary_hq_length_hist_2d.png
  |       |-- summary_meanscore_vs_yield_hex.png
  |       |-- summary_meanscore_vs_yield_hex_log10.png
  |       |-- summary_meanscore_vs_yield_jitter.png
  |       |-- summary_meanscore_vs_yield_jitter_log10.png
  |       |-- summary_read_length_hist_2d.png
  |       |-- summary_score_hist.png
  |       |-- summary_score_hist_2d.png
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
  
  10 directories, 50 files
 
