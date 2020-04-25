#requires gdal, nco, cdo to run 
#change directory
cd ../data/supplementary_data/

tif_file="tif/ds4g_landcover.tif"

#convert tif to netCDF
gdal_translate -of NETCDF -co "FORMAT=NC4" ${tif_file} GFSAD1000_landcover.nc


#rename th variables in the netcdf files
ncrename -v Band1,landcover_category GFSAD1000_landcover.nc

mv GFSAD1000_landcover.nc nc/GFSAD1000_landcover.nc
