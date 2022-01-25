#!/bin/bash

for((i=${conf_start};i<=${conf_end};i++))
do

conf_path="${conf_path_start}`printf %0${padding}d $i`${conf_path_end}"

echo $conf_path

if [ -f ${conf_path} ] && [ -s ${conf_path} ]; then

mkdir -p ${output_path}
smeared_path="${output_path}/conf_`printf %04d $i`"

parameters="-conf_format $conf_format -conf_path $conf_path -bites_skip ${bites_skip} -smeared_path $smeared_path\
 -HYP_alpha1 $HYP_alpha1 -HYP_alpha2 $HYP_alpha2 -HYP_alpha3 $HYP_alpha3 -APE_alpha $APE_alpha -APE $APE -HYP $HYP\
  -HYP_steps $HYP_steps -APE_steps $APE_steps -L_spat ${L_spat} -L_time ${L_time}"

/home/clusters/rrcmpi/kudrov/smearing_cluster/code/exe/smearing_${matrix_type} $parameters

fi
done
