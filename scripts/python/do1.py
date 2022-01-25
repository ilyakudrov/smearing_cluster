import sys
import json
sys.path.append('/home/clusters/rrcmpi/kudrov/scripts/python')
from iterate_confs import *
import subprocess
import os

# conf_size = "40^4"
conf_size = "24^4"
# conf_type = "qc2dstag"
conf_type = "su2_suzuki"
matrix_type1 = "su2"

HYP_alpha1 = "1"
HYP_alpha2 = "1"
HYP_alpha3 = "0.5"
APE_alpha = "0.5"
stout_alpha = "0.15"
APE = "1"
HYP = "1"
stout = "0"
APE_steps = "40"
HYP_steps = "0"
stout_steps = "0"

number_of_jobs = 50

monopole = "monopole"

for beta in ['2.4', '2.5', '2.6']:
    for mu in [""]:
        f = open(
            f'/home/clusters/rrcmpi/kudrov/conf/{matrix_type1}/{conf_type}/{conf_size}/beta{beta}/{mu}/{monopole}/parameters.json')
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
            log_path = f'/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/{matrix_type}/{conf_type}/{conf_size}/beta{beta}/{mu}/{monopole}/{job[0]}'
            conf_path_start1 = f'{conf_path_start}/{job[0]}/{conf_name}'
            try:
                os.makedirs(log_path)
            except:
                pass

            output_path = f'/home/clusters/rrcmpi/kudrov/smearing_cluster/confs_smeared/{matrix_type}/'\
                f'{conf_type}/{conf_size}/beta{beta}/{mu}/{monopole}/HYP{HYP_steps}_alpha={HYP_alpha1}_{HYP_alpha2}_{HYP_alpha3}_APE{APE_steps}_alpha={APE_alpha}/{job[0]}'

            bashCommand = f'qsub -q long -v conf_format={conf_format},bites_skip={bites_skip},conf_path_start={conf_path_start1},conf_path_end={conf_path_end},output_path={output_path},'\
                f'matrix_type={matrix_type},HYP_alpha1={HYP_alpha1},HYP_alpha2={HYP_alpha2},HYP_alpha3={HYP_alpha3},padding={padding},'\
                f'APE_alpha={APE_alpha},stout_alpha={stout_alpha},APE={APE},HYP={HYP},stout={stout},APE_steps={APE_steps},HYP_steps={HYP_steps},'\
                f'stout_steps={stout_steps},L_spat={L_spat},L_time={L_time},conf_start={job[1]},conf_end={job[2]}'\
                f' -o {log_path}/{job[1]:04}-{job[2]:04}.o -e {log_path}/{job[1]:04}-{job[2]:04}.e /home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do.sh'
        # print(bashCommand)
            process = subprocess.Popen(bashCommand.split())
            output, error = process.communicate()
        # print(output, error)