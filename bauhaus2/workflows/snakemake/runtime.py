#
# This module provides a little intelligence to the snakemake workflow
# at runtime, by initializing global variables that bauhaus2 workflows
# need to interrogate to define file paths and make decisions.
#

from bauhaus2.workflows import availableWorkflows
from bauhaus2.pbls2 import Resolver
from snakemake.workflow import config

resolver = Resolver()
WF_CLASS = availableWorkflows[config["bh2_workflow_name"]]
CT_CLASS = WF_CLASS.CONDITION_TABLE_TYPE

#
# Global variables to be used by snakemake workflows
#
ct = CT_CLASS(config.get("condition_table", "condition-table.csv"), resolver)
