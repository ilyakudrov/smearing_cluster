#include "result.h"
#include <iostream>
#include <sstream>
#include <sys/stat.h>

using namespace std;

int x_size;
int y_size;
int z_size;
int t_size;

int main(int argc, char* argv[]) {
	string path_wilson = argv[1];
	string conf_num;

	int steps = 152;
	result res(steps);
	vector<result> wilson(steps);

	int q1, q2, q3, q4;

	for(int i = 1;i <= 520;i++){
		q1 = i/1000;
                q2 = (i - q1 * 1000)/100;
                q3 = (i - q1 * 1000 - q2 * 100)/10;
                q4 = (i - q1 * 1000 - q2 * 100 - q3 * 10);
		conf_num = static_cast<ostringstream*>( &(ostringstream() << q1 << q2 << q3 << q4) )->str();
		struct stat buffer;
		if(stat((path_wilson + conf_num).c_str(), &buffer) == 0) {
			res.read((path_wilson + conf_num).c_str(), steps);
			for(int i = 0;i < steps;i++){
				wilson[i].array.push_back(res.array[i]);
			}
		}
	}
	ofstream output;
	string path_output = argv[2];
	output.open(path_output);
	double aver[2];
	for(int i = 0;i < steps;i++){
		wilson[i].average(aver);
		output<<i<<" "<<aver[0]<<" "<<aver[1]<<endl;
	}
	output.close();
}
