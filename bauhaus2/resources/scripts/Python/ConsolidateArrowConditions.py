import argparse
import csv


def parseArgs():
    """
    parse command-line arguments
    aset  -> path to alignmentset.xml
    arrow -> path to constantArrow output csv
    """
    parser = argparse.ArgumentParser(description=\
                                     'Generate mapping metrics CSV')
    parser.add_argument('--arrow-csv',
                        required=True,
                        help='path to errormode.csv')
    parser.add_argument('--output',
                        required=True,
                        help='path to output csv')
    args = parser.parse_args()

    return args.arrow_csv, args.output

def readArrowCsv(arrow_csv):
    errormodes = []
    with open(arrow_csv, 'rb') as csvfile:
        reader = csv.DictReader(csvfile)
        fieldnames = reader.fieldnames
        for row in reader:
            condition = '_'.join(row['Condition'].split('_')[0:-1])
            row['Condition'] = condition
            errormodes.append(row)
    return errormodes, fieldnames

def writeSimpleArrowCsv(errormodes, fieldnames, output):
    with open(output, 'wb') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in errormodes:
            writer.writerow(row)

def main():
    arrow_csv, output = parseArgs()
    errormodes, fieldnames = readArrowCsv(arrow_csv)
    writeSimpleArrowCsv(errormodes, fieldnames, output)
    return None

if __name__ == '__main__':
    main()
