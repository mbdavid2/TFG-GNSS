#include "TraverseGlobe.h"
#include <iostream>
#include <vector>
#include <chrono>

using namespace std;
using namespace std::chrono;

//Structs and typedefs
struct possibleSunInfo {
	double coefficient;
	string location;
};

typedef high_resolution_clock::time_point clockTime;

//External Fortran functions
extern "C" double mainfortran_(int* ra, int* dec, int* writeData);

//Global variables
clockTime startTime;

int writeData = 0;

///////////////////

void printExecutionTime(clockTime start_time, clockTime end_time) {
    // auto execution_time_ns = duration_cast<nanoseconds>(end_time - start_time).count();
    auto execution_time_ms = duration_cast<microseconds>(end_time - start_time).count();
    auto execution_time_sec = duration_cast<seconds>(end_time - start_time).count();
    auto execution_time_min = duration_cast<minutes>(end_time - start_time).count();
    // auto execution_time_hour = duration_cast<hours>(end_time - start_time).count();

    cout << "   -> Execution Time: ";
    // if(execution_time_hour > 0)
    // cout << "" << execution_time_hour << " Hours, ";
    if(execution_time_min > 0)
    	cout << "" << execution_time_min % 60 << "m ";
    if(execution_time_sec > 0)
    	cout << "" << execution_time_sec % 60 << "s ";
    if(execution_time_ms > 0)
    	cout << "" << execution_time_ms % long(1E+3) << "ms ";
    // if(execution_time_ns > 0)
    // cout << "" << execution_time_ns % long(1E+6) << " NanoSeconds, ";
	cout << endl;
}

void chronoStart() {
	startTime = high_resolution_clock::now();
}

void chronoEnd() {
	clockTime now = high_resolution_clock::now();
	printExecutionTime (startTime, now);
	// auto duration = duration_cast<microseconds>(now - startTime).count();
    // cout << duration;
}

void considerPossibleSuns(int step) {
	cout << endl << "[C++ -> Fortran: Computing Person coefficients | Possible Suns with step=" + to_string(step) + "]" << endl; // for possible Suns | Epoch = " + to_string(epoch) + "]" << endl;
	double pearsonCoefficient;
	int i = 0;
	possibleSunInfo bestSun;
	bestSun.coefficient = -23;
	bestSun.location = "salu2";
	for (int dec = -90; dec <= 90; dec += step) {
		if (dec != -90 and dec != 90) {
			for (int ra = 0; ra <= 360; ra += step) {
				pearsonCoefficient = mainfortran_(&ra, &dec, &writeData);
				cout << "\r" << "[" << ++i << " possible Suns considered]";
				if (pearsonCoefficient > bestSun.coefficient) {
					bestSun.coefficient = pearsonCoefficient;
					bestSun.location = "[ra=" + to_string(ra) + ", dec=" + to_string(dec) + "]";
				}
				// cout << "Generated file for: ra=" << ra << " dec=" << dec << " Pearson coefficient rxy = " << pearsonCoefficient << endl;
			}
		}
		else {
			//Do only once
			int ra = 0;
			pearsonCoefficient = mainfortran_(&ra, &dec, &writeData);
			cout << "\r" << "[" << ++i << " possible Suns considered]";
			if (pearsonCoefficient > bestSun.coefficient) {
				bestSun.coefficient = pearsonCoefficient;
				bestSun.location = "[ra=" + to_string(ra) + ", dec=" + to_string(dec) + "]";
			}
			// cout << "Generated file for: ra=" << ra << " dec=" << dec << " Pearson coefficient rxy = " << pearsonCoefficient << endl;
		}
	}
	cout << endl << "[C++: Results]" << endl;
	cout << "   -> Largest correlation coefficient: " << bestSun.coefficient << endl;
	cout << "   -> Estimated Sun's location: " << bestSun.location << endl;
}

void TraverseGlobe::decreasingSTEP() {
	vector<int> steps = {100,60,30,10,5,2,1};
	int step;
	for (unsigned int i = 0; i < steps.size(); ++i) {
		step = steps[i];
		chronoStart();
		considerPossibleSuns(step);
		chronoEnd();
	}
}

void TraverseGlobe::initialMeasures() {
	cout << "salu2" << endl;
}


void TraverseGlobe::test(float epoch) {
	decreasingSTEP();
}