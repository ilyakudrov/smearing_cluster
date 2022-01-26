import sys
import json
sys.path.append('/home/clusters/rrcmpi/kudrov/scripts/python')
from iterate_confs import *
import subprocess
import os

conf_size = "24^4"
conf_type = "su2_suzuki"
matrix_type = "su2"
bites_skip_plaket = 0
bites_skip_wilson = 0

monopole_plaket = '/'
#monopole_wilson = 'monopole'

if monopole_plaket == '/':
    monopole1 = matrix_type
else:
    monopole1 = monopole_plaket

HYP_alpha1 = "1"
HYP_alpha2 = "1"
HYP_alpha3 = "0.5"
APE_alpha = "0.7"
stout_alpha = "0.15"
APE = "1"
HYP = "1"
stout = "0"
APE_steps = "160"
HYP_steps = "0"
stout_steps = "0"

calculation_step_APE = 3

number_of_jobs = 20

for monopole_wilson in ['/', 'monopole', 'monopoless']:
    if monopole_wilson == '/':
        monopole2 = matrix_type
    else:
        monopole2 = monopole_wilson
    for beta in ['2.4', '2.5', '2.6']:
        for mu in [""]:
            f = open(
                f'/home/clusters/rrcmpi/kudrov/conf/{matrix_type}/{conf_type}/{conf_size}/beta{beta}/{mu}/{monopole_plaket}/parameters.json')
            data_plaket = json.load(f)

            conf_format_plaket = data_plaket['conf_format']
            bites_skip_plaket = data_plaket['bites_skip']
            matrix_type_plaket = data_plaket['matrix_type']
            L_spat = data_plaket['x_size']
            L_time = data_plaket['t_size']
            conf_path_plaket_start = data_plaket['conf_path_start']
            conf_path_plaket_end = data_plaket['conf_path_end']
            padding_plaket = data_plaket['padding']
            conf_name_plaket = data_plaket['conf_name']

            f = open(
                f'/home/clusters/rrcmpi/kudrov/conf/{matrix_type}/{conf_type}/{conf_size}/beta{beta}/{mu}/{monopole_wilson}/parameters.json')
            data_wilson = json.load(f)
            conf_format_wilson = data_wilson['conf_format']
            bites_skip_wilson = data_wilson['bites_skip']
            matrix_type_wilson = data_wilson['matrix_type']
            conf_path_wilson_start = data_wilson['conf_path_start']
            conf_path_wilson_end = data_wilson['conf_path_end']
            padding_wilson = data_wilson['padding']
            conf_name_wilson = data_wilson['conf_name']

            jobs = distribute_jobs(data_plaket['chains'], number_of_jobs)

            for job in jobs:

                log_path = f'/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing_test/flux_tube_wilson/{matrix_type}/{conf_type}/{conf_size}/beta{beta}/{mu}/{monopole1}-{monopole2}/{job[0]}'
                conf_path_plaket_start1 = f'{conf_path_plaket_start}/{job[0]}/{conf_name_plaket}'
                conf_path_wilson_start1 = f'{conf_path_wilson_start}/{job[0]}/{conf_name_wilson}'
                try:
                    os.makedirs(log_path)
                except:
                    pass

                output_path = f'/home/clusters/rrcmpi/kudrov/smearing_cluster/result/smearing_test/flux_tube_wilson/{matrix_type}/{conf_type}/{conf_size}/beta{beta}/{mu}/{monopole1}-{monopole2}/{job[0]}'

                bashCommand = f'qsub -q long -v conf_format_plaket={conf_format_plaket},conf_format_wilson={conf_format_wilson},bites_skip_plaket={bites_skip_plaket},'\
                    f'bites_skip_wilson={bites_skip_wilson},matrix_type_plaket={matrix_type_plaket},matrix_type_wilson={matrix_type_wilson},'\
                    f'conf_path_plaket_start={conf_path_plaket_start1},conf_path_plaket_end={conf_path_plaket_end},conf_path_wilson_start={conf_path_wilson_start1},conf_path_wilson_end={conf_path_wilson_end},'\
                    f'padding_plaket={padding_plaket},padding_wilson={padding_wilson},L_spat={L_spat},L_time={L_time},calculation_step_APE={calculation_step_APE},'\
                    f'output_path={output_path},chain={job[0]},conf_start={job[1]},conf_end={job[2]},HYP_alpha1={HYP_alpha1},HYP_alpha2={HYP_alpha2},'\
		    f'HYP_alpha3={HYP_alpha3},APE_alpha={APE_alpha},stout_alpha={stout_alpha},APE={APE},HYP={HYP},stout={stout},HYP_steps={HYP_steps},APE_steps={APE_steps},stout_steps={stout_steps}'\
                    f' -o {log_path}/{job[1]:04}-{job[2]:04}.o -e {log_path}/{job[1]:04}-{job[2]:04}.e /home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do_dep_flux_wilson.sh'
                #print(bashCommand)
                process = subprocess.Popen(bashCommand.split())
                output, error = process.communicate()
                #print(output, error)
