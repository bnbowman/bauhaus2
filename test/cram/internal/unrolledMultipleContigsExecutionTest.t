Test execution of the mapping reports workflow on some very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../../

Generate mapping reports workflow, starting from subreads.

  $ bauhaus2 --no-smrtlink --noGrid generate -w UnrolledNoHQMappingArrowByReference -t ${BH_ROOT}test/data/two-tiny-movies-unrolled-multiple-contigs.csv -o unrolled-multiple-contigs-mapping
  Validation and input resolution succeeded.
  Generated runnable workflow to "unrolled-multiple-contigs-mapping"

  $ (cd unrolled-multiple-contigs-mapping && ./run.sh >/dev/null 2>&1)


  $ tree -I __pycache__ unrolled-multiple-contigs-mapping
  unrolled-multiple-contigs-mapping
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
  |   |   |   |-- mapped.alignmentset.xml
  |   |   |   |-- ref_chunk
  |   |   |   |   |-- mapped.chunk0.alignmentset.xml
  |   |   |   |   |-- mapped.chunk1.alignmentset.xml
  |   |   |   |   |-- mapped.chunk2.alignmentset.xml
  |   |   |   |   |-- mapped.chunk3.alignmentset.xml
  |   |   |   |   |-- mapped.chunk4.alignmentset.xml
  |   |   |   |   |-- mapped.chunk5.alignmentset.xml
  |   |   |   |   `-- mapped.chunk6.alignmentset.xml
  |   |   |   `-- scatterdone.empty
  |   |   |-- reference.fasta -> /pbi/dept/secondary/siv/references/All5Mers_unrolled_circular_22x_l50600/sequence/All5Mers_unrolled_circular_22x_l50600.fasta
  |   |   |-- reference.fasta.fai -> /pbi/dept/secondary/siv/references/All5Mers_unrolled_circular_22x_l50600/sequence/All5Mers_unrolled_circular_22x_l50600.fasta.fai
  |   |   |-- sts.h5 -> .*/bauhaus2/resources/extras/no_sts.h5 (re)
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
  |       |   |-- mapped.alignmentset.xml
  |       |   |-- ref_chunk
  |       |   |   |-- mapped.chunk0.alignmentset.xml
  |       |   |   |-- mapped.chunk1.alignmentset.xml
  |       |   |   |-- mapped.chunk2.alignmentset.xml
  |       |   |   |-- mapped.chunk3.alignmentset.xml
  |       |   |   |-- mapped.chunk4.alignmentset.xml
  |       |   |   |-- mapped.chunk5.alignmentset.xml
  |       |   |   `-- mapped.chunk6.alignmentset.xml
  |       |   `-- scatterdone.empty
  |       |-- reference.fasta -> /pbi/dept/secondary/siv/references/All5Mers_unrolled_circular_22x_l50600/sequence/All5Mers_unrolled_circular_22x_l50600.fasta
  |       |-- reference.fasta.fai -> /pbi/dept/secondary/siv/references/All5Mers_unrolled_circular_22x_l50600/sequence/All5Mers_unrolled_circular_22x_l50600.fasta.fai
  |       |-- sts.h5 -> .*/bauhaus2/resources/extras/no_sts.h5 (re)
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
  |-- contig-chunked-condition-table.csv
  |-- log
  |-- prefix.sh
  |-- reports
  |   |-- AlignmentBasedHeatmaps
  |   |   |-- Accuracy_Heatmap_MovieA.png
  |   |   |-- Accuracy_Heatmap_MovieB.png
  |   |   |-- AlnReadLenExtRange_Heatmap_MovieA.png
  |   |   |-- AlnReadLenExtRange_Heatmap_MovieB.png
  |   |   |-- AlnReadLen_Heatmap_MovieA.png
  |   |   |-- AlnReadLen_Heatmap_MovieB.png
  |   |   |-- AvgPolsPerZMW_Heatmap_MovieA.png
  |   |   |-- AvgPolsPerZMW_Heatmap_MovieB.png
  |   |   |-- Count_Heatmap_MovieA.png
  |   |   |-- Count_Heatmap_MovieB.png
  |   |   |-- DeletionRate_Heatmap_MovieA.png
  |   |   |-- DeletionRate_Heatmap_MovieB.png
  |   |   |-- InsertionRate_Heatmap_MovieA.png
  |   |   |-- InsertionRate_Heatmap_MovieB.png
  |   |   |-- MaxSubreadLenExtRange_Heatmap_MovieA.png
  |   |   |-- MaxSubreadLenExtRange_Heatmap_MovieB.png
  |   |   |-- MaxSubreadLenToAlnReadLenRatio_Heatmap_MovieA.png
  |   |   |-- MaxSubreadLenToAlnReadLenRatio_Heatmap_MovieB.png
  |   |   |-- MaxSubreadLen_Heatmap_MovieA.png
  |   |   |-- MaxSubreadLen_Heatmap_MovieB.png
  |   |   |-- MismatchRate_Heatmap_MovieA.png
  |   |   |-- MismatchRate_Heatmap_MovieB.png
  |   |   |-- Reference_Heatmap_MovieA.png
  |   |   |-- Reference_Heatmap_MovieB.png
  |   |   |-- SNR_A_Heatmap_MovieA.png
  |   |   |-- SNR_A_Heatmap_MovieB.png
  |   |   |-- SNR_C_Heatmap_MovieA.png
  |   |   |-- SNR_C_Heatmap_MovieB.png
  |   |   |-- SNR_G_Heatmap_MovieA.png
  |   |   |-- SNR_G_Heatmap_MovieB.png
  |   |   |-- SNR_T_Heatmap_MovieA.png
  |   |   |-- SNR_T_Heatmap_MovieB.png
  |   |   |-- Uniformity_histogram_MovieA.png
  |   |   |-- Uniformity_histogram_MovieB.png
  |   |   |-- Uniformity_metrics_MovieA.csv
  |   |   |-- Uniformity_metrics_MovieB.csv
  |   |   |-- rEnd_Heatmap_MovieA.png
  |   |   |-- rEnd_Heatmap_MovieB.png
  |   |   |-- rStartExtRange_Heatmap_MovieA.png
  |   |   |-- rStartExtRange_Heatmap_MovieB.png
  |   |   |-- rStart_Heatmap_MovieA.png
  |   |   |-- rStart_Heatmap_MovieB.png
  |   |   |-- report.RData
  |   |   |-- report.json
  |   |   |-- tEnd_Heatmap_MovieA.png
  |   |   |-- tEnd_Heatmap_MovieB.png
  |   |   |-- tStart_Heatmap_MovieA.png
  |   |   `-- tStart_Heatmap_MovieB.png
  |   |-- ConstantArrowFishbonePlots
  |   |   |-- FishboneSnrBinnedSummary.csv
  |   |   |-- errormode-simple.csv
  |   |   |-- errormode.csv
  |   |   |-- mapped-metrics.csv
  |   |   |-- modelReport.json
  |   |   |-- report.Rd
  |   |   `-- report.json
  |   |-- LibDiagnosticPlots
  |   |   |-- MovieA_Tau_Estimates.csv
  |   |   |-- MovieB_Tau_Estimates.csv
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
  |   |   |-- active_zmw_normalized.png
  |   |   |-- bperr_rate_by_snr.png
  |   |   |-- bpmm_rate_by_snr.png
  |   |   |-- dutycycle_boxplot.png
  |   |   |-- global_localpolrate.png
  |   |   |-- ipddistbybase_boxplot.png
  |   |   |-- localpolrate_boxplot.png
  |   |   |-- medianIPD.csv
  |   |   |-- medianPolymerizationRate.csv
  |   |   |-- medianSNR.csv
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
  |   |   |-- pw_boxplot_by_base.png
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
  |       |-- nzmws_productivity_hist_percentage.png
  |       |-- nzmws_readtype_hist_percentage.png
  |       |-- readTypeAgg.1.png
  |       |-- readTypeAgg.2.png
  |       |-- report.Rd
  |       |-- report.json
  |       `-- unrolled_template_length_by_readtype_boxplot.png
  |-- run.sh
  |-- scripts
  |   |-- Python
  |   |   |-- ConsolidateArrowConditions.py
  |   |   |-- MakeChunkedConditionTable.py
  |   |   |-- MakeMappingMetricsCsv.py
  |   |   `-- RefilterMappedReadsByReference.py
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
  
  26 directories, 294 files

