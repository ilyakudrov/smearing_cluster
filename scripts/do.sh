#!/bin/bash

#HYP_alpha1="0.75"
#HYP_alpha2="0.6"
#HYP_alpha3="0.3"
#HYP_alpha1="0.1"
#HYP_alpha2="0.1"
#HYP_alpha3="0.5"
#APE_alpha="0.75"
stout_alpha="0.15"
smearing="HYP${HYP_steps}_alpha=${HYP_alpha1}_${HYP_alpha2}_${HYP_alpha3}_APE${APE_steps}_APE_alpha=${APE_alpha}"

for((i=$conf1;i<=${conf2};i++))
do

a=$(($i/1000))
b=$((($i-$a*1000)/100))
c=$((($i-$a*1000-$b*100)/10))
d=$(($i-$a*1000-$b*100-$c*10))

conf_path_qc2dstag="/home/clusters/rrcmpi/kudrov/conf/${conf_type}/${conf_size}/mu${mu}/$chain/confs/CONF$a$b$c$d"
conf_path_monopole="/home/clusters/rrcmpi/kudrov/decomposition/confs_decomposed/monopole/qc2dstag/${conf_size}/mu${mu}/$chain/conf_monopole_$a$b$c$d"
conf_path_monopoless="/home/clusters/rrcmpi/kudrov/decomposition/confs_decomposed/monopoless/qc2dstag/${conf_size}/mu${mu}/$chain/conf_monopoless_$a$b$c$d"

if [[ ${monopole} == "/" ]] ; then

conf_path="$conf_path_qc2dstag"

else

path1="conf_path_${monopole}"
conf_path=("${!path1}")

fi

#conf_path="/home/clusters/rrcmpi/kudrov/conf/SU2_dinam/CON_32^3x32_$b$c$d.LAT"
#conf_path="/home/clusters/01/vborn/Copy_from_lustre/SU2_dinam/MAG/mu0p0_b1p8_m0p0075_lam0p00075/OFFD/CON_OFF_MAG_$b$c$d.LAT"

if [ -f ${conf_path} ] ; then

echo 

smeared_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/confs_smeared/${monopole}/${conf_type}/${conf_size}/mu${mu}/${smearing}/$chain"
#smeared_path="/home/clusters/rrcmpi/kudrov/smearing_cluster/confs_smeared/${monopole}/SU2_dinam"
mkdir -p ${smeared_path}
smeared_path="${smeared_path}/conf_$a$b$c$d"

if [ ! -f ${smeared_path} ] || [  ${calculate_absent} == "false" ] ; then

parameters="-conf_format $conf_format -conf_path $conf_path -smeared_path $smeared_path -HYP_alpha1 $HYP_alpha1 -HYP_alpha2 $HYP_alpha2 -HYP_alpha3 $HYP_alpha3 -APE_alpha $APE_alpha -APE $APE -HYP $HYP -HYP_steps $HYP_steps -APE_steps $APE_steps -L_spat ${L_spat} -L_time ${L_time}"

/home/clusters/rrcmpi/kudrov/smearing_cluster/code/exe/smearing_${matrix_type} $parameters

fi
fi
done
