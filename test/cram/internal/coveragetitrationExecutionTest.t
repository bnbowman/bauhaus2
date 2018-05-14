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


  $ tree -I __pycache__ coverage-titration | sed 's|\ ->.*||'
  coverage-titration
  |-- benchmarks
  |   |-- MovieA_0_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieA_100_mask_variants.tsv
  |   |-- MovieA_100_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieA_10_mask_variants.tsv
  |   |-- MovieA_10_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieA_15_mask_variants.tsv
  |   |-- MovieA_15_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieA_1_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieA_20_mask_variants.tsv
  |   |-- MovieA_20_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieA_2_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieA_30_mask_variants.tsv
  |   |-- MovieA_30_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieA_3_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieA_40_mask_variants.tsv
  |   |-- MovieA_40_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieA_4_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieA_5_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieA_5_mask_variants.tsv
  |   |-- MovieA_5_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieA_63_mask_variants.tsv
  |   |-- MovieA_63_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieA_6_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieA_75_mask_variants.tsv
  |   |-- MovieA_75_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieA_7_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieA_88_mask_variants.tsv
  |   |-- MovieA_88_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieA_chunk_subreads_one_condition.tsv
  |   |-- MovieA_map_chunked_subreads_and_gather_one_condition.tsv
  |   |-- MovieA_summarize_coverage.tsv
  |   |-- MovieB_0_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieB_100_mask_variants.tsv
  |   |-- MovieB_100_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieB_10_mask_variants.tsv
  |   |-- MovieB_10_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieB_15_mask_variants.tsv
  |   |-- MovieB_15_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieB_1_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieB_20_mask_variants.tsv
  |   |-- MovieB_20_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieB_2_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieB_30_mask_variants.tsv
  |   |-- MovieB_30_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieB_3_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieB_40_mask_variants.tsv
  |   |-- MovieB_40_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieB_4_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieB_5_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieB_5_mask_variants.tsv
  |   |-- MovieB_5_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieB_63_mask_variants.tsv
  |   |-- MovieB_63_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieB_6_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieB_75_mask_variants.tsv
  |   |-- MovieB_75_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieB_7_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieB_88_mask_variants.tsv
  |   |-- MovieB_88_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieB_chunk_subreads_one_condition.tsv
  |   |-- MovieB_map_chunked_subreads_and_gather_one_condition.tsv
  |   |-- MovieB_summarize_coverage.tsv
  |   `-- coverage_titration_report.tsv
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
  |   |   |-- reference.fasta
  |   |   |-- reference.fasta.fai
  |   |   |-- sts.h5
  |   |   |-- sts.xml
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
  |   |       |-- consensus.63.fasta
  |   |       |-- consensus.63.fastq
  |   |       |-- consensus.75.fasta
  |   |       |-- consensus.75.fastq
  |   |       |-- consensus.88.fasta
  |   |       |-- consensus.88.fastq
  |   |       |-- masked-variants.10.gff
  |   |       |-- masked-variants.100.gff
  |   |       |-- masked-variants.15.gff
  |   |       |-- masked-variants.20.gff
  |   |       |-- masked-variants.30.gff
  |   |       |-- masked-variants.40.gff
  |   |       |-- masked-variants.5.gff
  |   |       |-- masked-variants.63.gff
  |   |       |-- masked-variants.75.gff
  |   |       |-- masked-variants.88.gff
  |   |       |-- variants.10.gff
  |   |       |-- variants.100.gff
  |   |       |-- variants.15.gff
  |   |       |-- variants.20.gff
  |   |       |-- variants.30.gff
  |   |       |-- variants.40.gff
  |   |       |-- variants.5.gff
  |   |       |-- variants.63.gff
  |   |       |-- variants.75.gff
  |   |       `-- variants.88.gff
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
  |       |-- reference.fasta
  |       |-- reference.fasta.fai
  |       |-- sts.h5
  |       |-- sts.xml
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
  |           |-- consensus.63.fasta
  |           |-- consensus.63.fastq
  |           |-- consensus.75.fasta
  |           |-- consensus.75.fastq
  |           |-- consensus.88.fasta
  |           |-- consensus.88.fastq
  |           |-- masked-variants.10.gff
  |           |-- masked-variants.100.gff
  |           |-- masked-variants.15.gff
  |           |-- masked-variants.20.gff
  |           |-- masked-variants.30.gff
  |           |-- masked-variants.40.gff
  |           |-- masked-variants.5.gff
  |           |-- masked-variants.63.gff
  |           |-- masked-variants.75.gff
  |           |-- masked-variants.88.gff
  |           |-- variants.10.gff
  |           |-- variants.100.gff
  |           |-- variants.15.gff
  |           |-- variants.20.gff
  |           |-- variants.30.gff
  |           |-- variants.40.gff
  |           |-- variants.5.gff
  |           |-- variants.63.gff
  |           |-- variants.75.gff
  |           `-- variants.88.gff
  |-- config.json
  |-- log
  |-- prefix.sh
  |-- reports
  |   `-- CoverageTitration
  |       |-- concordance-by-condition.png
  |       |-- coverage-diagnostic-plot.png
  |       |-- coverage-titration.csv
  |       `-- report.json
  |-- run.sh
  |-- scripts
  |   `-- R
  |       |-- Bauhaus2.R
  |       `-- coverageTitrationPlots.R
  |-- snakemake.log
  `-- workflow
      `-- Snakefile
  
  20 directories, 249 files


  $ rm -fr coverage-titration
  $ bauhaus2 --no-smrtlink --noGrid generate -w CoverageTitration -t ${BH_ROOT}test/data/two-tiny-movies-coverage-titration-modelpath.csv -o coverage-titration
  Validation and input resolution succeeded.
  Generated runnable workflow to "coverage-titration"

  $ (cd coverage-titration && ./run.sh >/dev/null 2>&1)


  $ tree -I __pycache__ coverage-titration | sed 's|\ ->.*||'
  coverage-titration
  |-- benchmarks
  |   |-- MovieAModelPath_0_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieAModelPath_100_mask_variants.tsv
  |   |-- MovieAModelPath_100_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieAModelPath_10_mask_variants.tsv
  |   |-- MovieAModelPath_10_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieAModelPath_15_mask_variants.tsv
  |   |-- MovieAModelPath_15_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieAModelPath_1_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieAModelPath_20_mask_variants.tsv
  |   |-- MovieAModelPath_20_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieAModelPath_2_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieAModelPath_30_mask_variants.tsv
  |   |-- MovieAModelPath_30_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieAModelPath_3_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieAModelPath_40_mask_variants.tsv
  |   |-- MovieAModelPath_40_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieAModelPath_4_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieAModelPath_5_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieAModelPath_5_mask_variants.tsv
  |   |-- MovieAModelPath_5_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieAModelPath_63_mask_variants.tsv
  |   |-- MovieAModelPath_63_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieAModelPath_6_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieAModelPath_75_mask_variants.tsv
  |   |-- MovieAModelPath_75_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieAModelPath_7_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieAModelPath_88_mask_variants.tsv
  |   |-- MovieAModelPath_88_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieAModelPath_chunk_subreads_one_condition.tsv
  |   |-- MovieAModelPath_map_chunked_subreads_and_gather_one_condition.tsv
  |   |-- MovieAModelPath_summarize_coverage.tsv
  |   |-- MovieBZiaJob_0_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieBZiaJob_100_mask_variants.tsv
  |   |-- MovieBZiaJob_100_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieBZiaJob_10_mask_variants.tsv
  |   |-- MovieBZiaJob_10_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieBZiaJob_15_mask_variants.tsv
  |   |-- MovieBZiaJob_15_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieBZiaJob_1_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieBZiaJob_20_mask_variants.tsv
  |   |-- MovieBZiaJob_20_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieBZiaJob_2_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieBZiaJob_30_mask_variants.tsv
  |   |-- MovieBZiaJob_30_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieBZiaJob_3_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieBZiaJob_40_mask_variants.tsv
  |   |-- MovieBZiaJob_40_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieBZiaJob_4_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieBZiaJob_5_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieBZiaJob_5_mask_variants.tsv
  |   |-- MovieBZiaJob_5_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieBZiaJob_63_mask_variants.tsv
  |   |-- MovieBZiaJob_63_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieBZiaJob_6_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieBZiaJob_75_mask_variants.tsv
  |   |-- MovieBZiaJob_75_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieBZiaJob_7_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieBZiaJob_88_mask_variants.tsv
  |   |-- MovieBZiaJob_88_variant_call_fixed_coverage_one_condition.tsv
  |   |-- MovieBZiaJob_chunk_subreads_one_condition.tsv
  |   |-- MovieBZiaJob_map_chunked_subreads_and_gather_one_condition.tsv
  |   |-- MovieBZiaJob_summarize_coverage.tsv
  |   `-- coverage_titration_report.tsv
  |-- condition-table.csv
  |-- conditions
  |   |-- MovieAModelPath
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
  |   |   |-- reference.fasta
  |   |   |-- reference.fasta.fai
  |   |   |-- sts.h5
  |   |   |-- sts.xml
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
  |   |       |-- consensus.63.fasta
  |   |       |-- consensus.63.fastq
  |   |       |-- consensus.75.fasta
  |   |       |-- consensus.75.fastq
  |   |       |-- consensus.88.fasta
  |   |       |-- consensus.88.fastq
  |   |       |-- masked-variants.10.gff
  |   |       |-- masked-variants.100.gff
  |   |       |-- masked-variants.15.gff
  |   |       |-- masked-variants.20.gff
  |   |       |-- masked-variants.30.gff
  |   |       |-- masked-variants.40.gff
  |   |       |-- masked-variants.5.gff
  |   |       |-- masked-variants.63.gff
  |   |       |-- masked-variants.75.gff
  |   |       |-- masked-variants.88.gff
  |   |       |-- variants.10.gff
  |   |       |-- variants.100.gff
  |   |       |-- variants.15.gff
  |   |       |-- variants.20.gff
  |   |       |-- variants.30.gff
  |   |       |-- variants.40.gff
  |   |       |-- variants.5.gff
  |   |       |-- variants.63.gff
  |   |       |-- variants.75.gff
  |   |       `-- variants.88.gff
  |   `-- MovieBZiaJob
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
  |       |-- reference.fasta
  |       |-- reference.fasta.fai
  |       |-- sts.h5
  |       |-- sts.xml
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
  |           |-- consensus.63.fasta
  |           |-- consensus.63.fastq
  |           |-- consensus.75.fasta
  |           |-- consensus.75.fastq
  |           |-- consensus.88.fasta
  |           |-- consensus.88.fastq
  |           |-- masked-variants.10.gff
  |           |-- masked-variants.100.gff
  |           |-- masked-variants.15.gff
  |           |-- masked-variants.20.gff
  |           |-- masked-variants.30.gff
  |           |-- masked-variants.40.gff
  |           |-- masked-variants.5.gff
  |           |-- masked-variants.63.gff
  |           |-- masked-variants.75.gff
  |           |-- masked-variants.88.gff
  |           |-- variants.10.gff
  |           |-- variants.100.gff
  |           |-- variants.15.gff
  |           |-- variants.20.gff
  |           |-- variants.30.gff
  |           |-- variants.40.gff
  |           |-- variants.5.gff
  |           |-- variants.63.gff
  |           |-- variants.75.gff
  |           `-- variants.88.gff
  |-- config.json
  |-- log
  |-- prefix.sh
  |-- reports
  |   `-- CoverageTitration
  |       |-- concordance-by-condition.png
  |       |-- coverage-diagnostic-plot.png
  |       |-- coverage-titration.csv
  |       `-- report.json
  |-- run.sh
  |-- scripts
  |   `-- R
  |       |-- Bauhaus2.R
  |       `-- coverageTitrationPlots.R
  |-- snakemake.log
  `-- workflow
      `-- Snakefile
  
  20 directories, 249 files
