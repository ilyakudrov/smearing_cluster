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

HYP_alpha1 = "1"
HYP_alpha2 = "1"
HYP_alpha3 = "0.5"
APE_alpha = "0.5"
stout_alpha = "0.15"
APE = "1"
HYP = "1"
stout = "0"
APE_steps = "3"
HYP_steps = "0"
stout_steps = "0"

calculation_step_APE = 1

number_of_jobs = 100

#for monopole in ['/', 'monopole', 'monopoless']:
for monopole in ['monopole']:
    if monopole == '/':
        monopole1 = matrix_type
    else:
        monopole1 = monopole
    #for beta in ['2.4', '2.5', '2.6']:
    for beta in ['2.4']:
        for mu in [""]:
            f = open(
                f'/home/clusters/rrcmpi/kudrov/conf/{matrix_type}/{conf_type}/{conf_size}/beta{beta}/{mu}/{monopole}/parameters.json')
            data = json.load(f)

            conf_format = data['conf_format']
            bites_skip = data['bites_skip']
            matrix_type = data['matrix_type']
            L_spat = data['x_size']
            L_time = data['t_size']
            conf_path_start = data['conf_path_start']
            conf_path_end = data['conf_path_end']
            padding = data['padding']
            conf_name = data['conf_name']

            jobs = distribute_jobs(data['chains'], number_of_jobs)

            for job in jobs:

                log_path = f'/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing_test/potential/{matrix_type}/{conf_type}/{conf_size}/beta{beta}/{mu}/{monopole1}/{job[0]}'
                conf_path_start1 = f'{conf_path_start}/{job[0]}/{conf_name}'
                try:
                    os.makedirs(log_path)
                except:
                    pass

                output_path = f'/home/clusters/rrcmpi/kudrov/smearing_cluster/result/smearing_test/potential/{matrix_type}/{conf_type}/{conf_size}/beta{beta}/{mu}/{monopole1}/{job[0]}'

                bashCommand = f'qsub -q long -v conf_format={conf_format},bites_skip={bites_skip},'\
                    f'conf_path_start={conf_path_start1},conf_path_end={conf_path_end},matrix_type={matrix_type},'\
                    f'padding={padding},L_spat={L_spat},L_time={L_time},calculation_step_APE={calculation_step_APE},'\
                    f'output_path={output_path},chain={job[0]},conf_start={job[1]},conf_end={job[2]},HYP_alpha1={HYP_alpha1},HYP_alpha2={HYP_alpha2},'\
                    f'HYP_alpha3={HYP_alpha3},APE_alpha={APE_alpha},stout_alpha={stout_alpha},APE={APE},HYP={HYP},stout={stout},HYP_steps={HYP_steps},APE_steps={APE_steps},stout_steps={stout_steps}'\
                    f' -o {log_path}/{job[1]:04}-{job[2]:04}.o -e {log_path}/{job[1]:04}-{job[2]:04}.e /home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do_dep_potential.sh'
                # print(bashCommand)
                process = subprocess.Popen(bashCommand.split())
                output, error = process.communicate()
                #print(output, error)
