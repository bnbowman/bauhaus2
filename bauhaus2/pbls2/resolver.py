from future import standard_library
standard_library.install_aliases()
from builtins import object
__all__ = [ "Resolver" ]


import requests, json, os.path as op, re
from glob import glob
try:
    from urllib.parse import urlparse
except: # Py3K
    from urllib.parse import urlparse

from .exceptions import DataNotFound, ResolverFailure, InvalidDataset

# We use the nibbler service to lookup run-codes until there is an
# alternative means.  We shouldn't use it to look up jobs.
def _nibble(query):
    r = requests.get("http://nibbler/" + query)
    if not r.ok:
        raise ResolverFailure("Nibbler failure: " + query)
    else:
        return json.loads(r.content.decode("UTF-8"))

def _isRuncode(runCode):
    return isinstance(runCode, str) and re.match("\d{7}-\d{4}", runCode)

def _isJobId(jobId):
    return isinstance(jobId, int)


class Resolver(object):
    """
    A `Resolver` object provides means to "resolve" identifiers to
    fully-qualified paths in PacBio NFS space.

    In particular, we can resolve: runcodes, secondary job
    identifiers, reference names (to the reference FASTA or the
    reference "mask")
    """
    REFERENCE_MASKS_ROOT = "/pbi/dept/consensus/bauhaus/genome-masks/"  # Maintained by consensus group
    REFERENCES_ROOT = "/pbi/dept/secondary/siv/references"              # This is a central location for SA3+ references
    BARCODE_SETS_ROOT = "/pbi/dept/secondary/siv/barcodes"              # This is the central location for SA3+ barcodeSets
    ZIA_PROJECTS_ROOT = "/pbi/dept/itg/zia/projects"                    # This is where Zia stores its projects

    SMRTLINK_SERVER_TO_JOBS_ROOT = \
        { serverName : ("/pbi/" + smrtLinkJobPath + "/smrtlink/" + smrtLinkId + smrtLinkFolder + "/userdata/jobs_root")
          for (serverName, smrtLinkJobPath, smrtLinkId, smrtLinkFolder) in [ ("smrtlink-beta", "dept/secondary/siv", "smrtlink-beta", "/smrtsuite"), 
                                                             ("smrtlink-alpha", "dept/secondary/siv", "smrtlink-alpha", "/smrtsuite"), 
                                                             ("smrtlink-siv", "dept/secondary/siv", "smrtlink-siv", "/smrtsuite"), 
                                                             ("smrtlink-internal", "dept/secondary/siv", "smrtlink-internal", "/smrtsuite"),
                                                             ("smrtlink-siv-alpha", "dept/secondary/siv", "smrtlink-siv-alpha", "/smrtsuite"),
                                                             ("smrtlink-sms", "dept/secondary/siv", "smrtlink-sms", "/smrtsuite"),
                                                             ("smrtlink-release", "analysis", "release", "/smrtsuite"),
                                                             ("smrtlink-mfg", "analysis", "mfg", "/smrtlink")] }

    def __init__(self):
        self._selfCheck()

    def _selfCheck(self):
        """
        Test connectivity to the services behind the resolver
        """
        try:
            r = requests.get("http://nibbler")
            if not r.ok:
                raise ResolverFailure("Nibbler unavailable?")
        except requests.ConnectionError:
                raise ResolverFailure("Nibbler unavailable?")

        if not op.exists(self.REFERENCES_ROOT):
            raise ResolverFailure("NFS unavailable?")

    def resolveRunCode(self, runCode):
        """
        NFS path for run directory from runCode
        """
        if not _isRuncode(runCode):
            raise ValueError('Argument "%s" does not appear to be a runcode' % runCode)
        j = _nibble("collection?runcode=%s" % runCode)
        path = urlparse(j[0]["path"]).path
        if not path:
            raise DataNotFound(runCode)
        else:
            return path

    def resolvePrimaryPath(self, runCode, reportsFolder=""):
        """
        NFS path for run directory for reports directory from runCode and
        reportsFolder.
        """
        return op.join(self.resolveRunCode(runCode), reportsFolder)

    def findSubreadSet(self, reportsPath):
        """
        Given the reports path, find the subreadset within
        """
        subreadsFnames = glob(op.join(reportsPath, "*.subreadset.xml"))
        if len(subreadsFnames) < 1:
            raise DataNotFound("SubreadSet not found in %s" % reportsPath)
        elif len(subreadsFnames) > 1:
            raise DataNotFound("Multiple SubreadSets present: %s" % reportsPath)
        return subreadsFnames[0]

    def findAlignmentSet(self, jobDir):
        """
        Given the secondary job path (SMRTlink), find the alignment set within
        """
        candidates = (glob(op.join(jobDir,
                                   "tasks/pbcoretools.tasks.gather_alignmentset-1/file.alignmentset.xml")) + 
                      glob(op.join(jobDir,
                                   "tasks/pbcoretools.tasks.gather_ccs_alignmentset-1/file.consensusalignmentset.xml")))
        if len(candidates) < 1:
            raise DataNotFound("AlignmentSet not found in job directory %s " % jobDir)
        elif len(candidates) > 1:
            raise DataNotFound("Multiple AlignmentSets present in job directory %s" % jobDir)
        else:
            return candidates[0]
            
    def findSmrtlinkSubreadSet(self, jobDir):
        """
        Given the secondary job path (SMRTlink), find the subread set within
        """
        with open(op.join(jobDir,"pbscala-job.sh")) as f:
            for line in f:
                if "eid_subread" in line:
                    list_of_words = line.split()
                    for string in list_of_words:
                        if ('eid_subread' in string):
                            return string.rsplit(':')[1].rsplit('xml')[0]+'xml'

    def resolveSubreadSet(self, runCode, reportsFolder=""):
        reportsPath = self.resolvePrimaryPath(runCode, reportsFolder)
        return self.findSubreadSet(reportsPath)

    def resolveReference(self, referenceName):
        referenceFasta = op.join(self.REFERENCES_ROOT, referenceName, "sequence", referenceName + ".fasta")
        if op.isfile(referenceName):
            if not op.isfile(referenceName + ".fai"):
                return DataNotFound("missing .fai index file for " + referenceName)
            return referenceName
        elif op.isfile(referenceFasta):
            return referenceFasta
        elif not op.exists(self.REFERENCES_ROOT):
            raise ResolverFailure("NFS unavailable?")
        else:
            raise DataNotFound(referenceName)

    def resolveReferenceSet(self, referenceName):
        # Here we serch two possible referencesets: referenceset.xml and referenceName.referenceset.xml
        # These two referencesets may share the same UUID so should exist at the same time
        candidates = (glob(op.join(self.REFERENCES_ROOT, referenceName, "referenceset.xml")) + 
                      glob(op.join(self.REFERENCES_ROOT, referenceName, referenceName + ".referenceset.xml")))
        if not op.exists(self.REFERENCES_ROOT):
            raise ResolverFailure("NFS unavailable?")
        else:
            if len(candidates) < 1:
                raise DataNotFound(referenceSet)
            elif len(candidates) > 1:
                raise DataNotFound("Multiple ReferenceSets xml files present")
            else:
                return candidates[0]

    def resolveArrowTraining(self, trainingPath):
        if not trainingPath: return None, None
        if trainingPath.isdigit():
            trainingPath = op.join(self.ZIA_PROJECTS_ROOT, trainingPath, "fit.json")
        if not op.exists(trainingPath): raise DataNotFound(trainingPath)
        with open(trainingPath) as h:
            try:
                d = json.load(h)
                spec = d["ChemistryName"]
                return trainingPath, spec
            except:
                raise InvalidDataSet("%s is not an Arrow training file" % trainingPath)

    def resolveReferenceMask(self, referenceName):
        maskGff = op.join(self.REFERENCE_MASKS_ROOT, referenceName + "-mask.gff")
        if op.isfile(maskGff):
            return maskGff
        elif not op.exists(self.REFERENCE_MASKS_ROOT):
            raise ResolverFailure("NFS unavailable?")
        else:
            raise DataNotFound("Reference mask (required for CoverageTitration) not found for " + referenceName)

    def resolveJob(self, smrtLinkServer, jobId):
        if smrtLinkServer not in self.SMRTLINK_SERVER_TO_JOBS_ROOT:
            raise DataNotFound("Unrecognized SMRTLink server: %s" % smrtLinkServer)
        jobsRoot = self.SMRTLINK_SERVER_TO_JOBS_ROOT[smrtLinkServer]
        if not op.exists(jobsRoot):
            raise ResolverFailure("NFS unavailable?")
        jobId = int(jobId)
        prefix = jobId // 1000
        jobPath = op.join(jobsRoot, "%03d" % prefix, "%06d" % jobId)
        if not op.isdir(jobPath):
            raise DataNotFound("Job dir not found: %s:%d" % (smrtLinkServer, jobId))
        return jobPath

    def resolveReferenceForJob(self, smrtLinkServer, jobId):
        raise NotImplementedError

    def resolveAlignmentSet(self, smrtLinkServer, jobId):
        jobDir = self.resolveJob(smrtLinkServer, jobId)
        return self.findAlignmentSet(jobDir)
    
    def resolveSmrtlinkSubreadSet(self, smrtLinkServer, jobId):
        jobDir = self.resolveJob(smrtLinkServer, jobId)
        return self.findSmrtlinkSubreadSet(jobDir)
        
    def resolveBarcodeSet(self, barcodeSet):
        if op.isfile(barcodeSet):
            return barcodeSet
        else:
            raise DataNotFound(barcodeSet)
            
    def resolveAdapter(self, adapter):
        if op.isfile(adapter):
            return adapter
        else:
            raise DataNotFound(adapter)
            
    def ensureSubreadSet(self, subreadSet):
        if not (subreadSet.endswith(".subreadset.xml") or subreadSet.endswith(".subreads.bam")):
            raise InvalidDataset("%s not a subreadset" % subreadSet)
        elif not op.isfile(subreadSet):
            raise DataNotFound("SubreadSet %s not found" % subreadSet)
        else:
            return subreadSet

    def ensureAlignmentSet(self, alignmentSet):
        if not (alignmentSet.endswith(".alignmentset.xml") or alignmentSet.endswith(".aligned_subreads.bam") 
                or alignmentSet.endswith(".consensusalignmentset.xml")):
            raise InvalidDataset("%s not an alignmentset" % alignmentSet)
        elif not op.isfile(alignmentSet):
            raise DataNotFound("AlignmentSet %s not found" % alignmentSet)
        else:
            return alignmentSet

    def ensureTraceH5File(self, traceH5File):
        if not traceH5File.endswith(".trc.h5"):
            raise InvalidDataset("%s not an trc.h5 file" % traceH5File)
        elif not op.isfile(traceH5File):
            raise DataNotFound("Trc.h5 file %s not found" % traceH5File)
        else:
            return traceH5File
