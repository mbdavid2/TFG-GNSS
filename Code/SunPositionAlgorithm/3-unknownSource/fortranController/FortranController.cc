#include <iostream>
#include <queue>
#include "FortranController.h"
#include "../auxiliary/Auxiliary.h"
#include "../fileManager/FileManager.h"

// computeCorrelationFortran //

extern "C" double computecorrelationfortran_(double* ra, double* dec);

extern "C" double computecosinesofcurrentsourcefortran_(double* ra, double* dec);

extern "C" double computecorrelationbasicfortran_(double* ra, double* dec);

void FortranController::discardOutliersLinearFit(double* ra, double* dec) {
	FileManager fileManager;
	int sigma = 1;
	int iterations = 3;
	computecosinesofcurrentsourcefortran_(ra, dec);
	fileManager.discardOutliersLinearFitFortran(sigma, iterations);	
}

double FortranController::computeCorrelationWithLinearFit(double* ra, double* dec) {
	consideredLocationsCounter++;
	discardOutliersLinearFit(ra, dec);
	return computecorrelationfortran_(ra, dec);
}

// Original
// double FortranController::computeCorrelation(double* ra, double* dec) {
// 	consideredLocationsCounter++;
// 	return computecorrelationbasicfortran_(ra, dec);
// }

double FortranController::computeCorrelation(double* ra, double* dec) {
	return computeCorrelationWithLinearFit(ra, dec);
}

void FortranController::printNumberOfConsideredLocations() {
	cout << endl << consideredLocationsCounter << " locations considered" << endl;
}

void FortranController::resetConsideredLocations() {
	consideredLocationsCounter = 0;
}

// leastSquaresFortran //

extern "C" double leastsquaresfortran_(const char* inputFileName, int* numRows, int* iterations, double* solutionRa, double* solutionDec);

double FortranController::leastSquares(const char* inputFileName, int numRows, int iterations, double* solutionRa, double* solutionDec) {
	numRows--; //TODO: mmmm
	return leastsquaresfortran_(inputFileName, &numRows, &iterations, solutionRa, solutionDec);
}