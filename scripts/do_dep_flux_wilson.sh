#!/bin/bash

for((i=${conf1};i<=${conf2};i++))
do

a=$(($i/1000))
b=$((($i-$a*1000)/100))
c=$((($i-$a*1000-$b*100)/10))
d=$(($i-$a*1000-$b*100-$c*10))

if [[ ${conf_type} == "qc2dstag" ]] ; then

conf_path_qc2dstag="/home/clusters/rrcmpi/kudrov/conf/${conf_type}/${conf_size}/mu${mu}/${chain}/confs/CONF$a$b$c$d"
conf_path_monopoless="/home/clusters/rrcmpi/kudrov/decomposition/confs_decomposed/monopoless/${conf_type}/${conf_size}/mu${mu}/${chain}/conf_monopoless_$a$b$c$d"

if [[ ${monopole} == "/" ]] ; then

conf_path=$conf_path_qc2dstag

else

path1="conf_path_${monopole}"
conf_path=("${!path1}")

fi

elif [[ ${conf_type} == "SU2_dinam" ]] ; then

conf_path="/home/clusters/rrcmpi/kudrov/conf/${conf_type}/${conf_size}/mu${mu}/confs/CON_32^3x32_$b$c$d.LAT"
nonabelian_format="float_fortran"
nonabelian_path="/home/clusters/rrcmpi/kudrov/conf/${conf_type}/${conf_size}/mu${mu}/confs/CON_32^3x32_$b$c$d.LAT"
bites_skip_nonabelian=4

elif [[ ${conf_type} == "su2_suzuki" ]] ; then

conf_path="/lustre/rrcmpi/vborn/tokyo/ITEP/su2/mag/b2.50_l24/CON_L24_B25_$b$c$d.LAT"
nonabelian_format="float_fortran"
nonabelian_path="/lustre/rrcmpi/vborn/tokyo/ITEP/su2/mag/b2.50_l24/CON_L24_B25_$b$c$d.LAT"
bites_skip_nonabelian=4

if [[ ${monopole} == "monopoless" ]] ; then

conf_path="/home/clusters/01/vborn/Copy_from_lustre/SU2/SUZUKI/L24/MAG/B2p5/DECOMPOS/CONFIGS/CON_OFF_MAG_$b$c$d.LAT"

fi

fi

if [ -f ${conf_path} ] && [ -s ${conf_path} ] ; then

#wilson_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/smearing_test/result/wilson_loop/${conf_type}/${conf_size}/${smearing}/mu${mu}/${chains[j]}"
#wilson_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/smearing_test/result/wilson_loop/monopoless/${conf_type}/${conf_size}/${smearing}/mu${mu}/${chains[j]}"
flux_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/smearing_test/result/flux_tube_wilson/${monopole}/${conf_type}/${conf_size}/${smearing}/mu${mu}/${chain}"
mkdir -p ${flux_path}
flux_path="${flux_path}/flux_wilson_$a$b$c$d"

if [ ! -f ${flux_path} ] || [ ${calculate_absent} == "false" ]; then

parameters="-conf_format $conf_format -bites_skip ${bites_skip} -nonabelian_format ${nonabelian_format} -nonabelian_path ${nonabelian_path} -bites_skip_nonabelian ${bites_skip_nonabelian}\
 -conf_path $conf_path -HYP_alpha1 $HYP_alpha1 -HYP_alpha2 $HYP_alpha2 -HYP_alpha3 $HYP_alpha3\
 -APE_alpha $APE_alpha -stout_alpha $stout_alpha -APE $APE -HYP $HYP -stout $stout -HYP_steps $HYP_steps -APE_steps $APE_steps -stout_steps $stout_steps\
  -L_spat ${L_spat} -L_time ${L_time} -flux_path ${flux_path} -calculation_step_APE ${calculation_step_APE}"

/home/clusters/rrcmpi/kudrov/smearing_cluster/code/exe/smearing_dependence_flux_wilson_${nonabelian_type}_${matrix_type} $parameters

fi

fi

done