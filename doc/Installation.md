
# Installation and development of `bauhaus2`

## Use the module on the PacBio cluster

If you are a PacBio-internal user and you just want to *use*
`bauhaus2`, we maintain a stable installation for general use via the
*modules* system.  Simply run


```sh
$ module load bauhaus2
```

and the tools `bauhaus2` and `snakemake` will be put in your system
path.

## Actual installation

If you want to develop on `bauhaus2` (to add a workflow for example),
you should install it in your own *virtualenv* (a sandbox for Python
libraries).  Instructions below are tailored for the PacBio cluster
environment:


```sh
# Checkout the bauhaus2 code
$ git clone git@github.com:PacificBiosciences/bauhaus2.git
$ cd bauhaus2

# Get python3 and virtualenv in our PATH
$ module add python/3.5.1
$ module add virtualenv

# Create a Python3 virtualenv, and *activate* it, which
# means we will be put in an isolated sandbox for Python
# code
$ virtualenv -p python3 VE
$ source ./VE/bin/activate

# Install prerequisites...
(VE)$ pip install -r requirements.txt
(VE)$ pip install -r requirements-test.txt

# Install snakemake, which is needed to *run* workflows
(VE)$ pip install snakemake

# Install bauhaus2 for development
(VE)$ python setup.py develop

# To exit the virtualenv later on, we do:
(VE)$ deactivate
$
```

Now, whenever you want to use `bauhaus2` or run `bauhaus2` workflows, we need to
activate the virtualenv again,

```sh
$ source /path/to/my/bauhaus2/VE/bin/activate
(VE)$ bauhaus2 ...
```

## Development guidelines

TODO