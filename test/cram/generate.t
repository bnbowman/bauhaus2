
  $ BH_ROOT=$TESTDIR/../../

Generate mapping reports workflow, starting from subreads.

  $ bauhaus2 -m generate -w MappingReports -t ${BH_ROOT}test/data/lambdaAndEcoli.csv -o mapping-reports
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
      |-- Snakefile
      |-- runtime.py
      `-- stdlib.py
  
  3 directories, 13 files

Let's look at the "plan" that got assembled in the Snakemake file.

  $ grep -e '^#' mapping-reports/workflow/Snakefile  | grep -v '\-\-'
  # stub.py : set up runtime/stdlib and initialize env for the snakemake workflow
  # summarize-mappings.snake: analyze mapping results, generating plots and tables.
  # map-subreads.snake: map (scattered) subreads and merge the resulting alignmentsets into one.
  # scatter-subreads.snake: split subreadsets into smaller chunks for analysis
  # collect-references.snake: hotlink "remote" reference FASTAs into our workflow directory
  # collect-subreads.snake: hotlink "remote" subreadsets into the workflow directory

  $ bauhaus2 -m generate -w MappingReports -t ${BH_ROOT}test/data/lambdaAndEcoliJobs.csv -o mapping-reports2
  Validation and input resolution succeeded.
  Generated runnable workflow to "mapping-reports2"

  $ tree mapping-reports2
  mapping-reports2
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
      |-- Snakefile
      |-- runtime.py
      `-- stdlib.py
  
  3 directories, 13 files


Again, let's look at the plan.  In this case, it doesn't include
mapping, since the mapping has already been done.

  $ grep -e '^#' mapping-reports2/workflow/Snakefile  | grep -v '\-\-'
  # stub.py : set up runtime/stdlib and initialize env for the snakemake workflow
  # summarize-mappings.snake: analyze mapping results, generating plots and tables.
  # collect-mappings.snake: hotlink pre-existing mappings into our workflow directory
  # collect-references.snake: hotlink "remote" reference FASTAs into our workflow directory
