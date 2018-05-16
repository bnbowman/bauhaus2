Test execution of the mapping reports workflow on some very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../../

Generate Arrow training workflow, starting from subreads.

  $ bauhaus2 --no-smrtlink --noGrid generate -w ArrowTraining -t ${BH_ROOT}test/data/two-tiny-movies-unrolled.csv -o arrow-training
  Validation and input resolution succeeded.
  Generated runnable workflow to "arrow-training"

  $ (cd arrow-training && ./run.sh >/dev/null 2>&1)


  $ tree -I __pycache__ arrow-training
  arrow-training
  |-- benchmarks
  |   |-- MovieA_0_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieA_1_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieA_2_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieA_3_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieA_4_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieA_5_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieA_6_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieA_7_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieA_chunk_subreads_one_condition.tsv
  |   |-- MovieA_map_chunked_subreads_and_gather_one_condition.tsv
  |   |-- MovieB_0_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieB_1_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieB_2_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieB_3_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieB_4_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieB_5_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieB_6_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieB_7_map_chunked_subreads_one_chunk.tsv
  |   |-- MovieB_chunk_subreads_one_condition.tsv
  |   |-- MovieB_map_chunked_subreads_and_gather_one_condition.tsv
  |   `-- arrow_training.tsv
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
  |   |   |-- reference.fasta -> /pbi/dept/secondary/siv/references/R_palustris_CGA009_pBR322_plasmidbell_4361bp_circular_6x_l52872/sequence/R_palustris_CGA009_pBR322_plasmidbell_4361bp_circular_6x_l52872.fasta
  |   |   |-- reference.fasta.fai -> /pbi/dept/secondary/siv/references/R_palustris_CGA009_pBR322_plasmidbell_4361bp_circular_6x_l52872/sequence/R_palustris_CGA009_pBR322_plasmidbell_4361bp_circular_6x_l52872.fasta.fai
  |   |   |-- sts.h5 -> .*/bauhaus2/resources/extras/no_sts.h5 (re)
  |   |   |-- sts.xml -> .*/bauhaus2/resources/extras/no_sts.xml (re)
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
  |       |-- reference.fasta -> /pbi/dept/secondary/siv/references/R_palustris_CGA009_pBR322_plasmidbell_4361bp_circular_6x_l52872/sequence/R_palustris_CGA009_pBR322_plasmidbell_4361bp_circular_6x_l52872.fasta
  |       |-- reference.fasta.fai -> /pbi/dept/secondary/siv/references/R_palustris_CGA009_pBR322_plasmidbell_4361bp_circular_6x_l52872/sequence/R_palustris_CGA009_pBR322_plasmidbell_4361bp_circular_6x_l52872.fasta.fai
  |       |-- sts.h5 -> .*/bauhaus2/resources/extras/no_sts.h5 (re)
  |       |-- sts.xml -> .*/bauhaus2/resources/extras/no_sts.xml (re)
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
  |-- fit.cpp
  |-- fit.json
  |-- fit.rda
  |-- log
  |-- prefix.sh
  |-- reports
  |   `-- ArrowTraining
  |       |-- AA-transition-rates.png
  |       |-- AC-transition-rates.png
  |       |-- AG-transition-rates.png
  |       |-- AT-transition-rates.png
  |       |-- CA-transition-rates.png
  |       |-- CC-transition-rates.png
  |       |-- CG-transition-rates.png
  |       |-- CT-transition-rates.png
  |       |-- GA-transition-rates.png
  |       |-- GC-transition-rates.png
  |       |-- GG-transition-rates.png
  |       |-- GT-transition-rates.png
  |       |-- TA-transition-rates.png
  |       |-- TC-transition-rates.png
  |       |-- TG-transition-rates.png
  |       |-- TT-transition-rates.png
  |       |-- cognate-extra-emission-rates.png
  |       |-- match-emission-rates.png
  |       |-- non-cognate-extra-emission-rates.png
  |       `-- report.json
  |-- run.sh
  |-- scripts
  |   `-- R
  |       |-- Bauhaus2.R
  |       `-- arrowTraining.R
  |-- snakemake.log
  |-- training
  |   |-- MovieA.alignmentset.xml -> ../conditions/MovieA/mapped/mapped.alignmentset.xml
  |   |-- MovieA.alignmentset.xml.ref.fa -> /pbi/dept/secondary/siv/references/R_palustris_CGA009_pBR322_plasmidbell_4361bp_circular_6x_l52872/sequence/R_palustris_CGA009_pBR322_plasmidbell_4361bp_circular_6x_l52872.fasta
  |   |-- MovieA.alignmentset.xml.ref.fa.fai -> /pbi/dept/secondary/siv/references/R_palustris_CGA009_pBR322_plasmidbell_4361bp_circular_6x_l52872/sequence/R_palustris_CGA009_pBR322_plasmidbell_4361bp_circular_6x_l52872.fasta.fai
  |   |-- MovieB.alignmentset.xml -> ../conditions/MovieB/mapped/mapped.alignmentset.xml
  |   |-- MovieB.alignmentset.xml.ref.fa -> /pbi/dept/secondary/siv/references/R_palustris_CGA009_pBR322_plasmidbell_4361bp_circular_6x_l52872/sequence/R_palustris_CGA009_pBR322_plasmidbell_4361bp_circular_6x_l52872.fasta
  |   `-- MovieB.alignmentset.xml.ref.fa.fai -> /pbi/dept/secondary/siv/references/R_palustris_CGA009_pBR322_plasmidbell_4361bp_circular_6x_l52872/sequence/R_palustris_CGA009_pBR322_plasmidbell_4361bp_circular_6x_l52872.fasta.fai
  `-- workflow
      `-- Snakefile
  
  19 directories, 150 files
