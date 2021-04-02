#!/bin/bash
conf_type="qc2dstag"
matrix_type="su2"
conf_format="double_qc2dstag"
L_spat=32
L_time=32
#parameters_dir="/home/clusters/rrcmpi/kudrov/matrix_parameters"
#source ${parameters_dir}/${conf_type}
conf_size="32^4"
HYP_alpha1="0.75"
HYP_alpha2="0.6"
HYP_alpha3="0.3"
APE_alpha="0.7"
stout_alpha="0.15"
APE="1"
HYP="1"
stout="0"
APE_steps="100"
HYP_steps="1"
stout_steps="0"
smearing="HYP_APE"

i=$conf_num
a=$(($i/1000))
b=$((($i-$a*1000)/100))
c=$((($i-$a*1000-$b*100)/10))
d=$(($i-$a*1000-$b*100-$c*10))
for mu in 25 #10 15 25 30 40
do
w=$(($mu/10))
q=$(($mu-$w*10))

#conf_path="/lustre/rrcmpi/vborn/SU2_dinam/MAG/mu0p${mu}_b1p8_m0p0075_lam0p00075/OFFD/CON_OFF_MAG_${a}${b}${c}${d}.LAT"
#conf_path="/home/clusters/rrcmpi/kudrov/conf/qc2dstag/mu0.$w$q/CONF${a}${b}${c}${d}"
#conf_path="/lustre/rrcmpi/vborn/SU2_dinam/MAG/mu0p${mu}_b1p8_m0p0075_lam0p00075/CON_32^3x32_${a}${b}${c}${d}.LAT"
#conf_path="/lustre/rrcmpi/vborn/SU2_dinam/MAG/mu0p${mu}_b1p8_m0p0075_lam0p00075/MON_WL/CON_MON_MAG_${a}${b}${c}${d}.LAT"
#conf_path="/home/clusters/rrcmpi/nikolaev/SU_2_staggered/configurations/N_f=2/improved/32^3x32/mu=0.$w$q/beta=1.8/ma=0.0075/lambda=0.00075/converted_Fort/conf_$a$b$c$d.fl"
#conf_path="/home/clusters/rrcmpi/kudrov/conf/${conf_size}/mu0.$w$q/${conf_chain}/confs/CONF$a$b$c$d"
conf_path="/home/clusters/rrcmpi/kudrov/conf/${conf_size}/mu0.$w$q/confs/CONF$a$b$c$d"
#smeared_path="/home/clusters/rrcmpi/kudrov/smearing/conf/qc2dstag/${conf_size}/${smearing}/mu0.$w$q/${conf_chain}/smeared_$a$b$c$d"
smeared_path="/home/clusters/rrcmpi/kudrov/smearing/conf/qc2dstag/${conf_size}/${smearing}/mu0.$w$q/smeared_$a$b$c$d"

parameters="-conf_format $conf_format -conf_path $conf_path -smeared_path $smeared_path -HYP_alpha1 $HYP_alpha1 -HYP_alpha2 $HYP_alpha2 -HYP_alpha3 $HYP_alpha3 -APE_alpha $APE_alpha -stout_alpha $stout_alpha -APE $APE -HYP $HYP -stout $stout -HYP_steps $HYP_steps -APE_steps $APE_steps -stout_steps $stout_steps -L_spat ${L_spat} -L_time ${L_time}"

if [ -f ${conf_path} ] ; then
	/home/clusters/rrcmpi/kudrov/smearing/code/exe/smearing_${matrix_type} $parameters
fi

#if false; then
#if test $i -lt 1000; then 
#conf_path="/lustre/rrcmpi/vborn/SU2_dinam/MAG/mu0p${mu}_b1p8_m0p0075_lam0p00075/OFFD/CON_OFF_MAG_${b}${c}${d}.LAT"
#conf_path="/home/clusters/rrcmpi/kudrov/conf/qc2dstag/mu0.$w$q/CONF${b}${c}${d}"
#conf_path="/lustre/rrcmpi/vborn/SU2_dinam/MAG/mu0p${mu}_b1p8_m0p0075_lam0p00075/CON_32^3x32_${b}${c}${d}.LAT"
#conf_path="/lustre/rrcmpi/vborn/SU2_dinam/MAG/mu0p${mu}_b1p8_m0p0075_lam0p00075/MON_WL/CON_MON_MAG_${b}${c}${d}.LAT"
#conf_path="/home/clusters/rrcmpi/nikolaev/SU_2_staggered/configurations/N_f=2/improved/32^3x32/mu=0.$w$q/beta=1.8/ma=0.0075/lambda=0.00075/converted_Fort/conf_$b$c$d.fl"

#parameters="-conf_format $conf_format -conf_path $conf_path -smeared_path $smeared_path -HYP_alpha1 $HYP_alpha1 -HYP_alpha2 $HYP_alpha2 -HYP_alpha3 $HYP_alpha3 -APE_alpha $APE_alpha -stout_alpha $stout_alpha -APE $APE -HYP $HYP -stout $stout -HYP_steps $HYP_steps -APE_steps $APE_steps -stout_steps $stout_steps -L_spat ${L_spat} -L_time ${L_time}"

#if [ -f ${conf_path} ] ; then
#        /home/clusters/rrcmpi/kudrov/smearing/code/exe/smearing_${matrix_type} $parameters
#fi
#fi
#fi
done
