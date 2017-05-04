import os
import csv
import argparse
import numpy as np
from pbcore.io import AlignmentSet


def parseArgs():
    """
    parse command-line arguments
    asets  -> paths to alignmentset.xmls
    arrow-csv -> path to constantArrow output csv
    """
    parser = argparse.ArgumentParser(
        description='Generate mapping metrics CSV')
    parser.add_argument('--asets',
                        required=True,
                        nargs='+',
                        help='alignmentset to grab metrics from')
    parser.add_argument('--arrow-csv',
                        required=True,
                        help='arrow csv for choosing ZMWs')
    parser.add_argument('--output',
                        required=True,
                        help='output csv for storing mapped metrics')
    args = parser.parse_args()

    return args.asets, args.arrow_csv, args.output

def grabArrowZmwsByCondition(arrow_csv, condition):
    """
    read contents of arrow csv into dictionary. return numpy array of ZMWs
    """
    arrow_zmws = []
    with open(arrow_csv) as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            if row['Condition'] == condition:
                arrow_zmws.append(row['ZMW'])
    return np.array(arrow_zmws, dtype=int)

def grabConditionName(aset):
    # path to aset is structured, split string to get condition name
    condition = aset.split(os.path.sep)[1]
    return condition

def openAlignmentSet(aset):
    alignments = AlignmentSet(aset)
    return alignments

def initializeMappedMetricsDictionary(zmws):
    """
    initialize dictionary for storing the mapped metrics for the arrow ZMWs
    """
    mapped_metrics = {'ZMW': np.empty((len(zmws), ), dtype=int),
                      'Condition': [],
                      'median-pw-A': np.empty((len(zmws), ), dtype='f'),
                      'median-pw-C': np.empty((len(zmws), ), dtype='f'),
                      'median-pw-G': np.empty((len(zmws), ), dtype='f'),
                      'median-pw-T': np.empty((len(zmws), ), dtype='f'),
                      'median-ipd-A': np.empty((len(zmws), ), dtype='f'),
                      'median-ipd-C': np.empty((len(zmws), ), dtype='f'),
                      'median-ipd-G': np.empty((len(zmws), ), dtype='f'),
                      'median-ipd-T': np.empty((len(zmws), ), dtype='f'),
                      'start-time': np.empty((len(zmws), ), dtype='f'),
                      'end-time': np.empty((len(zmws), ), dtype='f'),
                      'aStart': np.empty((len(zmws), ), dtype='f'),
                      'aEnd': np.empty((len(zmws), ), dtype='f'),
                      'spasmid': np.empty((len(zmws), ), dtype='f')}

    return mapped_metrics

def grabAlignmentPulseCalls(alignment):
    """
    retrieve pulsecalls from alignment. if pulsecall tag not present,
    return list of nans
    """
    if 'pc' in [tag[0] for tag in alignment.peer.tags]:
        # check if pc info is available
        pcs = alignment.peer.get_tag('pc')
    else:
        # if pc is not available, initialize array of capital Ns
        pcs = np.empty((alignment.aEnd+1, ), dtype='a1')
        pcs[:] = 'N'

    return pcs

def grabAlignmentPulseWidths(alignment):
    """
    retrieve pulsewidths from alignment. if pulsewidth tag not present,
    return list of nans
    """
    if 'pw' in [tag[0] for tag in alignment.peer.tags]:
        # check if pw info is available
        pws = alignment.PulseWidth()
    else:
        # if pw is not available, initialize to array of nans
        pws = np.empty((len(alignment.reference()), ))
        pws[:] = np.nan

    return pws

def grabAlignmentStartFrames(alignment):

    """
    retrieve start frames from alignment. if start frames tag not present,
    return list of nans. Note that start-frames are pulse-indexed.
    """
    if 'sf' in [tag[0] for tag in alignment.peer.tags]:
        # check if sf info is available
        sfs = alignment.peer.get_tag('sf')
    else:
        # if sf is not available, initialize to array of nans
        sfs = np.empty((alignment.aEnd+1, ))
        sfs[:] = np.nan

    return sfs

def bas2pls(pulses):
    """
    return pulse-index mapping of basecalls
    """
    pulses = np.array(list(pulses), dtype='a1')
    return np.flatnonzero(pulses[(pulses != 'a') &
                                 (pulses != 'c') &
                                 (pulses != 'g') &
                                 (pulses != 't')])

def getBaseStartframe(base, pulses, sfs, qstart):
    """
    return start-frame of particular basecall
    """
    sf_by_base = [sfs[basecall] for basecall in bas2pls(pulses)]
    base_sf = sf_by_base[base - qstart]
    return base_sf

def sortPwAndIpdByBase(pws, ipds, reference):
    """
    sort pulse widths and ipds by base
    """
    pw = {'A': [], 'C': [], 'G': [], 'T': [], '-': []}
    ipd = {'A': [], 'C': [], 'G': [], 'T': [], '-': []}
    EXCLUDED = 65535
    for i, base in enumerate(reference):
        if pws[i] != EXCLUDED and ipds[i] != EXCLUDED:
            # they weren't detected (i.e. deletions). 65535 is a placeholder
            base = base.upper()
            pw[base].append(pws[i])
            ipd[base].append(ipds[i])
    return pw, ipd

def addAlignmentMetrics(mapped_metrics, cnt, alignment, 
                        pw, ipd, sfs, pcs, astart, aend,
                        qstart, framerate, condition):
    """
    store metrics from particular alignment
    """
    mapped_metrics['ZMW'][cnt] = alignment.HoleNumber
    mapped_metrics['Condition'].append(condition)
    mapped_metrics['median-pw-A'][cnt] = np.divide(np.median(pw['A']),
                                                   framerate)
    mapped_metrics['median-pw-C'][cnt] = np.divide(np.median(pw['C']),
                                                   framerate)
    mapped_metrics['median-pw-G'][cnt] = np.divide(np.median(pw['G']),
                                                   framerate)
    mapped_metrics['median-pw-T'][cnt] = np.divide(np.median(pw['T']),
                                                   framerate)
    mapped_metrics['median-ipd-A'][cnt] = np.divide(np.median(ipd['A']),
                                                    framerate)
    mapped_metrics['median-ipd-C'][cnt] = np.divide(np.median(ipd['C']),
                                                    framerate)
    mapped_metrics['median-ipd-G'][cnt] = np.divide(np.median(ipd['G']),
                                                    framerate)
    mapped_metrics['median-ipd-T'][cnt] = np.divide(np.median(ipd['T']),
                                                    framerate)
    mapped_metrics['start-time'][cnt] = np.divide(getBaseStartframe(astart,
                                                                    pcs,
                                                                    sfs,
                                                                    qstart),
                                                  framerate)
    mapped_metrics['end-time'][cnt] = np.divide(getBaseStartframe(aend - 1,
                                                                  pcs,
                                                                  sfs,
                                                                  qstart),
                                                framerate)
    mapped_metrics['aStart'][cnt] = alignment.aStart
    mapped_metrics['aEnd'][cnt] = alignment.aEnd
    nErrs = alignment.nMM + alignment.nDel + alignment.nIns
    mapped_metrics['spasmid'][cnt] = 1. - np.divide(nErrs,
                                                    alignment.tEnd - \
                                                    alignment.tStart,
                                                    dtype='f')
    return mapped_metrics

def grabMappedMetrics(condition, alignments, arrow_zmws):
    """
    grab mapped metrics from ZMWs fit with constant Arrow model
    """
    index = alignments.index
    # alignment_indices of ZMWs fit w/ Arrow
    intersect_indices = np.flatnonzero(np.in1d(index['holeNumber'],
                                               arrow_zmws))

    mapped_metrics = initializeMappedMetricsDictionary(intersect_indices)
    for cnt, alignment_id in enumerate(intersect_indices):
        alignment = alignments[alignment_id]
        framerate = alignments.readGroupTable[
                                    'MovieName' == alignment.movieName][
                                    'FrameRate']
        pcs = grabAlignmentPulseCalls(alignment)
        pws = grabAlignmentPulseWidths(alignment)
        sfs = grabAlignmentStartFrames(alignment)
        ipds = alignment.IPD() # ipds are always stored
        pw, ipd = sortPwAndIpdByBase(pws, ipds, alignment.reference())
        astart = alignment.aStart
        aend = alignment.aEnd
        qstart = alignment.qStart
        mapped_metrics = addAlignmentMetrics(mapped_metrics,
                                             cnt,
                                             alignment,
                                             pw,
                                             ipd,
                                             sfs,
                                             pcs,
                                             astart,
                                             aend,
                                             qstart,
                                             framerate,
                                             condition)

    return mapped_metrics

def writeMappedMetricsCsv(mapped_metrics, output):
    """
    write mapped metrics to csv file
    """
    columns = ['ZMW', 'Condition', 'spasmid', 'aStart', 'aEnd',
               'start-time', 'end-time', 'median-pw-A', 'median-pw-C',
               'median-pw-G', 'median-pw-T', 'median-ipd-A', 'median-ipd-C',
               'median-ipd-G', 'median-ipd-T']

    with open(output, 'wb') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=columns)
        writer.writeheader()
        for metrics in mapped_metrics:
            for row_index, zmw in enumerate(metrics[columns[0]]):
                dump = {column: metrics[column][row_index]
                        for column in columns}
                writer.writerow(dump)

def main():
    asets, arrow_csv, output = parseArgs()
    conditions = [grabConditionName(aset) for aset in asets]
    arrow_zmws_by_condition = [grabArrowZmwsByCondition(arrow_csv,
                                                        condition)
                               for condition in conditions]
    alignments_by_condition = [openAlignmentSet(aset) for aset in asets]
    mapped_metrics = [grabMappedMetrics(arg[0], arg[1], arg[2])
                      for arg in zip(conditions,
                                     alignments_by_condition,
                                     arrow_zmws_by_condition)]
    writeMappedMetricsCsv(mapped_metrics, output)
    return None

if __name__ == '__main__':
    main()
