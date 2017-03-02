Test execution of the constant arrow workflow on some very tiny
datasets. 

  $ BH_ROOT=$TESTDIR/../../../

Generate constant arrow workflow, starting from subreads.

  $ bauhaus2 --noGrid generate -w ConstantArrow -t ${BH_ROOT}test/data/two-tiny-movies.csv -o constant-arrow
  Validation and input resolution succeeded.
  Generated runnable workflow to "constant-arrow"

  $ (cd constant-arrow && ./run.sh >/dev/null 2>&1)


  $ tree -I __pycache__ constant-arrow
  constant-arrow
  |-- condition-table.csv
  |-- conditions
  |   |-- MovieA
  |   |   |-- mapped
  |   |   |   `-- mapped.alignmentset.xml
  |   |   |-- mapped_chunks
  |   |   |   |-- mapped.chunk0.alignmentset.bam
  |   |   |   |-- mapped.chunk0.alignmentset.bam.bai
  |   |   |   |-- mapped.chunk0.alignmentset.bam.pbi
  |   |   |   |-- mapped.chunk0.alignmentset.xml
  |   |   |   |-- mapped.chunk1.alignmentset.bam
  |   |   |   |-- mapped.chunk1.alignmentset.bam.bai
  |   |   |   |-- mapped.chunk1.alignmentset.bam.pbi
  |   |   |   |-- mapped.chunk1.alignmentset.xml
  |   |   |   |-- mapped.chunk2.alignmentset.bam
  |   |   |   |-- mapped.chunk2.alignmentset.bam.bai
  |   |   |   |-- mapped.chunk2.alignmentset.bam.pbi
  |   |   |   |-- mapped.chunk2.alignmentset.xml
  |   |   |   |-- mapped.chunk3.alignmentset.bam
  |   |   |   |-- mapped.chunk3.alignmentset.bam.bai
  |   |   |   |-- mapped.chunk3.alignmentset.bam.pbi
  |   |   |   |-- mapped.chunk3.alignmentset.xml
  |   |   |   |-- mapped.chunk4.alignmentset.bam
  |   |   |   |-- mapped.chunk4.alignmentset.bam.bai
  |   |   |   |-- mapped.chunk4.alignmentset.bam.pbi
  |   |   |   |-- mapped.chunk4.alignmentset.xml
  |   |   |   |-- mapped.chunk5.alignmentset.bam
  |   |   |   |-- mapped.chunk5.alignmentset.bam.bai
  |   |   |   |-- mapped.chunk5.alignmentset.bam.pbi
  |   |   |   |-- mapped.chunk5.alignmentset.xml
  |   |   |   |-- mapped.chunk6.alignmentset.bam
  |   |   |   |-- mapped.chunk6.alignmentset.bam.bai
  |   |   |   |-- mapped.chunk6.alignmentset.bam.pbi
  |   |   |   |-- mapped.chunk6.alignmentset.xml
  |   |   |   |-- mapped.chunk7.alignmentset.bam
  |   |   |   |-- mapped.chunk7.alignmentset.bam.bai
  |   |   |   |-- mapped.chunk7.alignmentset.bam.pbi
  |   |   |   `-- mapped.chunk7.alignmentset.xml
  |   |   |-- reference.fasta -> /mnt/secondary/iSmrtanalysis/current/common/references/pBR322_EcoRV/sequence/pBR322_EcoRV.fasta
  |   |   |-- reference.fasta.fai -> /mnt/secondary/iSmrtanalysis/current/common/references/pBR322_EcoRV/sequence/pBR322_EcoRV.fasta.fai
  |   |   |-- subreads
  |   |   |   `-- input.subreadset.xml
  |   |   `-- subreads_chunks
  |   |       |-- input.chunk0.subreadset.xml
  |   |       |-- input.chunk1.subreadset.xml
  |   |       |-- input.chunk2.subreadset.xml
  |   |       |-- input.chunk3.subreadset.xml
  |   |       |-- input.chunk4.subreadset.xml
  |   |       |-- input.chunk5.subreadset.xml
  |   |       |-- input.chunk6.subreadset.xml
  |   |       `-- input.chunk7.subreadset.xml
  |   `-- MovieB
  |       |-- mapped
  |       |   `-- mapped.alignmentset.xml
  |       |-- mapped_chunks
  |       |   |-- mapped.chunk0.alignmentset.bam
  |       |   |-- mapped.chunk0.alignmentset.bam.bai
  |       |   |-- mapped.chunk0.alignmentset.bam.pbi
  |       |   |-- mapped.chunk0.alignmentset.xml
  |       |   |-- mapped.chunk1.alignmentset.bam
  |       |   |-- mapped.chunk1.alignmentset.bam.bai
  |       |   |-- mapped.chunk1.alignmentset.bam.pbi
  |       |   |-- mapped.chunk1.alignmentset.xml
  |       |   |-- mapped.chunk2.alignmentset.bam
  |       |   |-- mapped.chunk2.alignmentset.bam.bai
  |       |   |-- mapped.chunk2.alignmentset.bam.pbi
  |       |   |-- mapped.chunk2.alignmentset.xml
  |       |   |-- mapped.chunk3.alignmentset.bam
  |       |   |-- mapped.chunk3.alignmentset.bam.bai
  |       |   |-- mapped.chunk3.alignmentset.bam.pbi
  |       |   |-- mapped.chunk3.alignmentset.xml
  |       |   |-- mapped.chunk4.alignmentset.bam
  |       |   |-- mapped.chunk4.alignmentset.bam.bai
  |       |   |-- mapped.chunk4.alignmentset.bam.pbi
  |       |   |-- mapped.chunk4.alignmentset.xml
  |       |   |-- mapped.chunk5.alignmentset.bam
  |       |   |-- mapped.chunk5.alignmentset.bam.bai
  |       |   |-- mapped.chunk5.alignmentset.bam.pbi
  |       |   |-- mapped.chunk5.alignmentset.xml
  |       |   |-- mapped.chunk6.alignmentset.bam
  |       |   |-- mapped.chunk6.alignmentset.bam.bai
  |       |   |-- mapped.chunk6.alignmentset.bam.pbi
  |       |   |-- mapped.chunk6.alignmentset.xml
  |       |   |-- mapped.chunk7.alignmentset.bam
  |       |   |-- mapped.chunk7.alignmentset.bam.bai
  |       |   |-- mapped.chunk7.alignmentset.bam.pbi
  |       |   `-- mapped.chunk7.alignmentset.xml
  |       |-- reference.fasta -> /mnt/secondary/iSmrtanalysis/current/common/references/pBR322_EcoRV/sequence/pBR322_EcoRV.fasta
  |       |-- reference.fasta.fai -> /mnt/secondary/iSmrtanalysis/current/common/references/pBR322_EcoRV/sequence/pBR322_EcoRV.fasta.fai
  |       |-- subreads
  |       |   `-- input.subreadset.xml
  |       `-- subreads_chunks
  |           |-- input.chunk0.subreadset.xml
  |           |-- input.chunk1.subreadset.xml
  |           |-- input.chunk2.subreadset.xml
  |           |-- input.chunk3.subreadset.xml
  |           |-- input.chunk4.subreadset.xml
  |           |-- input.chunk5.subreadset.xml
  |           |-- input.chunk6.subreadset.xml
  |           `-- input.chunk7.subreadset.xml
  |-- config.json
  |-- log
  |-- prefix.sh
  |-- reports
  |   |-- errormode.csv
  |   |-- report.json
  |   `-- report.Rd
  |-- run.sh
  |-- scripts
  |   `-- R
  |       |-- Bauhaus2.R
  |       `-- constant_arrow.R
  |-- snakemake.log
  `-- workflow
      |-- Snakefile
      |-- runtime.py
      `-- stdlib.py
  
  16 directories, 102 files






  $ cat constant-arrow/reports/report.json
{
  "plots": [],
  "tables": [
    {
      "id": "errormode",
      "csv": "errormode.csv",
      "title": "Constant Arrow Errormode",
      "tags": []
    }
  ]
}
