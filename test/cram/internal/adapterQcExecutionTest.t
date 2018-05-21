Test execution of the mapping reports workflow on some very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../../

Generate mapping reports workflow, starting from trace files and basecallers

TODO (MDS 20180522): This conditiontable specifies basecaller/mainline, because
the --adpqc feature is not available in other modules. We should change this to
a more stable module when possible

  $ bauhaus2 --no-smrtlink --noGrid generate -w AdapterQC -t ${BH_ROOT}test/data/human_adapterqc.csv -o AdapterQC
  Validation and input resolution succeeded.
  Generated runnable workflow to "AdapterQC"

  $ (cd AdapterQC && ./run.sh >/dev/null 2>&1)


  $ tree -I __pycache__ AdapterQC
  AdapterQC
  |-- benchmarks
  |   |-- human_bam2bam_adapter_diagnostics.tsv
  |   `-- human_run_pbQcAdapters
  |-- condition-table.csv
  |-- conditions
  |   `-- human
  |       |-- primary
  |       |   |-- input.adapters.fasta
  |       |   |-- input.bam2bam_1.log
  |       |   |-- input.report.json.gz
  |       |   |-- input.scraps.bam
  |       |   |-- input.scraps.bam.pbi
  |       |   |-- input.subreads.bam
  |       |   |-- input.subreads.bam.pbi
  |       |   `-- input.subreadset.xml
  |       |-- reference.fasta -> /pbi/dept/secondary/siv/references/hg38_reference/sequence/hg38_reference.fasta
  |       |-- reference.fasta.fai -> /pbi/dept/secondary/siv/references/hg38_reference/sequence/hg38_reference.fasta.fai
  |       |-- sts.h5 -> */bauhaus2/resources/extras/no_sts.h5 (re)
  |       `-- sts.xml -> */bauhaus2/resources/extras/no_sts.xml (re)
  |       `-- subreads
  |           `-- input.subreadset.xml
  |-- config.json
  |-- log
  |-- prefix.sh
  |-- reports
  |   `-- AdapterQC
  |       |-- human
  |       |   |-- adapterQCReport.txt
  |       |   |-- adapterReport.csv
  |       |   `-- adapterZiaReport.csv
  |       `-- report.json
  |-- run.sh
  |-- scripts
  |-- snakemake.log
  `-- workflow
      `-- Snakefile
  
  11 directories, 25 files


