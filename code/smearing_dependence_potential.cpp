#include "basic_observables.h"
#include "data.h"
#include "flux_tube.h"
#include "link.h"
#include "matrix.h"
#include "smearing.h"
#include <iostream>

#include <ctime>

using namespace std;

int x_size;
int y_size;
int z_size;
int t_size;

int main(int argc, char *argv[]) {
  unsigned int start_time;
  unsigned int end_time;
  unsigned int search_time;

  string conf_format;
  string conf_path;
  string wilson_path;
  double HYP_alpha1, HYP_alpha2, HYP_alpha3;
  double APE_alpha;
  double stout_alpha;
  int APE_enabled, HYP_enabled, stout_enabled;
  int HYP_steps, APE_steps, stout_steps;
  int L_spat, L_time;
  int wilson_enabled;
  int calculation_step_APE;
  int T_min, T_max, R_min, R_max;
  int bites_skip = 0;
  for (int i = 1; i < argc; i++) {
    if (string(argv[i]) == "-conf_format") {
      conf_format = argv[++i];
    } else if (string(argv[i]) == "-bites_skip") {
      bites_skip = stoi(string(argv[++i]));
    } else if (string(argv[i]) == "-conf_path") {
      conf_path = argv[++i];
    } else if (string(argv[i]) == "-HYP_alpha1") {
      HYP_alpha1 = atof(argv[++i]);
    } else if (string(argv[i]) == "-HYP_alpha2") {
      HYP_alpha2 = atof(argv[++i]);
    } else if (string(argv[i]) == "-HYP_alpha3") {
      HYP_alpha3 = atof(argv[++i]);
    } else if (string(argv[i]) == "-APE_alpha") {
      APE_alpha = atof(argv[++i]);
    } else if (string(argv[i]) == "-stout_alpha") {
      stout_alpha = atof(argv[++i]);
    } else if (string(argv[i]) == "-APE") {
      APE_enabled = stoi(argv[++i]);
    } else if (string(argv[i]) == "-HYP") {
      HYP_enabled = stoi(argv[++i]);
    } else if (string(argv[i]) == "-stout") {
      stout_enabled = stoi(argv[++i]);
    } else if (string(argv[i]) == "-APE_steps") {
      APE_steps = stoi(argv[++i]);
    } else if (string(argv[i]) == "-HYP_steps") {
      HYP_steps = stoi(argv[++i]);
    } else if (string(argv[i]) == "-stout_steps") {
      stout_steps = stoi(argv[++i]);
    } else if (string(argv[i]) == "-L_spat") {
      L_spat = stoi(string(argv[++i]));
    } else if (string(argv[i]) == "-L_time") {
      L_time = stoi(string(argv[++i]));
    } else if (string(argv[i]) == "-wilson_path") {
      wilson_path = argv[++i];
    } else if (std::string(argv[i]) == "-T_min") {
      T_min = stoi(std::string(argv[++i]));
    } else if (std::string(argv[i]) == "-T_max") {
      T_max = stoi(std::string(argv[++i]));
    } else if (std::string(argv[i]) == "-R_min") {
      R_min = stoi(std::string(argv[++i]));
    } else if (std::string(argv[i]) == "-R_max") {
      R_max = stoi(std::string(argv[++i]));
    } else if (std::string(argv[i]) == "-calculation_step_APE") {
      calculation_step_APE = stoi(std::string(argv[++i]));
    }
  }

  x_size = L_spat;
  y_size = L_spat;
  z_size = L_spat;
  t_size = L_time;

  wilson_enabled = 1;

  cout << "conf_format " << conf_format << endl;
  cout << "conf_path " << conf_path << endl;
  cout << "bites_skip " << bites_skip << endl;
  cout << "HYP_alpha1 " << HYP_alpha1 << endl;
  cout << "HYP_alpha2 " << HYP_alpha2 << endl;
  cout << "HYP_alpha3 " << HYP_alpha3 << endl;
  cout << "APE_alpha " << APE_alpha << endl;
  cout << "stout_alpha " << stout_alpha << endl;
  cout << "APE_enabled " << APE_enabled << endl;
  cout << "HYP_enabled " << HYP_enabled << endl;
  cout << "stout_enabled " << stout_enabled << endl;
  cout << "APE_steps " << APE_steps << endl;
  cout << "HYP_steps " << HYP_steps << endl;
  cout << "stout_steps " << stout_steps << endl;
  cout << "L_spat " << L_spat << endl;
  cout << "L_time " << L_time << endl;
  cout << "wilson_path " << wilson_path << endl;
  cout << "wilson_enabled " << wilson_enabled << endl;
  std::cout << "T_min " << T_min << std::endl;
  std::cout << "T_max " << T_max << std::endl;
  std::cout << "R_min " << R_min << std::endl;
  std::cout << "R_max " << R_max << std::endl;
  std::cout << "calculation_step_APE " << calculation_step_APE << std::endl;
  cout << endl;

  data<MATRIX> conf;

  if (std::string(conf_format) == "float") {
    conf.read_float(conf_path, bites_skip);
  } else if (std::string(conf_format) == "double") {
    conf.read_double(conf_path, bites_skip);
  } else if (std::string(conf_format) == "double_qc2dstag") {
    conf.read_double_qc2dstag(conf_path);
  }

  cout << "average plaket unsmeared " << plaket(conf.array) << endl;

  ofstream stream_wilson;
  // open file
  if (wilson_enabled) {
    stream_wilson.open(wilson_path);

    stream_wilson << "smearing_step,time_size,space_size,wilson_loop"
                  << std::endl;
  }

  std::map<std::tuple<int, int>, double> wilson_loops;

  std::vector<std::vector<MATRIX>> conf_separated = separate_wilson(conf.array);

  conf.array.clear();
  conf.array.shrink_to_fit();

  if (wilson_enabled) {
    wilson_loops = wilson_parallel(conf_separated, R_min, R_max, T_min, T_max);

    for (auto it = wilson_loops.begin(); it != wilson_loops.end(); it++) {
      stream_wilson << "0," << get<0>(it->first) << "," << get<1>(it->first)
                    << "," << it->second << std::endl;
    }
  }

  if (HYP_enabled == 1) {
    start_time = clock();
    for (int HYP_step = 0; HYP_step < HYP_steps; HYP_step++) {

      smearing_HYP_new(conf_separated, HYP_alpha1, HYP_alpha2, HYP_alpha3);

      if (wilson_enabled) {
        wilson_loops =
            wilson_parallel(conf_separated, R_min, R_max, T_min, T_max);

        for (auto it = wilson_loops.begin(); it != wilson_loops.end(); it++) {
          stream_wilson << HYP_step << "," << get<0>(it->first) << "," << get<1>(it->first)
                        << "," << it->second << std::endl;
        }
      }
    }

    end_time = clock();
    search_time = end_time - start_time;
    cout << "i=" << HYP_steps
         << " iterations of HYP time: " << search_time * 1. / CLOCKS_PER_SEC
         << endl;
  }

  int step_number;

  if (APE_enabled == 1) {
    start_time = clock();
    for (int APE_step = 0; APE_step < APE_steps; APE_step++) {

      smearing_APE_new(conf_separated, APE_alpha);

      if (APE_step % calculation_step_APE == 0) {
        if (wilson_enabled) {
          wilson_loops =
              wilson_parallel(conf_separated, R_min, R_max, T_min, T_max);
          if(HYP_enabled == 1) step_number = HYP_steps +  APE_step;
          else step_number = APE_step;

          for (auto it = wilson_loops.begin(); it != wilson_loops.end(); it++) {
            stream_wilson << step_number << "," << get<0>(it->first) << ","
                          << get<1>(it->first) << "," << it->second
                          << std::endl;
          }
        }
      }

      end_time = clock();
      search_time = end_time - start_time;
      cout << "i=" << APE_steps
           << " iteration of APE time: " << search_time * 1. / CLOCKS_PER_SEC
           << endl;
    }
    if (wilson_enabled) {
      stream_wilson.close();
    }
  }
}
