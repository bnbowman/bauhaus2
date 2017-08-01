Test execution of the heatmaps workflow on some very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../../

Generate heatmaps workflow, starting from subreads.

  $ bauhaus2 --no-smrtlink --noGrid generate -w Heatmaps -t ${BH_ROOT}test/data/two-tiny-movies.csv -o heatmaps
  Validation and input resolution succeeded.
  Generated runnable workflow to "heatmaps"

  $ (cd heatmaps && ./run.sh >/dev/null 2>&1)


  $ tree -I __pycache__ heatmaps
  heatmaps
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
  |   |   |-- reference.fasta -> /pbi/dept/secondary/siv/references/pBR322_EcoRV/sequence/pBR322_EcoRV.fasta
  |   |   |-- reference.fasta.fai -> /pbi/dept/secondary/siv/references/pBR322_EcoRV/sequence/pBR322_EcoRV.fasta.fai
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
  |       |-- reference.fasta -> /pbi/dept/secondary/siv/references/pBR322_EcoRV/sequence/pBR322_EcoRV.fasta
  |       |-- reference.fasta.fai -> /pbi/dept/secondary/siv/references/pBR322_EcoRV/sequence/pBR322_EcoRV.fasta.fai
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
  |-- log
  |-- prefix.sh
  |-- reports
  |   `-- AlignmentBasedHeatmaps
  |       |-- Accuracy_Heatmap_MovieA.png
  |       |-- Accuracy_Heatmap_MovieB.png
  |       |-- AlnReadLenExtRange_Heatmap_MovieA.png
  |       |-- AlnReadLenExtRange_Heatmap_MovieB.png
  |       |-- AlnReadLen_Heatmap_MovieA.png
  |       |-- AlnReadLen_Heatmap_MovieB.png
  |       |-- AvgPolsPerZMW_Heatmap_MovieA.png
  |       |-- AvgPolsPerZMW_Heatmap_MovieB.png
  |       |-- Count_Heatmap_MovieA.png
  |       |-- Count_Heatmap_MovieB.png
  |       |-- DeletionRate_Heatmap_MovieA.png
  |       |-- DeletionRate_Heatmap_MovieB.png
  |       |-- InsertionRate_Heatmap_MovieA.png
  |       |-- InsertionRate_Heatmap_MovieB.png
  |       |-- MaxSubreadLenExtRange_Heatmap_MovieA.png
  |       |-- MaxSubreadLenExtRange_Heatmap_MovieB.png
  |       |-- MaxSubreadLenToAlnReadLenRatio_Heatmap_MovieA.png
  |       |-- MaxSubreadLenToAlnReadLenRatio_Heatmap_MovieB.png
  |       |-- MaxSubreadLen_Heatmap_MovieA.png
  |       |-- MaxSubreadLen_Heatmap_MovieB.png
  |       |-- MismatchRate_Heatmap_MovieA.png
  |       |-- MismatchRate_Heatmap_MovieB.png
  |       |-- Reference_Heatmap_MovieA.png
  |       |-- Reference_Heatmap_MovieB.png
  |       |-- SNR_A_Heatmap_MovieA.png
  |       |-- SNR_A_Heatmap_MovieB.png
  |       |-- SNR_C_Heatmap_MovieA.png
  |       |-- SNR_C_Heatmap_MovieB.png
  |       |-- SNR_G_Heatmap_MovieA.png
  |       |-- SNR_G_Heatmap_MovieB.png
  |       |-- SNR_T_Heatmap_MovieA.png
  |       |-- SNR_T_Heatmap_MovieB.png
  |       |-- Uniformity_histogram_MovieA.png
  |       |-- Uniformity_histogram_MovieB.png
  |       |-- Uniformity_metrics_MovieA.csv
  |       |-- Uniformity_metrics_MovieB.csv
  |       |-- barchart_of_uniformity.png
  |       |-- rEnd_Heatmap_MovieA.png
  |       |-- rEnd_Heatmap_MovieB.png
  |       |-- rStartExtRange_Heatmap_MovieA.png
  |       |-- rStartExtRange_Heatmap_MovieB.png
  |       |-- rStart_Heatmap_MovieA.png
  |       |-- rStart_Heatmap_MovieB.png
  |       |-- report.RData
  |       |-- report.json
  |       |-- tEnd_Heatmap_MovieA.png
  |       |-- tEnd_Heatmap_MovieB.png
  |       |-- tStart_Heatmap_MovieA.png
  |       `-- tStart_Heatmap_MovieB.png
  |-- run.sh
  |-- scripts
  |   `-- R
  |       |-- AlignmentBasedHeatmaps.R
  |       `-- Bauhaus2.R
  |-- snakemake.log
  `-- workflow
      `-- Snakefile
  
  17 directories, 149 files
