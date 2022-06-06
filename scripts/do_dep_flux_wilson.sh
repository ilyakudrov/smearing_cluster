#!/bin/bash

for((i=${conf_start};i<=${conf_end};i++))
do

if [[ ${conf_path_plaket_end} == "/" ]]; then

conf_path_plaket_end=""

fi

if [[ ${conf_path_wilson_end} == "/" ]]; then

conf_path_wilson_end=""

fi

conf_path_plaket="${conf_path_plaket_start}`printf %0${padding_plaket}d $i`${conf_path_plaket_end}"
conf_path_wilson="${conf_path_wilson_start}`printf %0${padding_wilson}d $i`${conf_path_wilson_end}"

if [ -f ${conf_path_plaket} ] && [ -s ${conf_path_plaket} ] && [ -f ${conf_path_wilson} ] && [ -s ${conf_path_wilson} ] ; then

mkdir -p ${output_path}
flux_path="${output_path}/electric_`printf %04d $i`"

parameters="-conf_format_plaket $conf_format_plaket -conf_path_plaket $conf_path_plaket -bites_skip_plaket ${bites_skip_plaket} -conf_format_wilson ${conf_format_wilson}\
 -conf_path_wilson ${conf_path_wilson} -bites_skip_wilson ${bites_skip_wilson} -HYP_alpha1 $HYP_alpha1 -HYP_alpha2 $HYP_alpha2 -HYP_alpha3 $HYP_alpha3\
 -APE_alpha $APE_alpha -stout_alpha $stout_alpha -APE $APE -HYP $HYP -stout $stout -HYP_steps $HYP_steps -APE_steps $APE_steps -stout_steps $stout_steps\
  -L_spat ${L_spat} -L_time ${L_time} -flux_path ${flux_path} -T_min ${T_min} -T_max ${T_max} -R_min ${R_min} -R_max ${R_max} -calculation_step_APE ${calculation_step_APE}"

/home/clusters/rrcmpi/kudrov/smearing_cluster/code/exe/smearing_dependence_flux_wilson_${matrix_type_plaket}_${matrix_type_wilson} $parameters

fi

done
