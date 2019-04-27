#ifndef AUXILIARY_H
#define AUXILIARY_H
#include <iostream>

using namespace std;

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

#endif