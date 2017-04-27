Test execution of the mapping reports workflow on some very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../../

Generate mapping reports workflow, starting from subreads.

  $ bauhaus2 --no-smrtlink --noGrid generate -w MappingReports -t ${BH_ROOT}test/data/two-tiny-movies.csv -o mapping-reports
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
  |   |   |-- Accuracy_Heatmap_MovieA.png
  |   |   |-- Accuracy_Heatmap_MovieB.png
  |   |   |-- AlnReadLenExtRange_Heatmap_MovieA.png
  |   |   |-- AlnReadLenExtRange_Heatmap_MovieB.png
  |   |   |-- AlnReadLen_Heatmap_MovieA.png
  |   |   |-- AlnReadLen_Heatmap_MovieB.png
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
  |   |   |-- NumBases_A_Heatmap_MovieA.png
  |   |   |-- NumBases_A_Heatmap_MovieB.png
  |   |   |-- NumBases_C_Heatmap_MovieA.png
  |   |   |-- NumBases_C_Heatmap_MovieB.png
  |   |   |-- NumBases_G_Heatmap_MovieA.png
  |   |   |-- NumBases_G_Heatmap_MovieB.png
  |   |   |-- NumBases_T_Heatmap_MovieA.png
  |   |   |-- NumBases_T_Heatmap_MovieB.png
  |   |   |-- PW_A_Heatmap_MovieA.png
  |   |   |-- PW_A_Heatmap_MovieB.png
  |   |   |-- PW_C_Heatmap_MovieA.png
  |   |   |-- PW_C_Heatmap_MovieB.png
  |   |   |-- PW_G_Heatmap_MovieA.png
  |   |   |-- PW_G_Heatmap_MovieB.png
  |   |   |-- PW_T_Heatmap_MovieA.png
  |   |   |-- PW_T_Heatmap_MovieB.png
  |   |   |-- PolRate_Heatmap_MovieA.png
  |   |   |-- PolRate_Heatmap_MovieB.png
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
  |   |   |-- TotalTime_Heatmap_MovieA.png
  |   |   |-- TotalTime_Heatmap_MovieB.png
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
  |   |   |-- bperr_rate_by_snr.png
  |   |   |-- bpmm_rate_by_snr.png
  |   |   |-- dutycycle_boxplot.png
  |   |   |-- global_localpolrate.png
  |   |   |-- ipddistbybase_boxplot.png
  |   |   |-- localpolrate_boxplot.png
  |   |   |-- medianIPD.csv
  |   |   |-- medianPolymerizationRate.csv
  |   |   |-- medianSNR.csv
  |   |   |-- noninternalBAM.csv
  |   |   |-- polrate_ref_box.png
  |   |   |-- polrate_template_per_second.png
  |   |   |-- pw_boxplot.png
  |   |   |-- pw_boxplot_by_base.png
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
  
  24 directories, 278 files






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
        "id": "pw_boxplot_by_base",
        "image": "pw_boxplot_by_base.png",
        "title": "PW Distribution By Base",
        "caption": "PW Distribution",
        "tags": ["sampled", "pw", "boxplot"]
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
        "id": "global_localpolrate",
        "image": "global_localpolrate.png",
        "title": "Global/Local PolRate",
        "caption": "Global/Local PolRate",
        "tags": ["sampled", "polrate", "john eid"]
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
