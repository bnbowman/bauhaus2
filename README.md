
![bauhaus2 logo](./doc/img/bauhaus2.png)

`bauhaus2` is a simplistic tertiary analysis engine for in-house use
at PacBio, enabling execution of analysis workflows from raw data to
multi-condition analysis plots.

`bauhaus2` is best understood as a *compiler*.  It accepts the user's
specification of the experiment (a CSV table with a [well-defined
schema][condition-table-spec]), validates the table, resolves the
inputs (which can be referred to symbolically using *runcodes*, or
*job identifiers*, or explicitly using paths), and then generates an
output directory containing a [Snakemake] workflow and a driver script
(`run.sh`).  Users can simply execute the `run.sh` script---the
environment will be properly configured and the workflow will execute.


## How to get started using `bauhaus2`?

   Please read the [tutorial](./doc/UsageTutorial.md).


## How to contribute a workflow or analysis?

   (TODO)


## What happened to the original `bauhaus`?

The original `bauhaus` was a prototype.  It had problems, which you
can read about [here](https://github.com/dalexander/bauhaus/wiki/Bauhaus-experience-report).

[Snakemake]: https://snakemake.readthedocs.io/en/stable/
[condition-table-spec]: ./doc/ConditionTableSpec.md
