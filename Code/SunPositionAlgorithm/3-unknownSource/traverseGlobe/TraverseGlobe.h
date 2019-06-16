#ifndef TRAVERSEGLOBE_H
#define TRAVERSEGLOBE_H
#include <iostream>
#include <vector>
#include <queue>
#include "../auxiliary/Auxiliary.h"

using namespace std;

class TraverseGlobe {

	private:
		void decreasingSTEP(int numRows);

		possibleSunInfo considerPossibleSuns(double step, searchRange range, ofstream& plotData, int numRows);

		searchRange setRange(possibleSunInfo sun, bool defaultRange, double step, int rangeSize);

	public:

		priority_queue<possibleSunInfo> bestSuns;
		
		TraverseGlobe();

		void estimateSourcePosition(int numRows);

		void printCorrelationResults(possibleSunInfo bestSun, string fileName);

		priority_queue<possibleSunInfo> getPriorityQueueBestSuns();

		void printAllPossibleSunsOrdered();

		void debugSingle();

		void deletePQ();
};

#endif





