#ifndef AUXILIARY_H
#define AUXILIARY_H
#include <iostream>
#include <chrono>

using namespace std;
using namespace std::chrono;

struct possibleSunInfo {
	double coefficient;
	double ra;
	double dec;
	string location;
};

bool operator<(possibleSunInfo a, possibleSunInfo b);

struct searchRange {
	double lowerRa;
	double upperRa;
	double lowerDec;
	double upperDec;
};

typedef high_resolution_clock::time_point clockTime;

class Auxiliary {

	public:
		void printExecutionTime(clockTime start_time, clockTime end_time);

		void chronoStart();

		void chronoEnd();

	private: 
		clockTime startTime;
};

#endif