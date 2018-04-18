Test execution of the masked mapping reports workflow on some very tiny
datasets. This test has been copied arrowTrainExecutionTest.t

  $ BH_ROOT=$TESTDIR/../../../

Generate Arrow training workflow, starting from subreads.

  $ bauhaus2 --no-smrtlink --noGrid generate -w MaskedArrowTraining -t ${BH_ROOT}/test/data/tiny-FY1679-training.csv -o masked-arrow-training
  Validation and input resolution succeeded.
  Generated runnable workflow to "masked-arrow-training"

  $ (cd masked-arrow-training && ./run.sh >/dev/null 2>&1)


  $ tree -I __pycache__ masked-arrow-training
  masked-arrow-training
  |-- conditions
  |   `-- FY1679
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
  |       |-- reference.fasta -> /pbi/dept/secondary/siv/references/scerevisiaeFY1679_pbi_Nov2017/sequence/scerevisiaeFY1679_pbi_Nov2017.fasta
  |       |-- reference.fasta.fai -> /pbi/dept/secondary/siv/references/scerevisiaeFY1679_pbi_Nov2017/sequence/scerevisiaeFY1679_pbi_Nov2017.fasta.fai
  |       |-- sts.h5 -> /home/dseifert/git/bauhaus2/bauhaus2/resources/extras/no_sts.h5
  |       |-- sts.xml -> /home/dseifert/git/bauhaus2/bauhaus2/resources/extras/no_sts.xml
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
  |-- condition-table.csv
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
  |       |-- cognate-extra-emission-rates.png
  |       |-- CT-transition-rates.png
  |       |-- GA-transition-rates.png
  |       |-- GC-transition-rates.png
  |       |-- GG-transition-rates.png
  |       |-- GT-transition-rates.png
  |       |-- match-emission-rates.png
  |       |-- non-cognate-extra-emission-rates.png
  |       |-- report.json
  |       |-- TA-transition-rates.png
  |       |-- TC-transition-rates.png
  |       |-- TG-transition-rates.png
  |       `-- TT-transition-rates.png
  |-- run.sh
  |-- scripts
  |   `-- R
  |       |-- arrowTraining.R
  |       `-- Bauhaus2.R
  |-- snakemake.log
  |-- training
  |   |-- FY1679.alignmentset.xml -> ../conditions/FY1679/mapped/mapped.alignmentset.xml
  |   |-- FY1679.alignmentset.xml.mask.gff -> /pbi/dept/consensus/bauhaus/genome-masks/scerevisiaeFY1679_pbi_Nov2017-mask.gff
  |   |-- FY1679.alignmentset.xml.ref.fa -> /pbi/dept/secondary/siv/references/scerevisiaeFY1679_pbi_Nov2017/sequence/scerevisiaeFY1679_pbi_Nov2017.fasta
  |   `-- FY1679.alignmentset.xml.ref.fa.fai -> /pbi/dept/secondary/siv/references/scerevisiaeFY1679_pbi_Nov2017/sequence/scerevisiaeFY1679_pbi_Nov2017.fasta.fai
  `-- workflow
      `-- Snakefile
  
  13 directories, 81 files
