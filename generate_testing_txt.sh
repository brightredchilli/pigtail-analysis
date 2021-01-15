#!/usr/bin/env python
from os import listdir
from os.path import isfile, join


def filenames(path):
    return frozenset(f for f in listdir(path) if isfile(join(path, f)))


def files(name):
    with open(name) as f:
        return f.read()


full = frozenset(f'data/obj/{f}' for f in filenames('frames'))
train = frozenset(files('train.txt').split())
test = frozenset(files('test.txt').split())


testing = full - train - test


for t in sorted(testing):
  if 'DS_Store' not in t:
    print(t)
