#include "smearing.h"
#include "basic_observables.h"
#include "data.h"
#include "link.h"
#include "matrix.h"
#include <sstream>

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
  string smeared_path;
  double HYP_alpha1, HYP_alpha2, HYP_alpha3;
  double APE_alpha;
  double stout_alpha = 0;
  int APE_enabled, HYP_enabled, stout_enabled = 0;
  int HYP_steps, APE_steps, stout_steps = 0;
  int L_spat, L_time;
  int bites_skip = 0;
  for (int i = 1; i < argc; i++) {
    if (string(argv[i]) == "-conf_format") {
      conf_format = argv[++i];
    } else if (string(argv[i]) == "-conf_path") {
      conf_path = argv[++i];
    } else if (string(argv[i]) == "-bites_skip") {
      bites_skip = stoi(string(argv[++i]));
    } else if (string(argv[i]) == "-smeared_path") {
      smeared_path = argv[++i];
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
      APE_enabled = atof(argv[++i]);
    } else if (string(argv[i]) == "-HYP") {
      HYP_enabled = atof(argv[++i]);
    } else if (string(argv[i]) == "-stout") {
      stout_enabled = atof(argv[++i]);
    } else if (string(argv[i]) == "-APE_steps") {
      APE_steps = atof(argv[++i]);
    } else if (string(argv[i]) == "-HYP_steps") {
      HYP_steps = atof(argv[++i]);
    } else if (string(argv[i]) == "-stout_steps") {
      stout_steps = atof(argv[++i]);
    } else if (string(argv[i]) == "-L_spat") {
      L_spat = stoi(string(argv[++i]));
    } else if (string(argv[i]) == "-L_time") {
      L_time = stoi(string(argv[++i]));
    }
  }

  x_size = L_spat;
  y_size = L_spat;
  z_size = L_spat;
  t_size = L_time;

  cout << "conf_format " << conf_format << endl;
  cout << "conf_path " << conf_path << endl;
  cout << "bites_skip " << bites_skip << endl;
  cout << "smeared_path " << smeared_path << endl;
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
  cout << endl;

  data<MATRIX> conf;
  link1 link(x_size, y_size, z_size, t_size);

  if (string(conf_format) == "float") {
    conf.read_float(conf_path, bites_skip);
  } else if (string(conf_format) == "double") {
    conf.read_double(conf_path, bites_skip);
  } else if (string(conf_format) == "double_qc2dstag") {
    conf.read_double_qc2dstag(conf_path);
  }

  cout << "average plaket unsmeared " << plaket(conf.array) << endl;

  if (HYP_enabled == 1) {
    for (int i = 0; i < HYP_steps; i++) {
      start_time = clock();

      vector<vector<MATRIX>> smearing_first(6, vector<MATRIX>(1));
      vector<vector<MATRIX>> smearing_second(4, vector<MATRIX>(1));
      smearing_first = smearing_first_full(conf.array, HYP_alpha3);
      smearing_second =
          smearing_second_full(conf.array, smearing_first, HYP_alpha2);
      conf.array = smearing_HYP(conf.array, smearing_second, HYP_alpha1);

      end_time = clock();
      search_time = end_time - start_time;
    }
    cout << HYP_steps
         << " iterations of HYP time: " << search_time * 1. / CLOCKS_PER_SEC
         << endl;
  }
  if (APE_enabled == 1) {
      start_time = clock();
    for (int i = 0; i < APE_steps; i++) {

      conf.array = smearing1_APE(conf.array, APE_alpha);
      end_time = clock();
      search_time = end_time - start_time;
    }
    cout << APE_steps
         << " iterations of APE time: " << search_time * 1. / CLOCKS_PER_SEC
         << endl;
  }
  /*if(stout_enabled == 1){
          for(int i = 0;i < stout_steps;i++){
                  start_time =  clock();

                  conf.array = smearing_stout(conf, stout_alpha);
                  end_time = clock();
                  search_time = end_time - start_time;
                  cout<<"i="<<i<<" iteration of APE time:
  "<<search_time*1./CLOCKS_PER_SEC<<endl;
          }
  }*/
  cout << "average plaket smeared " << plaket(conf.array) << endl;
  conf.write_double(smeared_path);
}
