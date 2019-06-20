#include <iostream>
#include <queue>
#include "FortranController.h"
#include "../auxiliary/Auxiliary.h"
#include "../fileManager/FileManager.h"

FortranController::FortranController() {
	consideredLocationsCounter = 0;
}

// computeCorrelationFortran //

extern "C" double computecorrelationfortran_(double* ra, double* dec, int* numRows);

extern "C" double computecosinesofcurrentsourcefortran_(double* ra, double* dec);

extern "C" double computecorrelationbasicfortran_(double* ra, double* dec);

void FortranController::discardOutliersLinearFit(double* ra, double* dec) {
	FileManager fileManager;
	int sigma = 3;
	int iterations = 4;
	computecosinesofcurrentsourcefortran_(ra, dec);
	// cout << "discard antes" << endl;
	fileManager.discardOutliersLinearFitFortran(sigma, iterations);	
	// cout << "discard hecho" << endl;
}

double FortranController::computeCorrelationWithLinearFit(double* ra, double* dec, int* numRows) {
	consideredLocationsCounter++;
	discardOutliersLinearFit(ra, dec);
	return computecorrelationfortran_(ra, dec, numRows);
}

double FortranController::computeCorrelation(double* ra, double* dec, int* numRows, bool discardOutliers) {
	consideredLocationsCounter++;
	// cout << "Estamos en el controller " << consideredLocationsCounter++ << endl;
	if (discardOutliers) {
		return computeCorrelationWithLinearFit(ra, dec, numRows);
	}
	else {
		return computecorrelationbasicfortran_(ra, dec);
	}
}


// double FortranController::computeCorrelation(double* ra, double* dec, int* numRows) {
// 	// cout << "Estamos en el controller " << consideredLocationsCounter++ << endl;
// 	return computeCorrelationWithLinearFit(ra, dec, numRows);
// }
 
void FortranController::printNumberOfConsideredLocations() {
	cout << endl << consideredLocationsCounter << " locations considered" << endl;
}

void FortranController::resetConsideredLocations() {
	consideredLocationsCounter = 0;
}

// leastSquaresFortran //

extern "C" double leastsquaresfortran_(const char* inputFileName, int* numRows, int* iterations, double* solutionRa, double* solutionDec, double* totalEstimationError);

extern "C" double leastsquaresfortranda_(const char* inputFileName, int* numRows, int* iterations, double* solutionRa, double* solutionDec, double* totalEstimationError);

double FortranController::leastSquares(const char* inputFileName, int numRows, int iterations, double* solutionRa, double* solutionDec, double* totalEstimationError) {
	int version = 0;
	if (version == 0) {
		numRows--;
		return leastsquaresfortran_(inputFileName, &numRows, &iterations, solutionRa, solutionDec, totalEstimationError);
	}
	else return leastsquaresfortranda_(inputFileName, &numRows, &iterations, solutionRa, solutionDec, totalEstimationError);
}

double FortranController::leastSquaresLinearFit(const char* inputFileName, int numRows, int iterations, double* solutionRa, double* solutionDec, double* totalEstimationError) {
	numRows--;
	leastsquaresfortran_(inputFileName, &numRows, &iterations, solutionRa, solutionDec, totalEstimationError);
	// cout << "Ra: " << (*solutionRa) << "Dec: " << (*solutionDec) << endl;
	string fileNameString = "cosineDataFitted.out";
	discardOutliersLinearFit(solutionRa, solutionDec);
	return leastsquaresfortran_(fileNameString.c_str(), &numRows, &iterations, solutionRa, solutionDec, totalEstimationError);
}