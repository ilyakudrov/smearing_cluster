import sys
import json
sys.path.append('/home/clusters/rrcmpi/kudrov/scripts/python')
from iterate_confs import *
import subprocess
import os

#conf_size = "40^4"
conf_size = "24^4"
#conf_type = "qc2dstag"
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
APE_steps = "100"
HYP_steps = "0"
stout_steps = "0"

number_of_jobs = 100

calculate_absent = 'false'

monopole = "/"
smearing = f'HYP{HYP_steps}_alpha={HYP_alpha1}_{HYP_alpha2}_{HYP_alpha3}_APE{APE_steps}_alpha={APE_alpha}'

for mu in ["0.00"]:
	#f = open(f'/home/clusters/rrcmpi/kudrov/conf/{conf_type}/{conf_size}/mu{mu}/parameters.json')
	#data = json.load(f)

	if conf_type == "su2_suzuki":
		matrix_type="su2"
		conf_format="double_fortran"
		bites_skip=8
		chains = {'/': [1, 100]}
		L_spat=24
		L_time=24

		if monopole == "monopoless":
			matrix_type="su2"
			conf_format="double_fortran"
			bites_skip=8
		elif monopole == "monopole":
			matrix_type = 'abelian'
			conf_format="float_fortran"
			bites_skip=8

	if conf_type == "qc2dstag":
		matrix_type="su2"
		conf_format="double_qc2dstag"
		chains = {'/': [201, 1000]}
		L_spat=40
		L_time=40

		if monopole == "monopoless":
			conf_format="double_fortran"
			bites_skip=4

	jobs = distribute_jobs(chains, number_of_jobs)

	for job in jobs:

		log_path = f'/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing/{monopole}/{conf_type}/{conf_size}/{smearing}/mu{mu}/{job[0]}'
		#log_path = f'/home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/python/dir1'

		try:
			os.makedirs(log_path)
		except:
			pass

		bashCommand = f'qsub -q long -v conf_format={conf_format},bites_skip={bites_skip},'\
			f'HYP_alpha1={HYP_alpha1},HYP_alpha2={HYP_alpha2},HYP_alpha3={HYP_alpha3},smearing={smearing},'\
			f'APE_alpha={APE_alpha},stout_alpha={stout_alpha},APE={APE},HYP={HYP},stout={stout},APE_steps={APE_steps},HYP_steps={HYP_steps},'\
			f'stout_steps={stout_steps},L_spat={L_spat},L_time={L_time},chain={job[0]},conf1={job[1]},conf2={job[2]},'\
			f'matrix_type={matrix_type},calculate_absent={calculate_absent},monopole={monopole},conf_type={conf_type},mu={mu},conf_size={conf_size}'\
			f' -o {log_path}/{job[1]:04}-{job[2]:04}.o -e {log_path}/{job[1]:04}-{job[2]:04}.e /home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do.sh'
		#print(bashCommand)
		process = subprocess.Popen(bashCommand.split())
		output, error = process.communicate()
		#print(output, error)
