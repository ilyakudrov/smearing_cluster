#!/bin/bash

for((i=${conf_start};i<=${conf_end};i++))
do

if [[ ${conf_path_end} == "/" ]]; then

conf_path_end=""

fi

conf_path="${conf_path_start}`printf %0${padding}d $i`${conf_path_end}"

if [ -f ${conf_path} ] ; then

mkdir -p ${output_path}
wilson_path="${output_path}/wilson_loops_`printf %04d $i`"

parameters="-conf_format $conf_format -conf_path $conf_path -wilson_path $wilson_path -HYP_alpha1 $HYP_alpha1 -HYP_alpha2 $HYP_alpha2 -HYP_alpha3 $HYP_alpha3 -bites_skip $bites_skip\
 -APE_alpha $APE_alpha -stout_alpha $stout_alpha -APE $APE -HYP $HYP -stout $stout -HYP_steps $HYP_steps -APE_steps $APE_steps -stout_steps $stout_steps\
  -L_spat ${L_spat} -L_time ${L_time} -wilson_enabled ${wilson_enabled} -T_min ${T_min} -T_max ${T_max} -R_min ${R_min} -R_max ${R_max} -calculation_step_APE ${calculation_step_APE}"

/home/clusters/rrcmpi/kudrov/smearing_cluster/code/exe/smearing_dependence_potential_${matrix_type} $parameters

fi

done
