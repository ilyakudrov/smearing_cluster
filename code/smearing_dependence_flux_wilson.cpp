#include "basic_observables.h"
#include "data.h"
#include "flux_tube.h"
#include "link.h"
#include "matrix.h"
#include "smearing.h"

#include <ctime>
#include <iostream>
#include <numeric>
#include <omp.h>

using namespace std;

int x_size;
int y_size;
int z_size;
int t_size;

int main(int argc, char *argv[]) {
  double start_time;
  double end_time;
  double search_time;

  std::string conf_format_plaket;
  std::string conf_format_wilson;
  std::string conf_path_plaket;
  std::string conf_path_wilson;
  std::string output_path_electric;
  std::string output_path_magnetic;
  string flux_path;
  double HYP_alpha1, HYP_alpha2, HYP_alpha3;
  double APE_alpha;
  double stout_alpha;
  int APE_enabled, HYP_enabled, stout_enabled;
  int HYP_steps, APE_steps, stout_steps;
  int L_spat, L_time;
  int flux_enabled;
  int calculation_step_APE;
  int bites_skip_plaket = 0;
  int bites_skip_wilson = 0;
  double T_min, T_max;
  double R_min, R_max;
  for (int i = 1; i < argc; i++) {
    if (string(argv[i]) == "-conf_format_plaket") {
      conf_format_plaket = argv[++i];
    } else if (string(argv[i]) == "-bites_skip_plaket") {
      bites_skip_plaket = stoi(string(argv[++i]));
    } else if (string(argv[i]) == "-bites_skip_wilson") {
      bites_skip_wilson = stoi(string(argv[++i]));
    } else if (string(argv[i]) == "-conf_path_plaket") {
      conf_path_plaket = argv[++i];
    } else if (string(argv[i]) == "-conf_format_wilson") {
      conf_format_wilson = argv[++i];
    } else if (string(argv[i]) == "-conf_path_wilson") {
      conf_path_wilson = argv[++i];
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
    } else if (string(argv[i]) == "-flux_path") {
      flux_path = argv[++i];
    } else if (std::string(argv[i]) == "-calculation_step_APE") {
      calculation_step_APE = stoi(std::string(argv[++i]));
    } else if (string(argv[i]) == "-T_min") {
      T_min = atof(argv[++i]);
    } else if (string(argv[i]) == "-T_max") {
      T_max = atof(argv[++i]);
    } else if (string(argv[i]) == "-R_min") {
      R_min = atof(argv[++i]);
    } else if (string(argv[i]) == "-R_max") {
      R_max = atof(argv[++i]);
    }
  }

  x_size = L_spat;
  y_size = L_spat;
  z_size = L_spat;
  t_size = L_time;

  flux_enabled = 1;

  std::cout << "conf_format_plaket " << conf_format_plaket << std::endl;
  cout << "bites_skip_plaket " << bites_skip_plaket << endl;
  std::cout << "conf_format_wilson " << conf_format_wilson << std::endl;
  cout << "bites_skip_wilson " << bites_skip_wilson << endl;
  std::cout << "conf_path_plaket " << conf_path_plaket << std::endl;
  std::cout << "conf_path_wilson " << conf_path_wilson << std::endl;
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
  cout << "flux_path " << flux_path << endl;
  cout << "flux_enabled " << flux_enabled << endl;
  std::cout << "calculation_step_APE " << calculation_step_APE << std::endl;
  cout << "T_min " << T_min << endl;
  cout << "T_max " << T_max << endl;
  cout << "R_min " << R_min << endl;
  cout << "R_max " << R_max << endl;
  cout << endl;

  data<MATRIX_PLAKET> conf_plaket;
  data<MATRIX_WILSON> conf_wilson;

  if (std::string(conf_format_plaket) == "float") {
    conf_plaket.read_float(conf_path_plaket, bites_skip_plaket);
  } else if (std::string(conf_format_plaket) == "double") {
    conf_plaket.read_double(conf_path_plaket, bites_skip_plaket);
  } else if (std::string(conf_format_plaket) == "double_qc2dstag") {
    conf_plaket.read_double_qc2dstag(conf_path_plaket);
  }

  if (std::string(conf_format_wilson) == "float") {
    conf_wilson.read_float(conf_path_wilson, bites_skip_wilson);
  } else if (std::string(conf_format_wilson) == "double") {
    conf_wilson.read_double(conf_path_wilson, bites_skip_wilson);
  } else if (std::string(conf_format_wilson) == "double_qc2dstag") {
    conf_wilson.read_double_qc2dstag(conf_path_wilson);
  }

  std::vector<std::vector<MATRIX_PLAKET>> separated_plaket =
      separate_wilson(conf_plaket.array);

  conf_plaket.array.clear();
  conf_plaket.array.shrink_to_fit();

  double plaket_time = plaket_time_parallel(separated_plaket);

  std::vector<double> plaket_time_tr = plaket_aver_tr_time(separated_plaket);

  cout << "plaket time = " << plaket_time << endl;

  separated_plaket.clear();
  separated_plaket.shrink_to_fit();

  std::map<std::tuple<int, int, int>, double> flux_tube;
  std::map<std::tuple<int, int>, double> wilson_loops;

  std::vector<std::vector<MATRIX_PLAKET>> separated_wilson =
      separate_wilson(conf_wilson.array);

  conf_wilson.array.clear();
  conf_wilson.array.shrink_to_fit();

  ofstream stream_flux;
  // open file
  if (flux_enabled) {
    stream_flux.open(flux_path);
    stream_flux << "smearing_step,time_size,space_size,d,correlator_electric,"
                   "wilson_loop,plaket"
                << std::endl;
  }

  if (flux_enabled) {

    wilson_loops =
        wilson_parallel(separated_wilson, R_min, R_max, T_min, T_max);

    flux_tube =
        wilson_plaket_correlator(plaket_time_tr, separated_wilson, T_min, T_max,
                                 R_min, R_max, 5, 0, "longitudinal");

    for (auto it = flux_tube.begin(); it != flux_tube.end(); it++) {
      stream_flux << 0 << "," << get<0>(it->first) << "," << get<1>(it->first)
                  << "," << get<2>(it->first) << "," << it->second << ","
                  << wilson_loops[std::tuple<int, int>(get<0>(it->first),
                                                       get<1>(it->first))]
                  << "," << plaket_time << std::endl;
    }
  }

  if (HYP_enabled == 1) {
    start_time = omp_get_wtime();
    for (int HYP_step = 0; HYP_step < HYP_steps; HYP_step++) {

      smearing_HYP_new(separated_wilson, HYP_alpha1, HYP_alpha2, HYP_alpha3);

      if (flux_enabled) {

        wilson_loops =
            wilson_parallel(separated_wilson, R_min, R_max, T_min, T_max);

        flux_tube =
            wilson_plaket_correlator(plaket_time_tr, separated_wilson, T_min,
                                     T_max, R_min, R_max, 5, 0, "longitudinal");

        for (auto it = flux_tube.begin(); it != flux_tube.end(); it++) {
          stream_flux << HYP_step + 1 << "," << get<0>(it->first) << ","
                      << get<1>(it->first) << "," << get<2>(it->first) << ","
                      << it->second << ","
                      << wilson_loops[std::tuple<int, int>(get<0>(it->first),
                                                           get<1>(it->first))]
                      << "," << plaket_time << std::endl;
        }
      }
    }

    end_time = omp_get_wtime();
    search_time = end_time - start_time;
    std::cout << "i=" << HYP_steps << " iterations of HYP time: " << search_time
              << std::endl;
  }

  if (APE_enabled == 1) {

    int step_number;
    start_time = omp_get_wtime();
    for (int APE_step = 0; APE_step < APE_steps; APE_step++) {

      smearing_APE_new(separated_wilson, APE_alpha);

      if (APE_step % calculation_step_APE == 0) {
        if (flux_enabled) {

          if (HYP_enabled == 1)
            step_number = HYP_steps + APE_step + 1;
          else
            step_number = APE_step + 1;

          wilson_loops =
              wilson_parallel(separated_wilson, R_min, R_max, T_min, T_max);

          flux_tube = wilson_plaket_correlator(plaket_time_tr, separated_wilson,
                                               T_min, T_max, R_min, R_max, 5, 0,
                                               "longitudinal");

          for (auto it = flux_tube.begin(); it != flux_tube.end(); it++) {
            stream_flux << step_number << "," << get<0>(it->first) << ","
                        << get<1>(it->first) << "," << get<2>(it->first) << ","
                        << it->second << ","
                        << wilson_loops[std::tuple<int, int>(get<0>(it->first),
                                                             get<1>(it->first))]
                        << "," << plaket_time << std::endl;
          }
        }
      }
    }

    end_time = omp_get_wtime();
    search_time = end_time - start_time;
    std::cout << "i=" << APE_steps << " iteration of APE time: " << search_time
              << std::endl;
  }
  if (flux_enabled) {
    stream_flux.close();
  }
}
