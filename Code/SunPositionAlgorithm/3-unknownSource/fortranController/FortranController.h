#ifndef FORTRANCONTROLLER_H
#define FORTRANCONTROLLER_H
#include <queue>
#include "../auxiliary/Auxiliary.h"

using namespace std;

class FortranController {

	private:
		int consideredLocationsCounter;
		
	public:
        void hillClimbing();

        double computeCorrelation(double* ra, double* dec);

        double leastSquares(const char* inputFileName);

        // Debug
        void printNumberOfConsideredLocations();
		void resetConsideredLocations();
};

#endif