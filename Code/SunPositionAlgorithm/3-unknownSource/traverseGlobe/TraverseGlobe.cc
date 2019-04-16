#include "TraverseGlobe.h"
#include <iostream>
#include <vector>
#include <chrono>

using namespace std;
using namespace std::chrono;

//Structs and typedefs
struct possibleSunInfo {
	double coefficient;
	double ra;
	double dec;
	string location;
};

struct searchRange {
	double lowerRa;
	double upperRa;
	double lowerDec;
	double upperDec;
};

typedef high_resolution_clock::time_point clockTime;

double sumy;
double sumy2;

//External Fortran functions
extern "C" double mainfortran_(double* ra, double* dec, double* sumy, double* sumy2, int* writeData);

//Global variables
clockTime startTime;

int writeData = 0;

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
	double correctRa = 212.338;
	double correctDec = -13.060;
	cout << endl << "[Results]" << endl;
	cout << "   -> Largest correlation coefficient: " << bestSun.coefficient << endl;
	cout << "   -> Estimated Sun's location: " << bestSun.location << endl;
	cout << "   -> Error: [" + to_string(abs(correctRa-bestSun.ra)) + ", " + to_string(abs(correctDec-bestSun.dec)) + "]" << endl;
}

void printCorrelationParameters(double step, searchRange range){
	cout << endl << "[C++ -> Fortran: Computing Person coefficients]" << endl; 
	cout << "[Parameters]" << endl; 
	cout << "   -> Angle step precision = " + to_string(step) << endl;
	cout << "   -> Right ascension range = [" + to_string(range.lowerRa) + ", " + to_string(range.upperRa) + "]" << endl;
	cout << "   -> Declination range = [" + to_string(range.lowerDec) + ", " + to_string(range.upperDec) + "]" << endl;
}

possibleSunInfo considerPossibleSuns(double step, searchRange range) {
	printCorrelationParameters(step, range);
	double pearsonCoefficient;
	int i = 0;
	possibleSunInfo bestSun;
	bestSun.coefficient = -23;
	bestSun.location = "salu2";
	for (double dec = range.lowerDec; dec <= range.upperDec; dec += step) {
		if (dec != -90 and dec != 90) {
			for (double ra = range.lowerRa; ra <= range.upperRa; ra += step) {
				pearsonCoefficient = mainfortran_(&ra, &dec, &sumy, &sumy2, &writeData);
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
			double ra = 0;
			pearsonCoefficient = mainfortran_(&ra, &dec, &sumy, &sumy2, &writeData);
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

searchRange initRange(possibleSunInfo sun, bool defaultRange, double step) {
	searchRange range;
	if (defaultRange) {
		range.lowerRa = 0;
		range.upperRa = 360;
		range.lowerDec = -180;
		range.upperDec = 180;
	}
	else {
		//TODO: esto deberia haber una mejor logica detras, quizas intentar que siempre haya el mismo numero de soles estudiados???
		// double raRange = step;
		// double decRange = step;
		double raRange = step*2;
		double decRange = step*2;
		// Esto es correcto lo de dar la vuelta??? (el else de las ternarias)
		range.lowerRa = sun.ra - raRange >= 0 ? sun.ra - raRange : 360 - raRange;
		range.upperRa = sun.ra + raRange <= 360 ? sun.ra + raRange : 0 + raRange;
		range.lowerDec = sun.dec - decRange >= -180 ? sun.dec - decRange : 180 - decRange;
		range.upperDec = sun.dec + decRange <= 180 ? sun.dec + decRange : 0 + decRange;
	}
	return range;
}

void TraverseGlobe::decreasingSTEP() {
	possibleSunInfo bestSun;
	searchRange range = initRange(bestSun, true, 100);
	for (double step = 120; step >= 0.05; step /= 2) {
		chronoStart();
		bestSun = considerPossibleSuns(step, range);
		printCorrelationResults(bestSun);
		chronoEnd();
		range = initRange(bestSun, false, step);
	}
}

void TraverseGlobe::decreasingSTEPHardcoded() {
	vector<double> steps = {100,60,30,10,5,2,1,0.5};
	double step;
	possibleSunInfo bestSun;
	searchRange range = initRange(bestSun, true, 100);
	for (unsigned int i = 0; i < steps.size(); ++i) {
		step = steps[i];
		chronoStart();
		bestSun = considerPossibleSuns(step, range);
		printCorrelationResults(bestSun);
		chronoEnd();
		range = initRange(bestSun, false, step);
	}
}

void TraverseGlobe::initialMeasures() {
	cout << "salu2" << endl;
}

void printRealSun() {
	double ra = 212.338;
	double dec = -13.060;
	double pearsonCoefficient = mainfortran_(&ra, &dec, &sumy, &sumy2, &writeData);
	possibleSunInfo bestSun;
	bestSun.coefficient = pearsonCoefficient;
	bestSun.ra = ra;
	bestSun.dec = dec;
	bestSun.location = "[ra=" + to_string(ra) + ", dec=" + to_string(dec) + "]";
	cout << endl << "### Real Sun's location [ra=212.338, dec=-13.060] ###" << endl;
	printCorrelationResults(bestSun);
}

void TraverseGlobe::test(float epoch, double sumyFortran, double sumy2Fortran) {
	sumy2 = sumy2Fortran;
	sumy = sumyFortran;
	decreasingSTEP();
	// printRealSun();
}