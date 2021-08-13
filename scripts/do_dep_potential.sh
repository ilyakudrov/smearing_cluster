#!/bin/bash
parameters="-conf_format $conf_format -conf_path $conf_path -HYP_alpha1 $HYP_alpha1 -HYP_alpha2 $HYP_alpha2 -HYP_alpha3 $HYP_alpha3\
 -APE_alpha $APE_alpha -stout_alpha $stout_alpha -APE $APE -HYP $HYP -stout $stout -HYP_steps $HYP_steps -APE_steps $APE_steps -stout_steps $stout_steps\
  -L_spat ${L_spat} -L_time ${L_time} -wilson_path ${wilson_path} -wilson_enabled ${wilson_enabled} -T_min ${T_min} -T_max ${T_max} -R_min ${R_min} -R_max ${R_max} -calculation_step_APE ${calculation_step_APE}"

/home/clusters/rrcmpi/kudrov/smearing_cluster/code/exe/smearing_dependence_potential_${matrix_type} $parameters
