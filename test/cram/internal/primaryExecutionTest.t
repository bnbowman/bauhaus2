Test execution of the mapping reports workflow on some very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../../

Generate mapping reports workflow, starting from trace files and basecallers

  $ bauhaus2 --no-smrtlink --noGrid generate -w PrimaryRefarm -t ${BH_ROOT}test/data/two-tiny-primary-refarms-hq-adapters-1k-nobam2bam.csv -o primary-refarm
  Validation and input resolution succeeded.
  Generated runnable workflow to "primary-refarm"

  $ (cd primary-refarm && ./run.sh >/dev/null 2>&1)


  $ tree -I __pycache__ primary-refarm
  primary-refarm
  |-- condition-table.csv
  |-- conditions
  |   |-- HQLib
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
  |   |   |-- primary
  |   |   |   |-- input.adapters.fasta -> /pbi/dept/itg/test-data/pbi/collections/323/3230043/r54011_20170509_182922/1_D01/m54011_170509_185953.adapters.fasta
  |   |   |   |-- input.baz
  |   |   |   |-- input.baz2bam_1.log
  |   |   |   |-- input.metadata.xml -> /pbi/dept/itg/test-data/pbi/collections/323/3230043/r54011_20170509_182922/1_D01/.m54011_170509_185953.metadata.xml
  |   |   |   |-- input.scraps.bam
  |   |   |   |-- input.scraps.bam.pbi
  |   |   |   |-- input.sts.h5
  |   |   |   |-- input.sts.xml
  |   |   |   |-- input.subreads.bam
  |   |   |   |-- input.subreads.bam.pbi
  |   |   |   |-- input.subreadset.xml
  |   |   |   `-- input.trc.h5 -> /pbi/dept/itg/test-data/pbi/collections/323/3230043/r54011_20170509_182922/1_D01/m54011_170509_185953.trc.h5
  |   |   |-- reference.fasta -> /pbi/dept/secondary/siv/references/11k_pbell_H1_6_ScaI/sequence/11k_pbell_H1_6_ScaI.fasta
  |   |   |-- reference.fasta.fai -> /pbi/dept/secondary/siv/references/11k_pbell_H1_6_ScaI/sequence/11k_pbell_H1_6_ScaI.fasta.fai
  |   |   |-- sts.h5 -> /home/UNIXHOME/mdsmith/Bitbucket/bauhaus2/bauhaus2/resources/extras/no_sts.h5
  |   |   |-- sts.xml -> /home/UNIXHOME/mdsmith/Bitbucket/bauhaus2/bauhaus2/resources/extras/no_sts.xml
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
  |   |       |-- input.adapters.fasta
  |   |       |-- input.scraps.bam
  |   |       |-- input.scraps.bam.pbi
  |   |       |-- input.sts.xml
  |   |       |-- input.subreads.bam
  |   |       |-- input.subreads.bam.pbi
  |   |       `-- input.subreadset.xml
  |   |-- HQunrolled
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
  |   |   |-- primary
  |   |   |   |-- input.adapters.fasta -> /pbi/dept/itg/test-data/pbi/collections/323/3230043/r54011_20170509_182922/1_D01/m54011_170509_185953.adapters.fasta
  |   |   |   |-- input.baz
  |   |   |   |-- input.baz2bam_1.log
  |   |   |   |-- input.metadata.xml -> /pbi/dept/itg/test-data/pbi/collections/323/3230043/r54011_20170509_182922/1_D01/.m54011_170509_185953.metadata.xml
  |   |   |   |-- input.scraps.bam
  |   |   |   |-- input.scraps.bam.pbi
  |   |   |   |-- input.sts.h5
  |   |   |   |-- input.sts.xml
  |   |   |   |-- input.subreads.bam
  |   |   |   |-- input.subreads.bam.pbi
  |   |   |   |-- input.subreadset.xml
  |   |   |   `-- input.trc.h5 -> /pbi/dept/itg/test-data/pbi/collections/323/3230043/r54011_20170509_182922/1_D01/m54011_170509_185953.trc.h5
  |   |   |-- reference.fasta -> /pbi/dept/secondary/siv/references/11k_pbell_H1_6_ScaI/sequence/11k_pbell_H1_6_ScaI.fasta
  |   |   |-- reference.fasta.fai -> /pbi/dept/secondary/siv/references/11k_pbell_H1_6_ScaI/sequence/11k_pbell_H1_6_ScaI.fasta.fai
  |   |   |-- sts.h5 -> /home/UNIXHOME/mdsmith/Bitbucket/bauhaus2/bauhaus2/resources/extras/no_sts.h5
  |   |   |-- sts.xml -> /home/UNIXHOME/mdsmith/Bitbucket/bauhaus2/bauhaus2/resources/extras/no_sts.xml
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
  |   |       |-- input.adapters.fasta
  |   |       |-- input.scraps.bam
  |   |       |-- input.scraps.bam.pbi
  |   |       |-- input.sts.xml
  |   |       |-- input.subreads.bam
  |   |       |-- input.subreads.bam.pbi
  |   |       `-- input.subreadset.xml
  |   `-- noHQunrolled
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
  |       |-- primary
  |       |   |-- input.adapters.fasta -> /pbi/dept/itg/test-data/pbi/collections/323/3230043/r54011_20170509_182922/1_D01/m54011_170509_185953.adapters.fasta
  |       |   |-- input.baz
  |       |   |-- input.baz2bam_1.log
  |       |   |-- input.metadata.xml -> /pbi/dept/itg/test-data/pbi/collections/323/3230043/r54011_20170509_182922/1_D01/.m54011_170509_185953.metadata.xml
  |       |   |-- input.scraps.bam
  |       |   |-- input.scraps.bam.pbi
  |       |   |-- input.sts.h5
  |       |   |-- input.sts.xml
  |       |   |-- input.subreads.bam
  |       |   |-- input.subreads.bam.pbi
  |       |   |-- input.subreadset.xml
  |       |   `-- input.trc.h5 -> /pbi/dept/itg/test-data/pbi/collections/323/3230043/r54011_20170509_182922/1_D01/m54011_170509_185953.trc.h5
  |       |-- reference.fasta -> /pbi/dept/secondary/siv/references/11k_pbell_H1_6_ScaI/sequence/11k_pbell_H1_6_ScaI.fasta
  |       |-- reference.fasta.fai -> /pbi/dept/secondary/siv/references/11k_pbell_H1_6_ScaI/sequence/11k_pbell_H1_6_ScaI.fasta.fai
  |       |-- sts.h5 -> /home/UNIXHOME/mdsmith/Bitbucket/bauhaus2/bauhaus2/resources/extras/no_sts.h5
  |       |-- sts.xml -> /home/UNIXHOME/mdsmith/Bitbucket/bauhaus2/bauhaus2/resources/extras/no_sts.xml
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
  |           |-- input.adapters.fasta
  |           |-- input.scraps.bam
  |           |-- input.scraps.bam.pbi
  |           |-- input.sts.xml
  |           |-- input.subreads.bam
  |           |-- input.subreads.bam.pbi
  |           `-- input.subreadset.xml
  |-- config.json
  |-- log
  |-- prefix.sh
  |-- reports
  |   |-- AlignmentBasedHeatmaps
  |   |   |-- Accuracy_Heatmap_HQLib.png
  |   |   |-- Accuracy_Heatmap_HQunrolled.png
  |   |   |-- Accuracy_Heatmap_noHQunrolled.png
  |   |   |-- AlnReadLenExtRange_Heatmap_HQLib.png
  |   |   |-- AlnReadLenExtRange_Heatmap_HQunrolled.png
  |   |   |-- AlnReadLenExtRange_Heatmap_noHQunrolled.png
  |   |   |-- AlnReadLen_Heatmap_HQLib.png
  |   |   |-- AlnReadLen_Heatmap_HQunrolled.png
  |   |   |-- AlnReadLen_Heatmap_noHQunrolled.png
  |   |   |-- AvgPolsPerZMW_Heatmap_HQLib.png
  |   |   |-- AvgPolsPerZMW_Heatmap_HQunrolled.png
  |   |   |-- AvgPolsPerZMW_Heatmap_noHQunrolled.png
  |   |   |-- Count_Heatmap_HQLib.png
  |   |   |-- Count_Heatmap_HQunrolled.png
  |   |   |-- Count_Heatmap_noHQunrolled.png
  |   |   |-- DeletionRate_Heatmap_HQLib.png
  |   |   |-- DeletionRate_Heatmap_HQunrolled.png
  |   |   |-- DeletionRate_Heatmap_noHQunrolled.png
  |   |   |-- InsertionRate_Heatmap_HQLib.png
  |   |   |-- InsertionRate_Heatmap_HQunrolled.png
  |   |   |-- InsertionRate_Heatmap_noHQunrolled.png
  |   |   |-- MaxSubreadLenExtRange_Heatmap_HQLib.png
  |   |   |-- MaxSubreadLenExtRange_Heatmap_HQunrolled.png
  |   |   |-- MaxSubreadLenExtRange_Heatmap_noHQunrolled.png
  |   |   |-- MaxSubreadLenToAlnReadLenRatio_Heatmap_HQLib.png
  |   |   |-- MaxSubreadLenToAlnReadLenRatio_Heatmap_HQunrolled.png
  |   |   |-- MaxSubreadLenToAlnReadLenRatio_Heatmap_noHQunrolled.png
  |   |   |-- MaxSubreadLen_Heatmap_HQLib.png
  |   |   |-- MaxSubreadLen_Heatmap_HQunrolled.png
  |   |   |-- MaxSubreadLen_Heatmap_noHQunrolled.png
  |   |   |-- MismatchRate_Heatmap_HQLib.png
  |   |   |-- MismatchRate_Heatmap_HQunrolled.png
  |   |   |-- MismatchRate_Heatmap_noHQunrolled.png
  |   |   |-- Reference_Heatmap_HQLib.png
  |   |   |-- Reference_Heatmap_HQunrolled.png
  |   |   |-- Reference_Heatmap_noHQunrolled.png
  |   |   |-- SNR_A_Heatmap_HQLib.png
  |   |   |-- SNR_A_Heatmap_HQunrolled.png
  |   |   |-- SNR_A_Heatmap_noHQunrolled.png
  |   |   |-- SNR_C_Heatmap_HQLib.png
  |   |   |-- SNR_C_Heatmap_HQunrolled.png
  |   |   |-- SNR_C_Heatmap_noHQunrolled.png
  |   |   |-- SNR_G_Heatmap_HQLib.png
  |   |   |-- SNR_G_Heatmap_HQunrolled.png
  |   |   |-- SNR_G_Heatmap_noHQunrolled.png
  |   |   |-- SNR_T_Heatmap_HQLib.png
  |   |   |-- SNR_T_Heatmap_HQunrolled.png
  |   |   |-- SNR_T_Heatmap_noHQunrolled.png
  |   |   |-- Uniformity_histogram_HQLib.png
  |   |   |-- Uniformity_histogram_HQunrolled.png
  |   |   |-- Uniformity_histogram_noHQunrolled.png
  |   |   |-- Uniformity_metrics_HQLib.csv
  |   |   |-- Uniformity_metrics_HQunrolled.csv
  |   |   |-- Uniformity_metrics_noHQunrolled.csv
  |   |   |-- barchart_of_uniformity.png
  |   |   |-- rEnd_Heatmap_HQLib.png
  |   |   |-- rEnd_Heatmap_HQunrolled.png
  |   |   |-- rEnd_Heatmap_noHQunrolled.png
  |   |   |-- rStartExtRange_Heatmap_HQLib.png
  |   |   |-- rStartExtRange_Heatmap_HQunrolled.png
  |   |   |-- rStartExtRange_Heatmap_noHQunrolled.png
  |   |   |-- rStart_Heatmap_HQLib.png
  |   |   |-- rStart_Heatmap_HQunrolled.png
  |   |   |-- rStart_Heatmap_noHQunrolled.png
  |   |   |-- report.RData
  |   |   |-- report.json
  |   |   |-- tEnd_Heatmap_HQLib.png
  |   |   |-- tEnd_Heatmap_HQunrolled.png
  |   |   |-- tEnd_Heatmap_noHQunrolled.png
  |   |   |-- tStart_Heatmap_HQLib.png
  |   |   |-- tStart_Heatmap_HQunrolled.png
  |   |   `-- tStart_Heatmap_noHQunrolled.png
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
  |   |   |-- HQLib_Tau_Estimates.csv
  |   |   |-- HQunrolled_Tau_Estimates.csv
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
  |   |   |-- noHQunrolled_Tau_Estimates.csv
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
  |   |   |-- LocAcc.HQLib.accuracy_scatter.png
  |   |   |-- LocAcc.HQLib.aln_cols.csv
  |   |   |-- LocAcc.HQLib.core.csv
  |   |   |-- LocAcc.HQLib.delta_confusion.png
  |   |   |-- LocAcc.HQLib.error_counts.csv
  |   |   |-- LocAcc.HQLib.high_confusion.png
  |   |   |-- LocAcc.HQLib.hqerr_cumulative_duration_histogram.png
  |   |   |-- LocAcc.HQLib.hqerr_duration_histogram.png
  |   |   |-- LocAcc.HQLib.hqerr_reverse_cumulative_duration_histogram.png
  |   |   |-- LocAcc.HQLib.hqerrlens.csv
  |   |   |-- LocAcc.HQLib.local_accuracies.csv
  |   |   |-- LocAcc.HQLib.low_confusion.png
  |   |   |-- LocAcc.HQLib.mask.csv
  |   |   |-- LocAcc.HQLib.read_bases.csv
  |   |   |-- LocAcc.HQLib.template_bases.csv
  |   |   |-- LocAcc.HQunrolled.accuracy_scatter.png
  |   |   |-- LocAcc.HQunrolled.aln_cols.csv
  |   |   |-- LocAcc.HQunrolled.core.csv
  |   |   |-- LocAcc.HQunrolled.delta_confusion.png
  |   |   |-- LocAcc.HQunrolled.error_counts.csv
  |   |   |-- LocAcc.HQunrolled.high_confusion.png
  |   |   |-- LocAcc.HQunrolled.hqerr_cumulative_duration_histogram.png
  |   |   |-- LocAcc.HQunrolled.hqerr_duration_histogram.png
  |   |   |-- LocAcc.HQunrolled.hqerr_reverse_cumulative_duration_histogram.png
  |   |   |-- LocAcc.HQunrolled.hqerrlens.csv
  |   |   |-- LocAcc.HQunrolled.local_accuracies.csv
  |   |   |-- LocAcc.HQunrolled.low_confusion.png
  |   |   |-- LocAcc.HQunrolled.mask.csv
  |   |   |-- LocAcc.HQunrolled.read_bases.csv
  |   |   |-- LocAcc.HQunrolled.template_bases.csv
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
  |   |   |-- LocAcc.noHQunrolled.accuracy_scatter.png
  |   |   |-- LocAcc.noHQunrolled.aln_cols.csv
  |   |   |-- LocAcc.noHQunrolled.core.csv
  |   |   |-- LocAcc.noHQunrolled.delta_confusion.png
  |   |   |-- LocAcc.noHQunrolled.error_counts.csv
  |   |   |-- LocAcc.noHQunrolled.high_confusion.png
  |   |   |-- LocAcc.noHQunrolled.hqerr_cumulative_duration_histogram.png
  |   |   |-- LocAcc.noHQunrolled.hqerr_duration_histogram.png
  |   |   |-- LocAcc.noHQunrolled.hqerr_reverse_cumulative_duration_histogram.png
  |   |   |-- LocAcc.noHQunrolled.hqerrlens.csv
  |   |   |-- LocAcc.noHQunrolled.local_accuracies.csv
  |   |   |-- LocAcc.noHQunrolled.low_confusion.png
  |   |   |-- LocAcc.noHQunrolled.mask.csv
  |   |   |-- LocAcc.noHQunrolled.read_bases.csv
  |   |   |-- LocAcc.noHQunrolled.template_bases.csv
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
  |   |   |-- PolRate_by_time.png
  |   |   |-- active_zmw_normalized.png
  |   |   |-- bperr_rate_by_snr.png
  |   |   |-- bpmm_rate_by_snr.png
  |   |   |-- dutycycle_boxplot.png
  |   |   |-- filtered_ipd_median_by_time.png
  |   |   |-- filtered_pw_mean_by_time.png
  |   |   |-- global_localpolrate.png
  |   |   |-- ipd_median_by_time.png
  |   |   |-- ipddistbybase_boxplot.png
  |   |   |-- localpolrate_boxplot.png
  |   |   |-- mean_pw_boxplot_by_base.png
  |   |   |-- medianIPD.csv
  |   |   |-- medianPolymerizationRate.csv
  |   |   |-- medianSNR.csv
  |   |   |-- median_pw_boxplot_by_base.png
  |   |   |-- pkMid_Accu_vs_Inaccu_Dens.png
  |   |   |-- pkMid_Box_accurate\ reference\ reads.png
  |   |   |-- pkMid_Box_all\ reference\ reads.png
  |   |   |-- pkMid_Box_inaccurate\ reference\ reads.png
  |   |   |-- pkMid_CDF_accurate\ reference\ reads.png
  |   |   |-- pkMid_CDF_all\ reference\ reads.png
  |   |   |-- pkMid_CDF_inaccurate\ reference\ reads.png
  |   |   |-- pkMid_Dens_accurate\ reference\ reads.png
  |   |   |-- pkMid_Dens_all\ reference\ reads.png
  |   |   |-- pkMid_Dens_inaccurate\ reference\ reads.png
  |   |   |-- pkMid_Hist_accurate\ reference\ reads.png
  |   |   |-- pkMid_Hist_all\ reference\ reads.png
  |   |   |-- pkMid_Hist_inaccurate\ reference\ reads.png
  |   |   |-- pkmid_mean_by_time.png
  |   |   |-- pkmid_median_by_time.png
  |   |   |-- pkmid_median_by_time_normalized.png
  |   |   |-- polrate_ref_box.png
  |   |   |-- polrate_template_per_second.png
  |   |   |-- pw_boxplot.png
  |   |   |-- pw_by_template.png
  |   |   |-- pw_by_template_cdf.png
  |   |   |-- pw_mean_by_time.png
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
  
  33 directories, 481 files

