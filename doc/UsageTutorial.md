
# `bauhaus2` usage tutorial

## Learn by example

Let's suppose we want to run an experiment on a couple different experimental
conditions---the regular "Control" chemistry and a special new "Sparkly"
chemistry from the lab.  We need to shepherd these runs through some secondary
analysis and then do some comparative analysis on the conditions.

First, we build a CSV file that describes the input sources and associated
variables. Here's the table we will encode in our CSV file `inputs.csv`:

| Condition   |      RunCode | ReportsFolder | Genome    | p_Chemistry |
|-------------|--------------|---------------|-----------|-------------|
| ControlChem | 3150120-0001 |               | lambdaNEB | Control     |
| ControlChem | 3150120-0002 |               | lambdaNEB | Control     |
| SparklyChem | 3150128-0001 |               | lambdaNEB | Sparkly     |
| SparklyChem | 3150128-0002 |               | lambdaNEB | Sparkly     |


A couple things to note.  First, note that we are "symbolically" referring to
locations of input data using the PacBio-internal "RunCode" idiom.  There are
other ways to refer to input data---see the [condition table
specification][condition-table-spec].

Also note that we've specified multiple runs for each condition; this means that
those input data will be combined within an analysis condition.

Now, we want to see some basic comparisons based on mapping---alignment lengths,
accuracy, etc.  We are going to feed this table to the `bauhaus2` command and it
will generate a runnable mapping workflow for us.  But first let's explicitly
ask `bauhaus2` to *validate* the table for us, to make sure we've encoded things
correctly and the data can actually be found.

  ```sh
  $ bauhaus2 validate -t inputs.csv -w MappingReports
  Validation and input resolution succeeded.
  ```

So far so good.  Note that we had to specify the "workflow" we want to run,
using `-w BasicMapping`.  In order to validate the table, we need to know what
workflow it will be used with---for example, the "Genome" column is necessary
for mapping-based workflows whereas it may not be necessary for other workflows.

Next, we want to generate a runnable workflow for performing this mapping:

  ```sh
  $ bauhaus2 generate -t inputs.csv -w BasicMapping -o experiment1
  Validation and input resolution succeeded.
  Runnable Workflow written to directory "experiment1"
  ```

Here we specified an output directory "experiment1" and called the
`generate` subcommand; the output directory was created and populated
as follows:

  ```sh
  $ tree experiment1
  experiment1
  ├── condition-table.csv
  ├── config.json
  ├── run.sh
  ├── scripts
  │   └── R
  │       ├── Bauhaus2.R
  │       ├── PbiPlots.R
  │       └── PbiSampledPlots.R
  └── workflow
      ├── Snakefile
      ├── runtime.py
      └── stdlib.py

  3 directories, 9 files
  ```

The idea is that this directory is now a (roughly) self-contained
workflow.  If we execute the `run.sh` script, the workflow will start.

However, before we start the workflow, we have the option to
*configure* it by editing `config.json`:

  ```sh
  $ cat experiment1/config.json
  {
     "bh2.scatter_subreads.chunks_per_condition": 8,
     "bh2.workflow_name": "MappingReports"
  }
  ```

Hypothetically you could imagine editing the setting for
`bh2.scatter_subreads.chunks_per_condition`, and this will change the number of
processing chunks that mapping gets divided into.  As another example, the
`CoverageTitration` workflow has an option
`bh2.call_variants_and_consensus.consensus_algorithm` that can be configured as
`arrow`, or `poa`, or `quiver` (for data supporting the Quiver algorithm).

## The general usage 

Usage of `bauhaus2` follows this pattern:
  
  1. Choose the analysis workflow you want to use.  You can list available
     workflows using `bauhaus2 list-workflows` and get documentation on any one
     in particular using `bauhaus2 describe-workflow`.

  2. Design your experiment, indicating the experimental variables and inputs,
     by writing the condition table (consult the
     [specification][condition-table-spec] as needed).

  3. Use `bauhaus2 validate` to double-check that your condition table is valid,
     and the inputs can be found.

  4. Use `bauhaus2 generate` to build your runnable workflow directory.

  5. Optionally, *configure* the workflow by editing the `config.json` file in
     the workflow directory, if there are analysis parameters you'd like to
     adjust.

  6. Finally, *execute* the worklow by running the `run.sh` script in the
     runnable workflow directory.


## Under the hood

Under the hood, `bauhaus2` works by generating a [Snakemake][snakemake] workflow
to execute analyses from inputs to reports.  Programmers familiar with the
syntax of Makefiles and Python should have no trouble learning Snakemake and
adding their own workflows.  More implementation details, important to
understand for contributors, can be found [here][contribution-tutorial].


## Differences from the original `bauhaus`

From the user's perspective, the chief differences from the original
`bauhaus` program are:

  - Command line interface slightly changed---the subcommand (`generate`,
    `validate`, etc.) is now specified *before* arguments like `-t`, `-w`, `-o`.
  - Configurability is a new feature
  - Greater reliability from using the Snakemake engine


[condition-table-spec]: ./ConditionTableSpec.md
[snakemake]:  https://snakemake.readthedocs.io/en/stable/
[contribution-tutorial]: ./ContributionTutorial.md