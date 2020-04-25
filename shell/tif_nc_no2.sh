#requires gdal, nco, cdo to run 
#change directory
cd ../data/starter_pack/s5p_no2/

filenamelist=`ls tif/*.tif`
for tif_file in $filenamelist
do

    echo $tif_file
    #tif_file="tif/s5p_no2_20180701T161259_20180707T175356.tif"

    #set names
    filename=${tif_file%.tif}
    nc_file=nc/${filename#tif/}.nc

    #convert tif to netCDF
    gdal_translate -of NETCDF -co "FORMAT=NC4" ${tif_file} convert.nc

    #rename th variables in the netcdf files
    ncrename -v Band1,NO2_column_number_density convert.nc
    ncrename -v Band2,tropospheric_NO2_column_number_density convert.nc
    ncrename -v Band3,stratospheric_NO2_column_number_density convert.nc
    ncrename -v Band4,NO2_slant_column_number_density convert.nc
    ncrename -v Band5,tropopause_pressure convert.nc
    ncrename -v Band6,absorbing_aerosol_index convert.nc
    ncrename -v Band7,cloud_fraction convert.nc
    ncrename -v Band8,sensor_altitude convert.nc
    ncrename -v Band9,sensor_azimuth_angle convert.nc
    ncrename -v Band10,sensor_zenith_angle convert.nc
    ncrename -v Band11,solar_azimuth_angle convert.nc
    ncrename -v Band12,solar_zenith_angle convert.nc

    #extract time from the file name and add as a dimension to the netCDF file
    timestrT="$(cut -d'_' -f3 <<<${filename})"
    timestr="${timestrT//T}"
    unix="$(date -j -u -f "%Y%m%d%H%M%S" "${timestr}" +"%s")"
    # printf "/***.nco ncap2 script***/
    # defdim(\"time\",1);
    # time[time]="$unix";
    # time@long_name=\"Time\";
    # time@units=\"seconds since 1970-01-01 00:00:00\";
    # time@standard_name=\"time\";
    # time@axis=\"T\";
    # time@coordinate_defines=\"point\";
    # time@calendar=\"standard\";
    # /***********/" > time.nco

    ncap2 -Oh -s 'defdim("time",1);time[time]=1561830483;time@long_name="Time";time@units="seconds since 1970-01-01 00:00:00";time@standard_name="time";time@axis="T";time@coordinate_defines="point";time@calendar="standard";' convert.nc convert1.nc
    date_string="$(date -u -r ${unix} +'%Y-%m-%d,%H:%M:%S')"
    cdo settaxis,"${date_string}" convert1.nc convert2.nc

    #save final version of netcdf file 
    mv convert2.nc ${nc_file}

    #clean up files
    rm convert.nc
    rm convert1.nc
    #rm time.nco 

done

cdo mergetime nc/*.nc no2_1year.nc