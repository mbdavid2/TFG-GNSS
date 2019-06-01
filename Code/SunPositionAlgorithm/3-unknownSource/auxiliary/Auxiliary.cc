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

void Auxiliary::printExecutionTime(clockTime start_time, clockTime end_time) {
    std::chrono::duration<double> elapsed_seconds = end_time - start_time;
    if (latex) cout << " & " << elapsed_seconds.count() << " \\\\" << endl << "\\hline" << endl;
    else cout << " " << elapsed_seconds.count() << endl;
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

void Auxiliary::printErrorResults(double ra, double dec, possibleSunInfo correctSunLocation) {
	double correctRa, correctDec, estimatedRa, estimatedDec;
    string dataName = "salu2";

    correctRa = toRadians(correctSunLocation.ra);
    correctDec = toRadians(correctSunLocation.dec);
	estimatedRa = toRadians(ra);
    estimatedDec = toRadians(dec);

	double cosineChi = sin(estimatedDec)*sin(correctDec) + cos(estimatedDec)*cos(correctDec)*cos(estimatedRa - correctRa);
	double errorDegrees = toDegrees(acos(cosineChi));
	if (latex) cout << dataName << " & " << abs(correctRa-ra) << " & " << abs(correctDec-dec) << " & ";
    else cout << "Ra: " << ra << " Dec: " <<  dec << " | " << errorDegrees;
	 
	// cout << "[Results]" << endl;
	// cout << "   -> Largest correlation coefficient: " << bestSun.coefficient << " || Error: [" + to_string(abs(correctRa-bestSun.ra)) + ", " + to_string(abs(correctDec-bestSun.dec)) + "]" << endl;
	// cout << "   -> Estimated Sun's location: " << bestSun.location << endl;
	// cout << " " << bestSun.ra << " " << bestSun.dec << " " << abs(correctRa-bestSun.ra) << " " << abs(correctDec-bestSun.dec) << " " << bestSun.coefficient << endl;
}