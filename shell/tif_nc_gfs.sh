#requires gdal, nco, cdo to run 
#change directory
cd ../data/starter_pack/gfs/

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
    ncrename -v Band1,temperature_2m_above_ground convert.nc
    ncrename -v Band2,specific_humidity_2m_above_ground convert.nc
    ncrename -v Band3,relative_humidity_2m_above_ground convert.nc
    ncrename -v Band4,u_component_of_wind_10m_above_ground convert.nc
    ncrename -v Band5,v_component_of_wind_10m_above_ground convert.nc
    ncrename -v Band6,precipitable_water_entire_atmosphere convert.nc

    #extract time from the file name and add as a dimension to the netCDF file
    timestrT="$(cut -d'_' -f2 <<<${filename})"
    timestr="${timestrT//T}"
    unix="$(date -j -u -f "%Y%m%d%H" "${timestr}" +"%s")"
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

    ncap2 -Oh -s "defdim("time",1);time[time]=${unix};time@long_name="Time";time@units="seconds since 1970-01-01 00:00:00";time@standard_name="time";time@axis="T";time@coordinate_defines="point";time@calendar="standard";" convert.nc convert1.nc
    date_string="$(date -u -r ${unix} +'%Y-%m-%d,%H:%M:%S')"
    cdo settaxis,"${date_string}" convert1.nc convert2.nc

    #save final version of netcdf file 
    mv convert2.nc ${nc_file}

    #clean up files
    rm convert.nc
    rm convert1.nc
    #rm time.nco 

done

cdo mergetime nc/*.nc gfs_1year.nc