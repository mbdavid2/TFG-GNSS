#ifndef AUXILIARY_H
#define AUXILIARY_H
#include <iostream>
#include <chrono>

using namespace std;
using namespace std::chrono;

struct infoIPP {
	double epoch;
	double vtec;
	double ra;
	double dec;
};

struct candidate { 
	double epoch; 
	double maxMeanVTEC;
	double maxIndividialVTEC;
	double bestRa;
	double bestDec;
};

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

		Auxiliary();
		
		void printExecutionTime(clockTime start_time, clockTime end_time);

		void chronoStart();

		void chronoEnd();

		void printErrorResults(double ra, double dec, possibleSunInfo correctSunLocation, double totalEstimationErrorLeastSquares);

		void resetTotalsMethod();

	private: 
		clockTime startTime;

		double totalTimeMethod;
		
		double totalErrorMethod;

		double toDegrees(double radians);
		
		double toRadians(double degrees);
};

#endif