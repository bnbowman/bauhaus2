Test execution of the IsoSeqRC0 workflow on one very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../../

Generate isoseq workflow, starting from subreads.

  $ bauhaus2 --no-smrtlink --noGrid generate -w IsoSeqRC0 -t ${BH_ROOT}test/data/one-isoseq-path.csv -o isoseq
  Validation and input resolution succeeded.
  Generated runnable workflow to "isoseq"

  $ (cd isoseq && ./run.sh >/dev/null 2>&1)
  $ (find . -name collapse_to_sirv -exec rm -rf {} \; >/dev/null 2>&1)
  [1]


  $ tree -I __pycache__ isoseq
  isoseq
  |-- condition-table.csv
  |-- conditions
  |   `-- 3280036-0001
  |       |-- eval
  |       |   |-- 022210 -> /pbi/dept/secondary/siv/smrtlink/smrtlink-alpha/jobs-root/022/022210
  |       |   |-- README_.txt
  |       |   |-- SIRV -> /pbi/dept/secondary/siv/testdata/isoseq/lexigoen-ground-truth/validation
  |       |   |-- SIRV_evaluation_summary.txt
  |       |   |-- chain_sample
  |       |   |   |-- all_samples.chained.gff
  |       |   |   |-- all_samples.chained_count.txt
  |       |   |   |-- all_samples.chained_ids.txt
  |       |   |   |-- chain_sample.contig
  |       |   |   |-- tmp_sample_name.gff
  |       |   |   |-- tmp_sample_name.group.txt
  |       |   |   `-- tmp_sample_name.mega_info.txt
  |       |   |-- csv
  |       |   |   |-- ccs_readlength.csv
  |       |   |   |-- collapsed_to_sirv_rep_readlength.csv
  |       |   |   |-- consensus_isoforms_readlength.csv
  |       |   |   |-- flnc_readlength.csv
  |       |   |   |-- hq_readlength.csv
  |       |   |   |-- lq_readlength.csv
  |       |   |   |-- nfl_readlength.csv
  |       |   |   `-- polymerase_readlength.csv
  |       |   |-- fasta
  |       |   |   |-- ccs.fasta -> /pbi/dept/secondary/siv/smrtlink/smrtlink-alpha/jobs-root/022/022210/tasks/pbcoretools.tasks.bam2fasta_ccs-0/ccs.fasta
  |       |   |   |-- consensus_isoforms.fasta -> /pbi/dept/secondary/siv/smrtlink/smrtlink-alpha/jobs-root/022/022210/tasks/pbtranscript.tasks.separate_flnc-0/combined/all.consensus_isoforms.fasta
  |       |   |   |-- hq_isoforms.fasta -> /pbi/dept/secondary/siv/smrtlink/smrtlink-alpha/jobs-root/022/022210/tasks/pbtranscript.tasks.separate_flnc-0/combined/all.polished_hq.fasta
  |       |   |   |-- hq_isoforms.fastq -> /pbi/dept/secondary/siv/smrtlink/smrtlink-alpha/jobs-root/022/022210/tasks/pbtranscript.tasks.separate_flnc-0/combined/all.polished_hq.fastq
  |       |   |   |-- isoseq_flnc.fasta
  |       |   |   |-- isoseq_nfl.fasta
  |       |   |   |-- lq_isoforms.fasta -> /pbi/dept/secondary/siv/smrtlink/smrtlink-alpha/jobs-root/022/022210/tasks/pbtranscript.tasks.separate_flnc-0/combined/all.polished_lq.fasta
  |       |   |   `-- lq_isoforms.fastq -> /pbi/dept/secondary/siv/smrtlink/smrtlink-alpha/jobs-root/022/022210/tasks/pbtranscript.tasks.separate_flnc-0/combined/all.polished_lq.fastq
  |       |   |-- isoseq_rc0_validation_report.csv
  |       |   |-- log
  |       |   |-- reseq_to_hg
  |       |   |   |-- flnc_reseq_to_hg_selected_transcripts.csv
  |       |   |   |-- flnc_to_hg.m4
  |       |   |   |-- hq_reseq_to_hg_selected_transcripts.csv
  |       |   |   `-- hq_to_hg.m4
  |       |   `-- reseq_to_sirv
  |       |       |-- hq_isoforms.sirv.m4
  |       |       |-- isoseq_flnc.sirv.m4
  |       |       `-- lq_isoforms.sirv.m4
  |       `-- validate_smrtlink_isoseq_rc0.done
  |-- config.json
  |-- log
  |   `-- print_env.done
  |-- prefix.sh
  |-- reports
  |   `-- IsoSeqRC0Plots
  |       |-- isoseq_rc0_ccs_readlength_hist.png
  |       |-- isoseq_rc0_collapse_to_sirv_n_false_negative.png
  |       |-- isoseq_rc0_collapse_to_sirv_n_false_positive.png
  |       |-- isoseq_rc0_collapse_to_sirv_n_true_positive.png
  |       |-- isoseq_rc0_collapsed_to_sirv_rep_readlength_hist.png
  |       |-- isoseq_rc0_consensus_isoforms_readlength_hist.png
  |       |-- isoseq_rc0_flnc_readlength_hist.png
  |       |-- isoseq_rc0_flnc_reseq_to_hg_selected.png
  |       |-- isoseq_rc0_hq_readlength_hist.png
  |       |-- isoseq_rc0_hq_reseq_to_hg_selected.png
  |       |-- isoseq_rc0_lq_readlength_hist.png
  |       |-- isoseq_rc0_nfl_readlength_hist.png
  |       |-- sts.h5 -> .*/bauhaus2/resources/extras/no_sts.h5 (re)
  |       |-- sts.xml -> .*/bauhaus2/resources/extras/no_sts.xml (re)
  |       |-- isoseq_rc0_reseq_to_sirv_hq_n_mapped_reads.png
  |       |-- isoseq_rc0_reseq_to_sirv_hq_n_mapped_refs.png
  |       |-- isoseq_rc0_reseq_to_sirv_lq_n_mapped_reads.png
  |       |-- isoseq_rc0_reseq_to_sirv_lq_n_mapped_refs.png
  |       |-- report.Rd
  |       `-- report.json
  |-- run.sh
  |-- scripts
  |   `-- R
  |       |-- Bauhaus2.R
  |       `-- IsoSeqRC0Plots.R
  |-- snakemake.log
  `-- workflow
      `-- Snakefile
  
  16 directories, 64 files

