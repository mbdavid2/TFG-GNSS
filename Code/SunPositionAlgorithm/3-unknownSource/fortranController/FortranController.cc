#include <iostream>
#include "FortranController.h"

// computeCorrelationFortran //

extern "C" double computecorrelationfortran_(double* ra, double* dec, double* sumy, double* sumy2, int* writeData);

double FortranController::computeCorrelation(double* ra, double* dec, double* sumy, double* sumy2, int* writeData) {
	return computecorrelationfortran_(ra, dec, sumy, sumy2, writeData);
}

// leastSquaresFortran //

extern "C" double leastsquaresfortran_();

double FortranController::leastSquares() {
	return leastsquaresfortran_();
}

void FortranController::hillClimbing() {
    cout << "dsadas" << endl;
}