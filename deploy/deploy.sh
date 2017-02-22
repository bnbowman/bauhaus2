#!/bin/bash

# - Run this only on a CentOS7 node, as user bamboo

# Module system
. /mnt/software/Modules/current/init/bash
module purge
module load python/3.5.1

set -euo pipefail
set -x

#
# Set up the virtualenv
#
BAUHAUS2_VE=${BAUHAUS2_VE:-/pbi/dept/itg/bauhaus2/python-ve}
rm -rf $BAUHAUS2_VE

set +u
/mnt/software/v/virtualenv/13.0.1/virtualenv.py -p python3 $BAUHAUS2_VE
source $BAUHAUS2_VE/bin/activate
set -u

pip install -r requirements.txt
pip install snakemake
python setup.py install

#
# Set up the wrapper scripts
#
cat > /mnt/software/b/bauhaus2/bauhaus2 <<EOF
#!/bin/bash
(source /pbi/dept/itg/bauhaus2/python-ve/bin/activate && bauhaus2 \$*)
EOF
chmod +x /mnt/software/b/bauhaus2/bauhaus2

cat > /mnt/software/b/bauhaus2/snakemake <<EOF
#!/bin/bash
(source /pbi/dept/itg/bauhaus2/python-ve/bin/activate && snakemake \$*)
EOF
chmod +x /mnt/software/b/bauhaus2/snakemake
