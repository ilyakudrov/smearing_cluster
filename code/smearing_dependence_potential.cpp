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

  vector<double> wilson_loop;

  std::vector<std::vector<int>> directions;
  directions.push_back({1, 0, 0});

  std::vector<wilson_result> wilson_offaxis_result;

  if (wilson_enabled) {
    wilson_offaxis_result =
        wilson_offaxis(conf.array, directions, R_min, R_max, T_min, T_max);

    for (int i = 0; i < wilson_offaxis_result.size(); i++) {
      stream_wilson << "0," << wilson_offaxis_result[i].time_size << ","
                    << wilson_offaxis_result[i].space_size << ","
                    << wilson_offaxis_result[i].wilson_loop << std::endl;
    }
    wilson_offaxis_result.clear();
  }

  if (HYP_enabled == 1) {
    start_time = clock();
    for (int HYP_step = 0; HYP_step < HYP_steps; HYP_step++) {

      vector<vector<MATRIX>> smearing_first;
      vector<vector<MATRIX>> smearing_second;
      smearing_first = smearing_first_full(conf.array, HYP_alpha3);
      smearing_second =
          smearing_second_full(conf.array, smearing_first, HYP_alpha2);
      conf.array = smearing_HYP(conf.array, smearing_second, HYP_alpha1);
      smearing_first.clear();
      smearing_second.clear();

      if (wilson_enabled) {
        wilson_offaxis_result =
            wilson_offaxis(conf.array, directions, R_min, R_max, T_min, T_max);

        for (int i = 0; i < wilson_offaxis_result.size(); i++) {
          stream_wilson << HYP_step + 1 << ","
                        << wilson_offaxis_result[i].time_size << ","
                        << wilson_offaxis_result[i].space_size << ","
                        << wilson_offaxis_result[i].wilson_loop << std::endl;
        }
        wilson_offaxis_result.clear();
      }
    }

    end_time = clock();
    search_time = end_time - start_time;
    cout << "i=" << HYP_steps
         << " iterations of HYP time: " << search_time * 1. / CLOCKS_PER_SEC
         << endl;
  }

  if (APE_enabled == 1) {
    start_time = clock();
    for (int APE_step = 0; APE_step < APE_steps; APE_step++) {

      conf.array = smearing1_APE(conf.array, APE_alpha);

      if (APE_step % calculation_step_APE == 0) {
        if (wilson_enabled) {
          wilson_offaxis_result = wilson_offaxis(conf.array, directions, R_min,
                                                 R_max, T_min, T_max);

          for (int i = 0; i < wilson_offaxis_result.size(); i++) {
            stream_wilson << APE_step + HYP_steps + 1 << ","
                          << wilson_offaxis_result[i].time_size << ","
                          << wilson_offaxis_result[i].space_size << ","
                          << wilson_offaxis_result[i].wilson_loop << std::endl;
          }
        }
        wilson_offaxis_result.clear();
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
