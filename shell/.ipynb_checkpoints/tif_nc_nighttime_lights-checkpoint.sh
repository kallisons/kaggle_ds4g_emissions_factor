#requires gdal, nco, cdo to run 
#change directory
cd ../data/supplementary_data/

tif_file="tif/ds4g_nighttime_lights.tif"

#convert tif to netCDF
gdal_translate -of NETCDF -co "FORMAT=NC4" ${tif_file} VIIRS_nighttime_lights.nc


#rename th variables in the netcdf files
ncrename -v Band1,avg_rad VIIRS_nighttime_lights.nc

mv VIIRS_nighttime_lights.nc nc/VIIRS_nighttime_lights.nc
