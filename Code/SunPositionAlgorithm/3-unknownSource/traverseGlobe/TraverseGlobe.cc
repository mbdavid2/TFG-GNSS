#include <iostream>
#include <vector>
#include <queue>
#include <fstream>
#include "TraverseGlobe.h"
#include "../auxiliary/Auxiliary.h"
#include "../fortranController/FortranController.h"

using namespace std;

double sumy;
double sumy2;

const bool output = false; 

TraverseGlobe::TraverseGlobe() {

}

void TraverseGlobe::deletePQ() {
	bestSuns = priority_queue<possibleSunInfo> ();
}

void TraverseGlobe::printAllPossibleSunsOrdered() {
	cout << endl << "[List of all the studied candidates ordered by pearson correlation coefficient]" << endl;
	cout << "WARNING: Pops candidates!" << endl;
	int i = 0;
	while (!bestSuns.empty()) {
		cout << ++i << " -> " << bestSuns.top().coefficient << " " << bestSuns.top().location << endl;
		bestSuns.pop();
	}
}

void TraverseGlobe::printCorrelationResults(possibleSunInfo bestSun, string fileName) {
	double correctRa;
	double correctDec;
	if (fileName == "ti.2003.301.10h30m-11h30m.gz") {
		correctRa = 212.338;
		correctDec = -13.060;
	}
	else {
		correctRa = 253.182;
		correctDec = -22.542;
	}
	cout << abs(correctRa-bestSun.ra) << " " << abs(correctDec-bestSun.dec);
	// double correctRa = 253.182;
	// double correctDec = -22.542;
	 
	// cout << "[Results]" << endl;
	// cout << "   -> Largest correlation coefficient: " << bestSun.coefficient << " || Error: [" + to_string(abs(correctRa-bestSun.ra)) + ", " + to_string(abs(correctDec-bestSun.dec)) + "]" << endl;
	// cout << "   -> Estimated Sun's location: " << bestSun.location << endl;
	// cout << " " << bestSun.ra << " " << bestSun.dec << " " << abs(correctRa-bestSun.ra) << " " << abs(correctDec-bestSun.dec) << " " << bestSun.coefficient << endl;
}

// void printRealSun() {
// 	double ra = 212.338;
// 	double dec = -13.060;
// 	double pearsonCoefficient = mainfortran_(&ra, &dec, &sumy, &sumy2, &writeData);
// 	possibleSunInfo bestSun;
// 	bestSun.coefficient = pearsonCoefficient;
// 	bestSun.ra = ra;
// 	bestSun.dec = dec;
// 	bestSun.location = "[ra=" + to_string(ra) + ", dec=" + to_string(dec) + "]";
// 	cout << endl << "### Real Sun's location [ra=212.338, dec=-13.060] ###" << endl;
// 	printCorrelationResults(bestSun);
// }

void printCorrelationParameters(double step, searchRange range){
	cout << endl << "-----------------------------------------------" << endl << endl;
	cout << "[C++ -> Fortran: Computing Person coefficients]" << endl; 
	cout << "[Parameters]" << endl; 
	cout << "   -> Angle step precision = " + to_string(step) << endl;
	cout << "   -> RightAscension = [" + to_string(range.lowerRa) + ", " + to_string(range.upperRa) + " || Declination = [" + to_string(range.lowerDec) + ", " + to_string(range.upperDec) + "]" << endl;
}

void writeCoefficientToFile(double ra, double dec, double pearsonCoefficient, ofstream& plotData) {
	plotData << ra << " " << dec << " " << pearsonCoefficient << endl;
	
}

possibleSunInfo TraverseGlobe::considerPossibleSuns(double step, searchRange range, ofstream& plotData) {
	FortranController fc;

	if (output) printCorrelationParameters(step, range);
	double pearsonCoefficient;
	int i = 0;
	possibleSunInfo bestSun;
	bestSun.coefficient = -23;
	bestSun.location = "salu2";
	for (double dec = range.lowerDec; dec <= range.upperDec; dec += step) {
		if (dec != -90 and dec != 90) {
			for (double ra = range.lowerRa; ra <= range.upperRa; ra += step) {
				pearsonCoefficient = fc.computeCorrelation(&ra, &dec);
				if (output) cout << "\r" << "[Computing: " << ++i << " possible Suns considered]";
				if (pearsonCoefficient > bestSun.coefficient) {
					bestSun.coefficient = pearsonCoefficient;
					bestSun.ra = ra;
					bestSun.dec = dec;
					bestSun.location = "[ra=" + to_string(ra) + ", dec=" + to_string(dec) + "]";
				}
				writeCoefficientToFile(ra, dec, pearsonCoefficient, plotData);
				// cout << "Generated file for: ra=" << ra << " dec=" << dec << " Pearson coefficient rxy = " << pearsonCoefficient << endl;
			}
		}
		else {
			//Do only once
			double ra = 0;
			pearsonCoefficient = fc.computeCorrelation(&ra, &dec);
			if (output) cout << "\r" << "[Computing: " << ++i << " possible Suns considered]";
			if (pearsonCoefficient > bestSun.coefficient) {
				bestSun.coefficient = pearsonCoefficient;
				bestSun.ra = ra;
				bestSun.dec = dec;
				bestSun.location = "[ra=" + to_string(ra) + ", dec=" + to_string(dec) + "]";
			}
			writeCoefficientToFile(ra, dec, pearsonCoefficient, plotData);
			// cout << "Generated file for: ra=" << ra << " dec=" << dec << " Pearson coefficient rxy = " << pearsonCoefficient << endl;
		}
	}
	if (output) cout << endl;
	return bestSun;
}

searchRange TraverseGlobe::setRange(possibleSunInfo sun, bool defaultRange, double step, int rangeSize) {
	searchRange range;
	if (defaultRange) {
		range.lowerRa = 0;
		range.upperRa = 360;
		range.lowerDec = -90;
		range.upperDec = 90;
	}
	else {
		//TODO: esto deberia haber una mejor logica detras, quizas intentar que siempre haya el mismo numero de soles estudiados???
		double raRange = step*rangeSize;
		double decRange = step*rangeSize;

		// range.lowerRa = sun.ra - raRange >= 0 ? sun.ra - raRange : 360 - (sun.ra - raRange);
		// range.upperRa = sun.ra + raRange <= 360 ? sun.ra + raRange : (sun.ra + raRange) - 360;
		// range.lowerDec = sun.dec - decRange >= -90 ? sun.dec - decRange : 90 - (sun.dec - decRange);
		// range.upperDec = sun.dec + decRange <= 90 ? sun.dec + decRange : (sun.dec + decRange) - 90;

		range.lowerRa = sun.ra - raRange >= 0 ? sun.ra - raRange : 0;
		range.upperRa = sun.ra + raRange <= 360 ? sun.ra + raRange : 360;
		range.lowerDec = sun.dec - decRange >= -90 ? sun.dec - decRange : -90;
		range.upperDec = sun.dec + decRange <= 90 ? sun.dec + decRange : 90;
	}
	return range;
}

void TraverseGlobe::decreasingSTEP() {
	ofstream plotData;
	plotData.open("gnuplot.in", ios::trunc);
	int rangeSize = 3;
	int initialStep = 60;
	possibleSunInfo currentSun;
	searchRange range = setRange(currentSun, true, initialStep, rangeSize);
	for (double step = initialStep; step >= 0.5; step /= 2) {
		currentSun = considerPossibleSuns(step, range, plotData);
		bestSuns.push(currentSun);
		// if (output) printCorrelationResults(currentSun);
		range = setRange(currentSun, false, step, rangeSize);
	}
	plotData.close();
}

void TraverseGlobe::debugSingle() {
	FortranController fc;
	double ra = 212.338;
	double dec = -13.060;
	double pearsonCoefficient = fc.computeCorrelationWithLinearFit(&ra, &dec);
	possibleSunInfo bestSun;
	bestSun.coefficient = pearsonCoefficient;
	bestSun.ra = ra;
	bestSun.dec = dec;
	bestSun.location = "[ra=" + to_string(ra) + ", dec=" + to_string(dec) + "]";
	bestSuns.push(bestSun);
}

void TraverseGlobe::estimateSourcePosition(double epoch, double sumyFortran, double sumy2Fortran) {
	sumy2 = sumy2Fortran;
	sumy = sumyFortran;
	decreasingSTEP();
	// printRealSun();
}



priority_queue<possibleSunInfo> TraverseGlobe::getPriorityQueueBestSuns() {
	return bestSuns;
}