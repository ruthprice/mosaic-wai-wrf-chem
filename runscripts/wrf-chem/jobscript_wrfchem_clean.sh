#!/bin/bash
#-------- Set up and run WRF-Chem with MOZART-MOSAIC-4bin-AQ --------
#
# Louis Marelle, 2025/03
#

# Resources used
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --mem=60G
#SBATCH --time=168:00:00


#-------- Input --------
CASENAME='MOSAIC_APRIL_VN46'
CASENAME_COMMENT='NO_ANTHRO_NO_FIRES'

# Root directory with the compiled WRF executables (main/wrf.exe and main/real.exe)
WRFDIR=~/WRF/src/WRF-Chem-Polar

# Simulation start year and month
yys=2020
mms=03
dds=15
hhs=00
# Simulation end year, month, day, hour
yye=2020
mme=05
dde=01
hhe=00

NAMELIST="namelist.input.YYYY.polluted"


#-------- Parameters --------
# Root directory for WRF input/output
OUTDIR_ROOT="/data/$(whoami)/WRFChem/${CASENAME}"
SCRATCH_ROOT="/scratchu/$(whoami)/${CASENAME}"
INDIR_ROOT="$OUTDIR_ROOT"
# WRF-Chem input data directory
WRFCHEM_INPUT_DATA_DIR="/data/marelle/marelle/WRFChem/wrf_utils/wrfchem_input"


#-------- Set up job environment --------
# Load modules used for WRF compilation
module purge
module load /proju/wrf-chem/software/libraries/gcc-v11.2.0/netcdf-fortran-v4.6.2_netcdf-c-v4.9.3_hdf5-v1.14.6_zlib-v1.3.1.module

# Set run start and end date
date_s="$yys-$mms-$dds"
date_e="$yye-$mme-$dde"


#-------- Set up WRF input and output directories & files  --------
# Run id
ID="$(date +"%Y%m%d").$SLURM_JOBID"

# Case name for the output folder
if [ -n "$CASENAME_COMMENT" ]; then
  CASENAME_COMMENT="_${CASENAME_COMMENT}"
fi

# Directory containing real output (e.g. wrfinput_d01, wrfbdy_d01 files)
REALDIR="${INDIR_ROOT}/real_${CASENAME}${CASENAME_COMMENT}_$(date -d "$date_s" "+%Y")"
# Directory containing WRF-Chem output
OUTDIR="${OUTDIR_ROOT}/DONE.${CASENAME}${CASENAME_COMMENT}.$ID"
mkdir "$OUTDIR"

# Also create a temporary run directory
SCRATCH="$SCRATCH_ROOT/DONE.${CASENAME}${CASENAME_COMMENT}.$ID.scratch"
rm -rf "$SCRATCH"
mkdir "$SCRATCH"
cd "$SCRATCH" || exit

# Write the info on input/output directories to run log file
echo " "
echo "-------- $SLURM_JOB_NAME --------"
echo "Running from $date_s to $date_e"
echo "Running version wrf.exe from $WRFDIR"
echo "Running on scratchdir $SCRATCH"
echo "Writing output to $OUTDIR"
echo "Input files from real.exe taken from $REALDIR"

# Save this slurm script to the output directory
cp "$0" "$OUTDIR/jobscript_wrf.sh"


#-------- Run WRF  --------
cd "$SCRATCH" || exit

#---- Copy all needed files to scrach space
# Input files from run setup directory
cp "$SLURM_SUBMIT_DIR/"* "$SCRATCH/"
# Executables and WRF aux files from WRFDIR
cp "$WRFDIR/run/"* "$SCRATCH/"
cp "$WRFDIR/main/wrf.exe" "$SCRATCH/wrf.exe"

#  Copy and prepare the WRF namelist, set up run start and end dates
cp "$SLURM_SUBMIT_DIR/${NAMELIST}" namelist.input
# Init spectral nudging parameters
# We only nudge over the scale $nudging_scale in meters
nudging_scale=1000000
wrf_dx=$(sed -n -e 's/^[ ]*dx[ ]*=[ ]*//p' namelist.input | sed -n -e 's/,.*//p')
wrf_dy=$(sed -n -e 's/^[ ]*dy[ ]*=[ ]*//p' namelist.input | sed -n -e 's/,.*//p')
wrf_e_we=$(sed -n -e 's/^[ ]*e_we[ ]*=[ ]*//p' namelist.input | sed -n -e 's/,.*//p')
wrf_e_sn=$(sed -n -e 's/^[ ]*e_sn[ ]*=[ ]*//p' namelist.input | sed -n -e 's/,.*//p')
xwavenum=$(( (wrf_dx * wrf_e_we) / nudging_scale))
ywavenum=$(( (wrf_dy * wrf_e_sn) / nudging_scale))
# Edit the namelist
sed -i "s/__STARTYEAR__/${yys}/g" namelist.input
sed -i "s/__STARTMONTH__/${mms}/g" namelist.input
sed -i "s/__STARTDAY__/${dds}/g" namelist.input
sed -i "s/__STARTHOUR__/${hhs}/g" namelist.input
sed -i "s/__ENDYEAR__/${yye}/g" namelist.input
sed -i "s/__ENDMONTH__/${mme}/g" namelist.input
sed -i "s/__ENDDAY__/${dde}/g" namelist.input
sed -i "s/__ENDHOUR__/${hhe}/g" namelist.input
sed -i "s/__BIO_EMISS_OPT__/3/g" namelist.input
sed -i "s/__XWAVENUM__/$xwavenum/g" namelist.input
sed -i "s/__YWAVENUM__/$ywavenum/g" namelist.input

# Copy the input files from real.exe
cp "${REALDIR}/wrfinput_d01" "$SCRATCH/"
cp "${REALDIR}/wrfbdy_d01" "$SCRATCH/"
# wrffdda is only needed if fdda (nudging) is active
cp "${REALDIR}/wrffdda_d01" "$SCRATCH/"
# wrflowinp is only needed if sst_update is active (lower boundary condition for SST and sea
# ice cover
cp "${REALDIR}/wrflowinp_d01" "$SCRATCH/"

# exo_coldens and wrf_season_wes_usgs only  needed for MOZART gas phase chemistry
cp "${REALDIR}/exo_coldens_d01" "$SCRATCH/"
cp "${REALDIR}/wrf_season_wes_usgs_d01.nc" "$SCRATCH/"
# Only needed for TUV photolysis
cp "$WRFCHEM_INPUT_DATA_DIR/upper_bdy/wrf_tuv_xsqy.nc" "$SCRATCH/"
cp -r "$WRFCHEM_INPUT_DATA_DIR/upper_bdy/DATA"?? "$SCRATCH/"

# Transfer other input data
cp "$WRFCHEM_INPUT_DATA_DIR/upper_bdy/clim_p_trop.nc" "$SCRATCH/"
cp "$WRFCHEM_INPUT_DATA_DIR/upper_bdy/ubvals_b40.20th.track1_1996-2005.nc" "$SCRATCH/"

# Run WRF --------
echo " "
echo "-------- $SLURM_JOB_NAME: run wrf.exe ---------"
echo " "
mpirun ./wrf.exe
# Check the end of the log file in case the code crashes
tail -n20 rsl.error.0000

#-------- Transfer results and clean up  --------
echo " "
echo "-------- $SLURM_JOB_NAME: transfer WRF results --------"
echo " "
# Transfer files to the output dir
mv ./wrfout_* "$OUTDIR/" || exit
mv ./wrfrst_* "$OUTDIR/" || exit
cp ./rsl.* ./namelist.* "$OUTDIR/" || exit

# Remove scratch dir
rm -rf "$SCRATCH"

