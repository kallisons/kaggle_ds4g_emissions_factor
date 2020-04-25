#requires gdal, nco, cdo to run 
#change directory
cd ../data/supplementary_data/

tif_file="tif/ds4g_population.tif"

#convert tif to netCDF
gdal_translate -of NETCDF -co "FORMAT=NC4" ${tif_file} GPWv411_populationdensity.nc


#rename th variables in the netcdf files
ncrename -v Band1,population_density GPWv411_populationdensity.nc

mv GPWv411_populationdensity.nc nc/GPWv411_populationdensity.nc
