
  $ BH_ROOT=$TESTDIR/../../

Generate mapping reports workflow, starting from subreads, and doing mapping ourselves (not via SMRTLink)

  $ bauhaus2 -m --no-smrtlink generate -w MappingReports -t ${BH_ROOT}test/data/lambdaAndEcoli.csv -o mapping-reports
  Validation and input resolution succeeded.
  Generated runnable workflow to "mapping-reports"

  $ tree mapping-reports
  mapping-reports
  |-- condition-table.csv
  |-- config.json
  |-- prefix.sh
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
  `-- workflow
      `-- Snakefile
  
  4 directories, 16 files

Let's look at the "plan" that got assembled in the Snakemake file.

  $ grep -e '^#' mapping-reports/workflow/Snakefile  | grep -v '\-\-'
  # stub.py : set up runtime/stdlib and initialize env for the snakemake workflow
  # summarize-mappings.snake: analyze mapping results, generating plots and tables.
  # constant-arrow.snake: fit constant arrow model, generating csv file of errormode,
  # and make Fishbone plots using the csv file.
  # heatmaps.snake: Generate alignment based heatmaps.
  # locacc.snake: Generate locacc plots (tool from Martin).
  # uid-tag.snake: Generate a csv file that matches the uid and tags.
  # map-subreads.snake: map (scattered) subreads and merge the resulting alignmentsets into one.
  # scatter-subreads.snake: split subreadsets into smaller chunks for analysis
  # collect-references.snake: hotlink "remote" reference FASTAs into our workflow directory
  # collect-subreads.snake: hotlink "remote" subreadsets into the workflow directory

Now let's use SMRTLink for mapping.  The plan looks different.

  $ bauhaus2 -m generate -w MappingReports -t ${BH_ROOT}test/data/lambdaAndEcoli.csv -o mapping-reports2
  Validation and input resolution succeeded.
  Generated runnable workflow to "mapping-reports2"

  $ grep -e '^#' mapping-reports2/workflow/Snakefile  | grep -v '\-\-'
  # stub.py : set up runtime/stdlib and initialize env for the snakemake workflow
  # summarize-mappings.snake: analyze mapping results, generating plots and tables.
  # constant-arrow.snake: fit constant arrow model, generating csv file of errormode,
  # and make Fishbone plots using the csv file.
  # heatmaps.snake: Generate alignment based heatmaps.
  # locacc.snake: Generate locacc plots (tool from Martin).
  # uid-tag.snake: Generate a csv file that matches the uid and tags.
  # map-subreads-smrtlink.snake: map subreads using a SMRTLink server, via pbservice call
  # There was an design problem in peservice to output json files
  # The log of the job is incorrectly saved in the json output before the "real" json output
  # The progress of correcting the json output in pbservice is at SE-660
  # This function stripOutJunk adds a gross workaround to read the job is and path from the incorrect json output
  # collect-references.snake: hotlink "remote" reference FASTAs into our workflow directory
  # collect-subreads.snake: hotlink "remote" subreadsets into the workflow directory


If we had used inputs that were already mapped, the plan would look
different as it would include a "copy/symlink" (collect) step instead
of a mapping:

  $ bauhaus2 -m generate -w MappingReports -t ${BH_ROOT}test/data/lambdaAndEcoliJobs.csv -o mapping-reports3
  Validation and input resolution succeeded.
  Generated runnable workflow to "mapping-reports3"

  $ grep -e '^#' mapping-reports3/workflow/Snakefile  | grep -v '\-\-'
  # stub.py : set up runtime/stdlib and initialize env for the snakemake workflow
  # summarize-mappings.snake: analyze mapping results, generating plots and tables.
  # constant-arrow.snake: fit constant arrow model, generating csv file of errormode,
  # and make Fishbone plots using the csv file.
  # heatmaps.snake: Generate alignment based heatmaps.
  # locacc.snake: Generate locacc plots (tool from Martin).
  # uid-tag.snake: Generate a csv file that matches the uid and tags.
  # collect-smrtlink-references.snake: hotlink "remote" smrtlink reference FASTAs into our workflow directory
  # Here the sts.h5 file is fetched at the same time as the reference, just to simplify the process 
  # When more sts or other data files are collected, they should be separated to a new snakemake file
  # Define local mapping alignemntset
  # collect-mappings.snake: hotlink pre-existing mappings into our workflow directory
  # When resolving the smrtlink job server and id, the mapped alignmentset and the subreadset are returned as a list
  # So here ct.inputs(c)[0] returns the list that contains the mapped alignmentset and the subreadset
  # Later in this workflow, only the alignmentset (remote_alignmentsets[wc.condition][0]) is used

Test bauhaus2 isoseq workflow
  $ bauhaus2 generate -w IsoSeqRC0 -t ${BH_ROOT}test/data/two-isoseq-jobs.csv -o isoseq_output
  Validation and input resolution succeeded.
  Generated runnable workflow to "isoseq_output"
  $ ls isoseq_output/workflow/Snakefile
  isoseq_output/workflow/Snakefile

  $ bauhaus2 generate -w IsoSeqRC0 -t ${BH_ROOT}test/data/two-isoseq-paths.csv -o isoseq_output2
  Validation and input resolution succeeded.
  Generated runnable workflow to "isoseq_output2"
  $ ls isoseq_output2/workflow/Snakefile
  isoseq_output2/workflow/Snakefile
