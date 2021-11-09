#!/bin/bash

for((i=$conf1;i<=${conf2};i++))
do

a=$(($i/1000))
b=$((($i-$a*1000)/100))
c=$((($i-$a*1000-$b*100)/10))
d=$(($i-$a*1000-$b*100-$c*10))

conf_path_qc2dstag="/home/clusters/rrcmpi/kudrov/conf/${conf_type}/${conf_size}/mu${mu}/$chain/confs/CONF$a$b$c$d"
conf_path_monopoless="/home/clusters/rrcmpi/kudrov/decomposition/confs_decomposed/monopoless/qc2dstag/${conf_size}/mu${mu}/$chain/conf_monopoless_$a$b$c$d"

if [[ ${monopole} == "/" ]] ; then

conf_path=$conf_path_qc2dstag

else

path1="conf_path_${monopole}"
conf_path=("${!path1}")

fi

#echo ${conf_path}

if [ -f ${conf_path} ] ; then

output_path_wilson="/home/clusters/rrcmpi/kudrov/smearing_cluster/smearing_test/result/wilson_loop_spatial/${monopole}/${conf_type}/${conf_size}/mu${mu}/$chain"
mkdir -p ${output_path_wilson}
output_path_wilson="${output_path_wilson}/wilson_loop_spatial_$a$b$c$d"

#echo ${output_path_wilson}

if [ ! -f ${output_path_wilson} ] || [  ${calculate_absent} == "false" ] ; then

#echo ok

echo -APE_alpha ${APE_alpha} -APE_enabled ${APE_enabled} -APE_steps ${APE_steps}

parameters="-conf_format $conf_format -conf_path $conf_path -wilson_path $output_path_wilson -L_spat ${L_spat} -L_time ${L_time} -T_min ${T_min} -T_max ${T_max} -R_min ${R_min} -R_max ${R_max} -APE_alpha ${APE_alpha} -APE_enabled ${APE_enabled} -APE_steps ${APE_steps}  -calculation_step_APE ${calculation_step_APE}"

/home/clusters/rrcmpi/kudrov/smearing_cluster/code/exe/smearing_dependence_potential_spatial_${matrix_type} $parameters

fi

fi

done
