#include "TraverseGlobe.h"
#include <iostream>
#include <vector>
#include <chrono>

using namespace std;
using namespace std::chrono;

//Structs and typedefs
struct possibleSunInfo {
	double coefficient;
	int ra;
	int dec;
	string location;
};

struct searchRange {
	int lowerRa;
	int upperRa;
	int lowerDec;
	int upperDec;
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
}

void printCorrelationResults(possibleSunInfo bestSun) {
	cout << endl << "[Results]" << endl;
	cout << "   -> Largest correlation coefficient: " << bestSun.coefficient << endl;
	cout << "   -> Estimated Sun's location: " << bestSun.location << endl;
}

void printCorrelationParameters(int step, searchRange range){
	cout << endl << "[C++ -> Fortran: Computing Person coefficients]" << endl; 
	cout << "[Parameters]" << endl; 
	cout << "   -> Possible Suns with step = " + to_string(step) << endl;
	cout << "   -> Right ascension range = [" + to_string(range.lowerRa) + ", " + to_string(range.upperRa) + "]" << endl;
	cout << "   -> Declination range = [" + to_string(range.lowerDec) + ", " + to_string(range.upperDec) + "]" << endl;
}

possibleSunInfo considerPossibleSuns(int step, searchRange range) {
	printCorrelationParameters(step, range);
	double pearsonCoefficient;
	int i = 0;
	possibleSunInfo bestSun;
	bestSun.coefficient = -23;
	bestSun.location = "salu2";
	for (int dec = range.lowerDec; dec <= range.upperDec; dec += step) {
		if (dec != -90 and dec != 90) {
			for (int ra = range.lowerRa; ra <= range.upperRa; ra += step) {
				pearsonCoefficient = mainfortran_(&ra, &dec, &writeData);
				cout << "\r" << "[Computing: " << ++i << " possible Suns considered]";
				if (pearsonCoefficient > bestSun.coefficient) {
					bestSun.coefficient = pearsonCoefficient;
					bestSun.ra = ra;
					bestSun.dec = dec;
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
	
	return bestSun;
}

searchRange initRange(possibleSunInfo sun, bool defaultRange) {
	searchRange range;
	if (defaultRange) {
		range.lowerRa = 0;
		range.upperRa = 360;
		range.lowerDec = -180;
		range.upperDec = 180;
	}
	else {
		int raRange = 10; // 5 y 5 da mal resultado, asi da bien
		int decRange = 10;
		range.lowerRa = sun.ra - raRange >= 0 ? sun.ra - raRange : 0;
		range.upperRa = sun.ra + raRange <= 360 ? sun.ra + raRange : 360;
		range.lowerDec = sun.dec - decRange >= -180 ? sun.dec - decRange : -180;
		range.upperDec = sun.dec + decRange <= 180 ? sun.dec + decRange : 180;
	}
	return range;
}

void TraverseGlobe::decreasingSTEP() {
	vector<int> steps = {100,60,30,10,5,2,1};
	int step;
	possibleSunInfo bestSun;
	searchRange range = initRange(bestSun, true);
	for (unsigned int i = 0; i < steps.size(); ++i) {
		step = steps[i];
		chronoStart();
		bestSun = considerPossibleSuns(step, range);
		printCorrelationResults(bestSun);
		chronoEnd();
		range = initRange(bestSun, false);
		
	}
}

void TraverseGlobe::initialMeasures() {
	cout << "salu2" << endl;
}

void TraverseGlobe::test(float epoch) {
	decreasingSTEP();
}