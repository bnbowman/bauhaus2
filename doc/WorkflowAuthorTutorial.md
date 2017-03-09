
# `bauhaus2` workflow author tutorial

*If you haven't read the usage tutorial, please [start there][usage-tutorial].*

## Step 1: Learn Snakemake

`bauhaus2` simply constructs a Snakemake workflow from pieces.  If you
want to write a workflow, you'll have to write some of these pieces.
So the first step is to learn Snakemake, using [these slides][snakemake-tutorial-slides]
or [this website][snakemake-tutorial-site].

## Step 2: Understand what `bauhaus2` adds

Now that you know Snakemake, you can write your own workflows.  What
advantage is there to putting them in `bauhaus2`?  There are a few:

  1. The workflow will be available immediately to the Zia server,
     which means that other PacBio R&D groups (SMS, Enzymology, etc.)
     will have easy access to running it.

  2. Users can refer to inputs conveniently by runcode, SMRTLink job
     id, etc.

  3. Inputs will be checked for validity and compatibility with your
     workflow before the workflow is executed!

  4. You can build your workflow on top of preexisting workflows in
     `bauhaus2`.  For example, if you need mapped data to do your
     analysis, you don't need to write mapping code into your
     workflow, you can just "declare" that you will need mapped
     inputs, and they will be delivered in a prescribed location in
     your workflow folder upon execution.


### Step 3: Write your workflow class

In order to find your workflow, you need to write a subclass of
`bauhaus2.Workflow`.  It should be put in the subpackage
`bauhaus2.workflows`.  There are four important aspects to implementing
the workflow class:

  1. Declare its name using the `WORKFLOW_NAME` class variable;

  2. Declare the *condition table class* using the
     `CONDITION_TABLE_TYPE` class variable---this tells `bauhaus2` how
     to validate the condition table provided by users of this
     workflow.  This is important because different workflows might
     have different requirements on the table, for example specific
     additional columns might be required;

  3. Declare the files (plotting scripts, `pbsmrtpipe` XML presets)
     that we you will need `bauhaus2` to bundle into the workflow
     directory, using the class variables `R_SCRIPTS`,
     `PYTHON_SCRIPTS`, `SMRTPIPE_PRESETS`, etc.

  4. Implement the `plan()` method for your workflow class.  The
     `plan()` method should return a list of Snakemake filenames,
     referring to files `bauhaus2/resources/snakemake`.  These files
     are "pieces" which are concatenated by `bauhaus` to form a whole
     workflow.

     A monolithic workflow could just return a single-entry list for
     its `plan()`, but more typically we will want to leverage other
     snakemake files to provide mapping, CCS, etc.  Thus, we more
     generally will list a few snakemake files.  Note that the *first
     entry in `plan()` determines the "target rule"*, so you should
     list the "end goal" first.

     Also note that the `plan()` method can construct the plan
     dynamically, after looking at the condition table and the
     command-line arguments to `bauhaus2`.  This is powerful---it
     enables us to be smart and skip mapping if we see that the inputs
     are already mapped, for example; or, it can let us decide whether
     to use SMRTLink for mapping (vs calling pbalign directly).

### Step 3: Add your snakemake files, scripts, and other files

Next, you need to bundle your "resource" files under `bauhaus2/resources/`;

- Your snakemake files go under `bauhaus2/resources/snakemake`;
- Your scripts go under `bauhaus2/resources/scripts/{R,Python,MATLAB}`

*Note that every Snakemake file you want to bundle should be accompanied by a `.json` file with a corresponding name, enumerating configurable settings and their default values.*

### Step 5: Learn from examples

Given limited development resources, we can't write a very
comprehensive document at this time; we encourage workflow authors to
refer to the other workflows for examples.

### Step 6: Pull request

Please submit a pull request for your workflow to be included.  Once the PR is accepted and merged, it will be automatically deployed to the cluster and will be available to Zia.

### Step 6: Getting help!

Please reach out to Martin Smith, Yuan Tian, or David Alexander if you
have trouble getting this to work.





[snakemake-tutorial-slides]: http://slides.com/johanneskoester/snakemake-tutorial-2016
[snakemake-tutorial-site]: https://snakemake.readthedocs.io/en/stable/tutorial/tutorial.html
[usage-tutorial]: ./UsageTutorial.md
