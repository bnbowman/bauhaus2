from __future__ import print_function
import argparse, shutil, sys, os, os.path as op

from bauhaus2.pbls2 import Resolver, MockResolver
from bauhaus2.utils import mkdirp
from bauhaus2.experiment import (InputResolutionError, TableValidationError)
from bauhaus2.workflows import availableWorkflows
from bauhaus2.__version__ import __VERSION__


def doWorkflowHelp(args):
    wfg = availableWorkflows[args.workflow]()
    print(wfg.__doc__)

def doValidate(args):
    if args.mockResolver:
        r = MockResolver()
    else:
        r = Resolver()
    wfg = availableWorkflows[args.workflow]()
    ct = wfg.conditionTableType()(args.conditionTable, r)
    return wfg, ct

def doGenerate(args, wfg, ct):
    wfg.generate(args.conditionTable, args.outputDirectory)

def doRun(args):
    raise NotImplementedError

def parseArgs():
    parser = argparse.ArgumentParser(prog="bauhaus2")
    parser.add_argument("--version", action="version", version=__VERSION__)

    parser.add_argument(
        "--mockResolver", "-m",
        action="store_true",
        help="Use mock pbls2 resolver (for testing purposes)")
    parser.add_argument(
        "--pdb", action="store_true",
        help="Drop into debugger on exception")
    parser.add_argument(
        "--noGrid", action="store_true",
        help="Disable the qsub submission to the grid")
    parser.add_argument(
        "--chunks", type=int, default=8,
        help="The number of chunks that should be used for scatter-gather compatible workflows (0 means disable chunking)")
    parser.add_argument(
        "-q", "--sgeQueue",
        default="default", type=str,
        help="Specify destination SGE queue for workflow tasks")

    subparsers = parser.add_subparsers(help="sub-command help", dest="subcommand")
    subparsers.required=True
    subparsers.add_parser("list-workflows", help="List available workflows")
    pDescribe = subparsers.add_parser("describe-workflow", help="Describe chosen workflow")
    pValidate = subparsers.add_parser("validate", help="Validate the condition table")
    pGenerate = subparsers.add_parser("generate", help="Generate the ninja script to run the workflow")
    pRun      = subparsers.add_parser("run", help="Run the workflow")

    for p in (pDescribe, pValidate, pGenerate, pRun):
        p.add_argument(
            "--workflow", "-w",
            action="store", type=str,
            required=True,
            choices = list(availableWorkflows.keys()),
            metavar="WORKFLOW")

    for p in (pValidate, pGenerate, pRun):
        p.add_argument(
            "--conditionTable", "-t",
            action="store", metavar="CONDITION_TABLE.CSV",
            required=True,
            type=op.abspath)

    for p in (pGenerate, pRun):
        p.add_argument(
            "--outputDirectory", "-o",
            default="out",
            action="store", type=str)


    args = parser.parse_args()
    return args


def _main(args):
    #print args

    if args.subcommand == "describe-workflow":
        doWorkflowHelp(args)
        return

    if args.subcommand == "list-workflows":
        for wf in availableWorkflows:
            print(wf)
        return

    if args.subcommand in ("validate", "generate", "run"):
        try:
            wfg, ct = doValidate(args)
            print("Validation and input resolution succeeded.")
            if args.subcommand == "validate": return 0
        except (TableValidationError, InputResolutionError) as e:
            print("Condition table validation error:", e)
            return 1

    if args.subcommand == "generate":
        doGenerate(args, wfg, ct)

    elif args.subcommand == "run":
        doGenerate(args, wfg, ct)
        doRun(args)


def main():
    args = parseArgs()
    if args.pdb:
        try:
            import ipdb
            with ipdb.launch_ipdb_on_exception():
                _main(args)
            return 0
        except ImportError:
            return _main(args)
    else:
        return _main(args)


if __name__ == '__main__':
    sys.exit(main())
