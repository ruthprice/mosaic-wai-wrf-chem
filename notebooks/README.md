# Notebooks and python scripts to reproduce figures

## Ruth Price, 2026/04/14

### Pre-processing steps
- `dl_cams.py` and `cams_to_netcdf.sh`: scripts to download CAMS EAC4 data from Copernicus Atmosphere Data Store and convert files to netcdf format. Requires a CDS API key [(see more here](https://ads.atmosphere.copernicus.eu/how-to-api), last accessed 14/04/2026)
- `extract-mosaic-cams.ipynb` and `extract-mosaic-cesm.ipynb`: notebooks to extract position of Polarstern ship from gridded CESM and CAMS data
- `read-and-save-emep-data.ipynb`: notebook to process EMEP PM2.5 measurements from several stations into one netcdf, with homogeneous metadata and coordinates.
- `save-mosaic-lat-lon.py`: script to save hourly mean ship coordinates for April 2020 as netcdf file

### Main code
- `figure-X-description.ipynb`: notebooks for each figure in the manuscript
- `requirements.txt`: conda environment file for this code
- `utils.py`: commonly used functions that are imported into different notebooks

### Wrfpp
wrfpp is an open source package for post-processing of WRF-Chem output, see [website](https://wrf-chem-polar.eu/) and [github](https://github.com/WRF-Chem-Polar/WRF-infra/tree/main/postprocess) (last accessed 14/04/2026). At time of writing it can be used here by downloading the file `wrfpp.py` from github and copying into this directory.
