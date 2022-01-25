#include "basic_observables.h"
#include "data.h"
#include "flux_tube.h"
#include "link.h"
#include "matrix.h"
#include "result.h"
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

  vector<double> plaket_time_trace =
      calculate_plaket_time_tr(conf_plaket.array);

  double plaket_time_average =
      accumulate(plaket_time_trace.cbegin(), plaket_time_trace.cend(), 0.0) /
      plaket_time_trace.size();

  conf_plaket.array.clear();

  cout << "average plaket unsmeared " << plaket_time_trace << endl;

  ofstream stream_flux;
  // open file
  if (flux_enabled) {
    stream_flux.open(flux_path);
  }

  int T_num = 5;
  int R_num = 3;

  vector<int> T_sizes = {4, 6, 8, 10, 12};
  vector<int> R_sizes = {6, 8, 12};

  vector<double> wilson_loop_trace;
  std::map<int, double> flux_tmp;
  int d;
  int x_trans = 0;
  int T, R;

  if (flux_enabled) {

    stream_flux << "smearing_step,T,R,d,correlator,wilson,plaket" << endl;

    for (int i = 0; i < T_num; i++) {
      T = T_sizes[i];
      for (int j = 0; j < R_num; j++) {
        R = R_sizes[j];
        d = R / 2;
        wilson_loop_trace = calculate_wilson_loop_tr(conf_wilson.array, R, T);
        wilson_loop_average = accumulate(wilson_loop_trace.cbegin(),
                                         wilson_loop_trace.cend(), 0.0) /
                              wilson_loop_trace.size();
        flux_tmp = wilson_plaket_correlator_electric(
            wilson_loop_trace, plaket_time_trace, R, T, x_trans, 0, 0);
        stream_flux << "0," << T << "," << R << "," << d << "," << flux_tmp[0]
                    << "," << wilson_loop_average << "," << plaket_time_average
                    << endl;
        flux_tmp = wilson_plaket_correlator_electric(
            wilson_loop_trace, plaket_time_trace, R, T, x_trans, d, d);
        stream_flux << "0," << T << "," << R << "," << d << "," << flux_tmp[d]
                    << "," << wilson_loop_average << "," << plaket_time_average
                    << endl;
      }
    }
  }

  if (HYP_enabled == 1) {
    start_time = clock();
    for (int HYP_step = 0; HYP_step < HYP_steps; HYP_step++) {

      vector<vector<MATRIX_WILSON>> smearing_first;
      vector<vector<MATRIX_WILSON>> smearing_second;
      smearing_first = smearing_first_full(conf_wilson.array, HYP_alpha3);
      smearing_second =
          smearing_second_full(conf_wilson.array, smearing_first, HYP_alpha2);
      conf_wilson.array =
          smearing_HYP(conf_wilson.array, smearing_second, HYP_alpha1);
      smearing_first.clear();
      smearing_second.clear();

      if (flux_enabled) {
        for (int i = 0; i < T_num; i++) {
          T = T_sizes[i];
          for (int j = 0; j < R_num; j++) {
            R = R_sizes[j];
            d = R / 2;
            wilson_loop_trace =
                calculate_wilson_loop_tr(conf_wilson.array, R, T);
            wilson_loop_average = accumulate(wilson_loop_trace.cbegin(),
                                             wilson_loop_trace.cend(), 0.0) /
                                  wilson_loop_trace.size();
            flux_tmp = wilson_plaket_correlator_electric(
                wilson_loop_trace, plaket_time_trace, R, T, x_trans, 0, 0);
            stream_flux << HYP_step + 1 << "," << T << "," << R << "," << 0
                        << "," << flux_tmp[0] << "," << wilson_loop_average
                        << "," << plaket_time_average << endl;
            flux_tmp = wilson_plaket_correlator_electric(
                wilson_loop_trace, plaket_time_trace, R, T, x_trans, d, d);
            stream_flux << HYP_step + 1 << "," << T << "," << R << "," << d
                        << "," << flux_tmp[d] << "," << wilson_loop_average
                        << "," << plaket_time_average << endl;
          }
        }
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
        if (flux_enabled) {
          for (int i = 0; i < T_num; i++) {
            T = T_sizes[i];
            for (int j = 0; j < R_num; j++) {
              R = R_sizes[j];
              d = R / 2;
              wilson_loop_trace =
                  calculate_wilson_loop_tr(conf_wilson.array, R, T);
              wilson_loop_average = accumulate(wilson_loop_trace.cbegin(),
                                               wilson_loop_trace.cend(), 0.0) /
                                    wilson_loop_trace.size();
              flux_tmp = wilson_plaket_correlator_electric(
                  wilson_loop_trace, plaket_time_trace, R, T, x_trans, 0, 0);
              stream_flux << APE_step + HYP_steps + 1 << "," << T << "," << R
                          << "," << 0 << "," << flux_tmp[0] << ","
                          << wilson_loop_average << "," << plaket_time_average
                          << endl;
              flux_tmp = wilson_plaket_correlator_electric(
                  wilson_loop_trace, plaket_time_trace, R, T, x_trans, d, d);
              stream_flux << APE_step + HYP_steps + 1 << "," << T << "," << R
                          << "," << d << "," << flux_tmp[d] << ","
                          << wilson_loop_average << "," << plaket_time_average
                          << endl;
            }
          }
        }
      }
    }

    end_time = clock();
    search_time = end_time - start_time;
    cout << "i=" << APE_steps
         << " iteration of APE time: " << search_time * 1. / CLOCKS_PER_SEC
         << endl;
  }
  if (flux_enabled) {
    stream_flux.close();
  }
}
