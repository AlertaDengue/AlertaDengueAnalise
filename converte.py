#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Atribui casos de dengue a APS usando a OGR
"""

import ogr
import sys

# Criando a Shapefile com as CAPs
drv = ogr.GetDriverByName('ESRI Shapefile')
ds_in = drv.Open("../cap_sms_4326.shp")
lyr_in = ds_in.GetLayer(0)

geometries = {ogr.ForceToPolygon(feat.GetGeometryRef()): feat.GetFieldAsDouble(feat.GetFieldIndex("COD_AP_SMS")) for feat in lyr_in}




def get_AP(ind,lon, lat):
    """
    Returns the AP corresponding to the point
    """
    # create point geometry
    pt = ogr.Geometry(ogr.wkbPoint)
    pt.SetPoint_2D(0, lon, lat)
    
    # go over all the polygons in the layer see if one include the point
    
    for geo, i in geometries.items():
        # roughly subsets features, instead of go over everything
        if geo.Contains(pt):
            #print ("Coords {},  {} belong to AP {}".format(lat, lon, i))
            break
    return i

if __name__ == "__main__":
    # Criando a Shapefile com os pontos
    source = sys.argv[1]
    drv2 = ogr.GetDriverByName('ESRI Shapefile')
    ds_in2 = drv2.Open(source)
    points_in = ds_in2.GetLayer(0)
    sys.stdout.write("NU_NOTIF, AP\n")
    for ind,j in enumerate(points_in):
        coord = j.GetGeometryRef()
        notif = j.GetFieldAsInteger(j.GetFieldIndex("NU_NOTIF"))
        lon = coord.GetX()
        lat = coord.GetY()
        
        ap = get_AP(ind,lon , lat)
        sys.stdout.write("{}, {}\n".format(notif,  ap))

    len(points_in)



