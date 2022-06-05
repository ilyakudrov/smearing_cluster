import sys
import json
sys.path.append('/home/clusters/rrcmpi/kudrov/scripts/python')
from iterate_confs import *
import subprocess
import os

#conf_size = "24^4"
conf_size = "40^4"
#conf_size = "48^4"
#conf_type = "su2_suzuki"
conf_type = "qc2dstag"
theory_type = "su2"

HYP_alpha1 = "1"
HYP_alpha2 = "0.5"
HYP_alpha3 = "0.5"
#HYP_alpha1 = "0.75"
#HYP_alpha2 = "0.6"
#HYP_alpha3 = "0.3"
APE_alpha = "0.5"
stout_alpha = "0.15"
APE = "1"
HYP = "1"
stout = "0"
APE_steps = "610"
HYP_steps = "2"
stout_steps = "0"

calculation_step_APE = 10

number_of_jobs = 50

T_min=1
T_max=20
R_min=1
R_max=20
#T_min=1
#T_max=24
#R_min=1
#R_max=24
#T_min=1
#T_max=12
#R_min=1
#R_max=12
#T_min=1
#T_max=2
#R_min=1
#R_max=2

#queue_str = 'qsub -q long -v'
queue_str = 'qsub -q mem4gb -l nodes=1:ppn=2 -v'

for monopole in ['/', 'monopoless', 'monopole']:
#for monopole in ['/']:
    #for beta in ['beta2.7', 'beta2.8']:
    for beta in ['']:
        #for mu in ['']:
        for mu in ['mu0.00', 'mu0.05', 'mu0.20', 'mu0.25', 'mu0.30', 'mu0.35', 'mu0.45']:
            f = open(
                f'/home/clusters/rrcmpi/kudrov/conf/{theory_type}/{conf_type}/{conf_size}/{beta}/{mu}/{monopole}/parameters.json')
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

            if monopole == '/':
                monopole1 = matrix_type
            else:
                monopole1 = monopole

            #chains = {'/': [3, 3]}
            #jobs = distribute_jobs(chains, number_of_jobs)
            jobs = distribute_jobs(data['chains'], number_of_jobs)

            if HYP == '0':
                smearing_str = f'HYP0_APE_alpha={APE_alpha}'
            else:
                smearing_str = f'HYP{HYP_steps}_alpha={HYP_alpha1}_{HYP_alpha2}_{HYP_alpha3}_APE_alpha={APE_alpha}'

            for job in jobs:

                log_path = f'/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing_test/potential/{theory_type}/{conf_type}/{conf_size}/{beta}/{mu}/{monopole1}/{smearing_str}/{job[0]}'
                conf_path_start1 = f'{conf_path_start}/{job[0]}/{conf_name}'
                try:
                    os.makedirs(log_path)
                except:
                    pass

                output_path = f'/home/clusters/rrcmpi/kudrov/smearing_cluster/smearing_test/potential/{theory_type}/{conf_type}/{conf_size}/{beta}/{mu}/{monopole1}'\
                    f'/{smearing_str}/{job[0]}'

                bashCommand = f'{queue_str} conf_format={conf_format},bites_skip={bites_skip},'\
                    f'conf_path_start={conf_path_start1},conf_path_end={conf_path_end},matrix_type={matrix_type},'\
                    f'padding={padding},L_spat={L_spat},L_time={L_time},calculation_step_APE={calculation_step_APE},'\
                    f'output_path={output_path},chain={job[0]},conf_start={job[1]},conf_end={job[2]},HYP_alpha1={HYP_alpha1},HYP_alpha2={HYP_alpha2},'\
                    f'HYP_alpha3={HYP_alpha3},APE_alpha={APE_alpha},stout_alpha={stout_alpha},APE={APE},HYP={HYP},stout={stout},HYP_steps={HYP_steps},APE_steps={APE_steps},stout_steps={stout_steps},'\
                    f'T_min={T_min},T_max={T_max},R_min={R_min},R_max={R_max}'\
                    f' -o {log_path}/{job[1]:04}-{job[2]:04}.o -e {log_path}/{job[1]:04}-{job[2]:04}.e /home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do_dep_potential.sh'
                # print(bashCommand)
                process = subprocess.Popen(bashCommand.split())
                output, error = process.communicate()
                #print(output, error)
