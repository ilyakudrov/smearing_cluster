#!/bin/bash
parameters="-conf_format $conf_format -conf_path $conf_path -HYP_alpha1 $HYP_alpha1 -HYP_alpha2 $HYP_alpha2 -HYP_alpha3 $HYP_alpha3 -APE_alpha $APE_alpha -stout_alpha $stout_alpha -APE $APE -HYP $HYP -stout $stout -HYP_steps $HYP_steps -APE_steps $APE_steps -stout_steps $stout_steps -L_spat ${L_spat} -L_time ${L_time} -wilson_path ${wilson_path} -flux_path ${flux_path} -wilson_enabled ${wilson_enabled} -flux_enabled ${flux_enabled}"

/home/clusters/rrcmpi/kudrov/smearing_cluster/code/exe/smearing_dependence_${matrix_type} $parameters
