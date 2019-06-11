#include <iostream>
#include <chrono>
#include "Auxiliary.h"
#include <cmath> 

using namespace std;
using namespace std::chrono;

bool latex = false;

typedef high_resolution_clock::time_point clockTime;

bool operator<(possibleSunInfo a, possibleSunInfo b) { 
	return a.coefficient < b.coefficient ? true : false; 
}

Auxiliary::Auxiliary() {
	totalErrorMethod = 0;
	totalTimeMethod = 0;
}

void Auxiliary::chronoStart() {
	startTime = high_resolution_clock::now();
}

void Auxiliary::chronoEnd() {
	clockTime now = high_resolution_clock::now();
	printExecutionTime (startTime, now);
}

double Auxiliary::toDegrees(double radians) {
	return radians*180/M_PI;
}

double Auxiliary::toRadians(double degrees) {
	return degrees*M_PI/180;
}

void Auxiliary::resetTotalsMethod() {
	cout << "Total & " << totalErrorMethod << " & " << totalTimeMethod << endl;
	totalTimeMethod = 0;
	totalErrorMethod = 0;
}

void Auxiliary::printExecutionTime(clockTime start_time, clockTime end_time) {
    std::chrono::duration<double> elapsed_seconds = end_time - start_time;
    if (latex) cout << " & " << elapsed_seconds.count() << " \\\\" << endl << "\\hline" << endl;
    else cout << " " << elapsed_seconds.count() << endl;

	// Update total error of the method
	totalTimeMethod += elapsed_seconds.count();
}

void Auxiliary::printErrorResults(double ra, double dec, possibleSunInfo correctSunLocation, double totalEstimationErrorLeastSquares) {
	double correctRa, correctDec, estimatedRa, estimatedDec;
    string dataName = "salu2";

    correctRa = toRadians(correctSunLocation.ra);
    correctDec = toRadians(correctSunLocation.dec);
	correctRa = 217.4;
	correctDec = -69.5;
	estimatedRa = toRadians(ra);
    estimatedDec = toRadians(dec);

	double cosineChi = sin(estimatedDec)*sin(correctDec) + cos(estimatedDec)*cos(correctDec)*cos(estimatedRa - correctRa);
	double errorDegrees = toDegrees(acos(cosineChi));
	if (latex) cout << " & " << errorDegrees;
    else cout << " Ra: " << ra << " Dec: " <<  dec << " | Error:" << errorDegrees;
	// else cout << " " << errorDegrees;
	// if (totalEstimationErrorLeastSquares != -1) cout << " & " << totalEstimationErrorLeastSquares;
	// Update total error of the method
	totalErrorMethod += errorDegrees;
	 
	// cout << "[Results]" << endl;
	// cout << "   -> Largest correlation coefficient: " << bestSun.coefficient << " || Error: [" + to_string(abs(correctRa-bestSun.ra)) + ", " + to_string(abs(correctDec-bestSun.dec)) + "]" << endl;
	// cout << "   -> Estimated Sun's location: " << bestSun.location << endl;
	// cout << " " << bestSun.ra << " " << bestSun.dec << " " << abs(correctRa-bestSun.ra) << " " << abs(correctDec-bestSun.dec) << " " << bestSun.coefficient << endl;
}