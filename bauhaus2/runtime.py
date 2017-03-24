#
# This module provides a little intelligence to the snakemake workflow
# at runtime, by
#
# 1) initializing global variables that bauhaus2 workflows
#    need to interrogate to define file paths and make decisions.
#
# 2) exposing a few convenience functions as a "standard library"
#
__all__ = [ "ct", "listConcat" ]

from bauhaus2.workflows import availableWorkflows
from bauhaus2.pbls2 import Resolver
from snakemake.workflow import config

resolver = Resolver()
WF_CLASS = availableWorkflows[config["bh2.workflow_name"]]
CT_CLASS = WF_CLASS.CONDITION_TABLE_TYPE

# ----
# Global variables to be used by snakemake workflows
ct = CT_CLASS("condition-table.csv", resolver)


# ----
# Standard library
from bauhaus2.utils import listConcat
