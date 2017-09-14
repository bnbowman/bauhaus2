
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

   Please read the [usage tutorial](./doc/UsageTutorial.md).


## How to contribute a workflow or analysis?

   Please read the [workflow author tutorial](./doc/WorkflowAuthorTutorial.md


## What happened to the original `bauhaus`?

The original `bauhaus` was a prototype.  It had problems, which you
can read about [here](https://github.com/dalexander/bauhaus/wiki/Bauhaus-experience-report).

[Snakemake]: https://snakemake.readthedocs.io/en/stable/
[condition-table-spec]: ./doc/ConditionTableSpec.md

## Disclaimer

THIS WEBSITE AND CONTENT AND ALL SITE-RELATED SERVICES, INCLUDING ANY DATA, ARE PROVIDED "AS IS," WITH ALL FAULTS, WITH NO REPRESENTATIONS OR WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, ANY WARRANTIES OF MERCHANTABILITY, SATISFACTORY QUALITY, NON-INFRINGEMENT OR FITNESS FOR A PARTICULAR PURPOSE. YOU ASSUME TOTAL RESPONSIBILITY AND RISK FOR YOUR USE OF THIS SITE, ALL SITE-RELATED SERVICES, AND ANY THIRD PARTY WEBSITES OR APPLICATIONS. NO ORAL OR WRITTEN INFORMATION OR ADVICE SHALL CREATE A WARRANTY OF ANY KIND. ANY REFERENCES TO SPECIFIC PRODUCTS OR SERVICES ON THE WEBSITES DO NOT CONSTITUTE OR IMPLY A RECOMMENDATION OR ENDORSEMENT BY PACIFIC BIOSCIENCES.