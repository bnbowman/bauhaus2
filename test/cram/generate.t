
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
  |   `-- R
  |       |-- Bauhaus2.R
  |       |-- ConstantArrowFishbonePlots.R
  |       |-- LibDiagnosticPlots.R
  |       |-- PbiPlots.R
  |       |-- PbiSampledPlots.R
  |       `-- ReadPlots.R
  `-- workflow
      `-- Snakefile
  
  3 directories, 11 files

Let's look at the "plan" that got assembled in the Snakemake file.

  $ grep -e '^#' mapping-reports/workflow/Snakefile  | grep -v '\-\-'
  # stub.py : set up runtime/stdlib and initialize env for the snakemake workflow
  # summarize-mappings.snake: analyze mapping results, generating plots and tables.
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
  # map-subreads-smrtlink.snake: map subreads using a SMRTLink server, via pbservice call
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
  # collect-mappings.snake: hotlink pre-existing mappings into our workflow directory
  # collect-references.snake: hotlink "remote" reference FASTAs into our workflow directory
