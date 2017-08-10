Test execution of the mapping reports workflow on some very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../../

Generate mapping reports workflow, starting from subreads.

  $ bauhaus2 --no-smrtlink --noGrid generate -w CoverageTitration -t ${BH_ROOT}test/data/two-tiny-movies-coverage-titration.csv -o coverage-titration
  Validation and input resolution succeeded.
  Generated runnable workflow to "coverage-titration"

  $ (cd coverage-titration && ./run.sh >/dev/null 2>&1)


  $ tree -I __pycache__ coverage-titration
  coverage-titration
  |-- condition-table.csv
  |-- conditions
  |   |-- MovieA
  |   |   |-- mapped
  |   |   |   |-- chunks
  |   |   |   |   |-- mapped.chunk0.alignmentset.bam
  |   |   |   |   |-- mapped.chunk0.alignmentset.bam.bai
  |   |   |   |   |-- mapped.chunk0.alignmentset.bam.pbi
  |   |   |   |   |-- mapped.chunk0.alignmentset.xml
  |   |   |   |   |-- mapped.chunk1.alignmentset.bam
  |   |   |   |   |-- mapped.chunk1.alignmentset.bam.bai
  |   |   |   |   |-- mapped.chunk1.alignmentset.bam.pbi
  |   |   |   |   |-- mapped.chunk1.alignmentset.xml
  |   |   |   |   |-- mapped.chunk2.alignmentset.bam
  |   |   |   |   |-- mapped.chunk2.alignmentset.bam.bai
  |   |   |   |   |-- mapped.chunk2.alignmentset.bam.pbi
  |   |   |   |   |-- mapped.chunk2.alignmentset.xml
  |   |   |   |   |-- mapped.chunk3.alignmentset.bam
  |   |   |   |   |-- mapped.chunk3.alignmentset.bam.bai
  |   |   |   |   |-- mapped.chunk3.alignmentset.bam.pbi
  |   |   |   |   |-- mapped.chunk3.alignmentset.xml
  |   |   |   |   |-- mapped.chunk4.alignmentset.bam
  |   |   |   |   |-- mapped.chunk4.alignmentset.bam.bai
  |   |   |   |   |-- mapped.chunk4.alignmentset.bam.pbi
  |   |   |   |   |-- mapped.chunk4.alignmentset.xml
  |   |   |   |   |-- mapped.chunk5.alignmentset.bam
  |   |   |   |   |-- mapped.chunk5.alignmentset.bam.bai
  |   |   |   |   |-- mapped.chunk5.alignmentset.bam.pbi
  |   |   |   |   |-- mapped.chunk5.alignmentset.xml
  |   |   |   |   |-- mapped.chunk6.alignmentset.bam
  |   |   |   |   |-- mapped.chunk6.alignmentset.bam.bai
  |   |   |   |   |-- mapped.chunk6.alignmentset.bam.pbi
  |   |   |   |   |-- mapped.chunk6.alignmentset.xml
  |   |   |   |   |-- mapped.chunk7.alignmentset.bam
  |   |   |   |   |-- mapped.chunk7.alignmentset.bam.bai
  |   |   |   |   |-- mapped.chunk7.alignmentset.bam.pbi
  |   |   |   |   `-- mapped.chunk7.alignmentset.xml
  |   |   |   `-- mapped.alignmentset.xml
  |   |   |-- reference.fasta -> /pbi/dept/secondary/siv/references/ecoliK12_pbi_March2013/sequence/ecoliK12_pbi_March2013.fasta
  |   |   |-- reference.fasta.fai -> /pbi/dept/secondary/siv/references/ecoliK12_pbi_March2013/sequence/ecoliK12_pbi_March2013.fasta.fai
  |   |   |-- sts.h5 -> .*/bauhaus2/resources/extras/no_sts.h5 (re)
  |   |   |-- sts.xml -> .*/bauhaus2/resources/extras/no_sts.xml (re)
  |   |   |-- subreads
  |   |   |   |-- chunks
  |   |   |   |   |-- input.chunk0.subreadset.xml
  |   |   |   |   |-- input.chunk1.subreadset.xml
  |   |   |   |   |-- input.chunk2.subreadset.xml
  |   |   |   |   |-- input.chunk3.subreadset.xml
  |   |   |   |   |-- input.chunk4.subreadset.xml
  |   |   |   |   |-- input.chunk5.subreadset.xml
  |   |   |   |   |-- input.chunk6.subreadset.xml
  |   |   |   |   `-- input.chunk7.subreadset.xml
  |   |   |   `-- input.subreadset.xml
  |   |   `-- variant_calling
  |   |       |-- alignments-summary.gff
  |   |       |-- consensus.10.fasta
  |   |       |-- consensus.10.fastq
  |   |       |-- consensus.100.fasta
  |   |       |-- consensus.100.fastq
  |   |       |-- consensus.15.fasta
  |   |       |-- consensus.15.fastq
  |   |       |-- consensus.20.fasta
  |   |       |-- consensus.20.fastq
  |   |       |-- consensus.30.fasta
  |   |       |-- consensus.30.fastq
  |   |       |-- consensus.40.fasta
  |   |       |-- consensus.40.fastq
  |   |       |-- consensus.5.fasta
  |   |       |-- consensus.5.fastq
  |   |       |-- consensus.50.fasta
  |   |       |-- consensus.50.fastq
  |   |       |-- consensus.60.fasta
  |   |       |-- consensus.60.fastq
  |   |       |-- consensus.80.fasta
  |   |       |-- consensus.80.fastq
  |   |       |-- masked-variants.10.gff
  |   |       |-- masked-variants.100.gff
  |   |       |-- masked-variants.15.gff
  |   |       |-- masked-variants.20.gff
  |   |       |-- masked-variants.30.gff
  |   |       |-- masked-variants.40.gff
  |   |       |-- masked-variants.5.gff
  |   |       |-- masked-variants.50.gff
  |   |       |-- masked-variants.60.gff
  |   |       |-- masked-variants.80.gff
  |   |       |-- variants.10.gff
  |   |       |-- variants.100.gff
  |   |       |-- variants.15.gff
  |   |       |-- variants.20.gff
  |   |       |-- variants.30.gff
  |   |       |-- variants.40.gff
  |   |       |-- variants.5.gff
  |   |       |-- variants.50.gff
  |   |       |-- variants.60.gff
  |   |       `-- variants.80.gff
  |   `-- MovieB
  |       |-- mapped
  |       |   |-- chunks
  |       |   |   |-- mapped.chunk0.alignmentset.bam
  |       |   |   |-- mapped.chunk0.alignmentset.bam.bai
  |       |   |   |-- mapped.chunk0.alignmentset.bam.pbi
  |       |   |   |-- mapped.chunk0.alignmentset.xml
  |       |   |   |-- mapped.chunk1.alignmentset.bam
  |       |   |   |-- mapped.chunk1.alignmentset.bam.bai
  |       |   |   |-- mapped.chunk1.alignmentset.bam.pbi
  |       |   |   |-- mapped.chunk1.alignmentset.xml
  |       |   |   |-- mapped.chunk2.alignmentset.bam
  |       |   |   |-- mapped.chunk2.alignmentset.bam.bai
  |       |   |   |-- mapped.chunk2.alignmentset.bam.pbi
  |       |   |   |-- mapped.chunk2.alignmentset.xml
  |       |   |   |-- mapped.chunk3.alignmentset.bam
  |       |   |   |-- mapped.chunk3.alignmentset.bam.bai
  |       |   |   |-- mapped.chunk3.alignmentset.bam.pbi
  |       |   |   |-- mapped.chunk3.alignmentset.xml
  |       |   |   |-- mapped.chunk4.alignmentset.bam
  |       |   |   |-- mapped.chunk4.alignmentset.bam.bai
  |       |   |   |-- mapped.chunk4.alignmentset.bam.pbi
  |       |   |   |-- mapped.chunk4.alignmentset.xml
  |       |   |   |-- mapped.chunk5.alignmentset.bam
  |       |   |   |-- mapped.chunk5.alignmentset.bam.bai
  |       |   |   |-- mapped.chunk5.alignmentset.bam.pbi
  |       |   |   |-- mapped.chunk5.alignmentset.xml
  |       |   |   |-- mapped.chunk6.alignmentset.bam
  |       |   |   |-- mapped.chunk6.alignmentset.bam.bai
  |       |   |   |-- mapped.chunk6.alignmentset.bam.pbi
  |       |   |   |-- mapped.chunk6.alignmentset.xml
  |       |   |   |-- mapped.chunk7.alignmentset.bam
  |       |   |   |-- mapped.chunk7.alignmentset.bam.bai
  |       |   |   |-- mapped.chunk7.alignmentset.bam.pbi
  |       |   |   `-- mapped.chunk7.alignmentset.xml
  |       |   `-- mapped.alignmentset.xml
  |       |-- reference.fasta -> /pbi/dept/secondary/siv/references/ecoliK12_pbi_March2013/sequence/ecoliK12_pbi_March2013.fasta
  |       |-- reference.fasta.fai -> /pbi/dept/secondary/siv/references/ecoliK12_pbi_March2013/sequence/ecoliK12_pbi_March2013.fasta.fai
  |       |-- sts.h5 -> .*/bauhaus2/resources/extras/no_sts.h5 (re)
  |       |-- sts.xml -> .*/bauhaus2/resources/extras/no_sts.xml (re)
  |       |-- subreads
  |       |   |-- chunks
  |       |   |   |-- input.chunk0.subreadset.xml
  |       |   |   |-- input.chunk1.subreadset.xml
  |       |   |   |-- input.chunk2.subreadset.xml
  |       |   |   |-- input.chunk3.subreadset.xml
  |       |   |   |-- input.chunk4.subreadset.xml
  |       |   |   |-- input.chunk5.subreadset.xml
  |       |   |   |-- input.chunk6.subreadset.xml
  |       |   |   `-- input.chunk7.subreadset.xml
  |       |   `-- input.subreadset.xml
  |       `-- variant_calling
  |           |-- alignments-summary.gff
  |           |-- consensus.10.fasta
  |           |-- consensus.10.fastq
  |           |-- consensus.100.fasta
  |           |-- consensus.100.fastq
  |           |-- consensus.15.fasta
  |           |-- consensus.15.fastq
  |           |-- consensus.20.fasta
  |           |-- consensus.20.fastq
  |           |-- consensus.30.fasta
  |           |-- consensus.30.fastq
  |           |-- consensus.40.fasta
  |           |-- consensus.40.fastq
  |           |-- consensus.5.fasta
  |           |-- consensus.5.fastq
  |           |-- consensus.50.fasta
  |           |-- consensus.50.fastq
  |           |-- consensus.60.fasta
  |           |-- consensus.60.fastq
  |           |-- consensus.80.fasta
  |           |-- consensus.80.fastq
  |           |-- masked-variants.10.gff
  |           |-- masked-variants.100.gff
  |           |-- masked-variants.15.gff
  |           |-- masked-variants.20.gff
  |           |-- masked-variants.30.gff
  |           |-- masked-variants.40.gff
  |           |-- masked-variants.5.gff
  |           |-- masked-variants.50.gff
  |           |-- masked-variants.60.gff
  |           |-- masked-variants.80.gff
  |           |-- variants.10.gff
  |           |-- variants.100.gff
  |           |-- variants.15.gff
  |           |-- variants.20.gff
  |           |-- variants.30.gff
  |           |-- variants.40.gff
  |           |-- variants.5.gff
  |           |-- variants.50.gff
  |           |-- variants.60.gff
  |           `-- variants.80.gff
  |-- config.json
  |-- log
  |-- prefix.sh
  |-- reports
  |   `-- CoverageTitration
  |       |-- concordance-by-condition.png
  |       `-- coverage-titration.csv
  |-- run.sh
  |-- scripts
  |   `-- R
  |       |-- Bauhaus2.R
  |       `-- coverageTitrationPlots.R
  |-- snakemake.log
  `-- workflow
      `-- Snakefile
  
  19 directories, 184 files