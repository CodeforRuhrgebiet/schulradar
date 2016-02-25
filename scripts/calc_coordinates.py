#! python
#-*- coding: utf-8 -*-

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)) + '/GKConverter')
import gkconverter as GKConverter

(x, y) = GKConverter.convert_GK_to_lat_long(float(sys.argv[1]), float(sys.argv[2]))

print x
print y
#print "%s,%s" % (x, y)
