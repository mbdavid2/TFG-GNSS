#include <iostream>
#include <vector>
#include <queue>

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

class TraverseGlobe {

	private:
		void decreasingSTEP();

		possibleSunInfo considerPossibleSuns(double step, searchRange range);

		searchRange setRange(possibleSunInfo sun, bool defaultRange, double step, int rangeSize);

	public:
		void estimateSourcePosition(float epoch, double sumyFortran, double sumy2Fortran);

		void printCorrelationResults(possibleSunInfo bestSun);

		priority_queue<possibleSunInfo> getPriorityQueueBestSuns();

		void printAllPossibleSunsOrdered();
};






