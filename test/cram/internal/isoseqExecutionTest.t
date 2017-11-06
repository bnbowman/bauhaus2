Test execution of the IsoSeqRC0 workflow on one very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../..
  $ CWD=`pwd`
  $ echo working directory $CWD
  * (glob)

  $ bauhaus2 --no-smrtlink --noGrid generate -w IsoSeqRC0 -t ${BH_ROOT}/test/data/one-isoseq2-path.csv -o isoseq
  Validation and input resolution succeeded.
  Generated runnable workflow to "isoseq"

  $ (cd isoseq && ./run.sh >/dev/null 2>&1)

Check reports.
  $ ls -1 ${CWD}/isoseq/reports/IsoSeqRC0Plots/
  isoseq_rc0_ccs_readlength_hist.png
  isoseq_rc0_collapse_to_sirv_n_false_negative.png
  isoseq_rc0_collapse_to_sirv_n_false_positive.png
  isoseq_rc0_collapse_to_sirv_n_true_positive.png
  isoseq_rc0_consensus_isoforms_readlength_hist.png
  isoseq_rc0_flnc_readlength_hist.png
  isoseq_rc0_flnc_reseq_to_hg_selected.png
  isoseq_rc0_hq_readlength_hist.png
  isoseq_rc0_hq_reseq_to_hg_selected.png
  isoseq_rc0_lq_readlength_hist.png
  isoseq_rc0_nfl_readlength_hist.png
  isoseq_rc0_reseq_to_sirv_flnc_n_mapped_reads.png
  isoseq_rc0_reseq_to_sirv_flnc_n_mapped_refs.png
  isoseq_rc0_reseq_to_sirv_hq_n_mapped_reads.png
  isoseq_rc0_reseq_to_sirv_hq_n_mapped_refs.png
  isoseq_rc0_reseq_to_sirv_lq_n_mapped_reads.png
  isoseq_rc0_reseq_to_sirv_lq_n_mapped_refs.png
  report.Rd
  report.json
