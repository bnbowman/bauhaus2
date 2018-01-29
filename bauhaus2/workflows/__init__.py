from .arrow     import *
from .ccs       import *
from .consensus import *
from .hmm       import *
from .hmmshort       import *
from .mapping   import *
from .maskedArrow   import *
from .subreads  import *
from .unrolled  import *
from .unrolledArrowByReference import *
from .hqrf      import *
from .primary      import *
from .isoseq_rc0      import *
from .heatmaps       import *
from .barcodingQC       import *
from .cas9Yield       import *
from .sv       import *
from bauhaus2 import Workflow

availableWorkflows = \
 { wf.name() : wf
   for wf in Workflow.__subclasses__() }
