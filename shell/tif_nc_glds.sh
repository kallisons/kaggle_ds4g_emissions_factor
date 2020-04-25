#requires gdal, nco, cdo to run 
#change directory
cd ../data/starter_pack/gldas/

filenamelist=`ls tif/*.tif`
for tif_file in $filenamelist
do

    echo $tif_file
    #tif_file="tif/gldas_20180701_0300.tif"

    #set names
    filename=${tif_file%.tif}
    nc_file=nc/${filename#tif/}.nc

    #convert tif to netCDF
    gdal_translate -of NETCDF -co "FORMAT=NC4" ${tif_file} convert.nc

    #rename th variables in the netcdf files
    ncrename -v Band1,LWdown_f_tavg convert.nc
    ncrename -v Band2,Lwnet_tavg convert.nc
    ncrename -v Band3,Psurf_f_inst convert.nc
    ncrename -v Band4,Qair_f_inst convert.nc
    ncrename -v Band5,Qg_tavg convert.nc
    ncrename -v Band6,Qh_tavg convert.nc
    ncrename -v Band7,Qle_tavg convert.nc
    ncrename -v Band8,Rainf_f_tavg convert.nc
    ncrename -v Band9,SWdown_f_tavg convert.nc
    ncrename -v Band10,Swnet_tavg convert.nc
    ncrename -v Band11,Tair_f_inst convert.nc
    ncrename -v Band12,Wind_f_inst convert.nc

    #extract time from the file name and add as a dimension to the netCDF file
    datestr="$(cut -d'_' -f2 <<<${filename})"
    timestr="$(cut -d'_' -f3 <<<${filename})"
    datetimestr=${datestr}${timestr}
    unix="$(date -j -u -f "%Y%m%d%H%M" "${datetimestr}" +"%s")"
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
    date_string="$(date -u -r ${unix} +'%Y-%m-%d,%H:%M')"
    cdo settaxis,"${date_string}" convert1.nc convert2.nc

    #save final version of netcdf file 
    mv convert2.nc ${nc_file}

    #clean up files
    rm convert.nc
    rm convert1.nc
    #rm time.nco 

done

cdo mergetime nc/*.nc gldas_1year.nc