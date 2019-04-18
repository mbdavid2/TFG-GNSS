#include "TraverseGlobe.h"
#include <iostream>
#include <vector>
#include <chrono>
#include <queue>

using namespace std;
using namespace std::chrono;

typedef high_resolution_clock::time_point clockTime;

bool operator<(possibleSunInfo a, possibleSunInfo b) { 
	return a.coefficient < b.coefficient ? true : false; 
}

priority_queue<possibleSunInfo> bestSuns;

double sumy;
double sumy2;

//External Fortran functions
extern "C" double mainfortran_(double* ra, double* dec, double* sumy, double* sumy2, int* writeData);

//Global variables
clockTime startTime;

int writeData = 0;

const bool output = true; 

void TraverseGlobe::printAllPossibleSunsOrdered() {
	cout << endl << "[List of all the studied candidates ordered by pearson correlation coefficient]" << endl;
	cout << "WARNING: Pops candidates!" << endl;
	int i = 0;
	while (!bestSuns.empty()) {
		cout << ++i << " -> " << bestSuns.top().coefficient << " " << bestSuns.top().location << endl;
		bestSuns.pop();
	}
}

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
	cout << "[Results]" << endl;
	cout << "   -> Largest correlation coefficient: " << bestSun.coefficient << endl;
	cout << "   -> Estimated Sun's location: " << bestSun.location << endl;
	cout << "   -> Error: [" + to_string(abs(correctRa-bestSun.ra)) + ", " + to_string(abs(correctDec-bestSun.dec)) + "]" << endl;
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

void printCorrelationParameters(double step, searchRange range){
	cout << endl << "[C++ -> Fortran: Computing Person coefficients]" << endl; 
	cout << "[Parameters]" << endl; 
	cout << "   -> Angle step precision = " + to_string(step) << endl;
	cout << "   -> Right ascension range = [" + to_string(range.lowerRa) + ", " + to_string(range.upperRa) + "]" << endl;
	cout << "   -> Declination range = [" + to_string(range.lowerDec) + ", " + to_string(range.upperDec) + "]" << endl;
}

possibleSunInfo TraverseGlobe::considerPossibleSuns(double step, searchRange range) {
	if (output) printCorrelationParameters(step, range);
	double pearsonCoefficient;
	int i = 0;
	possibleSunInfo bestSun;
	bestSun.coefficient = -23;
	bestSun.location = "salu2";
	for (double dec = range.lowerDec; dec <= range.upperDec; dec += step) {
		if (dec != -90 and dec != 90) {
			for (double ra = range.lowerRa; ra <= range.upperRa; ra += step) {
				pearsonCoefficient = mainfortran_(&ra, &dec, &sumy, &sumy2, &writeData);
				if (output) cout << "\r" << "[Computing: " << ++i << " possible Suns considered]";
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
			if (output) cout << "\r" << "[" << ++i << " possible Suns considered]";
			if (pearsonCoefficient > bestSun.coefficient) {
				bestSun.coefficient = pearsonCoefficient;
				bestSun.location = "[ra=" + to_string(ra) + ", dec=" + to_string(dec) + "]";
			}
			// cout << "Generated file for: ra=" << ra << " dec=" << dec << " Pearson coefficient rxy = " << pearsonCoefficient << endl;
		}
	}
	
	return bestSun;
}

searchRange TraverseGlobe::setRange(possibleSunInfo sun, bool defaultRange, double step, int rangeSize) {
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
		double raRange = step*rangeSize;
		double decRange = step*rangeSize;
		range.lowerRa = sun.ra - raRange >= 0 ? sun.ra - raRange : 360 - raRange;
		range.upperRa = sun.ra + raRange <= 360 ? sun.ra + raRange : raRange - 360;
		range.lowerDec = sun.dec - decRange >= -180 ? sun.dec - decRange : 180 - decRange;
		range.upperDec = sun.dec + decRange <= 180 ? sun.dec + decRange : decRange - 180;

		// range.lowerRa = range.lowerRa < 0 ? 0 : range.lowerRa;
		// range.upperRa = range.upperRa > 360 ? 360 : range.upperRa;
		// range.lowerDec = range.lowerDec < -180 ? -180 :range.upperDec;
		// range.upperDec = range.upperDec > 180 ? 180 : range.lowerDec;
	}
	return range;
}

void TraverseGlobe::decreasingSTEP() {
	int rangeSize = 4;
	int initialStep = 100;
	possibleSunInfo currentSun;
	searchRange range = setRange(currentSun, true, initialStep, rangeSize);
	for (double step = 120; step >= 0.5; step /= 2) {
		if (output) chronoStart();
		currentSun = considerPossibleSuns(step, range);
		bestSuns.push(currentSun);
		if (output) printCorrelationResults(currentSun);
		if (output) chronoEnd();
		//TODO: SHOULD ONLY USE NEW COORDINATES IF THERE'S AN IMPROVEMENT
		range = setRange(currentSun, false, step, rangeSize);
	}
	// printCorrelationResults(currentSun);
}

void TraverseGlobe::estimateSourcePosition(float epoch, double sumyFortran, double sumy2Fortran) {
	sumy2 = sumy2Fortran;
	sumy = sumyFortran;
	decreasingSTEP();
	// printRealSun();
}

priority_queue<possibleSunInfo> TraverseGlobe::getPriorityQueueBestSuns() {
	return bestSuns;
}