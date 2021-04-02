#!/bin/bash
smearing="HYP_APE"
for conf_type in "mon_wl" "mag" "offd"
do
for mu in 0 #10 15 25 30 40
do
w=$(($mu/10))
q=$(($mu-$w*10))

for i in 8 12 16
do

R=$i
T=$i

electric_path="/home/clusters/rrcmpi/kudrov/smearing/smearing_test/result/flux_tube/${conf_type}/${smearing}/mu0.$w$q/flux_dep_T=${R}_R=${T}_"
#magnetic_path="/home/clusters/rrcmpi/kudrov/observables/result/flux_tube/${conf_type}${smearing}/mu0.$w$q/T=$T/R=$R/magnetic_"
output_electric_mid="/home/clusters/rrcmpi/kudrov/smearing/smearing_test/get_result/result/flux_tube/${conf_type}/${smearing}/mu0.$w$q/electric_mid_T=${T}_R=${R}"
output_electric_bot="/home/clusters/rrcmpi/kudrov/smearing/smearing_test/get_result/result/flux_tube/${conf_type}/${smearing}/mu0.$w$q/electric_bot_T=${T}_R=${R}"
#output_magnetic="/home/clusters/rrcmpi/kudrov/observables/get_result/result/flux_tube/${conf_type}${smearing}/mu0.$w$q/magnetic_T=${T}_R=${R}"
#output_energy="/home/clusters/rrcmpi/kudrov/observables/get_result/result/flux_tube/${conf_type}${smearing}/mu0.$w$q/energy_T=${T}_R=${R}"
#output_action="/home/clusters/rrcmpi/kudrov/observables/get_result/result/flux_tube/${conf_type}${smearing}/mu0.$w$q/action_T=${T}_R=${R}"

if test -f ${conf_path}; then
	/home/clusters/rrcmpi/kudrov/smearing/smearing_test/get_result/code/exe/get_aver_flux $electric_path $output_electric_mid $output_electric_bot
fi
done
done
done
