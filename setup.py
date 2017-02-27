from __future__ import absolute_import
from __future__ import print_function
from setuptools import setup, Extension, find_packages
import os.path
import sys

REQUIREMENTS_TXT = "requirements.txt"

globals = {}
exec(compile(open("bauhaus2/__version__.py").read(), "bauhaus2/__version__.py", 'exec'), globals)
__VERSION__ = globals["__VERSION__"]

def _get_local_file(file_name):
    return os.path.join(os.path.dirname(__file__), file_name)

def _get_requirements(file_name):
    with open(file_name, 'r') as f:
        reqs = [line for line in f if not line.startswith("#")]
    return reqs

def _get_local_requirements(file_name):
    return _get_requirements(_get_local_file(file_name))

setup(
    name = "bauhaus2",
    version=__VERSION__,
    author="David Alexander",
    author_email="dalexander@pacificbiosciences.com",
    description="Snakemake workflows for internal analysis at PacBio",
    license=open("COPYING").read(),
    packages = find_packages('.'),
    zip_safe = False,
    entry_points = {
        "console_scripts" : [ "bauhaus2 = bauhaus2.main:main" ]
    },
    package_data={ "bauhaus2.workflows.snakemake" : [ "*.snake" ],
                   "bauhaus2.workflows.runtime"   : [ "*.py" ],
                   "bauhaus2.workflows.config"    : [ "*.json" ],
                   "bauhaus2.scripts"             : [ "run.sh", "prefix.sh" ],
                   "bauhaus2.scripts.R"           : [ "*.R" ],
                   "bauhaus2.scripts.Python"      : [ "*.py" ],
                   "bauhaus2.scripts.MATLAB"      : [ "*.m" ] },
    install_requires=_get_local_requirements(REQUIREMENTS_TXT)
)
