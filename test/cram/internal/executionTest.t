Test execution of the mapping reports workflow on some very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../../

Generate mapping reports workflow, starting from subreads.

  $ bauhaus2 --no-smrtlink --noGrid generate -w MappingReports -t ${BH_ROOT}test/data/two-tiny-movies-four-conditions-with-p.csv -o mapping-reports
  Validation and input resolution succeeded.
  Generated runnable workflow to "mapping-reports"

  $ (cd mapping-reports && ./run.sh >/dev/null 2>&1)


  $ tree -I __pycache__ mapping-reports
  mapping-reports
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
  |   |-- MovieB
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
  |   |-- MovieC
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
  |   `-- MovieD
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
  |   |   |-- Accuracy_MovieC.png
  |   |   |-- Accuracy_MovieD.png
  |   |   |-- AlnReadLenExtRange_MovieA.png
  |   |   |-- AlnReadLenExtRange_MovieB.png
  |   |   |-- AlnReadLenExtRange_MovieC.png
  |   |   |-- AlnReadLenExtRange_MovieD.png
  |   |   |-- AlnReadLen_MovieA.png
  |   |   |-- AlnReadLen_MovieB.png
  |   |   |-- AlnReadLen_MovieC.png
  |   |   |-- AlnReadLen_MovieD.png
  |   |   |-- AvgPolsPerZMW_MovieA.png
  |   |   |-- AvgPolsPerZMW_MovieB.png
  |   |   |-- AvgPolsPerZMW_MovieC.png
  |   |   |-- AvgPolsPerZMW_MovieD.png
  |   |   |-- Count_MovieA.png
  |   |   |-- Count_MovieB.png
  |   |   |-- Count_MovieC.png
  |   |   |-- Count_MovieD.png
  |   |   |-- DeletionRate_MovieA.png
  |   |   |-- DeletionRate_MovieB.png
  |   |   |-- DeletionRate_MovieC.png
  |   |   |-- DeletionRate_MovieD.png
  |   |   |-- InsertionRate_MovieA.png
  |   |   |-- InsertionRate_MovieB.png
  |   |   |-- InsertionRate_MovieC.png
  |   |   |-- InsertionRate_MovieD.png
  |   |   |-- MaxSubreadLenExtRange_MovieA.png
  |   |   |-- MaxSubreadLenExtRange_MovieB.png
  |   |   |-- MaxSubreadLenExtRange_MovieC.png
  |   |   |-- MaxSubreadLenExtRange_MovieD.png
  |   |   |-- MaxSubreadLenToAlnReadLenRatio_MovieA.png
  |   |   |-- MaxSubreadLenToAlnReadLenRatio_MovieB.png
  |   |   |-- MaxSubreadLenToAlnReadLenRatio_MovieC.png
  |   |   |-- MaxSubreadLenToAlnReadLenRatio_MovieD.png
  |   |   |-- MaxSubreadLen_MovieA.png
  |   |   |-- MaxSubreadLen_MovieB.png
  |   |   |-- MaxSubreadLen_MovieC.png
  |   |   |-- MaxSubreadLen_MovieD.png
  |   |   |-- MismatchRate_MovieA.png
  |   |   |-- MismatchRate_MovieB.png
  |   |   |-- MismatchRate_MovieC.png
  |   |   |-- MismatchRate_MovieD.png
  |   |   |-- Reference_Heatmap_MovieA.png
  |   |   |-- Reference_Heatmap_MovieB.png
  |   |   |-- Reference_Heatmap_MovieC.png
  |   |   |-- Reference_Heatmap_MovieD.png
  |   |   |-- SNR_A_MovieA.png
  |   |   |-- SNR_A_MovieB.png
  |   |   |-- SNR_A_MovieC.png
  |   |   |-- SNR_A_MovieD.png
  |   |   |-- SNR_C_MovieA.png
  |   |   |-- SNR_C_MovieB.png
  |   |   |-- SNR_C_MovieC.png
  |   |   |-- SNR_C_MovieD.png
  |   |   |-- SNR_G_MovieA.png
  |   |   |-- SNR_G_MovieB.png
  |   |   |-- SNR_G_MovieC.png
  |   |   |-- SNR_G_MovieD.png
  |   |   |-- SNR_T_MovieA.png
  |   |   |-- SNR_T_MovieB.png
  |   |   |-- SNR_T_MovieC.png
  |   |   |-- SNR_T_MovieD.png
  |   |   |-- Uniformity_histogram_MovieA.png
  |   |   |-- Uniformity_histogram_MovieB.png
  |   |   |-- Uniformity_histogram_MovieC.png
  |   |   |-- Uniformity_histogram_MovieD.png
  |   |   |-- Uniformity_metrics_MovieA.csv
  |   |   |-- Uniformity_metrics_MovieB.csv
  |   |   |-- Uniformity_metrics_MovieC.csv
  |   |   |-- Uniformity_metrics_MovieD.csv
  |   |   |-- barchart_of_uniformity.png
  |   |   |-- rEnd_MovieA.png
  |   |   |-- rEnd_MovieB.png
  |   |   |-- rEnd_MovieC.png
  |   |   |-- rEnd_MovieD.png
  |   |   |-- rStartExtRange_MovieA.png
  |   |   |-- rStartExtRange_MovieB.png
  |   |   |-- rStartExtRange_MovieC.png
  |   |   |-- rStartExtRange_MovieD.png
  |   |   |-- rStart_MovieA.png
  |   |   |-- rStart_MovieB.png
  |   |   |-- rStart_MovieC.png
  |   |   |-- rStart_MovieD.png
  |   |   |-- report.RData
  |   |   |-- report.json
  |   |   |-- tEnd_MovieA.png
  |   |   |-- tEnd_MovieB.png
  |   |   |-- tEnd_MovieC.png
  |   |   |-- tEnd_MovieD.png
  |   |   |-- tStart_MovieA.png
  |   |   |-- tStart_MovieB.png
  |   |   |-- tStart_MovieC.png
  |   |   `-- tStart_MovieD.png
  |   |-- ConstantArrowFishbonePlots
  |   |   |-- FishboneSnrBinnedSummary.csv
  |   |   |-- errormode.csv
  |   |   |-- fishboneplot_deletion.png
  |   |   |-- fishboneplot_deletion_enlarged.png
  |   |   |-- fishboneplot_insertion.png
  |   |   |-- fishboneplot_insertion_enlarged.png
  |   |   |-- fishboneplot_merge.png
  |   |   |-- fishboneplot_merge_enlarged.png
  |   |   |-- fishboneplot_mismatch.png
  |   |   |-- fishboneplot_mismatch_enlarged.png
  |   |   |-- mapped-metrics.csv
  |   |   |-- modelReport.json
  |   |   |-- report.Rd
  |   |   `-- report.json
  |   |-- LibDiagnosticPlots
  |   |   |-- MovieA_Tau_Estimates.csv
  |   |   |-- MovieB_Tau_Estimates.csv
  |   |   |-- MovieC_Tau_Estimates.csv
  |   |   |-- MovieD_Tau_Estimates.csv
  |   |   |-- cdf_astart.png
  |   |   |-- cdf_astart_log.png
  |   |   |-- cdf_hqlenmax.png
  |   |   |-- cdf_ratio.png
  |   |   |-- cdf_tlen.png
  |   |   |-- density_max.png
  |   |   |-- density_max_region.png
  |   |   |-- density_unroll.png
  |   |   |-- density_unroll_summation.png
  |   |   |-- first_pass_tau.png
  |   |   |-- hist_max.png
  |   |   |-- hist_unroll.png
  |   |   |-- long_library_metrics.csv
  |   |   |-- max_hqlen.png
  |   |   |-- max_subread_len_cdf_with_N50.png
  |   |   |-- max_subread_len_density.png
  |   |   |-- max_subread_len_survival.png
  |   |   |-- max_unrolled.png
  |   |   |-- maxt_unrolledt.png
  |   |   |-- nsubreads_ref_hist_percentage.png
  |   |   |-- report.Rd
  |   |   |-- report.json
  |   |   |-- subreads_ref_hist.png
  |   |   |-- sumtable.csv
  |   |   |-- template_span_ref_box.png
  |   |   |-- unrolled_ref_hist.png
  |   |   |-- unrolled_ref_hist_percentage.png
  |   |   |-- unrolled_template.png
  |   |   |-- unrolled_template_boxplot.png
  |   |   |-- unrolled_template_densityplot.png
  |   |   |-- unrolled_template_densityplot_summation.png
  |   |   `-- unrolled_template_log.png
  |   |-- LocAccPlots
  |   |   |-- LocAcc.MovieA.accuracy_scatter.png
  |   |   |-- LocAcc.MovieA.aln_cols.csv
  |   |   |-- LocAcc.MovieA.core.csv
  |   |   |-- LocAcc.MovieA.delta_confusion.png
  |   |   |-- LocAcc.MovieA.error_counts.csv
  |   |   |-- LocAcc.MovieA.high_confusion.png
  |   |   |-- LocAcc.MovieA.hqerr_cumulative_duration_histogram.png
  |   |   |-- LocAcc.MovieA.hqerr_duration_histogram.png
  |   |   |-- LocAcc.MovieA.hqerr_reverse_cumulative_duration_histogram.png
  |   |   |-- LocAcc.MovieA.hqerrlens.csv
  |   |   |-- LocAcc.MovieA.local_accuracies.csv
  |   |   |-- LocAcc.MovieA.low_confusion.png
  |   |   |-- LocAcc.MovieA.mask.csv
  |   |   |-- LocAcc.MovieA.read_bases.csv
  |   |   |-- LocAcc.MovieA.template_bases.csv
  |   |   |-- LocAcc.MovieB.accuracy_scatter.png
  |   |   |-- LocAcc.MovieB.aln_cols.csv
  |   |   |-- LocAcc.MovieB.core.csv
  |   |   |-- LocAcc.MovieB.delta_confusion.png
  |   |   |-- LocAcc.MovieB.error_counts.csv
  |   |   |-- LocAcc.MovieB.high_confusion.png
  |   |   |-- LocAcc.MovieB.hqerr_cumulative_duration_histogram.png
  |   |   |-- LocAcc.MovieB.hqerr_duration_histogram.png
  |   |   |-- LocAcc.MovieB.hqerr_reverse_cumulative_duration_histogram.png
  |   |   |-- LocAcc.MovieB.hqerrlens.csv
  |   |   |-- LocAcc.MovieB.local_accuracies.csv
  |   |   |-- LocAcc.MovieB.low_confusion.png
  |   |   |-- LocAcc.MovieB.mask.csv
  |   |   |-- LocAcc.MovieB.read_bases.csv
  |   |   |-- LocAcc.MovieB.template_bases.csv
  |   |   |-- LocAcc.MovieC.accuracy_scatter.png
  |   |   |-- LocAcc.MovieC.aln_cols.csv
  |   |   |-- LocAcc.MovieC.core.csv
  |   |   |-- LocAcc.MovieC.delta_confusion.png
  |   |   |-- LocAcc.MovieC.error_counts.csv
  |   |   |-- LocAcc.MovieC.high_confusion.png
  |   |   |-- LocAcc.MovieC.hqerr_cumulative_duration_histogram.png
  |   |   |-- LocAcc.MovieC.hqerr_duration_histogram.png
  |   |   |-- LocAcc.MovieC.hqerr_reverse_cumulative_duration_histogram.png
  |   |   |-- LocAcc.MovieC.hqerrlens.csv
  |   |   |-- LocAcc.MovieC.local_accuracies.csv
  |   |   |-- LocAcc.MovieC.low_confusion.png
  |   |   |-- LocAcc.MovieC.mask.csv
  |   |   |-- LocAcc.MovieC.read_bases.csv
  |   |   |-- LocAcc.MovieC.template_bases.csv
  |   |   |-- LocAcc.MovieD.accuracy_scatter.png
  |   |   |-- LocAcc.MovieD.aln_cols.csv
  |   |   |-- LocAcc.MovieD.core.csv
  |   |   |-- LocAcc.MovieD.delta_confusion.png
  |   |   |-- LocAcc.MovieD.error_counts.csv
  |   |   |-- LocAcc.MovieD.high_confusion.png
  |   |   |-- LocAcc.MovieD.hqerr_cumulative_duration_histogram.png
  |   |   |-- LocAcc.MovieD.hqerr_duration_histogram.png
  |   |   |-- LocAcc.MovieD.hqerr_reverse_cumulative_duration_histogram.png
  |   |   |-- LocAcc.MovieD.hqerrlens.csv
  |   |   |-- LocAcc.MovieD.local_accuracies.csv
  |   |   |-- LocAcc.MovieD.low_confusion.png
  |   |   |-- LocAcc.MovieD.mask.csv
  |   |   |-- LocAcc.MovieD.read_bases.csv
  |   |   |-- LocAcc.MovieD.template_bases.csv
  |   |   |-- LocAcc.accuracy_delta_densities.png
  |   |   |-- LocAcc.binomlocacc_boxes.png
  |   |   |-- LocAcc.canonglobacc_boxes.png
  |   |   |-- LocAcc.filt_glob_acc_densities.png
  |   |   |-- LocAcc.filtglobacc_boxes.png
  |   |   |-- LocAcc.filtglobacc_snr_scatter.png
  |   |   |-- LocAcc.glob_acc_densities.png
  |   |   |-- LocAcc.globacc_boxes.png
  |   |   |-- LocAcc.globacc_snr_scatter.png
  |   |   |-- LocAcc.hqerr_duration_boxplot.png
  |   |   |-- LocAcc.hqerr_fraction_boxplot.png
  |   |   |-- LocAcc.hqerr_frequency_boxplot.png
  |   |   |-- LocAcc.locacc_boxes.png
  |   |   |-- LocAcc.localacc_densities.png
  |   |   |-- LocAcc.nDelrate_snr_scatter.png
  |   |   |-- LocAcc.nInsrate_snr_scatter.png
  |   |   |-- LocAcc.nMMrate_snr_scatter.png
  |   |   |-- LocAcc.refloss_bars.png
  |   |   |-- LocAcc.yield_bars.png
  |   |   |-- LocAcc.yieldloss_bars.png
  |   |   `-- report.json
  |   |-- PbiPlots
  |   |   |-- acc_accvrl.png
  |   |   |-- acc_accvtl.png
  |   |   |-- acc_density.png
  |   |   |-- alen_density.png
  |   |   |-- alen_v_qlen.png
  |   |   |-- aligned_read_length_survival\ (Log-scale).png
  |   |   |-- aligned_read_length_survival.png
  |   |   |-- base_count_bar.png
  |   |   |-- etype__drate_boxplot.png
  |   |   |-- etype__irate_boxplot.png
  |   |   |-- etype__mmrate_boxplot.png
  |   |   |-- nreads_hist.png
  |   |   |-- report.Rd
  |   |   |-- report.json
  |   |   |-- sumtable.csv
  |   |   |-- template_span_survival\ (Log-scale).png
  |   |   |-- template_span_survival.png
  |   |   |-- tlen_box.png
  |   |   `-- tlen_density.png
  |   |-- PbiSampledPlots
  |   |   |-- bperr_rate_by_snr.png
  |   |   |-- bpmm_rate_by_snr.png
  |   |   |-- dutycycle_boxplot.png
  |   |   |-- ipddistbybase_boxplot.png
  |   |   |-- localpolrate_boxplot.png
  |   |   |-- mean_pw_boxplot_by_base.png
  |   |   |-- medianAccuracyvsp_Enzbyp_LP.png
  |   |   |-- medianIPD.csv
  |   |   |-- medianPolymerizationRate.csv
  |   |   |-- medianSNR.csv
  |   |   |-- median_pw_boxplot_by_base.png
  |   |   |-- medianalenvsp_Enzbyp_LP.png
  |   |   |-- mediandratevsp_Enzbyp_LP.png
  |   |   |-- medianiratevsp_Enzbyp_LP.png
  |   |   |-- medianmmratevsp_Enzbyp_LP.png
  |   |   |-- mediansnrCvsp_Enzbyp_LP.png
  |   |   |-- mediantlenvsp_Enzbyp_LP.png
  |   |   |-- noninternalBAM.csv
  |   |   |-- polrate_ref_box.png
  |   |   |-- polrate_template_per_second.png
  |   |   |-- pw_boxplot.png
  |   |   |-- pw_by_template.png
  |   |   |-- pw_by_template_cdf.png
  |   |   |-- report.Rd
  |   |   |-- report.json
  |   |   |-- snrBoxNoViolin.png
  |   |   |-- snrDensity.png
  |   |   |-- snrvsacc.png
  |   |   |-- snrvsdeletion.png
  |   |   |-- snrvsindelrat.png
  |   |   |-- snrvsinsertion.png
  |   |   `-- snrvsmismatch.png
  |   |-- ReadPlots
  |   |   |-- clip_rate.png
  |   |   |-- deletion_norm.png
  |   |   |-- deletion_rate.png
  |   |   |-- deletion_size_log.png
  |   |   |-- insert_size_log.png
  |   |   |-- insert_size_norm.png
  |   |   |-- insertion_rate.png
  |   |   |-- mismatch_rate.png
  |   |   |-- report.Rd
  |   |   `-- report.json
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
  |   |-- Python
  |   |   `-- MakeMappingMetricsCsv.py
  |   `-- R
  |       |-- AlignmentBasedHeatmaps.R
  |       |-- Bauhaus2.R
  |       |-- FishbonePlots.R
  |       |-- LibDiagnosticPlots.R
  |       |-- PbiPlots.R
  |       |-- PbiSampledPlots.R
  |       |-- ReadPlots.R
  |       |-- ZMWstsPlots.R
  |       `-- constant_arrow.R
  |-- snakemake.log
  `-- workflow
      `-- Snakefile
  
  35 directories, 497 files






  $ cat mapping-reports/reports/PbiSampledPlots/report.json
  {
    "plots": [
      {
        "id": "snr_density",
        "image": "snrDensity.png",
        "title": "SNR Density Plot",
        "caption": "Distribution of SNR in Aligned Files (Density plot)",
        "tags": ["sampled", "snr", "density"]
      },
      {
        "id": "snr_boxplot",
        "image": "snrBoxNoViolin.png",
        "title": "SNR Box Plot",
        "caption": "Distribution of SNR in Aligned Files (Boxplot)",
        "tags": ["sampled", "snr", "boxplot"]
      },
      {
        "id": "mediantlenvsp_Enzbyp_LP",
        "image": "mediantlenvsp_Enzbyp_LP.png",
        "title": "Median of tlen vs p_Enz grouped by p_LP",
        "caption": "Median Template Length vs p_Enz grouped by p_LP",
        "tags": ["sampled", "p_", "titration", "median", "tlen"]
      },
      {
        "id": "medianalenvsp_Enzbyp_LP",
        "image": "medianalenvsp_Enzbyp_LP.png",
        "title": "Median of alen vs p_Enz grouped by p_LP",
        "caption": "Median Template Length vs p_Enz grouped by p_LP",
        "tags": ["sampled", "p_", "titration", "median", "alen"]
      },
      {
        "id": "medianAccuracyvsp_Enzbyp_LP",
        "image": "medianAccuracyvsp_Enzbyp_LP.png",
        "title": "Median of Accuracy vs p_Enz grouped by p_LP",
        "caption": "Median Template Length vs p_Enz grouped by p_LP",
        "tags": ["sampled", "p_", "titration", "median", "Accuracy"]
      },
      {
        "id": "medianiratevsp_Enzbyp_LP",
        "image": "medianiratevsp_Enzbyp_LP.png",
        "title": "Median of irate vs p_Enz grouped by p_LP",
        "caption": "Median Template Length vs p_Enz grouped by p_LP",
        "tags": ["sampled", "p_", "titration", "median", "irate"]
      },
      {
        "id": "mediandratevsp_Enzbyp_LP",
        "image": "mediandratevsp_Enzbyp_LP.png",
        "title": "Median of drate vs p_Enz grouped by p_LP",
        "caption": "Median Template Length vs p_Enz grouped by p_LP",
        "tags": ["sampled", "p_", "titration", "median", "drate"]
      },
      {
        "id": "medianmmratevsp_Enzbyp_LP",
        "image": "medianmmratevsp_Enzbyp_LP.png",
        "title": "Median of mmrate vs p_Enz grouped by p_LP",
        "caption": "Median Template Length vs p_Enz grouped by p_LP",
        "tags": ["sampled", "p_", "titration", "median", "mmrate"]
      },
      {
        "id": "mediansnrCvsp_Enzbyp_LP",
        "image": "mediansnrCvsp_Enzbyp_LP.png",
        "title": "Median of snrC vs p_Enz grouped by p_LP",
        "caption": "Median Template Length vs p_Enz grouped by p_LP",
        "tags": ["sampled", "p_", "titration", "median", "snrC"]
      },
      {
        "id": "snr_vs_acc",
        "image": "snrvsacc.png",
        "title": "SNR vs Accuracy",
        "caption": "SNR vs. Accuracy",
        "tags": ["sampled", "snr", "accuracy"]
      },
      {
        "id": "snr_vs_ins",
        "image": "snrvsinsertion.png",
        "title": "SNR vs Insertion Rate",
        "caption": "SNR vs. Insertion Rate",
        "tags": ["sampled", "snr", "insertion"]
      },
      {
        "id": "snr_vs_del",
        "image": "snrvsdeletion.png",
        "title": "SNR vs Deletion Rate",
        "caption": "SNR vs. Deletion Rate",
        "tags": ["sampled", "snr", "deletion"]
      },
      {
        "id": "snr_vs_mm",
        "image": "snrvsmismatch.png",
        "title": "SNR vs Mismatch Rate",
        "caption": "SNR vs. Mismatch Rate",
        "tags": ["sampled", "snr", "mismatch"]
      },
      {
        "id": "snr_vs_indel_rat",
        "image": "snrvsindelrat.png",
        "title": "SNR vs Relative Indels",
        "caption": "SNR vs. Indel Rate / Deletion Rate",
        "tags": ["sampled", "snr", "deletion"]
      },
      {
        "id": "polrate_template_per_second",
        "image": "polrate_template_per_second.png",
        "title": "Polymerization Rate (template bases per second)",
        "caption": "Polymerization Rate (template bases per second)",
        "tags": ["sampled", "boxplot", "polrate", "template", "time"]
      },
      {
        "id": "polrate_ref_box",
        "image": "polrate_ref_box.png",
        "title": "Polymerization Rate by Reference",
        "caption": "Polymerization Rate by Reference",
        "tags": ["sampled", "boxplot", "polrate", "reference"]
      },
      {
        "id": "pw_by_template.png",
        "image": "pw_by_template.png",
        "title": "Pulse Width by Template Base",
        "caption": "Pulse Width by Template Base",
        "tags": ["sampled", "density", "pw"]
      },
      {
        "id": "pw_by_template_cdf.png",
        "image": "pw_by_template_cdf.png",
        "title": "Pulse Width by Template Base (CDF)",
        "caption": "Pulse Width by Template Base (CDF)",
        "tags": ["sampled", "pw", "cdf"]
      },
      {
        "id": "ipd_boxplot_by_base",
        "image": "ipddistbybase_boxplot.png",
        "title": "IPD Distribution by Ref Base - Boxplot",
        "caption": "IPD Distribution by Ref Base - Boxplot",
        "tags": ["sampled", "boxplot", "ipd"]
      },
      {
        "id": "pw_boxplot",
        "image": "pw_boxplot.png",
        "title": "PW Distribution - Boxplot",
        "caption": "PW Distribution - Boxplot",
        "tags": ["sampled", "boxplot", "pw"]
      },
      {
        "id": "median_pw_boxplot_by_base",
        "image": "median_pw_boxplot_by_base.png",
        "title": "Median PW Distribution By Base",
        "caption": "Median PW Distribution",
        "tags": ["sampled", "pw", "boxplot", "median"]
      },
      {
        "id": "mean_pw_boxplot_by_base",
        "image": "mean_pw_boxplot_by_base.png",
        "title": "Mean PW Distribution By Base",
        "caption": "Mean PW Distribution",
        "tags": ["sampled", "pw", "boxplot", "mean"]
      },
      {
        "id": "dutycycle_boxplot",
        "image": "dutycycle_boxplot.png",
        "title": "Duty Cycle - Boxplot",
        "caption": "Duty Cycle - Boxplot",
        "tags": ["sampled", "boxplot", "duty cycle"]
      },
      {
        "id": "localpolrate_boxplot",
        "image": "localpolrate_boxplot.png",
        "title": "Local PolRate - Boxplot",
        "caption": "Local PolRate - Boxplot",
        "tags": ["sampled", "boxplot", "polrate"]
      },
      {
        "id": "bp_err_rate_by_snr",
        "image": "bperr_rate_by_snr.png",
        "title": "BP Error Rates by SNR",
        "caption": "BP Error Rates by SNR",
        "tags": ["sampled", "error rate", "base"]
      },
      {
        "id": "bp_mm_err_rate_by_snr",
        "image": "bpmm_rate_by_snr.png",
        "title": "Mismatch Rates by SNR",
        "caption": "Mismatch Rates by SNR",
        "tags": ["sampled", "mismatch", "error rate"]
      }
    ],
    "tables": [
      {
        "id": "noninternalBAM",
        "csv": "noninternalBAM.csv",
        "title": "Missing plots that require internal BAM files",
        "tags": []
      },
      {
        "id": "medianIPD",
        "csv": "medianIPD.csv",
        "title": "Median IPD/PW Values by Reference",
        "tags": []
      },
      {
        "id": "medianPolymerizationRate",
        "csv": "medianPolymerizationRate.csv",
        "title": "Median Polymerization Rate",
        "tags": []
      },
      {
        "id": "medianSNR",
        "csv": "medianSNR.csv",
        "title": "Median SNR values",
        "tags": []
      }
    ]
  }
