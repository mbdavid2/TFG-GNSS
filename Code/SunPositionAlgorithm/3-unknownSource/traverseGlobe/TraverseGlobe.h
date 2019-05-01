#ifndef TRAVERSEGLOBE_H
#define TRAVERSEGLOBE_H
#include <iostream>
#include <vector>
#include <queue>
#include "../auxiliary/Auxiliary.h"

using namespace std;

class TraverseGlobe {

	private:
		void decreasingSTEP();

		possibleSunInfo considerPossibleSuns(double step, searchRange range, ofstream& plotData);

		searchRange setRange(possibleSunInfo sun, bool defaultRange, double step, int rangeSize);

	public:
		void estimateSourcePosition(double epoch, double sumyFortran, double sumy2Fortran);

		void printCorrelationResults(possibleSunInfo bestSun);

		priority_queue<possibleSunInfo> getPriorityQueueBestSuns();

		void printAllPossibleSunsOrdered();
};

#endif





