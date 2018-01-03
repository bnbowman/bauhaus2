Test execution of the CCSMappingReports workflow on some very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../../

Generate mapping reports workflow, starting from subreads.

  $ bauhaus2 --no-smrtlink --noGrid generate -w CCSMappingReports -t ${BH_ROOT}test/data/two-tiny-movies.csv -o ccsmappingreports
  Validation and input resolution succeeded.
  Generated runnable workflow to "ccsmappingreports"

  $ (cd ccsmappingreports && ./run.sh >/dev/null 2>&1)


  $ tree -I __pycache__ ccsmappingreports | sed 's|\ ->.*||'
  ccsmappingreports
  |-- condition-table.csv
  |-- conditions
  |   |-- MovieA
  |   |   |-- ccs
  |   |   |   `-- chunks
  |   |   |       |-- ccs.chunk0.ccs.bam
  |   |   |       |-- ccs.chunk0.ccs.bam.pbi
  |   |   |       |-- ccs.chunk0.consensusreadset.xml
  |   |   |       |-- ccs.chunk0.report.txt
  |   |   |       |-- ccs.chunk1.ccs.bam
  |   |   |       |-- ccs.chunk1.ccs.bam.pbi
  |   |   |       |-- ccs.chunk1.consensusreadset.xml
  |   |   |       |-- ccs.chunk1.report.txt
  |   |   |       |-- ccs.chunk2.ccs.bam
  |   |   |       |-- ccs.chunk2.ccs.bam.pbi
  |   |   |       |-- ccs.chunk2.consensusreadset.xml
  |   |   |       |-- ccs.chunk2.report.txt
  |   |   |       |-- ccs.chunk3.ccs.bam
  |   |   |       |-- ccs.chunk3.ccs.bam.pbi
  |   |   |       |-- ccs.chunk3.consensusreadset.xml
  |   |   |       |-- ccs.chunk3.report.txt
  |   |   |       |-- ccs.chunk4.ccs.bam
  |   |   |       |-- ccs.chunk4.ccs.bam.pbi
  |   |   |       |-- ccs.chunk4.consensusreadset.xml
  |   |   |       |-- ccs.chunk4.report.txt
  |   |   |       |-- ccs.chunk5.ccs.bam
  |   |   |       |-- ccs.chunk5.ccs.bam.pbi
  |   |   |       |-- ccs.chunk5.consensusreadset.xml
  |   |   |       |-- ccs.chunk5.report.txt
  |   |   |       |-- ccs.chunk6.ccs.bam
  |   |   |       |-- ccs.chunk6.ccs.bam.pbi
  |   |   |       |-- ccs.chunk6.consensusreadset.xml
  |   |   |       |-- ccs.chunk6.report.txt
  |   |   |       |-- ccs.chunk7.ccs.bam
  |   |   |       |-- ccs.chunk7.ccs.bam.pbi
  |   |   |       |-- ccs.chunk7.consensusreadset.xml
  |   |   |       `-- ccs.chunk7.report.txt
  |   |   |-- mapped_ccs
  |   |   |   |-- chunks
  |   |   |   |   |-- mapped-ccs.chunk0.alignmentset.bam
  |   |   |   |   |-- mapped-ccs.chunk0.alignmentset.bam.bai
  |   |   |   |   |-- mapped-ccs.chunk0.alignmentset.bam.pbi
  |   |   |   |   |-- mapped-ccs.chunk0.alignmentset.xml
  |   |   |   |   |-- mapped-ccs.chunk1.alignmentset.bam
  |   |   |   |   |-- mapped-ccs.chunk1.alignmentset.bam.bai
  |   |   |   |   |-- mapped-ccs.chunk1.alignmentset.bam.pbi
  |   |   |   |   |-- mapped-ccs.chunk1.alignmentset.xml
  |   |   |   |   |-- mapped-ccs.chunk2.alignmentset.bam
  |   |   |   |   |-- mapped-ccs.chunk2.alignmentset.bam.bai
  |   |   |   |   |-- mapped-ccs.chunk2.alignmentset.bam.pbi
  |   |   |   |   |-- mapped-ccs.chunk2.alignmentset.xml
  |   |   |   |   |-- mapped-ccs.chunk3.alignmentset.bam
  |   |   |   |   |-- mapped-ccs.chunk3.alignmentset.bam.bai
  |   |   |   |   |-- mapped-ccs.chunk3.alignmentset.bam.pbi
  |   |   |   |   |-- mapped-ccs.chunk3.alignmentset.xml
  |   |   |   |   |-- mapped-ccs.chunk4.alignmentset.bam
  |   |   |   |   |-- mapped-ccs.chunk4.alignmentset.bam.bai
  |   |   |   |   |-- mapped-ccs.chunk4.alignmentset.bam.pbi
  |   |   |   |   |-- mapped-ccs.chunk4.alignmentset.xml
  |   |   |   |   |-- mapped-ccs.chunk5.alignmentset.bam
  |   |   |   |   |-- mapped-ccs.chunk5.alignmentset.bam.bai
  |   |   |   |   |-- mapped-ccs.chunk5.alignmentset.bam.pbi
  |   |   |   |   |-- mapped-ccs.chunk5.alignmentset.xml
  |   |   |   |   |-- mapped-ccs.chunk6.alignmentset.bam
  |   |   |   |   |-- mapped-ccs.chunk6.alignmentset.bam.bai
  |   |   |   |   |-- mapped-ccs.chunk6.alignmentset.bam.pbi
  |   |   |   |   |-- mapped-ccs.chunk6.alignmentset.xml
  |   |   |   |   |-- mapped-ccs.chunk7.alignmentset.bam
  |   |   |   |   |-- mapped-ccs.chunk7.alignmentset.bam.bai
  |   |   |   |   |-- mapped-ccs.chunk7.alignmentset.bam.pbi
  |   |   |   |   `-- mapped-ccs.chunk7.alignmentset.xml
  |   |   |   `-- mapped-ccs.alignmentset.xml
  |   |   |-- reference.fasta
  |   |   |-- reference.fasta.fai
  |   |   |-- sts.h5
  |   |   |-- sts.xml
  |   |   `-- subreads
  |   |       |-- chunks
  |   |       |   |-- input.chunk0.subreadset.xml
  |   |       |   |-- input.chunk1.subreadset.xml
  |   |       |   |-- input.chunk2.subreadset.xml
  |   |       |   |-- input.chunk3.subreadset.xml
  |   |       |   |-- input.chunk4.subreadset.xml
  |   |       |   |-- input.chunk5.subreadset.xml
  |   |       |   |-- input.chunk6.subreadset.xml
  |   |       |   `-- input.chunk7.subreadset.xml
  |   |       `-- input.subreadset.xml
  |   `-- MovieB
  |       |-- ccs
  |       |   `-- chunks
  |       |       |-- ccs.chunk0.ccs.bam
  |       |       |-- ccs.chunk0.ccs.bam.pbi
  |       |       |-- ccs.chunk0.consensusreadset.xml
  |       |       |-- ccs.chunk0.report.txt
  |       |       |-- ccs.chunk1.ccs.bam
  |       |       |-- ccs.chunk1.ccs.bam.pbi
  |       |       |-- ccs.chunk1.consensusreadset.xml
  |       |       |-- ccs.chunk1.report.txt
  |       |       |-- ccs.chunk2.ccs.bam
  |       |       |-- ccs.chunk2.ccs.bam.pbi
  |       |       |-- ccs.chunk2.consensusreadset.xml
  |       |       |-- ccs.chunk2.report.txt
  |       |       |-- ccs.chunk3.ccs.bam
  |       |       |-- ccs.chunk3.ccs.bam.pbi
  |       |       |-- ccs.chunk3.consensusreadset.xml
  |       |       |-- ccs.chunk3.report.txt
  |       |       |-- ccs.chunk4.ccs.bam
  |       |       |-- ccs.chunk4.ccs.bam.pbi
  |       |       |-- ccs.chunk4.consensusreadset.xml
  |       |       |-- ccs.chunk4.report.txt
  |       |       |-- ccs.chunk5.ccs.bam
  |       |       |-- ccs.chunk5.ccs.bam.pbi
  |       |       |-- ccs.chunk5.consensusreadset.xml
  |       |       |-- ccs.chunk5.report.txt
  |       |       |-- ccs.chunk6.ccs.bam
  |       |       |-- ccs.chunk6.ccs.bam.pbi
  |       |       |-- ccs.chunk6.consensusreadset.xml
  |       |       |-- ccs.chunk6.report.txt
  |       |       |-- ccs.chunk7.ccs.bam
  |       |       |-- ccs.chunk7.ccs.bam.pbi
  |       |       |-- ccs.chunk7.consensusreadset.xml
  |       |       `-- ccs.chunk7.report.txt
  |       |-- mapped_ccs
  |       |   |-- chunks
  |       |   |   |-- mapped-ccs.chunk0.alignmentset.bam
  |       |   |   |-- mapped-ccs.chunk0.alignmentset.bam.bai
  |       |   |   |-- mapped-ccs.chunk0.alignmentset.bam.pbi
  |       |   |   |-- mapped-ccs.chunk0.alignmentset.xml
  |       |   |   |-- mapped-ccs.chunk1.alignmentset.bam
  |       |   |   |-- mapped-ccs.chunk1.alignmentset.bam.bai
  |       |   |   |-- mapped-ccs.chunk1.alignmentset.bam.pbi
  |       |   |   |-- mapped-ccs.chunk1.alignmentset.xml
  |       |   |   |-- mapped-ccs.chunk2.alignmentset.bam
  |       |   |   |-- mapped-ccs.chunk2.alignmentset.bam.bai
  |       |   |   |-- mapped-ccs.chunk2.alignmentset.bam.pbi
  |       |   |   |-- mapped-ccs.chunk2.alignmentset.xml
  |       |   |   |-- mapped-ccs.chunk3.alignmentset.bam
  |       |   |   |-- mapped-ccs.chunk3.alignmentset.bam.bai
  |       |   |   |-- mapped-ccs.chunk3.alignmentset.bam.pbi
  |       |   |   |-- mapped-ccs.chunk3.alignmentset.xml
  |       |   |   |-- mapped-ccs.chunk4.alignmentset.bam
  |       |   |   |-- mapped-ccs.chunk4.alignmentset.bam.bai
  |       |   |   |-- mapped-ccs.chunk4.alignmentset.bam.pbi
  |       |   |   |-- mapped-ccs.chunk4.alignmentset.xml
  |       |   |   |-- mapped-ccs.chunk5.alignmentset.bam
  |       |   |   |-- mapped-ccs.chunk5.alignmentset.bam.bai
  |       |   |   |-- mapped-ccs.chunk5.alignmentset.bam.pbi
  |       |   |   |-- mapped-ccs.chunk5.alignmentset.xml
  |       |   |   |-- mapped-ccs.chunk6.alignmentset.bam
  |       |   |   |-- mapped-ccs.chunk6.alignmentset.bam.bai
  |       |   |   |-- mapped-ccs.chunk6.alignmentset.bam.pbi
  |       |   |   |-- mapped-ccs.chunk6.alignmentset.xml
  |       |   |   |-- mapped-ccs.chunk7.alignmentset.bam
  |       |   |   |-- mapped-ccs.chunk7.alignmentset.bam.bai
  |       |   |   |-- mapped-ccs.chunk7.alignmentset.bam.pbi
  |       |   |   `-- mapped-ccs.chunk7.alignmentset.xml
  |       |   `-- mapped-ccs.alignmentset.xml
  |       |-- reference.fasta
  |       |-- reference.fasta.fai
  |       |-- sts.h5
  |       |-- sts.xml
  |       `-- subreads
  |           |-- chunks
  |           |   |-- input.chunk0.subreadset.xml
  |           |   |-- input.chunk1.subreadset.xml
  |           |   |-- input.chunk2.subreadset.xml
  |           |   |-- input.chunk3.subreadset.xml
  |           |   |-- input.chunk4.subreadset.xml
  |           |   |-- input.chunk5.subreadset.xml
  |           |   |-- input.chunk6.subreadset.xml
  |           |   `-- input.chunk7.subreadset.xml
  |           `-- input.subreadset.xml
  |-- config.json
  |-- log
  |-- prefix.sh
  |-- reports
  |   `-- CCSMappingReports
  |       |-- ccs-mapping.csv
  |       |-- ccs_boxplot_ref1.png
  |       |-- ccs_titration.png
  |       |-- fractional_yield_ccs_accuracy.png
  |       |-- numpasses_dist_density.png
  |       |-- numpasses_dist_ecdf.png
  |       |-- read_quality_vs_empirical_accuracy.png
  |       |-- read_quality_vs_empirical_accuracy_phred.png
  |       |-- report.Rd
  |       |-- report.json
  |       `-- yield_reads_ccs_accuracy.png
  |-- run.sh
  |-- scripts
  |   `-- R
  |       |-- Bauhaus2.R
  |       `-- ccsMappingPlots.R
  |-- snakemake.log
  `-- workflow
      `-- Snakefile
  
  21 directories, 175 files


  $ rm -fr ccsmappingreports
  $ bauhaus2 --no-smrtlink --noGrid generate -w CCSMappingReports -t ${BH_ROOT}test/data/two-tiny-movies-modelpath.csv -o ccsmappingreports
  Validation and input resolution succeeded.
  Generated runnable workflow to "ccsmappingreports"

  $ (cd ccsmappingreports && ./run.sh >/dev/null 2>&1)


  $ tree -I __pycache__ ccsmappingreports | sed 's|\ ->.*||'
  ccsmappingreports
  |-- condition-table.csv
  |-- conditions
  |   |-- MovieA
  |   |   |-- ccs
  |   |   |   `-- chunks
  |   |   |       |-- ccs.chunk0.ccs.bam
  |   |   |       |-- ccs.chunk0.ccs.bam.pbi
  |   |   |       |-- ccs.chunk0.consensusreadset.xml
  |   |   |       |-- ccs.chunk0.report.txt
  |   |   |       |-- ccs.chunk1.ccs.bam
  |   |   |       |-- ccs.chunk1.ccs.bam.pbi
  |   |   |       |-- ccs.chunk1.consensusreadset.xml
  |   |   |       |-- ccs.chunk1.report.txt
  |   |   |       |-- ccs.chunk2.ccs.bam
  |   |   |       |-- ccs.chunk2.ccs.bam.pbi
  |   |   |       |-- ccs.chunk2.consensusreadset.xml
  |   |   |       |-- ccs.chunk2.report.txt
  |   |   |       |-- ccs.chunk3.ccs.bam
  |   |   |       |-- ccs.chunk3.ccs.bam.pbi
  |   |   |       |-- ccs.chunk3.consensusreadset.xml
  |   |   |       |-- ccs.chunk3.report.txt
  |   |   |       |-- ccs.chunk4.ccs.bam
  |   |   |       |-- ccs.chunk4.ccs.bam.pbi
  |   |   |       |-- ccs.chunk4.consensusreadset.xml
  |   |   |       |-- ccs.chunk4.report.txt
  |   |   |       |-- ccs.chunk5.ccs.bam
  |   |   |       |-- ccs.chunk5.ccs.bam.pbi
  |   |   |       |-- ccs.chunk5.consensusreadset.xml
  |   |   |       |-- ccs.chunk5.report.txt
  |   |   |       |-- ccs.chunk6.ccs.bam
  |   |   |       |-- ccs.chunk6.ccs.bam.pbi
  |   |   |       |-- ccs.chunk6.consensusreadset.xml
  |   |   |       |-- ccs.chunk6.report.txt
  |   |   |       |-- ccs.chunk7.ccs.bam
  |   |   |       |-- ccs.chunk7.ccs.bam.pbi
  |   |   |       |-- ccs.chunk7.consensusreadset.xml
  |   |   |       `-- ccs.chunk7.report.txt
  |   |   |-- mapped_ccs
  |   |   |   |-- chunks
  |   |   |   |   |-- mapped-ccs.chunk0.alignmentset.bam
  |   |   |   |   |-- mapped-ccs.chunk0.alignmentset.bam.bai
  |   |   |   |   |-- mapped-ccs.chunk0.alignmentset.bam.pbi
  |   |   |   |   |-- mapped-ccs.chunk0.alignmentset.xml
  |   |   |   |   |-- mapped-ccs.chunk1.alignmentset.bam
  |   |   |   |   |-- mapped-ccs.chunk1.alignmentset.bam.bai
  |   |   |   |   |-- mapped-ccs.chunk1.alignmentset.bam.pbi
  |   |   |   |   |-- mapped-ccs.chunk1.alignmentset.xml
  |   |   |   |   |-- mapped-ccs.chunk2.alignmentset.bam
  |   |   |   |   |-- mapped-ccs.chunk2.alignmentset.bam.bai
  |   |   |   |   |-- mapped-ccs.chunk2.alignmentset.bam.pbi
  |   |   |   |   |-- mapped-ccs.chunk2.alignmentset.xml
  |   |   |   |   |-- mapped-ccs.chunk3.alignmentset.bam
  |   |   |   |   |-- mapped-ccs.chunk3.alignmentset.bam.bai
  |   |   |   |   |-- mapped-ccs.chunk3.alignmentset.bam.pbi
  |   |   |   |   |-- mapped-ccs.chunk3.alignmentset.xml
  |   |   |   |   |-- mapped-ccs.chunk4.alignmentset.bam
  |   |   |   |   |-- mapped-ccs.chunk4.alignmentset.bam.bai
  |   |   |   |   |-- mapped-ccs.chunk4.alignmentset.bam.pbi
  |   |   |   |   |-- mapped-ccs.chunk4.alignmentset.xml
  |   |   |   |   |-- mapped-ccs.chunk5.alignmentset.bam
  |   |   |   |   |-- mapped-ccs.chunk5.alignmentset.bam.bai
  |   |   |   |   |-- mapped-ccs.chunk5.alignmentset.bam.pbi
  |   |   |   |   |-- mapped-ccs.chunk5.alignmentset.xml
  |   |   |   |   |-- mapped-ccs.chunk6.alignmentset.bam
  |   |   |   |   |-- mapped-ccs.chunk6.alignmentset.bam.bai
  |   |   |   |   |-- mapped-ccs.chunk6.alignmentset.bam.pbi
  |   |   |   |   |-- mapped-ccs.chunk6.alignmentset.xml
  |   |   |   |   |-- mapped-ccs.chunk7.alignmentset.bam
  |   |   |   |   |-- mapped-ccs.chunk7.alignmentset.bam.bai
  |   |   |   |   |-- mapped-ccs.chunk7.alignmentset.bam.pbi
  |   |   |   |   `-- mapped-ccs.chunk7.alignmentset.xml
  |   |   |   `-- mapped-ccs.alignmentset.xml
  |   |   |-- reference.fasta
  |   |   |-- reference.fasta.fai
  |   |   |-- sts.h5
  |   |   |-- sts.xml
  |   |   `-- subreads
  |   |       |-- chunks
  |   |       |   |-- input.chunk0.subreadset.xml
  |   |       |   |-- input.chunk1.subreadset.xml
  |   |       |   |-- input.chunk2.subreadset.xml
  |   |       |   |-- input.chunk3.subreadset.xml
  |   |       |   |-- input.chunk4.subreadset.xml
  |   |       |   |-- input.chunk5.subreadset.xml
  |   |       |   |-- input.chunk6.subreadset.xml
  |   |       |   `-- input.chunk7.subreadset.xml
  |   |       `-- input.subreadset.xml
  |   `-- MovieB
  |       |-- ccs
  |       |   `-- chunks
  |       |       |-- ccs.chunk0.ccs.bam
  |       |       |-- ccs.chunk0.ccs.bam.pbi
  |       |       |-- ccs.chunk0.consensusreadset.xml
  |       |       |-- ccs.chunk0.report.txt
  |       |       |-- ccs.chunk1.ccs.bam
  |       |       |-- ccs.chunk1.ccs.bam.pbi
  |       |       |-- ccs.chunk1.consensusreadset.xml
  |       |       |-- ccs.chunk1.report.txt
  |       |       |-- ccs.chunk2.ccs.bam
  |       |       |-- ccs.chunk2.ccs.bam.pbi
  |       |       |-- ccs.chunk2.consensusreadset.xml
  |       |       |-- ccs.chunk2.report.txt
  |       |       |-- ccs.chunk3.ccs.bam
  |       |       |-- ccs.chunk3.ccs.bam.pbi
  |       |       |-- ccs.chunk3.consensusreadset.xml
  |       |       |-- ccs.chunk3.report.txt
  |       |       |-- ccs.chunk4.ccs.bam
  |       |       |-- ccs.chunk4.ccs.bam.pbi
  |       |       |-- ccs.chunk4.consensusreadset.xml
  |       |       |-- ccs.chunk4.report.txt
  |       |       |-- ccs.chunk5.ccs.bam
  |       |       |-- ccs.chunk5.ccs.bam.pbi
  |       |       |-- ccs.chunk5.consensusreadset.xml
  |       |       |-- ccs.chunk5.report.txt
  |       |       |-- ccs.chunk6.ccs.bam
  |       |       |-- ccs.chunk6.ccs.bam.pbi
  |       |       |-- ccs.chunk6.consensusreadset.xml
  |       |       |-- ccs.chunk6.report.txt
  |       |       |-- ccs.chunk7.ccs.bam
  |       |       |-- ccs.chunk7.ccs.bam.pbi
  |       |       |-- ccs.chunk7.consensusreadset.xml
  |       |       `-- ccs.chunk7.report.txt
  |       |-- mapped_ccs
  |       |   |-- chunks
  |       |   |   |-- mapped-ccs.chunk0.alignmentset.bam
  |       |   |   |-- mapped-ccs.chunk0.alignmentset.bam.bai
  |       |   |   |-- mapped-ccs.chunk0.alignmentset.bam.pbi
  |       |   |   |-- mapped-ccs.chunk0.alignmentset.xml
  |       |   |   |-- mapped-ccs.chunk1.alignmentset.bam
  |       |   |   |-- mapped-ccs.chunk1.alignmentset.bam.bai
  |       |   |   |-- mapped-ccs.chunk1.alignmentset.bam.pbi
  |       |   |   |-- mapped-ccs.chunk1.alignmentset.xml
  |       |   |   |-- mapped-ccs.chunk2.alignmentset.bam
  |       |   |   |-- mapped-ccs.chunk2.alignmentset.bam.bai
  |       |   |   |-- mapped-ccs.chunk2.alignmentset.bam.pbi
  |       |   |   |-- mapped-ccs.chunk2.alignmentset.xml
  |       |   |   |-- mapped-ccs.chunk3.alignmentset.bam
  |       |   |   |-- mapped-ccs.chunk3.alignmentset.bam.bai
  |       |   |   |-- mapped-ccs.chunk3.alignmentset.bam.pbi
  |       |   |   |-- mapped-ccs.chunk3.alignmentset.xml
  |       |   |   |-- mapped-ccs.chunk4.alignmentset.bam
  |       |   |   |-- mapped-ccs.chunk4.alignmentset.bam.bai
  |       |   |   |-- mapped-ccs.chunk4.alignmentset.bam.pbi
  |       |   |   |-- mapped-ccs.chunk4.alignmentset.xml
  |       |   |   |-- mapped-ccs.chunk5.alignmentset.bam
  |       |   |   |-- mapped-ccs.chunk5.alignmentset.bam.bai
  |       |   |   |-- mapped-ccs.chunk5.alignmentset.bam.pbi
  |       |   |   |-- mapped-ccs.chunk5.alignmentset.xml
  |       |   |   |-- mapped-ccs.chunk6.alignmentset.bam
  |       |   |   |-- mapped-ccs.chunk6.alignmentset.bam.bai
  |       |   |   |-- mapped-ccs.chunk6.alignmentset.bam.pbi
  |       |   |   |-- mapped-ccs.chunk6.alignmentset.xml
  |       |   |   |-- mapped-ccs.chunk7.alignmentset.bam
  |       |   |   |-- mapped-ccs.chunk7.alignmentset.bam.bai
  |       |   |   |-- mapped-ccs.chunk7.alignmentset.bam.pbi
  |       |   |   `-- mapped-ccs.chunk7.alignmentset.xml
  |       |   `-- mapped-ccs.alignmentset.xml
  |       |-- reference.fasta
  |       |-- reference.fasta.fai
  |       |-- sts.h5
  |       |-- sts.xml
  |       `-- subreads
  |           |-- chunks
  |           |   |-- input.chunk0.subreadset.xml
  |           |   |-- input.chunk1.subreadset.xml
  |           |   |-- input.chunk2.subreadset.xml
  |           |   |-- input.chunk3.subreadset.xml
  |           |   |-- input.chunk4.subreadset.xml
  |           |   |-- input.chunk5.subreadset.xml
  |           |   |-- input.chunk6.subreadset.xml
  |           |   `-- input.chunk7.subreadset.xml
  |           `-- input.subreadset.xml
  |-- config.json
  |-- log
  |-- prefix.sh
  |-- reports
  |   `-- CCSMappingReports
  |       |-- ccs-mapping.csv
  |       |-- ccs_boxplot_ref1.png
  |       |-- ccs_titration.png
  |       |-- fractional_yield_ccs_accuracy.png
  |       |-- numpasses_dist_density.png
  |       |-- numpasses_dist_ecdf.png
  |       |-- read_quality_vs_empirical_accuracy.png
  |       |-- read_quality_vs_empirical_accuracy_phred.png
  |       |-- report.Rd
  |       |-- report.json
  |       `-- yield_reads_ccs_accuracy.png
  |-- run.sh
  |-- scripts
  |   `-- R
  |       |-- Bauhaus2.R
  |       `-- ccsMappingPlots.R
  |-- snakemake.log
  `-- workflow
      `-- Snakefile
  
  21 directories, 175 files
