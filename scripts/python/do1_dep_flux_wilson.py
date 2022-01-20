import sys
import json
sys.path.append('/home/clusters/rrcmpi/kudrov/scripts/python')
from iterate_confs import *
import subprocess
import os

conf_size = "24^4"
conf_type = "su2_suzuki"
bites_skip = 4
bites_skip_nonabelian = 4

HYP_alpha1 = "1"
HYP_alpha2 = "1"
HYP_alpha3 = "0.5"
APE_alpha = "0.5"
stout_alpha = "0.15"
APE = "1"
HYP = "1"
stout = "0"
APE_steps = "510"
HYP_steps = "1"
stout_steps = "0"

calculation_step_APE = 100

number_of_jobs = 100

calculate_absent = 'false'

monopole = "monopoless"
nonabelian_format = 'float_fortran'
nonabelian_type = 'su2'
smearing = f'HYP{HYP_steps}_alpha={HYP_alpha1}_{HYP_alpha2}_{HYP_alpha3}_APE_alpha={APE_alpha}'

for mu in ["0.00"]:
	#f = open(f'/home/clusters/rrcmpi/kudrov/conf/{conf_type}/{conf_size}/mu{mu}/parameters.json')
	#data = json.load(f)

	if conf_type == "su2_suzuki":
		matrix_type="su2"
		conf_format="float_fortran"
		chains = {'/': [1, 100]}
		L_spat=24
		L_time=24

		if monopole == "monopoless":
			conf_format="double_fortran"
			bites_skip=8

	jobs = distribute_jobs(chains, number_of_jobs)

	for job in jobs:

		log_path = f'/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing_test/flux_tube_wilson/{monopole}/{conf_type}/{conf_size}/mu{mu}/{job[0]}'
		#log_path = f'/home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/python'
		try:
			os.makedirs(log_path)
		except:
			pass

		bashCommand = f'qsub -q long -v conf_format={conf_format},bites_skip={bites_skip},nonabelian_format={nonabelian_format},'\
			f'bites_skip_nonabelian={bites_skip_nonabelian},nonabelian_type={nonabelian_type},'\
			f'HYP_alpha1={HYP_alpha1},HYP_alpha2={HYP_alpha2},HYP_alpha3={HYP_alpha3},smearing={smearing},'\
			f'APE_alpha={APE_alpha},stout_alpha={stout_alpha},APE={APE},HYP={HYP},stout={stout},APE_steps={APE_steps},HYP_steps={HYP_steps},'\
			f'stout_steps={stout_steps},L_spat={L_spat},L_time={L_time},calculation_step_APE={calculation_step_APE},chain={job[0]},conf1={job[1]},conf2={job[2]},'\
			f'matrix_type={matrix_type},calculate_absent={calculate_absent},monopole={monopole},conf_type={conf_type},mu={mu},conf_size={conf_size}'\
			f' -o {log_path}/{job[1]:04}-{job[2]:04}.o -e {log_path}/{job[1]:04}-{job[2]:04}.e /home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do_dep_flux_wilson.sh'
		#-o {log_path}/{job[1]:04}.o -e {log_path}/{job[2]:04}.e
		#print(bashCommand)
		process = subprocess.Popen(bashCommand.split())
		output, error = process.communicate()
		#print(output, error)
