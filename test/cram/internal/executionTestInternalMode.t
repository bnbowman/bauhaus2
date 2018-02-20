Test execution of the mapping reports workflow on some very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../../

Generate mapping reports workflow, starting from subreads.

  $ bauhaus2 --no-smrtlink --noGrid generate -w MappingReports -t ${BH_ROOT}test/data/all4mer-ct.csv -o mapping-reports
  Validation and input resolution succeeded.
  Generated runnable workflow to "mapping-reports"

  $ (cd mapping-reports && ./run.sh >/dev/null 2>&1)


  $ tree -I __pycache__ mapping-reports
  mapping-reports
  |-- benchmarks
  |   `-- locacc.tsv
  |-- condition-table.csv
  |-- conditions
  |   `-- Movie
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
  |       |-- reference.fasta -> /pbi/dept/secondary/siv/references/All4mer_V2_001_unrolled_circular_216x_l150768/sequence/All4mer_V2_001_unrolled_circular_216x_l150768.fasta
  |       |-- reference.fasta.fai -> /pbi/dept/secondary/siv/references/All4mer_V2_001_unrolled_circular_216x_l150768/sequence/All4mer_V2_001_unrolled_circular_216x_l150768.fasta.fai
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
  |   |   |-- AccuracyExtRange_Movie.png
  |   |   |-- Accuracy_Movie.png
  |   |   |-- AlnReadLenExtRange_Movie.png
  |   |   |-- AlnReadLen_Movie.png
  |   |   |-- AvgPolsPerZMW_Movie.png
  |   |   |-- Count_Movie.png
  |   |   |-- DeletionRate_Movie.png
  |   |   |-- InsertionRate_Movie.png
  |   |   |-- MaxSubreadLenExtRange_Movie.png
  |   |   |-- MaxSubreadLenToAlnReadLenRatio_Movie.png
  |   |   |-- MaxSubreadLen_Movie.png
  |   |   |-- MismatchRate_Movie.png
  |   |   |-- Movie_All4mer.V2.001_unrolled_circular_216x_l150768_Coverage_vs_GC_Content.png
  |   |   |-- Movie_All4mer.V2.001_unrolled_circular_216x_l150768_Coverage_vs_tpl_position.png
  |   |   |-- Movie_All4mer.V2.001_unrolled_circular_216x_l150768_GC_Content_vs_tpl_position.png
  |   |   |-- Movie_All4mer.V2.001_unrolled_circular_216x_l150768_Subread_Length_vs_GC_Content.png
  |   |   |-- Movie_All4mer.V2.001_unrolled_circular_216x_l150768_Subread_Length_vs_tpl_position.png
  |   |   |-- Reference_Heatmap_Movie.png
  |   |   |-- SNR_A_Movie.png
  |   |   |-- SNR_C_Movie.png
  |   |   |-- SNR_G_Movie.png
  |   |   |-- SNR_T_Movie.png
  |   |   |-- Uniformity_histogram_Movie.png
  |   |   |-- Uniformity_metrics_Movie.csv
  |   |   |-- barchart_of_center_to_edge_p1.png
  |   |   |-- barchart_of_uniformity.png
  |   |   |-- rEnd_Movie.png
  |   |   |-- rStartExtRange_Movie.png
  |   |   |-- rStart_Movie.png
  |   |   |-- report.RData
  |   |   |-- report.json
  |   |   |-- tEnd_Movie.png
  |   |   `-- tStart_Movie.png
  |   |-- ConstantArrowFishbonePlots
  |   |   |-- errormode.csv
  |   |   |-- errormode_Movie.csv
  |   |   |-- mapped-metrics.csv
  |   |   |-- modelReport.json
  |   |   |-- report.Rd
  |   |   `-- report.json
  |   |-- LibDiagnosticPlots
  |   |   |-- Movie_Tau_Estimates.csv
  |   |   |-- Nvalues.csv
  |   |   |-- Yieldbycdandref.csv
  |   |   |-- Yieldbycdandref_unrolled.csv
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
  |   |   |-- max_hqlen.png
  |   |   |-- max_subread_len_cdf_with_50th_percentile.png
  |   |   |-- max_subread_len_density.png
  |   |   |-- max_subread_len_survival.png
  |   |   |-- max_subreads_per_zmw_metrics.csv
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
  |   |   |-- unrolled_template_boxplot.png
  |   |   |-- unrolled_template_densityplot.png
  |   |   `-- unrolled_template_densityplot_summation.png
  |   |-- LocAccPlots
  |   |   |-- LocAcc.Movie.accuracy_scatter.png
  |   |   |-- LocAcc.Movie.aln_cols.csv
  |   |   |-- LocAcc.Movie.core.csv
  |   |   |-- LocAcc.Movie.delta_confusion.png
  |   |   |-- LocAcc.Movie.error_counts.csv
  |   |   |-- LocAcc.Movie.high_confusion.png
  |   |   |-- LocAcc.Movie.hqerr_cumulative_duration_histogram.png
  |   |   |-- LocAcc.Movie.hqerr_duration_histogram.png
  |   |   |-- LocAcc.Movie.hqerr_reverse_cumulative_duration_histogram.png
  |   |   |-- LocAcc.Movie.hqerrlens.csv
  |   |   |-- LocAcc.Movie.local_accuracies.csv
  |   |   |-- LocAcc.Movie.low_confusion.png
  |   |   |-- LocAcc.Movie.mask.csv
  |   |   |-- LocAcc.Movie.read_bases.csv
  |   |   |-- LocAcc.Movie.template_bases.csv
  |   |   |-- LocAcc.accuracy_delta_densities.png
  |   |   |-- LocAcc.binomlocacc_boxes.png
  |   |   |-- LocAcc.canonglobacc_boxes.png
  |   |   |-- LocAcc.filtglobacc_boxes.png
  |   |   |-- LocAcc.filtglobacc_snr_scatter.png
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
  |   |   |-- alen_pol_density.png
  |   |   |-- alen_subread_density.png
  |   |   |-- alen_v_qlen.png
  |   |   |-- base_count_bar.png
  |   |   |-- etype__drate_boxplot.png
  |   |   |-- etype__irate_boxplot.png
  |   |   |-- etype__mmrate_boxplot.png
  |   |   |-- nreads_hist.png
  |   |   |-- report.Rd
  |   |   |-- report.json
  |   |   |-- sumtable.csv
  |   |   |-- tlen_box.png
  |   |   `-- tlen_density.png
  |   |-- PbiSampledPlots
  |   |   |-- Accuracyvsp_Foo.png
  |   |   |-- PolRate_by_time.png
  |   |   |-- active_zmw_normalized.png
  |   |   |-- alenvsp_Foo.png
  |   |   |-- bperr_rate_by_snr.png
  |   |   |-- bpmm_rate_by_snr.png
  |   |   |-- dratevsp_Foo.png
  |   |   |-- dutycycle_boxplot.png
  |   |   |-- filtered_ipd_median_by_time.png
  |   |   |-- filtered_pw_mean_by_time.png
  |   |   |-- global_localpolrate.png
  |   |   |-- ipd_median_by_time.png
  |   |   |-- ipddistbybase_boxplot.png
  |   |   |-- iratevsp_Foo.png
  |   |   |-- localpolrate_boxplot.png
  |   |   |-- mean_pw_boxplot_by_base.png
  |   |   |-- medianIPD.csv
  |   |   |-- medianPolymerizationRate.csv
  |   |   |-- medianSNR.csv
  |   |   |-- median_pw_boxplot_by_base.png
  |   |   |-- mmratevsp_Foo.png
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
  |   |   |-- snrCvsp_Foo.png
  |   |   |-- snrDensity.png
  |   |   |-- snrvsacc.png
  |   |   |-- snrvsdeletion.png
  |   |   |-- snrvsindelrat.png
  |   |   |-- snrvsinsertion.png
  |   |   |-- snrvsmismatch.png
  |   |   |-- tlenvsendtime.png
  |   |   |-- tlenvsp_Foo.png
  |   |   `-- tlenvsstarttime.png
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
  |   |-- ZMWstsPlots
  |   |   |-- accuracy_by_readtype_boxplot.png
  |   |   |-- adapter_dimer_fraction.png
  |   |   |-- nzmws_productivity_hist_percentage.png
  |   |   |-- nzmws_readtype_hist_percentage.png
  |   |   |-- readTypeAgg.1.png
  |   |   |-- readTypeAgg.2.png
  |   |   |-- report.Rd
  |   |   |-- report.json
  |   |   |-- short_insert_fraction.png
  |   |   `-- unrolled_template_length_by_readtype_boxplot.png
  |   `-- uidTag.csv
  |-- run.sh
  |-- scripts
  |   |-- Python
  |   |   |-- GetZiaTags.py
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
  
  21 directories, 264 files






  $ cat mapping-reports/reports/PbiSampledPlots/report.json
  {
    "plots": [
      {
        "uid": "0040001",
        "id": "active_zmw_normalized.png",
        "image": "active_zmw_normalized.png",
        "title": "Active ZMW - Normalized",
        "caption": "Active ZMW - Normalized",
        "tags": ["sampled", "activeZMW", "time"]
      },
      {
        "uid": "0040002",
        "id": "pkMid_boxplot_all reference reads",
        "image": "pkMid_Box_all reference reads.png",
        "title": "pkMid Box Plot - all reference reads",
        "caption": "Distribution of pkMid for all reference reads (Boxplot)",
        "tags": ["sampled", "pkmid", "boxplot", "<c2><a0>allreferencereads", "#dye", "#photonics"]
      },
      {
        "uid": "0040003",
        "id": "pkMid_boxplot_accurate reference reads",
        "image": "pkMid_Box_accurate reference reads.png",
        "title": "pkMid Box Plot - accurate reference reads",
        "caption": "Distribution of pkMid for accurate reference reads (Boxplot)",
        "tags": ["sampled", "pkmid", "boxplot", "<c2><a0>accuratereferencereads", "#dye", "#photonics"]
      },
      {
        "uid": "0040004",
        "id": "pkMid_boxplot_inaccurate reference reads",
        "image": "pkMid_Box_inaccurate reference reads.png",
        "title": "pkMid Box Plot - inaccurate reference reads",
        "caption": "Distribution of pkMid for inaccurate reference reads (Boxplot)",
        "tags": ["sampled", "pkmid", "boxplot", "<c2><a0>inaccuratereferencereads", "#dye", "#photonics"]
      },
      {
        "uid": "0040005",
        "id": "pkMid_densityplot_all reference reads",
        "image": "pkMid_Dens_all reference reads.png",
        "title": "pkMid Density Plot - all reference reads",
        "caption": "Distribution of pkMid for all reference reads (Density plot)",
        "tags": ["sampled", "pkmid", "density", "<c2><a0>allreferencereads", "#dye", "#photonics"]
      },
      {
        "uid": "0040006",
        "id": "pkMid_densityplot_accurate reference reads",
        "image": "pkMid_Dens_accurate reference reads.png",
        "title": "pkMid Density Plot - accurate reference reads",
        "caption": "Distribution of pkMid for accurate reference reads (Density plot)",
        "tags": ["sampled", "pkmid", "density", "<c2><a0>accuratereferencereads", "#dye", "#photonics"]
      },
      {
        "uid": "0040007",
        "id": "pkMid_densityplot_inaccurate reference reads",
        "image": "pkMid_Dens_inaccurate reference reads.png",
        "title": "pkMid Density Plot - inaccurate reference reads",
        "caption": "Distribution of pkMid for inaccurate reference reads (Density plot)",
        "tags": ["sampled", "pkmid", "density", "<c2><a0>inaccuratereferencereads", "#dye", "#photonics"]
      },
      {
        "uid": "0040008",
        "id": "pkMid_cdf_all reference reads",
        "image": "pkMid_CDF_all reference reads.png",
        "title": "pkMid CDF - all reference reads",
        "caption": "Distribution of pkMid for all reference reads (CDF)",
        "tags": ["sampled", "pkmid", "cdf", "<c2><a0>allreferencereads", "#dye", "#photonics"]
      },
      {
        "uid": "0040009",
        "id": "pkMid_cdf_accurate reference reads",
        "image": "pkMid_CDF_accurate reference reads.png",
        "title": "pkMid CDF - accurate reference reads",
        "caption": "Distribution of pkMid for accurate reference reads (CDF)",
        "tags": ["sampled", "pkmid", "cdf", "<c2><a0>accuratereferencereads", "#dye", "#photonics"]
      },
      {
        "uid": "0040010",
        "id": "pkMid_cdf_inaccurate reference reads",
        "image": "pkMid_CDF_inaccurate reference reads.png",
        "title": "pkMid CDF - inaccurate reference reads",
        "caption": "Distribution of pkMid for inaccurate reference reads (CDF)",
        "tags": ["sampled", "pkmid", "cdf", "<c2><a0>inaccuratereferencereads", "#dye", "#photonics"]
      },
      {
        "uid": "0040011",
        "id": "pkMid_histogram_all reference reads",
        "image": "pkMid_Hist_all reference reads.png",
        "title": "pkMid Histogram - all reference reads",
        "caption": "Distribution of pkMid for all reference reads (Histogram)",
        "tags": ["sampled", "pkmid", "histogram", "<c2><a0>allreferencereads"]
      },
      {
        "uid": "0040012",
        "id": "pkMid_histogram_accurate reference reads",
        "image": "pkMid_Hist_accurate reference reads.png",
        "title": "pkMid Histogram - accurate reference reads",
        "caption": "Distribution of pkMid for accurate reference reads (Histogram)",
        "tags": ["sampled", "pkmid", "histogram", "<c2><a0>accuratereferencereads", "#dye", "#photonics"]
      },
      {
        "uid": "0040013",
        "id": "pkMid_histogram_inaccurate reference reads",
        "image": "pkMid_Hist_inaccurate reference reads.png",
        "title": "pkMid Histogram - inaccurate reference reads",
        "caption": "Distribution of pkMid for inaccurate reference reads (Histogram)",
        "tags": ["sampled", "pkmid", "histogram", "<c2><a0>inaccuratereferencereads", "#dye", "#photonics"]
      },
      {
        "uid": "0040014",
        "id": "pkMid_Accu_Inaccu_densityplot",
        "image": "pkMid_Accu_vs_Inaccu_Dens.png",
        "title": "pkMid Density Plot - Accurate vs Inaccurate bases",
        "caption": "Distribution of pkMid for Accurate vs inaccurate bases (Density plot)",
        "tags": ["sampled", "pkmid", "density", "#dye", "#photonics"]
      },
      {
        "uid": "0040015",
        "id": "pw_mean_by_time",
        "image": "pw_mean_by_time.png",
        "title": "Mean Pulse Width by Time",
        "caption": "Mean Pulse Width by Time",
        "tags": ["sampled", "pw", "time"]
      },
      {
        "uid": "0040016",
        "id": "filtered_pw_mean_by_time",
        "image": "filtered_pw_mean_by_time.png",
        "title": "Filtered Mean Pulse Width by Time",
        "caption": "Filtered Mean Pulse Width by Time",
        "tags": ["sampled", "pw", "time", "filtered"]
      },
      {
        "uid": "0040017",
        "id": "ipd_median_by_time",
        "image": "ipd_median_by_time.png",
        "title": "Median IPD by Time",
        "caption": "Median IPD by Time",
        "tags": ["sampled", "ipd", "time"]
      },
      {
        "uid": "0040018",
        "id": "filtered_ipd_median_by_time",
        "image": "filtered_ipd_median_by_time.png",
        "title": "Filtered Median IPD by Time",
        "caption": "Filtered Median IPD by Time",
        "tags": ["sampled", "ipd", "time", "filtered"]
      },
      {
        "uid": "0040019",
        "id": "PolRate_by_time",
        "image": "PolRate_by_time.png",
        "title": "1/PolRate by Time",
        "caption": "1/PolRate by Time",
        "tags": ["sampled", "polrate", "time"]
      },
      {
        "uid": "0040020",
        "id": "pkmid_mean_by_time",
        "image": "pkmid_mean_by_time.png",
        "title": "Mean Pkmid by Time",
        "caption": "Mean Pkmid by Time",
        "tags": ["sampled", "pkmid", "time"]
      },
      {
        "uid": "0040021",
        "id": "pkmid_median_by_time",
        "image": "pkmid_median_by_time.png",
        "title": "Median Pkmid by Time",
        "caption": "Median Pkmid by Time",
        "tags": ["sampled", "pkmid", "time"]
      },
      {
        "uid": "0040022",
        "id": "pkmid_median_by_time_normalized",
        "image": "pkmid_median_by_time_normalized.png",
        "title": "Median Pkmid by Time (Normalized)",
        "caption": "Median Pkmid by Time (Normalized)",
        "tags": ["sampled", "pkmid", "time"]
      },
      {
        "uid": "0040023",
        "id": "polrate_template_per_second",
        "image": "polrate_template_per_second.png",
        "title": "Polymerization Rate (template bases per second)",
        "caption": "Polymerization Rate (template bases per second)",
        "tags": ["sampled", "boxplot", "polrate", "template", "time"]
      },
      {
        "uid": "0040024",
        "id": "polrate_ref_box",
        "image": "polrate_ref_box.png",
        "title": "Polymerization Rate by Reference",
        "caption": "Polymerization Rate by Reference",
        "tags": ["sampled", "boxplot", "polrate", "reference"]
      },
      {
        "uid": "0040025",
        "id": "pw_by_template.png",
        "image": "pw_by_template.png",
        "title": "Pulse Width by Template Base",
        "caption": "Pulse Width by Template Base",
        "tags": ["sampled", "density", "pw"]
      },
      {
        "uid": "0040026",
        "id": "pw_by_template_cdf.png",
        "image": "pw_by_template_cdf.png",
        "title": "Pulse Width by Template Base (CDF)",
        "caption": "Pulse Width by Template Base (CDF)",
        "tags": ["sampled", "pw", "cdf"]
      },
      {
        "uid": "0040027",
        "id": "ipd_boxplot_by_base",
        "image": "ipddistbybase_boxplot.png",
        "title": "IPD Distribution by Ref Base - Boxplot",
        "caption": "IPD Distribution by Ref Base - Boxplot",
        "tags": ["sampled", "boxplot", "ipd"]
      },
      {
        "uid": "0040028",
        "id": "pw_boxplot",
        "image": "pw_boxplot.png",
        "title": "PW Distribution - Boxplot",
        "caption": "PW Distribution - Boxplot",
        "tags": ["sampled", "boxplot", "pw"]
      },
      {
        "uid": "0040029",
        "id": "median_pw_boxplot_by_base",
        "image": "median_pw_boxplot_by_base.png",
        "title": "Median PW Distribution By Base",
        "caption": "Median PW Distribution",
        "tags": ["sampled", "pw", "boxplot", "median"]
      },
      {
        "uid": "0040030",
        "id": "mean_pw_boxplot_by_base",
        "image": "mean_pw_boxplot_by_base.png",
        "title": "Mean PW Distribution By Base",
        "caption": "Mean PW Distribution",
        "tags": ["sampled", "pw", "boxplot", "mean"]
      },
      {
        "uid": "0040031",
        "id": "dutycycle_boxplot",
        "image": "dutycycle_boxplot.png",
        "title": "Duty Cycle - Boxplot",
        "caption": "Duty Cycle - Boxplot",
        "tags": ["sampled", "boxplot", "dutycycle"]
      },
      {
        "uid": "0040032",
        "id": "localpolrate_boxplot",
        "image": "localpolrate_boxplot.png",
        "title": "Local PolRate - Boxplot",
        "caption": "Local PolRate - Boxplot",
        "tags": ["sampled", "boxplot", "polrate"]
      },
      {
        "uid": "0040033",
        "id": "global_localpolrate",
        "image": "global_localpolrate.png",
        "title": "Global/Local PolRate",
        "caption": "Global/Local PolRate",
        "tags": ["sampled", "polrate", "johneid"]
      },
      {
        "uid": "0040034",
        "id": "bp_err_rate_by_snr",
        "image": "bperr_rate_by_snr.png",
        "title": "BP Error Rates by SNR",
        "caption": "BP Error Rates by SNR",
        "tags": ["sampled", "errorrate", "base"]
      },
      {
        "uid": "0040035",
        "id": "bp_mm_err_rate_by_snr",
        "image": "bpmm_rate_by_snr.png",
        "title": "Mismatch Rates by SNR",
        "caption": "Mismatch Rates by SNR",
        "tags": ["sampled", "mismatch", "errorrate"]
      },
      {
        "uid": "0040036",
        "id": "snr_vs_acc",
        "image": "snrvsacc.png",
        "title": "SNR vs Accuracy",
        "caption": "SNR vs. Accuracy",
        "tags": ["sampled", "snr", "accuracy"]
      },
      {
        "uid": "0040037",
        "id": "snr_vs_ins",
        "image": "snrvsinsertion.png",
        "title": "SNR vs Insertion Rate",
        "caption": "SNR vs. Insertion Rate",
        "tags": ["sampled", "snr", "insertion"]
      },
      {
        "uid": "0040038",
        "id": "snr_vs_del",
        "image": "snrvsdeletion.png",
        "title": "SNR vs Deletion Rate",
        "caption": "SNR vs. Deletion Rate",
        "tags": ["sampled", "snr", "deletion"]
      },
      {
        "uid": "0040039",
        "id": "snr_vs_mm",
        "image": "snrvsmismatch.png",
        "title": "SNR vs Mismatch Rate",
        "caption": "SNR vs. Mismatch Rate",
        "tags": ["sampled", "snr", "mismatch"]
      },
      {
        "uid": "0040040",
        "id": "snr_vs_indel_rat",
        "image": "snrvsindelrat.png",
        "title": "SNR vs Relative Indels",
        "caption": "SNR vs. Indel Rate / Deletion Rate",
        "tags": ["sampled", "snr", "deletion"]
      },
      {
        "uid": "0040041",
        "id": "snr_density",
        "image": "snrDensity.png",
        "title": "SNR Density Plot",
        "caption": "Distribution of SNR in Aligned Files (Density plot)",
        "tags": ["sampled", "snr", "density", "#dye", "#photonics"]
      },
      {
        "uid": "0040042",
        "id": "snr_boxplot",
        "image": "snrBoxNoViolin.png",
        "title": "SNR Box Plot",
        "caption": "Distribution of SNR in Aligned Files (Boxplot)",
        "tags": ["sampled", "snr", "boxplot", "#dye", "#photonics"]
      },
      {
        "uid": "0040043",
        "id": "tlenvsstarttime",
        "image": "tlenvsstarttime.png",
        "title": "Template Span vs. Start Time",
        "caption": "Template Span vs. Start Time",
        "tags": ["sampled", "tlen", "time", "start", "template"]
      },
      {
        "uid": "0040044",
        "id": "tlenvsendtime",
        "image": "tlenvsendtime.png",
        "title": "Template Span vs. End Time",
        "caption": "Template Span vs. End Time",
        "tags": ["sampled", "tlen", "time", "end", "template"]
      },
      {
        "uid": "0040045",
        "id": "tlenvsp_Foo",
        "image": "tlenvsp_Foo.png",
        "title": "tlen vs. p_Foo",
        "caption": "tlen vs. p_Foo",
        "tags": ["sampled", "p_", "titration", "tlen", "boxplot"]
      },
      {
        "uid": "0040046",
        "id": "alenvsp_Foo",
        "image": "alenvsp_Foo.png",
        "title": "alen vs. p_Foo",
        "caption": "alen vs. p_Foo",
        "tags": ["sampled", "p_", "titration", "alen", "boxplot"]
      },
      {
        "uid": "0040047",
        "id": "Accuracyvsp_Foo",
        "image": "Accuracyvsp_Foo.png",
        "title": "Accuracy vs. p_Foo",
        "caption": "Accuracy vs. p_Foo",
        "tags": ["sampled", "p_", "titration", "Accuracy", "boxplot"]
      },
      {
        "uid": "0040048",
        "id": "iratevsp_Foo",
        "image": "iratevsp_Foo.png",
        "title": "irate vs. p_Foo",
        "caption": "irate vs. p_Foo",
        "tags": ["sampled", "p_", "titration", "irate", "boxplot"]
      },
      {
        "uid": "0040049",
        "id": "dratevsp_Foo",
        "image": "dratevsp_Foo.png",
        "title": "drate vs. p_Foo",
        "caption": "drate vs. p_Foo",
        "tags": ["sampled", "p_", "titration", "drate", "boxplot"]
      },
      {
        "uid": "0040050",
        "id": "mmratevsp_Foo",
        "image": "mmratevsp_Foo.png",
        "title": "mmrate vs. p_Foo",
        "caption": "mmrate vs. p_Foo",
        "tags": ["sampled", "p_", "titration", "mmrate", "boxplot"]
      },
      {
        "uid": "0040051",
        "id": "snrCvsp_Foo",
        "image": "snrCvsp_Foo.png",
        "title": "snrC vs. p_Foo",
        "caption": "snrC vs. p_Foo",
        "tags": ["sampled", "p_", "titration", "snrC", "boxplot"]
      }
    ],
    "tables": [
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
