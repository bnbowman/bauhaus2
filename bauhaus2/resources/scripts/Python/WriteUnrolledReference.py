#! /usr/bin/env pyton

import sys
from pbcore.io import FastaReader, FastaWriter, FastaRecord

MIN_TEMPLATE_SIZE = 50000

refs = list(FastaReader(sys.argv[1]))
adps = list(FastaReader(sys.argv[2]))
outputPrefix = sys.argv[3]

# Convert the adapters to their names
aTypes = []
for adp in adps:
    if   adp.sequence == "ATCTCTCTCAACAACAACAACGGAGGAGGAGGAAAAGAGAGAGAT":
        aTypes.append( "TC6" )
    elif adp.sequence == "ATCTCTCTCAATTTTTTTTTTTTTTTTTTTTTTTAAGAGAGAGAT":
        aTypes.append( "POLYA" )
    elif adp.sequence == "ATCTCTCTCAACAACAACAGGCGAAGAGGAAGGAAAGAGAGAGAT":
        aTypes.append( "SCR" )
    else:
        aTypes.append( "OTHER" )

def _createForwardUnrolledReference( refIdx, reference, adps ):
    refName = "Reference{0}_Forward".format(refIdx)
    seq = ""
    idx = 0
    adpPos = []
    while len(seq) < MIN_TEMPLATE_SIZE:
        if idx == 0:
            seq += reference.sequence.upper()
        else:
            seq += reference.reverseComplement().sequence.upper()
        adpPos.append( (refName, len(seq), len(seq) + len(adps[idx].sequence), idx) )
        seq += adps[idx].sequence.upper()
        idx += 1
        if idx >= len(adps):
            idx = 0
    return FastaRecord(refName, seq), adpPos

def _createReverseUnrolledReference( refIdx, reference, adps ):
    refName = "Reference{0}_Reverse".format(refIdx)
    seq = ""
    idx = 0
    adpPos = []
    while len(seq) < MIN_TEMPLATE_SIZE:
        if idx == 0:
            seq += reference.reverseComplement().sequence.upper()
        else:
            seq += reference.sequence.upper()
        adpPos.append( (refName, len(seq), len(seq) + len(adps[idx].sequence), idx) )
        seq += adps[idx].sequence.upper()
        idx += 1
        if idx >= len(adps):
            idx = 0
    return FastaRecord(refName, seq), adpPos

def _createUnrolledReference( refIdx, reference, adp ):
    refName = "Reference{0}".format(refIdx)
    seq = ""
    idx = 0
    adpPos = []
    while len(seq) < MIN_TEMPLATE_SIZE:
        if idx % 2 == 0:
            seq += reference.reverseComplement().sequence.upper()
        else:
            seq += reference.sequence.upper()
        adpPos.append( (refName, len(seq), len(seq) + len(adp.sequence), 0) )
        seq += adp.sequence.upper()
        idx += 1
    return FastaRecord(refName, seq), adpPos

def createUnrolledReferences( references, adapters ):
    if len(adapters) == 0 or len(adapters) > 2:
        raise SystemExit
    unrolled = []
    for refIdx, ref in enumerate( references ):
        if len(adapters) == 1:
            unrolled.append(_createUnrolledReference(refIdx, ref, adapters[0]))
        elif len(adapters) == 2:
            unrolled.append(_createForwardUnrolledReference(refIdx, ref, adapters))
            unrolled.append(_createReverseUnrolledReference(refIdx, ref, adapters))
    recs = []
    pos  = []
    for rec, pList in unrolled:
        recs.append( rec )
        for pTuple in pList:
            pos.append( pTuple )
    return recs, pos

def writeRecords( records, prefix ):
    with FastaWriter( prefix + ".fasta" ) as handle:
        for record in records:
            handle.writeRecord( record )

def writePositions( positions, prefix ):
    with open( prefix + "_pos.csv", 'w' ) as handle:
        handle.write( "Reference,AdpStart,AdpEnd,AdpType\n" )
        print (positions)
        for ref, s, e, idx in positions:
            handle.write( "{0},{1},{2},{3}\n".format(ref, s, e, aTypes[idx]) )

unrolled, positions = createUnrolledReferences( refs, adps )
writeRecords( unrolled, outputPrefix )
writePositions( positions, outputPrefix )
