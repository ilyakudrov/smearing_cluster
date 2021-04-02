#include "data.h"
#include "basic_observables.h"
#include "link.h"
#include "matrix.h"
#include "result.h"
#include "flux_tube.h"
#include "smearing.h"
#include <iostream>

#include <ctime>

using namespace std;

int x_size;
int y_size;
int z_size;
int t_size;

int main(int argc, char* argv[]) {
	unsigned int start_time;
        unsigned int end_time;
        unsigned int search_time;

	string conf_format;
        string conf_path;
	string conf_num;
        //string smeared_path;
	string wilson_path;
	string flux_path;
	double HYP_alpha1, HYP_alpha2, HYP_alpha3;
	double APE_alpha;
	double stout_alpha;
	int APE_enabled, HYP_enabled, stout_enabled;
	int HYP_steps, APE_steps, stout_steps;
	int L_spat, L_time;
	//int T, R;
	int flux_enabled, wilson_enabled;
        for (int i = 1; i < argc; i++) {
                if (string(argv[i]) == "-conf_format") { conf_format = argv[++i]; }
                else if (string(argv[i]) == "-conf_path") { conf_path = argv[++i]; }
                //else if (string(argv[i]) == "-smeared_path") { smeared_path = argv[++i]; }
		else if (string(argv[i]) == "-HYP_alpha1") { HYP_alpha1 = atof(argv[++i]); }
		else if (string(argv[i]) == "-HYP_alpha2") { HYP_alpha2 = atof(argv[++i]); }
		else if (string(argv[i]) == "-HYP_alpha3") { HYP_alpha3 = atof(argv[++i]); }
		else if (string(argv[i]) == "-APE_alpha") { APE_alpha = atof(argv[++i]); }
		else if (string(argv[i]) == "-stout_alpha") { stout_alpha = atof(argv[++i]); }
		else if (string(argv[i]) == "-APE") { APE_enabled = atof(argv[++i]); }
		else if (string(argv[i]) == "-HYP") { HYP_enabled = atof(argv[++i]); }
		else if (string(argv[i]) == "-stout") { stout_enabled = atof(argv[++i]); }
		else if (string(argv[i]) == "-APE_steps") { APE_steps = atof(argv[++i]); }
		else if (string(argv[i]) == "-HYP_steps") { HYP_steps = atof(argv[++i]); }
		else if (string(argv[i]) == "-stout_steps") { stout_steps = atof(argv[++i]); }
		else if (string(argv[i]) == "-L_spat") { L_spat = stoi(string(argv[++i])); }
                else if (string(argv[i]) == "-L_time") { L_time = stoi(string(argv[++i])); }
		else if (string(argv[i]) == "-wilson_path") { wilson_path = argv[++i]; }
		else if (string(argv[i]) == "-flux_path") { flux_path = argv[++i]; }
		//else if (string(argv[i]) == "-T") { T = stoi(string(argv[++i])); }
		//else if (string(argv[i]) == "-R") { R = stoi(string(argv[++i])); }
		else if (string(argv[i]) == "-flux_enabled") { flux_enabled = atof(argv[++i]); }
		else if (string(argv[i]) == "-wilson_enabled") { wilson_enabled = atof(argv[++i]); }
		else if (string(argv[i]) == "-conf_num") { conf_num = argv[++i]; }
        }

	x_size = L_spat;
        y_size = L_spat;
        z_size = L_spat;
        t_size = L_time;

	cout<<"conf_format "<<conf_format<<endl;
	cout<<"conf_path "<<conf_path<<endl;
	//cout<<"smeared_path "<<smeared_path<<endl;
	cout<<"HYP_alpha1 "<<HYP_alpha1<<endl;
	cout<<"HYP_alpha2 "<<HYP_alpha2<<endl;
	cout<<"HYP_alpha3 "<<HYP_alpha3<<endl;
	cout<<"APE_alpha "<<APE_alpha<<endl;
	cout<<"stout_alpha "<<stout_alpha<<endl;
	cout<<"APE_enabled "<<APE_enabled<<endl;
	cout<<"HYP_enabled "<<HYP_enabled<<endl;
	cout<<"stout_enabled "<<stout_enabled<<endl;
	cout<<"APE_steps "<<APE_steps<<endl;
	cout<<"HYP_steps "<<HYP_steps<<endl;
	cout<<"stout_steps "<<stout_steps<<endl;
	cout<<"L_spat "<<-L_spat<<endl;
	cout<<"L_time "<<L_time<<endl;
	cout<<"wilson_path "<<wilson_path<<endl;
	cout<<"flux_path "<<flux_path<<endl;
	cout<<"flux_enabled "<<flux_enabled<<endl;
	cout<<"wilson_enabled "<<wilson_enabled<<endl;
	cout<<"conf_num "<<conf_num<<endl;
	cout<<endl;

	data<MATRIX> conf;
	link1 link(x_size, y_size, z_size, t_size);

	if(string(conf_format) == "float"){
                conf.read_float(conf_path);
        }
        else if (string(conf_format) == "double"){
                conf.read_double(conf_path);
        }
        else if (string(conf_format) == "double_fortran"){
                conf.read_double_fortran(conf_path);
        }
        else if (string(conf_format) == "float_fortran"){
                conf.read_float_fortran(conf_path);
        }
	else if (string(conf_format) == "double_qc2dstag"){
                conf.read_double_qc2dstag(conf_path);
        }

        cout<<"average plaket unsmeared "<<plaket(conf.array)<<endl;

	// open file
	ofstream stream_flux;
	stream_flux.open(flux_path);

	int R, T;
	vector<result> wilson_res(3);
	//wilson_res.array.push_back(wilson(conf.array, R, T));
	vector<FLOAT> wilson_loops;
	if(wilson_enabled){
		for(int j = 0;j < 3;j++){
			wilson_loops = wilson(conf.array, R+j*4, R+j*4, T+j*4, T+j*4);
        		wilson_res[j].array.push_back(wilson_loops[0]);
		}
	}
	double c = plaket_time(conf.array);
	double a, b;
	double aver[2];
	result vec_wilson;
        vector<FLOAT> vec_plaket_time;
	vec_plaket_time = calculate_plaket_time_tr(conf.array);
	vector<FLOAT> flux_res;
	vector<FLOAT> flux_tmp;
	int d_min;
	int d_max;
	int x_trans = 0;
	vector<int> T_sizes = {8, 16};
	vector<int> R_sizes = {8, 16};

	stream_flux<<"smearing_step";
	for(int i = 0;i < 2;i++){
		for(int j = 0;j < 2;j++){
			for(int k = 0;k < 2;k++){
				stream_flux<<",T="<<T_sizes[i]<<"_R="<<R_sizes[j]<<"_d="<<k*(R_sizes[j]/2)<<"_electric";
			}
			stream_flux<<",T="<<T_sizes[i]<<"_R="<<R_sizes[j]<<"_wilson";
		}
	}
	stream_flux<<",plaket"<<endl;

	if(flux_enabled){
		stream_flux<<0;
		for(int i = 0;i < 2;i++){
			T = T_sizes[i];
			for(int j = 0;j < 2;j++){
				R = R_sizes[j];
				d_min = R/2;
				d_max = R/2;
				vec_wilson.array = calculate_wilson_loop_tr(conf.array, R, T);
        			vec_wilson.average(aver);
        			b = aver[0];
				flux_tmp = wilson_plaket_correlator_electric(vec_wilson.array, vec_plaket_time, R, T, x_trans, 0, 0);
				stream_flux<<","<<flux_tmp[0];
				flux_tmp = wilson_plaket_correlator_electric(vec_wilson.array, vec_plaket_time, R, T, x_trans, d_min, d_max);
				stream_flux<<","<<flux_tmp[0];
				stream_flux<<","<<b;
			}
		}
		stream_flux<<","<<c<<endl;
	}

	if(HYP_enabled == 1){
		for(int HYP_step = 0;HYP_step < HYP_steps;HYP_step++){
			start_time =  clock();
			
			vector<vector<MATRIX> > smearing_first;
    			vector<vector<MATRIX> > smearing_second;
    			smearing_first = smearing_first_full(conf.array, HYP_alpha3);
    			smearing_second = smearing_second_full(conf.array, smearing_first, HYP_alpha2);
    			conf.array = smearing_HYP(conf.array, smearing_second, HYP_alpha1);

			if(wilson_enabled){
				cout<<"wilson_enabled"<<endl;
				for(int j = 0;j < 3;j++){
					wilson_loops = wilson(conf.array, R+j*4, R+j*4, T+j*4, T+j*4);
					wilson_res[j].array.push_back(wilson_loops[0]);
				}
			}
			
			if(flux_enabled){
				cout<<"flux_enabled"<<endl;
				stream_flux<<HYP_step+1;
                		for(int i = 0;i < 2;i++){
                        		T = T_sizes[i];
                        		for(int j = 0;j < 2;j++){
                                		R = R_sizes[j];
                                		d_min = R/2;
                                		d_max = R/2;
                                		vec_wilson.array = calculate_wilson_loop_tr(conf.array, R, T);
                                		vec_wilson.average(aver);
                                		b = aver[0];
                                		flux_tmp = wilson_plaket_correlator_electric(vec_wilson.array, vec_plaket_time, R, T, x_trans, 0, 0);
                                		stream_flux<<","<<flux_tmp[0];
                                		flux_tmp = wilson_plaket_correlator_electric(vec_wilson.array, vec_plaket_time, R, T, x_trans, d_min, d_max);
                                		stream_flux<<","<<flux_tmp[0];
						stream_flux<<","<<b;
                        		}
                		}
                		stream_flux<<","<<c<<endl;
        		}
		}

		end_time = clock();
                search_time = end_time - start_time;
               	cout<<"i="<<HYP_steps<<" iterations of HYP time: "<<search_time*1./CLOCKS_PER_SEC<<endl;
	}
	if(APE_enabled == 1){
        	for(int APE_step = 0;APE_step < APE_steps;APE_step++){
			start_time =  clock();

        		conf.array = smearing_APE(conf.array, APE_alpha);

			if(wilson_enabled){
                                for(int j = 0;j < 3;j++){
                                        wilson_loops = wilson(conf.array, R+j*4, R+j*4, T+j*4, T+j*4);
                                        wilson_res[j].array.push_back(wilson_loops[0]);
                                }
                        }

			if(APE_step % 5 == 0){
                        	if(flux_enabled){
					stream_flux<<APE_step + HYP_steps + 1;
                			for(int i = 0;i < 2;i++){
                        			T = T_sizes[i];
                        			for(int j = 0;j < 2;j++){
                                			R = R_sizes[j];
                                			d_min = R/2;
                                			d_max = R/2;
                                			vec_wilson.array = calculate_wilson_loop_tr(conf.array, R, T);
                                			vec_wilson.average(aver);
                                			b = aver[0];
                                			flux_tmp = wilson_plaket_correlator_electric(vec_wilson.array, vec_plaket_time, R, T, x_trans, 0, 0);
                                			stream_flux<<","<<flux_tmp[0];
                                			flux_tmp = wilson_plaket_correlator_electric(vec_wilson.array, vec_plaket_time, R, T, x_trans, d_min, d_max);
                                			stream_flux<<","<<flux_tmp[0];
							stream_flux<<","<<b;
                        			}
                			}
                			stream_flux<<","<<c<<endl;
                        	}
			}
		}

		end_time = clock();
        	search_time = end_time - start_time;
        	cout<<"i="<<APE_steps<<" iteration of APE time: "<<search_time*1./CLOCKS_PER_SEC<<endl;
	}
	/*if(stout_enabled == 1){
                for(int i = 0;i < stout_steps;i++){
                        start_time =  clock();

                        //conf.array = link.smearing_stout(conf, stout_alpha);
                        end_time = clock();
                        search_time = end_time - start_time;
                        cout<<"i="<<i<<" iteration of APE time: "<<search_time*1./CLOCKS_PER_SEC<<endl;
                }
        }*/
	cout<<"average plaket smeared "<<plaket(conf.array)<<endl;
	string path;
	if(wilson_enabled){
		for(int j = 0;j < 3;j++){
			path = string(wilson_path) + "T=" + to_string(T+j*4) + "_R=" + to_string(R+j*4) + "_" + string(conf_num);
			wilson_res[j].write(path.c_str());
		}
	}
	/*if(flux_enabled){
		for(int j = 0;j < 3;j++){
			path = string(flux_path) + "T=" + to_string(T+j*4) + "_R=" + to_string(R+j*4) + "_" + string(conf_num);
			flux_res[j].write(path.c_str());
		}
	}*/

	stream_flux.close();
}
