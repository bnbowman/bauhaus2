#! /usr/bin/env python

import csv
import sys
from bisect import bisect_left, bisect_right
from collections import defaultdict

from pbcore.io import IndexedBamReader, CmpH5Reader, BamAlignment

PRECISION      = 4
MIN_ADP_LENGTH = 20
MIN_ALN_LENGTH = 4000
N_READS        = None

adpCsvFile = sys.argv[1]
alignFile  = sys.argv[2]
csvFile    = sys.argv[3]
ADAPTER_TYPES = ["TC6", "SCR", "POLYA", "OTHER"]

class AdapterCall(object):
    Zmw     = None
    qStart  = None
    qEnd    = None
    Adapter = None

    def __str__( self ):
        return "<{0}: {1}/{2}_{3} ({4})>".format(self.__class__.__name__, self.Zmw, self.qStart, self.qEnd, self.adapter)


class AlgorithmAdapter(AdapterCall):
    """
    Represent an algorithmic AdapterCall and all it's rich metadata
    """

    def __init__( self, args ):
        if isinstance(args, str):
            self._init_from_list( args.strip().split(',') )
        elif isinstance(args, list) or isinstance(args, tuple):
            self._init_from_list( args )
    
    def _init_from_list( self, vals ):
        assert len(vals) == 11
        self.Zmw           = vals[0]
        self.holeNumber    = int(vals[0].split('/')[1])
        self.qStart        = int(vals[1])
        self.qEnd          = int(vals[2])
        self.accuracy      = round(float(vals[3]), PRECISION)
        self.score         = int(vals[4])
        self.flankingScore = int(vals[5])
        self.passRSII      = True if vals[7].lower() in ["true", "t"] else False
        self.passSequel    = True if vals[8].lower() in ["true", "t"] else False
        self.sequence      = vals[9]
        self.adapter       = vals[10] 

    @classmethod
    def _bool_as_str(self, boolean):
        return "T" if boolean == True else "F"

    @property
    def passRSIIStr(self):
        return self._bool_as_str(self.passRSII)

    @property
    def passSequelStr(self):
        return self._bool_as_str(self.passSequel)


class AlignmentAdapter(AdapterCall):
    """
    Represent a minimal AdapterCall from an alignment
    """
    def __init__( self, *args ):
        if isinstance(args, str):
            self._init_from_list( args.strip().split(',') )
        elif isinstance(args, list) or isinstance(args, tuple):
            self._init_from_list( args )
    
    def __str__( self ):
        return "<AlignmentAdapter: {0}/{1}_{2} ({3})>".format(self.Zmw, self.qStart, self.qEnd, self.adapter)

    def _init_from_list( self, vals ):
        assert len(vals) == 5
        self.Zmw      = str(vals[0])
        self.qStart   = int(vals[1])
        self.qEnd     = int(vals[2])
        self.adapter  = str(vals[3])
        assert self.adapter in ADAPTER_TYPES
        self.sequence = str(vals[4])

    @property
    def isMissing(self):
        return "T" if len(self.sequence) < MIN_ADP_LENGTH else "F"

class AlignmentData(object):
    """
    Summarize alignment quality and other ZMW-wide metrics
    """

    def __init__(self, record):
        assert isinstance( record, BamAlignment )
        self.Zmw     = "{0}/{1}".format(record.movieName, record.holeNumber)
        self.aStart   = record.aStart
        self.aEnd     = record.aEnd
        self.accuracy = round(record.identity, PRECISION)
        self.maxGap   = self._largestGap( record )
        self.SnrA, self.SnrC, self.SnrG, self.SnrT = [round(s, PRECISION) for s in record.hqRegionSnr]
    
    def __str__( self ):
        return "<AlignmentData: {0}/{1}_{2}>".format(self.Zmw, self.aStart, self.aEnd)

    @classmethod
    def _largestGap(cls, record):
        maxLength = 0
        for cType, cLength in record.peer.cigar:
            if cType == 2 and cLength > maxLength:
                maxLength = cLength
        return maxLength


def readAdpCsv( csvFile ):
    adps = defaultdict(list)
    with open( csvFile ) as csvHandle:
        for record in csv.DictReader( csvHandle ):
            ref   = record['Reference']
            start = int(record['AdpStart'])
            stop  = int(record['AdpEnd'])
            aType = record['AdpType']
            adps[ref].append( (start, stop, aType) )
    return adps

def readAlignments( alnFile, adps, minAlnLength=MIN_ALN_LENGTH, nReads=N_READS ):
    # Using that reader, parse the regions aligned to known adapters
    queryAdps = defaultdict(list)
    queryData = {}
    count = 0
    for record in IndexedBamReader( alnFile ):
        if record.tEnd - record.tStart < minAlnLength:
            continue
        count += 1
        if nReads and count > nReads:
            break
        zmw    = "{0}/{1}".format(record.movieName, record.holeNumber)
        refAdps = adps[record.referenceName]
        alnAdps = [adp for adp in refAdps if adp[0] < record.tEnd
                                          if adp[1] > record.tStart]
        queryData[zmw] = AlignmentData( record )
        read   = record.read(aligned=False, orientation="genomic")
        for adpStart, adpEnd, adpType in alnAdps:
            clip = record.clippedTo(adpStart, adpEnd)
            # Skip adapters in SVs / large deletions, since we never had a chance
            if clip.aStart == clip.aEnd:
                continue
            aStart = clip.aStart - record.aStart
            aEnd   = clip.aEnd - record.aStart
            adpSeq = read[aStart:aEnd]
            alnAdp = AlignmentAdapter(zmw, clip.aStart, clip.aEnd, adpType, adpSeq)
            queryAdps[zmw].append( alnAdp )
    return (queryData, queryAdps)

def readAdapterCallCsv( csvFile, alnData ):
    adps = defaultdict(list)
    with open( csvFile ) as handle:
        handle.next()
        for line in handle:
            adp = AlgorithmAdapter(line)
            try:
                data = alnData[adp.Zmw]
            except:
                continue
            if adp.qEnd <= data.aEnd and adp.qStart >= data.aStart:
                adps[adp.Zmw].append( adp )
    return adps

def isAdpHit( adpCalls, qStart, qEnd ):
    for adp in adpCalls:
        if adp.qStart > qEnd:
            return None
        if (adp.qStart <= qStart     and qStart     <= adp.qEnd) or \
           (  qStart   <= adp.qStart and adp.qStart <  qEnd) or \
           (  qStart   <  adp.qEnd   and adp.qEnd   <= qEnd):
            return adp
    return None

def combine_records( adapters, scraps ):
    combined = {}
    # Find and combine true adapter locations with their call, if any
    for alnAdp in adapters:
        hit = isAdpHit( scraps, alnAdp.qStart, alnAdp.qEnd )
        if hit:
            key = (hit.qStart, hit.qEnd)
            combined[key] = (alnAdp.qStart, alnAdp.qEnd, alnAdp.adapter, alnAdp.sequence, "T", "T", "F",
                             hit.qStart, hit.qEnd, alnAdp.adapter, hit.sequence, hit.accuracy, hit.flankingScore, hit.passRSIIStr, hit.passSequelStr)
        else:
            yield (alnAdp.qStart, alnAdp.qEnd, alnAdp.adapter, alnAdp.sequence, "T", "F", alnAdp.isMissing, -1, -1, -1, "N/A", -1, -1, "F", "F")
    # Iterate over the results
    for hit in scraps:
        key = (hit.qStart, hit.qEnd)
        if key in combined:
            yield combined[key]
        else:
            yield (-1, -1, -1, "N/A", "F", "T", "F", hit.qStart, hit.qEnd, hit.adapter, hit.sequence, hit.accuracy, hit.flankingScore, hit.passRSIIStr, hit.passSequelStr)

def compareAdpCalls( alnData, alnAdps, calledAdps ):
    print ("Zmw,ZmwAccuracy,MaximumAlignGap,SnrT,isReal,isHit,isMissing,AdpStart,AdpEnd,AdpType,AdpSequence,CallStart,CallEnd,CallType,CallSequence,CallAccuracy,CallFlankingScore,CallPassRSII,CallPassSequel")
    for zmw, adps in alnAdps.iteritems():
        calls = calledAdps[zmw]
        try:
            data = alnData[zmw]
        except:
            #print "WARNING: No alignment data for ZMW {0}".format( zmw )
            continue
        #print data.aStart, data.aEnd
        #print [(a.qStart, a.qEnd) for a in adps]
        #print [(c.qStart, c.qEnd) for c in calls]
        for aStart, aEnd, aType, aSeq, isReal, isHit, isMissing, cStart, cEnd, cType, cSeq, acc, flank, pRSII, pSeq  in combine_records( adps, calls ):
            print ("{0},{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16},{17},{18}".format(zmw, data.accuracy, data.maxGap, data.SnrT,
                                                                                                                isReal, isHit, isMissing,
                                                                                                                aStart, aEnd, aType, aSeq, 
                                                                                                                cStart, cEnd, cType, cSeq, 
                                                                                                                acc, flank, pRSII, pSeq))

adps             = readAdpCsv( adpCsvFile )
alnData, alnAdps = readAlignments( alignFile, adps )
calledAdps       = readAdapterCallCsv( csvFile, alnData )
compareAdpCalls( alnData, alnAdps, calledAdps )
