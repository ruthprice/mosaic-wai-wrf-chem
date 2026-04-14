#!/bin/bash

files="*.grib"
for file_in in $files
do
  echo "Converting $file_in to netCDF"
  file_out="${file_in/.grib/}.nc"
  grib_to_netcdf -o ${file_out} ${file_in}
done

echo "Script finished"
