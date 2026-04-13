from glob import glob
import pandas as pd

apr2020 = slice('2020-04-01T00:00:00', '2020-04-30T23:00:00')
mosaic_file_list = glob('/mnt/data/mosaic_nav/*.txt')
mosaic_nav_df = []
print('\n[INFO] looping over MOSAiC files to read data')
print('[INFO] warnings about mixed types can be ignored')
for file in mosaic_file_list:
    data = pd.read_table(file)
    mosaic_nav_df.append(pd.DataFrame(data)) 
mosaic_nav_df = pd.concat(mosaic_nav_df, axis=0) 
t_label = 'Date/Time (UTC)'
mosaic_nav_df[t_label] = pd.to_datetime(mosaic_nav_df[t_label])
mosaic_data = mosaic_nav_df.set_index(t_label).to_xarray().rename({t_label:'time'}).sortby('time')
mosaic_data = mosaic_data.sel(time=apr2020)
mosaic_data = mosaic_data.resample(time='1h').mean()

mosaic_data.to_netcdf('mosaic_coords_2020-04_1h.nc')