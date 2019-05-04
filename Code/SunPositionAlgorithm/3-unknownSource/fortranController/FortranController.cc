#include <iostream>
#include <queue>
#include "FortranController.h"
#include "../auxiliary/Auxiliary.h"

// computeCorrelationFortran //

extern "C" double computecorrelationfortran_(double* ra, double* dec);

double FortranController::computeCorrelation(double* ra, double* dec) {
	consideredLocationsCounter++;
	return computecorrelationfortran_(ra, dec);
}

void FortranController::printNumberOfConsideredLocations() {
	cout << endl << consideredLocationsCounter << " locations considered" << endl;
}

void FortranController::resetConsideredLocations() {
	consideredLocationsCounter = 0;
}

// leastSquaresFortran //

extern "C" double leastsquaresfortran_(const char* inputFileName, int* numRows);

double FortranController::leastSquares(const char* inputFileName, int numRows) {
	numRows--; //TODO: mmmm
	return leastsquaresfortran_(inputFileName, &numRows);
}