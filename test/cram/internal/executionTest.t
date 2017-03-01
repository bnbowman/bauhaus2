Test execution of the mapping reports workflow on some very tiny
datasets.  This test is likely a bit "volatile" in the sense that it's
overly sensitive to addition of new plots, etc.  But let's keep it
until we have a better plan.

  $ BH_ROOT=$TESTDIR/../../../

Generate mapping reports workflow, starting from subreads.

  $ bauhaus2 --noGrid generate -w MappingReports -t ${BH_ROOT}test/data/two-tiny-movies.csv -o mapping-reports
  Validation and input resolution succeeded.
  Generated runnable workflow to "mapping-reports"

  $ (cd mapping-reports && ./run.sh >/dev/null 2>&1)


  $ tree -I __pycache__ mapping-reports
  mapping-reports
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
  |   |-- ConstantArrowFishbonePlots
  |   |   |-- FishboneSnrBinnedSummary.csv
  |   |   |-- errormode_MovieA.csv
  |   |   |-- errormode_MovieB.csv
  |   |   |-- fishboneplot_deletion.png
  |   |   |-- fishboneplot_insertion.png
  |   |   |-- fishboneplot_mismatch.png
  |   |   |-- report.Rd
  |   |   `-- report.json
  |   |-- LibDiagnosticPlots
  |   |   |-- cdf_astart.png
  |   |   |-- cdf_astart_log.png
  |   |   |-- cdf_hqlenmax.png
  |   |   |-- cdf_ratio.png
  |   |   |-- cdf_tlen.png
  |   |   |-- density_max.png
  |   |   |-- density_max_region.png
  |   |   |-- density_unroll.png
  |   |   |-- density_unroll_summation.png
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
  |   |   |-- acc_violin.png
  |   |   |-- alen_density.png
  |   |   |-- alen_v_qlen.png
  |   |   |-- aligned_read_length_survival\ (Log-scale).png
  |   |   |-- aligned_read_length_survival.png
  |   |   |-- base_count_bar.png
  |   |   |-- etype__drate_boxplot.png
  |   |   |-- etype__drate_violin.png
  |   |   |-- etype__irate_boxplot.png
  |   |   |-- etype__irate_violin.png
  |   |   |-- etype__mmrate_boxplot.png
  |   |   |-- etype__mmrate_violin.png
  |   |   |-- nreads_hist.png
  |   |   |-- report.Rd
  |   |   |-- report.json
  |   |   |-- sumtable.csv
  |   |   |-- template_span_survival\ (Log-scale).png
  |   |   |-- template_span_survival.png
  |   |   |-- tlen_box.png
  |   |   |-- tlen_density.png
  |   |   `-- tlen_violin.png
  |   |-- PbiSampledPlots
  |   |   |-- bperr_rate_by_snr.png
  |   |   |-- bpmm_rate_by_snr.png
  |   |   |-- dutycycle_boxplot.png
  |   |   |-- global_localpolrate.png
  |   |   |-- ipddist.png
  |   |   |-- ipddistbybase_boxplot.png
  |   |   |-- ipddistbybase_violin.png
  |   |   |-- localpolrate_boxplot.png
  |   |   |-- medianIPD.csv
  |   |   |-- medianPolymerizationRate.csv
  |   |   |-- medianSNR.csv
  |   |   |-- noninternalBAM.csv
  |   |   |-- polrate_ref_box.png
  |   |   |-- pw_boxplot.png
  |   |   |-- pw_boxplot_by_base.png
  |   |   |-- pw_by_template.png
  |   |   |-- pw_by_template_cdf.png
  |   |   |-- pw_violin.png
  |   |   |-- report.Rd
  |   |   |-- report.json
  |   |   |-- snrBoxNoViolin.png
  |   |   |-- snrDensity.png
  |   |   |-- snrViolin.png
  |   |   |-- snrvsacc.png
  |   |   |-- snrvsdeletion.png
  |   |   |-- snrvsindelrat.png
  |   |   |-- snrvsinsertion.png
  |   |   `-- snrvsmismatch.png
  |   `-- ReadPlots
  |       |-- clip_rate.png
  |       |-- deletion_norm.png
  |       |-- deletion_rate.png
  |       |-- deletion_size_log.png
  |       |-- insert_size_log.png
  |       |-- insert_size_norm.png
  |       |-- insertion_rate.png
  |       |-- mismatch_rate.png
  |       |-- report.Rd
  |       `-- report.json
  |-- run.sh
  |-- scripts
  |   `-- R
  |       |-- Bauhaus2.R
  |       |-- ConstantArrowFishbonePlots.R
  |       |-- LibDiagnosticPlots.R
  |       |-- PbiPlots.R
  |       |-- PbiSampledPlots.R
  |       `-- ReadPlots.R
  |-- snakemake.log
  `-- workflow
      |-- Snakefile
      |-- runtime.py
      `-- stdlib.py
  
  21 directories, 199 files






  $ cat mapping-reports/reports/PbiSampledPlots/report.json
  {
    "plots": [
      {
        "id": "snr_violin",
        "image": "snrViolin.png",
        "title": "SNR Violin Plot",
        "caption": "Distribution of SNR in Aligned Files (Violin plot)",
        "tags": []
      },
      {
        "id": "snr_density",
        "image": "snrDensity.png",
        "title": "SNR Density Plot",
        "caption": "Distribution of SNR in Aligned Files (Density plot)",
        "tags": []
      },
      {
        "id": "snr_boxplot",
        "image": "snrBoxNoViolin.png",
        "title": "SNR Box Plot",
        "caption": "Distribution of SNR in Aligned Files (Boxplot)",
        "tags": []
      },
      {
        "id": "snr_vs_acc",
        "image": "snrvsacc.png",
        "title": "SNR vs Accuracy",
        "caption": "SNR vs. Accuracy",
        "tags": []
      },
      {
        "id": "snr_vs_ins",
        "image": "snrvsinsertion.png",
        "title": "SNR vs Insertion Rate",
        "caption": "SNR vs. Insertion Rate",
        "tags": []
      },
      {
        "id": "snr_vs_del",
        "image": "snrvsdeletion.png",
        "title": "SNR vs Deletion Rate",
        "caption": "SNR vs. Deletion Rate",
        "tags": []
      },
      {
        "id": "snr_vs_mm",
        "image": "snrvsmismatch.png",
        "title": "SNR vs Mismatch Rate",
        "caption": "SNR vs. Mismatch Rate",
        "tags": []
      },
      {
        "id": "snr_vs_indel_rat",
        "image": "snrvsindelrat.png",
        "title": "SNR vs Relative Indels",
        "caption": "SNR vs. Indel Rate / Deletion Rate",
        "tags": []
      },
      {
        "id": "polrate_ref_box",
        "image": "polrate_ref_box.png",
        "title": "Polymerization Rate by Reference",
        "caption": "Polymerization Rate by Reference",
        "tags": []
      },
      {
        "id": "pw_by_template.png",
        "image": "pw_by_template.png",
        "title": "Pulse Width by Template Base",
        "caption": "Pulse Width by Template Base",
        "tags": []
      },
      {
        "id": "pw_by_template_cdf.png",
        "image": "pw_by_template_cdf.png",
        "title": "Pulse Width by Template Base (CDF)",
        "caption": "Pulse Width by Template Base (CDF)",
        "tags": []
      },
      {
        "id": "ipd_violin",
        "image": "ipddist.png",
        "title": "IPD Distribution - Violin Plot",
        "caption": "IPD Distribution - Violin Plot",
        "tags": []
      },
      {
        "id": "ipd_violin_by_base",
        "image": "ipddistbybase_violin.png",
        "title": "IPD Distribution by Ref Base - Violin Plot",
        "caption": "IPD Distribution by Ref Base - Violin Plot",
        "tags": []
      },
      {
        "id": "ipd_boxplot_by_base",
        "image": "ipddistbybase_boxplot.png",
        "title": "IPD Distribution by Ref Base - Boxplot",
        "caption": "IPD Distribution by Ref Base - Boxplot",
        "tags": []
      },
      {
        "id": "pw_violin",
        "image": "pw_violin.png",
        "title": "PW Distribution - Violin Plot",
        "caption": "PW Distribution - Violin Plot",
        "tags": []
      },
      {
        "id": "pw_boxplot",
        "image": "pw_boxplot.png",
        "title": "PW Distribution - Boxplot",
        "caption": "PW Distribution - Boxplot",
        "tags": []
      },
      {
        "id": "pw_boxplot_by_base",
        "image": "pw_boxplot_by_base.png",
        "title": "PW Distribution By Base",
        "caption": "PW Distribution",
        "tags": []
      },
      {
        "id": "dutycycle_boxplot",
        "image": "dutycycle_boxplot.png",
        "title": "Duty Cycle - Boxplot",
        "caption": "Duty Cycle - Boxplot",
        "tags": []
      },
      {
        "id": "localpolrate_boxplot",
        "image": "localpolrate_boxplot.png",
        "title": "Local PolRate - Boxplot",
        "caption": "Local PolRate - Boxplot",
        "tags": []
      },
      {
        "id": "global_localpolrate",
        "image": "global_localpolrate.png",
        "title": "Global/Local PolRate",
        "caption": "Global/Local PolRate",
        "tags": []
      },
      {
        "id": "bp_err_rate_by_snr",
        "image": "bperr_rate_by_snr.png",
        "title": "BP Error Rates by SNR",
        "caption": "BP Error Rates by SNR",
        "tags": []
      },
      {
        "id": "bp_mm_err_rate_by_snr",
        "image": "bpmm_rate_by_snr.png",
        "title": "Mismatch Rates by SNR",
        "caption": "Mismatch Rates by SNR",
        "tags": []
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
