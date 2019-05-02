#include <iostream>
#include <queue>
#include "FortranController.h"
#include "../auxiliary/Auxiliary.h"

// computeCorrelationFortran //

extern "C" double computecorrelationfortran_(double* ra, double* dec);

double FortranController::computeCorrelation(double* ra, double* dec) {
	return computecorrelationfortran_(ra, dec);
}

// leastSquaresFortran //

extern "C" double leastsquaresfortran_();

double FortranController::leastSquares(priority_queue<infoIPP> bestIPPs) {
	return leastsquaresfortran_();
}

void FortranController::hillClimbing() {
    cout << "dsadas" << endl;
}