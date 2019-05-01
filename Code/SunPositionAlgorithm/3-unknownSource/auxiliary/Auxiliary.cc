#include <iostream>
#include <chrono>
#include "Auxiliary.h"

using namespace std;
using namespace std::chrono;

typedef high_resolution_clock::time_point clockTime;

bool operator<(possibleSunInfo a, possibleSunInfo b) { 
	return a.coefficient < b.coefficient ? true : false; 
}

void Auxiliary::printExecutionTime(clockTime start_time, clockTime end_time) {
    // auto execution_time_ns = duration_cast<nanoseconds>(end_time - start_time).count();
    auto execution_time_ms = duration_cast<microseconds>(end_time - start_time).count();
    auto execution_time_sec = duration_cast<seconds>(end_time - start_time).count();
    auto execution_time_min = duration_cast<minutes>(end_time - start_time).count();
    // auto execution_time_hour = duration_cast<hours>(end_time - start_time).count();

    cout << "Execution Time: ";
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

void Auxiliary::chronoStart() {
	startTime = high_resolution_clock::now();
}

void Auxiliary::chronoEnd() {
	clockTime now = high_resolution_clock::now();
	printExecutionTime (startTime, now);
}