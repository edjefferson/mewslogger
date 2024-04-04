
import pandas as pd
from pyproj import Proj, transform

v84 = Proj(proj="latlong",towgs84="0,0,0",ellps="WGS84")
v36 = Proj(proj="latlong", k=0.9996012717, ellps="airy",
        towgs84="446.448,-125.157,542.060,0.1502,0.2470,0.8421,-20.4894")
vgrid = Proj(init="world:bng")


def vectorized_convert(df):
    vlon36, vlat36 = vgrid(df['easting'].values, 
                           df['northing'].values, 
                           inverse=True)
    converted = transform(v36, v84, vlon36, vlat36)
    df['longitude'] = converted[0]
    df['latitude'] = converted[1]
    return df

df = pd.read_csv('os_names_northing_easting.csv',header=None,names=["id","easting","northing"])
print(df)
new_df = vectorized_convert(df)
new_df.to_csv('os_names_lat_lng.csv',index=False)

print(new_df)