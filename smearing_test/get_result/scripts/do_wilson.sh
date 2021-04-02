#!/bin/bash
#conf_type="qc2dstag"
smearing="HYP_APE"
for conf_type in "mon_wl"
do
for mu in 0 #10 15 25 30 40
do
w=$(($mu/10))
q=$(($mu-$w*10))

for i in 8 12 16
do

T=$i
R=$i

echo ${T} ${R}

data_path="/home/clusters/rrcmpi/kudrov/smearing/smearing_test/result/wilson_loop/${conf_type}/${smearing}/mu0.$w$q/wilson_dep_T=${R}_R=${T}_"
output_path="/home/clusters/rrcmpi/kudrov/smearing/smearing_test/get_result/result/wilson_loop/${conf_type}/${smearing}/mu0.$w$q/wilson_dep_T=${T}_R=${R}"

#if test -f ${conf_path}; then
	/home/clusters/rrcmpi/kudrov/smearing/smearing_test/get_result/code/exe/get_aver_wilson $data_path $output_path
#fi
done
done
done
