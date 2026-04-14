# Python script to download CAMS EAC4 data (10.24381/d58bbf47) as used in Figure 4.
# see Copernicus Atmosphere Data Store for more info:
# https://ads.atmosphere.copernicus.eu/how-to-api
#
# Data is downloaded in grib format. cams_to_netcdf.sh can be used to convert to nc


import cdsapi
import os

# Ensure correct API URL (ADS)
os.environ['CDSAPI_URL'] = 'https://ads.atmosphere.copernicus.eu/api'

# Settings --------------------------------------
var = "sulphate_aerosol_mixing_ratio"
#      hydrophilic_black_carbon_aerosol_mixing_ratio
#      hydrophobic_black_carbon_aerosol_mixing_ratio
#      hydrophilic_organic_matter_aerosol_mixing_ratio
#      hydrophobic_organic_matter_aerosol_mixing_ratio
start_date = "2020-04-10"
end_date = "2020-04-20"
# -----------------------------------------------

date = f"{start_date}/{end_date}"
savedir = "/Users/ruthprice/mosaic-wai-wrf-chem-data/cams"

dataset = "cams-global-reanalysis-eac4"
request = {
    "variable": [var],
    "model_level": ["60"],
    "date": [date],
    "time": [
        "00:00", "03:00", "06:00",
        "09:00", "12:00", "15:00",
        "18:00", "21:00"
    ],
    "data_format": "grib",
    "area": [90, -180, 0, 180]
}

filename = f"{savedir}/cams_eac4_{var}_{start_date}_{end_date}.grib"

client = cdsapi.Client()
client.retrieve(dataset, request).download(filename)
