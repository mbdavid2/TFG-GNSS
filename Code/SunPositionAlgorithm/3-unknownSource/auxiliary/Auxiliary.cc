#include <iostream>
#include <chrono>
#include "Auxiliary.h"

using namespace std;
using namespace std::chrono;

bool latex = false;

typedef high_resolution_clock::time_point clockTime;

bool operator<(possibleSunInfo a, possibleSunInfo b) { 
	return a.coefficient < b.coefficient ? true : false; 
}

void Auxiliary::printExecutionTime(clockTime start_time, clockTime end_time) {
    // auto execution_time_ns = duration_cast<nanoseconds>(end_time - start_time).count();
    // auto execution_time_ms = duration_cast<microseconds>(end_time - start_time).count();
    // auto execution_time_sec = duration_cast<seconds>(end_time - start_time).count();
    // auto execution_time_min = duration_cast<minutes>(end_time - start_time).count();
    // // auto execution_time_hour = duration_cast<hours>(end_time - start_time).count();

    // cout << endl << "Execution Time: ";
    // // if(execution_time_hour > 0)
    // // cout << "" << execution_time_hour << " Hours, ";
    // if(execution_time_min > 0) {
    // 	cout << "" << execution_time_min % 60 << "m ";
    // }
    // if(execution_time_sec > 0) {
    // 	cout << "" << execution_time_sec % 60 << "s ";
    // }
    // if(execution_time_ms > 0) {
    // 	cout << "" << (execution_time_ms % long(1E+3)) << "ms ";
    // }
    // // if(execution_time_ns > 0)
    // // cout << "" << execution_time_ns % long(1E+6) << " NanoSeconds, ";
	// cout << endl;        


    //Alternative
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

void Auxiliary::printErrorResults(double ra, double dec, string fileName) {
	double correctRa;
	double correctDec;
    string dataName;
	if (fileName == "ti.2003.301.10h30m-11h30m.gz") {
        dataName = "X17.2";
		correctRa = 212.338;
		correctDec = -13.060;
	}
	else {
        dataName = "Other";
		correctRa = 253.182;
		correctDec = -22.542;
	}
    double absErrorDec = abs(correctDec-dec);
    double absErrorRa = abs(correctRa-ra);
    double absoluteError = absErrorDec + absErrorRa;
    // double relativeError = absoluteError/(abs(correctRa) + abs(correctDec));
	if (latex) cout << dataName << " & " << abs(correctRa-ra) << " & " << abs(correctDec-dec) << " & " << absoluteError;
    else cout << abs(correctRa-ra) << " " << abs(correctDec-dec) << " " << absoluteError;
	// double correctRa = 253.182;
	// double correctDec = -22.542;
	 
	// cout << "[Results]" << endl;
	// cout << "   -> Largest correlation coefficient: " << bestSun.coefficient << " || Error: [" + to_string(abs(correctRa-bestSun.ra)) + ", " + to_string(abs(correctDec-bestSun.dec)) + "]" << endl;
	// cout << "   -> Estimated Sun's location: " << bestSun.location << endl;
	// cout << " " << bestSun.ra << " " << bestSun.dec << " " << abs(correctRa-bestSun.ra) << " " << abs(correctDec-bestSun.dec) << " " << bestSun.coefficient << endl;
}