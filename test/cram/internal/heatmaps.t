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
  |   |-- AlignmentBasedHeatmaps
  |   |   |-- Accuracy_MovieA.png
  |   |   |-- Accuracy_MovieB.png
  |   |   |-- AlnReadLenExtRange_MovieA.png
  |   |   |-- AlnReadLenExtRange_MovieB.png
  |   |   |-- AlnReadLen_MovieA.png
  |   |   |-- AlnReadLen_MovieB.png
  |   |   |-- AvgPolsPerZMW_MovieA.png
  |   |   |-- AvgPolsPerZMW_MovieB.png
  |   |   |-- Count_MovieA.png
  |   |   |-- Count_MovieB.png
  |   |   |-- DeletionRate_MovieA.png
  |   |   |-- DeletionRate_MovieB.png
  |   |   |-- InsertionRate_MovieA.png
  |   |   |-- InsertionRate_MovieB.png
  |   |   |-- MaxSubreadLenExtRange_MovieA.png
  |   |   |-- MaxSubreadLenExtRange_MovieB.png
  |   |   |-- MaxSubreadLenToAlnReadLenRatio_MovieA.png
  |   |   |-- MaxSubreadLenToAlnReadLenRatio_MovieB.png
  |   |   |-- MaxSubreadLen_MovieA.png
  |   |   |-- MaxSubreadLen_MovieB.png
  |   |   |-- MismatchRate_MovieA.png
  |   |   |-- MismatchRate_MovieB.png
  |   |   |-- Reference_Heatmap_MovieA.png
  |   |   |-- Reference_Heatmap_MovieB.png
  |   |   |-- SNR_A_MovieA.png
  |   |   |-- SNR_A_MovieB.png
  |   |   |-- SNR_C_MovieA.png
  |   |   |-- SNR_C_MovieB.png
  |   |   |-- SNR_G_MovieA.png
  |   |   |-- SNR_G_MovieB.png
  |   |   |-- SNR_T_MovieA.png
  |   |   |-- SNR_T_MovieB.png
  |   |   |-- Uniformity_histogram_MovieA.png
  |   |   |-- Uniformity_histogram_MovieB.png
  |   |   |-- Uniformity_metrics_MovieA.csv
  |   |   |-- Uniformity_metrics_MovieB.csv
  |   |   |-- barchart_of_center_to_edge_p1.png
  |   |   |-- barchart_of_uniformity.png
  |   |   |-- rEnd_MovieA.png
  |   |   |-- rEnd_MovieB.png
  |   |   |-- rStartExtRange_MovieA.png
  |   |   |-- rStartExtRange_MovieB.png
  |   |   |-- rStart_MovieA.png
  |   |   |-- rStart_MovieB.png
  |   |   |-- report.RData
  |   |   |-- report.json
  |   |   |-- tEnd_MovieA.png
  |   |   |-- tEnd_MovieB.png
  |   |   |-- tStart_MovieA.png
  |   |   `-- tStart_MovieB.png
  |   `-- ZMWstsPlots
  |       |-- accuracy_by_readtype_boxplot.png
  |       |-- adapter_dimer_fraction.png
  |       |-- nzmws_productivity_hist_percentage.png
  |       |-- nzmws_readtype_hist_percentage.png
  |       |-- readTypeAgg.1.png
  |       |-- readTypeAgg.2.png
  |       |-- report.Rd
  |       |-- report.json
  |       |-- short_insert_fraction.png
  |       `-- unrolled_template_length_by_readtype_boxplot.png
  |-- run.sh
  |-- scripts
  |   `-- R
  |       |-- AlignmentBasedHeatmaps.R
  |       |-- Bauhaus2.R
  |       `-- ZMWstsPlots.R
  |-- snakemake.log
  `-- workflow
      `-- Snakefile
  
  18 directories, 161 files
