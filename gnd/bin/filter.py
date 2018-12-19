# coding: utf-8

from __future__ import print_function
import argparse
import sys
import time

def file_len(fname):
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
    return i + 1

def printProgressBar (iteration, total, found = 0, prefix = '', suffix = '', decimals = 1, length = 100, fill = '█'):
    """
    Call in a loop to create terminal progress bar
    @params:
        iteration   - Required  : current iteration (Int)
        total       - Required  : total iterations (Int)
        prefix      - Optional  : prefix string (Str)
        suffix      - Optional  : suffix string (Str)
        decimals    - Optional  : positive number of decimals in percent complete (Int)
        length      - Optional  : character length of bar (Int)
        fill        - Optional  : bar fill character (Str)

    Taken from https://stackoverflow.com/a/34325723/9539770
    """
    percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
    filledLength = int(length * iteration // total)
    bar = fill * filledLength + '-' * (length - filledLength)
    print('\r%s |%s| %s%% %s - %i out of %i, found %i' % (prefix, bar, percent, suffix, iteration, total, found), end = '\r')
    # Print New Line on Complete
    if iteration == total: 
        print()

parser = argparse.ArgumentParser(description='Filter an ntriples file by subjects.')
parser.add_argument('--ids', type=str,
                    required=True,
                    help='Path to the file with subject URIs we want to filter by.')
parser.add_argument('--inpath', type=str,
                    required=True,
                    help='Path to the ntriples file we want to filter.')
parser.add_argument('--outpath', type=str,
                    required=True,
                    help='Path to the folder where we want to write our output.')

args = parser.parse_args()

start_time = time.time()
print("\nReading URIs from '{}'".format(args.ids))
ids = set()
num_ids = 0
with open(args.ids) as id_file:
    for line in id_file:
        num_ids += 1
        line = line.strip()
        ids.add(line)
print("  done: {} URIs read in {}".format(num_ids, (time.time() - start_time)))

print("\ndetermine size of '{}':".format(args.inpath))
# num_triples = file_len(args.inpath)
num_triples = 60511976
print("  counted {} triples".format(num_triples))

print("\nExtracting triples from '{}' to '{}'".format(args.inpath, args.outpath))
triple_counter = 0
print("\n")

start_time = time.time()
outfile = open(args.outpath, "w")
num_found = 0
printProgressBar(triple_counter, num_triples, num_found, prefix = 'Progress:', suffix = 'Complete', length = 80)
with open(args.inpath) as triples:
    for triple in triples:
        triple_counter += 1
        printProgressBar(triple_counter, num_triples, num_found, prefix = 'Progress:', suffix = 'Complete', length = 80)
        parts = triple.split()
        if len(parts) > 0:
            subject = parts[0]
            if subject in ids:
                num_found += 1
                outfile.write(triple)
        if triple_counter > 1000:
            print("\n--- %s seconds ---" % (time.time() - start_time))
            sys.exit()

outfile.close
