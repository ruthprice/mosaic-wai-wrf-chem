# Job scripts for launching WRF-Chem-Polar runs for the April 2020 Arctic warm air mass intrusion

## Ruth Price, 2026/04/13

Namelists and SLURM/bash jobscripts for launching WRF and WRF preprocessors:

- `wps/jobscript_wps.sh` - jobscript for WPS: prepares met_em files for WRF with ERA5, adds ocean chlorophyll-a and DMS concentrations to met_em files
- `wps/namelist.wps.YYYY` - namelist: contains options used to run WPS
- `real/jobscript_real_polluted.sh` - jobscript for real.exe: prepares WRF-Chem-Polar input files, including emissions and IC/BC
- `real/jobscript_real_clean.sh` - prepares input files without including aerosol emissions from anthropogenic sources or fires
- `real/namelist.input.YYYY.[polluted/clean]` - namelists: contains options used to run real.exe and WRF-Chem-Polar, with or without anthropogenic and fire emissions respectively
- `wrf-chem/jobscript_wrfchem_polluted.sh` - jobscript for WRF-Chem-Polar: launches a run, including aerosol emissions from anthropogenic sources and fires
- `wrf-chem/jobscript_wrfchem_clean.sh` - launches a run without aerosol emissions from anthropogenic sources and fires

Additional scripts:
- `wps/add_chloroa_wps.py` and `wps/add_dmsocean_wps.py` - Python scripts to read external ocean chlorophyll and DMS concentrations and write to the met_em files
- `real/cams2wrfchem.py` - Python script to read anthropogenic aerosol emissions from CAMS emission dataset and prepare for WRF-Chem-Polar input files
- `real/*.inp` - namelists for WRF-Chem pre-processors
