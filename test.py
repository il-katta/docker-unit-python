#!/usr/bin/env python
from sys import exit
from osgeo import gdal

if not gdal.ColorTable():
    exit(1)

if not gdal.GetDriverByName("GTiff"):
    exit(1)
