#include <iostream>
#include <fstream>
#include <queue>
#include "spikeFinder/SpikeFinder.h"
#include "traverseGlobe/TraverseGlobe.h"
#include "fileManager/FileManager.h"
#include "resultsDebugger/ResultsDebugger.h"
#include "hillClimbing/HillClimbing.h"
#include "simulatedAnnealing/SimulatedAnnealing.h"
#include "auxiliary/Auxiliary.h"
#include "fortranController/FortranController.h"

using namespace std;

const string FILTER_AWK_SCRIPT = "filterDataTi.awk";
const string FILTER_TIME_AWK_SCRIPT = "filterDataByTime.awk";

//Global variables
int iterationsLeastSquares;
double estimatedRa;
double estimatedDec;
//= "ti.2003.301.10h30m-11h30m.gz";
// const string INPUT_DATA_FILE = "ti.2006.340.67190s-68500s.flare.gz";

void decreaseRangeMethod() {
	// Execute main algorithm
	TraverseGlobe traverseGlobe;
	traverseGlobe.estimateSourcePosition();
	possibleSunInfo best = traverseGlobe.getPriorityQueueBestSuns().top();
	estimatedRa = best.ra;
	estimatedDec = best.dec;
}

void multipleEpochsTest(SpikeFinder spikeFinder, priority_queue<candidate> candidates, FileManager fileManager, int n) {
	int i = 0;
	while (!candidates.empty() && ++i <= n) {
		spikeFinder.printInfoCandidate(candidates.top());
		cout << candidates.top().epoch;
		fileManager.filterTiFileByTime(candidates.top().epoch);
		decreaseRangeMethod();
		candidates.pop();
	}
}

void leastSquaresMethod(int numRows, int iterationsLeastSquares) {
	FortranController fc;
	string fileNameString = "filteredByTime.out";
	//Discarding outliers by using the Sun's location? (before filtering the Sun hemisphere)
	// fc.discardOutliersLinearFit(raSun, decSun);
	fc.leastSquares(fileNameString.c_str(), numRows, iterationsLeastSquares, &estimatedRa, &estimatedDec);	
}

void hillClimbingMethod() {
	HillClimbing hillClimbing;
	hillClimbing.estimateSourcePosition();
}

void simulatedAnnealingMethod() {
	SimulatedAnnealing simulatedAnnealing;
	simulatedAnnealing.estimateSourcePositionSA();
}

void iterateOverMultipleEpochs(string inputDataFile) {
	FileManager fileManager;
	fileManager.setInputFile(inputDataFile);
	fileManager.setAWKScripts(FILTER_AWK_SCRIPT, FILTER_TIME_AWK_SCRIPT);
	fileManager.filterTiFileByBasicData();

	SpikeFinder spikeFinder;
	spikeFinder.computeInfoBestCandidate(fileManager.getFilteredFile(), 1);
	priority_queue<candidate> bestPQ = spikeFinder.getPQBestCandidates();
	int numRows;

	int n = 2;
	int iterationsLeastSquares = 10;
	while (!bestPQ.empty() and n--) {
		fileManager.filterTiFileByBasicData();
		cout << "Epoch: " << bestPQ.top().epoch << endl;
		numRows = fileManager.filterTiFileByTime(bestPQ.top().epoch);
		leastSquaresMethod(numRows, iterationsLeastSquares);
		bestPQ.pop();
	}
}

/**
- Finds the best epoch
- Filters the time from the data file
- Uses the specified method
- Outputs the results
**/
void mainAlgorithm(string methodId, string inputDataFile) {
	// cout << "-- " << inputDataFile << "--" << endl;

	FileManager fileManager;

	// First filter
	fileManager.setInputFile(inputDataFile);
	fileManager.setAWKScripts(FILTER_AWK_SCRIPT, FILTER_TIME_AWK_SCRIPT);
	fileManager.filterTiFileByBasicData();

	// Find spike
	SpikeFinder spikeFinder;
	candidate bestCandidate = spikeFinder.computeInfoBestCandidate(fileManager.getFilteredFile(), 1);
	// cout << "[Best epoch: " << bestCandidate.epoch << "]" << endl;

	// Filter by time
	int numRows = fileManager.filterTiFileByTime(bestCandidate.epoch);

	Auxiliary aux;
	aux.chronoStart();
	// Simulated Annealing
	if (methodId == "sa") {
		cout << "[Simulated Annealing method]" << endl;
		simulatedAnnealingMethod();
	}
	else if (methodId == "me") {
		cout << "[Least Squares (multiple epochs)]" << endl;
		iterateOverMultipleEpochs(inputDataFile);
		return;
	}
	else if (methodId == "dr") {
		// cout << "[Decrease range method]" << endl;
		decreaseRangeMethod();
	}
	else if (methodId == "hc") {
		cout << "[Hill Climbing method]" << endl;
		hillClimbingMethod();
	}
	else if (methodId == "ls") {
		// cout << "[Least Squares method]" << endl;
		leastSquaresMethod(numRows, iterationsLeastSquares);
	}
	else if (methodId == "lsiter") {
		//Ls with iterations
		for (int i = 0; i < 15; i++) {
			iterationsLeastSquares = i;
			cout << i << " ";
			mainAlgorithm("ls", inputDataFile);
		}
	}
	
	//Print the results
	if (methodId != "lsiter") {
		possibleSunInfo correctSunLocation = fileManager.getCorrectSunLocation();
		aux.printErrorResults(estimatedRa, estimatedDec, correctSunLocation);
		aux.chronoEnd();
	}
}

void methodPrompt() {
	cout << endl << "### Blind GNSS Search of Extraterrestrial EUV Sources Algorithm ###" << endl << endl;
	string methodId;
	cout << "Input method id (dr/ls/hc/sa/me/lsiter): ";
	cin >> methodId;
	
	string inputDataFile = "ti.2003.301.10h30m-11h30m.gz";
	// INPUT_DATA_FILE = "ti.2006.340.67190s-68500s.flare.gz";
	// INPUT_DATA_FILE = "ti.2016.078.07h32m-09h32m.LARGESIZE.flare.gz";
	mainAlgorithm(methodId, inputDataFile);
}

void resultsDebugLatex () {
	cout << "(iterations) errorRa errorDec errorAbsoluto Total time" << endl;
	//Aqui llamar a main algorithm con los methods que yo quiera sin usar el prompt
	string inputDataFile = "ti.2003.301.10h30m-11h30m.gz";
	mainAlgorithm("ls", inputDataFile);
	mainAlgorithm("dr", inputDataFile);
	inputDataFile = "ti.2003.301.10h30m-11h30m.gz";
	mainAlgorithm("ls", inputDataFile);
}

int main() {
	methodPrompt();
}
