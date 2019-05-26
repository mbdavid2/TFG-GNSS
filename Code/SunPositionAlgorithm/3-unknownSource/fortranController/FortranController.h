#ifndef FORTRANCONTROLLER_H
#define FORTRANCONTROLLER_H
#include <queue>
#include "../auxiliary/Auxiliary.h"

using namespace std;

class FortranController {

	private:
		int consideredLocationsCounter;
		
	public:
        //Linear fitting: discard outliers
        void discardOutliersLinearFit(double* ra, double* dec);

        //Compute correlation
        double computeCorrelationWithLinearFit(double* ra, double* dec);
        double computeCorrelation(double* ra, double* dec);

        void printNumberOfConsideredLocations();

		void resetConsideredLocations();

		//Least Squares
        double leastSquares(const char* inputFileName, int numRows, int iterations, double* solutionRa, double* solutionDec);
};

#endif