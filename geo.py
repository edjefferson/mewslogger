from shapely import Polygon
import fiona
from shapely.geometry import shape, mapping 
from pyproj import Proj, transform
import csv

v84 = Proj(proj="latlong",towgs84="0,0,0",ellps="WGS84")
v36 = Proj(proj="latlong", k=0.9996012717, ellps="airy",
        towgs84="446.448,-125.157,542.060,0.1502,0.2470,0.8421,-20.4894")
vgrid = Proj(init="world:bng")


def convertLL(easting,northing):

    

    vlon36, vlat36 = vgrid(easting, northing, inverse=True)

    converted = transform(v36, v84, vlon36, vlat36)

  

    return converted[1],converted[0]




with open('eggs.csv', 'w', newline='') as csvfile:
  spamwriter = csv.writer(csvfile)
  with fiona.open('osopenusrn_202405.gpkg') as layer:
      for feature in layer:
          print(feature["properties"]["usrn"])
          try:
            geom = shape(feature['geometry'])
            
            lat_lng = convertLL(geom.centroid.x,geom.centroid.y)
            print(convertLL(geom.centroid.x,geom.centroid.y))
            spamwriter.writerow([feature["properties"]["usrn"],lat_lng[0],lat_lng[1]])
          except: 
            spamwriter.writerow([feature["properties"]["usrn"],None,None])

#data = gpd.read_file("osopenusrn_202405.gpkg")
#print(data.head())