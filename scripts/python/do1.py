import sys
import json
sys.path.append('/home/clusters/rrcmpi/kudrov/scripts/python')
from iterate_confs import *
import subprocess
import os

#conf_size = "40^4"
conf_size = "48^4"
#conf_size = "32^4"
#conf_size = "24^4"
#conf_type = "qc2dstag"
conf_type = "su2_suzuki"
theory_type = "su2"

#HYP_alpha1 = "1"
#HYP_alpha2 = "1"
#HYP_alpha3 = "0.5"
#APE_alpha = "0.5"
#APE = "1"
#HYP = "1"
#APE_steps = "40"
#HYP_steps = "0"

observable = 'flux'

number_of_jobs = 50

for monopole in ['monopoless', 'monopole', '/']:
    #for beta in ['beta2.4', 'beta2.5', 'beta2.6']:
    for beta in ['beta2.8']:
    #for beta in ['']:
        #for mu in ['mu0.20', 'mu0.25', 'mu0.30']:
        #for mu in ['mu0.25']:
        for mu in ['/']:
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

            #f = open(
            #    f'/home/clusters/rrcmpi/kudrov/smearing_cluster/smearing_parameters/{theory_type}/{conf_type}/{conf_size}/{beta}/{mu}/{monopole}/smearing_{observable}.json')
            #data_smearing = json.load(f)
            #HYP_alpha1 = data_smearing['HYP_alpha1']
            #HYP_alpha2 = data_smearing['HYP_alpha2']
            #HYP_alpha3 = data_smearing['HYP_alpha3']
            #APE_alpha = data_smearing['APE_alpha']
            #APE = data_smearing['APE']
            #HYP = data_smearing['HYP']
            #APE_steps = data_smearing['APE_steps']
            #HYP_steps = data_smearing['HYP_steps']

            #HYP_alpha1 = "1"
            #HYP_alpha2 = "1"
            #HYP_alpha3 = "0.5"
            HYP_alpha1 = "0.75"
            HYP_alpha2 = "0.6"
            HYP_alpha3 = "0.3"
            APE_alpha = "0.5"
            APE = "1"
            HYP = "1"
            APE_steps = "400"
            HYP_steps = "1"

            #chains = {'/': [201, 201]}

            #jobs = distribute_jobs(chains, number_of_jobs)
            jobs = distribute_jobs(data['chains'], number_of_jobs)
            for job in jobs:
                log_path = f'/home/clusters/rrcmpi/kudrov/smearing_cluster/logs/smearing/{theory_type}/{conf_type}/{conf_size}/{beta}/{mu}/{monopole}'\
			f'/HYP{HYP_steps}_alpha={HYP_alpha1}_{HYP_alpha2}_{HYP_alpha3}_APE{APE_steps}_alpha={APE_alpha}/{job[0]}'
                conf_path_start1 = f'{conf_path_start}/{job[0]}/{conf_name}'
                try:
                    os.makedirs(log_path)
                except:
                    pass

                output_path = f'/home/clusters/rrcmpi/kudrov/smearing_cluster/confs_smeared/{theory_type}/'\
                    f'{conf_type}/{conf_size}/{beta}/{mu}/{monopole}/HYP{HYP_steps}_alpha={HYP_alpha1}_{HYP_alpha2}_{HYP_alpha3}_APE{APE_steps}_alpha={APE_alpha}/{job[0]}'

                #qsub -q mem4gb -l nodes=1:ppn=2
                bashCommand = f'qsub -q mem4gb -l nodes=1:ppn=2 -v conf_format={conf_format},bites_skip={bites_skip},conf_path_start={conf_path_start1},conf_path_end={conf_path_end},output_path={output_path},'\
                    f'matrix_type={matrix_type},HYP_alpha1={HYP_alpha1},HYP_alpha2={HYP_alpha2},HYP_alpha3={HYP_alpha3},padding={padding},'\
                    f'APE_alpha={APE_alpha},APE={APE},HYP={HYP},APE_steps={APE_steps},HYP_steps={HYP_steps},'\
                    f'L_spat={L_spat},L_time={L_time},conf_start={job[1]},conf_end={job[2]}'\
                    f' -o {log_path}/{job[1]:04}-{job[2]:04}.o -e {log_path}/{job[1]:04}-{job[2]:04}.e /home/clusters/rrcmpi/kudrov/smearing_cluster/scripts/do.sh'
                #print(bashCommand)
                process = subprocess.Popen(bashCommand.split())
                output, error = process.communicate()
            # print(output, error)
