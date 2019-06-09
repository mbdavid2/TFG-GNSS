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

//Old large range
// const vector<string> fileNames = {
// 	"ti.2001.347.51800-52200",
// 	"ti.2002.196.70440-74040",
// 	"ti.2003.301.36000-41400", 
// 	// "ti.2003.308.71000-72100",
// 	// "ti.2005.020.24200-24400",
// 	// "ti.2005.258.29190-32790",
// 	// "ti.2011.210.42334-45934",
// 	// "ti.2012.066.4400-4700",
// 	// "ti.2012.130.50600-51000",
// 	// "ti.2012.297.11600-12000",
// };

const vector<string> fileNames = {
	// "ti.2001.347.gz",
	// "ti.2002.196.gz",
	"ti.2003.301.gz",
	// "ti.2003.308.gz",
	// "ti.2005.020.gz",
	// "ti.2005.258.gz", 
	// "ti.2011.210.gz",
	// "ti.2012.066.gz",
	// "ti.2012.130.gz",
	// "ti.2012.297.gz",
};

//Global variables
int iterationsLeastSquares;
double estimatedRa;
double estimatedDec;
double totalEstimationError;
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
	fc.leastSquares(fileNameString.c_str(), numRows, iterationsLeastSquares, &estimatedRa, &estimatedDec, &totalEstimationError);	
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
void mainAlgorithm(string methodId, string inputDataFile, Auxiliary* aux) {
	// cout << "-- " << inputDataFile << "--" << endl;

	FileManager fileManager;

	// First filter
	fileManager.setInputFile(inputDataFile);
	fileManager.setAWKScripts(FILTER_AWK_SCRIPT, FILTER_TIME_AWK_SCRIPT);
	fileManager.filterTiFileByBasicData();

	// Find spike
	SpikeFinder spikeFinder;
	candidate bestCandidate = spikeFinder.computeInfoBestCandidate(fileManager.getFilteredFile(), 1);
	// cout << "[Epoch: " << bestCandidate.epoch << "]" << endl;

	// Filter by time
	int numRows = fileManager.filterTiFileByTime(bestCandidate.epoch);

	
	(*aux).chronoStart();
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
			mainAlgorithm("ls", inputDataFile, aux);
		}
	}
	
	//Print the results
	if (methodId != "lsiter") {
		possibleSunInfo correctSunLocation = fileManager.getCorrectSunLocation();
		(*aux).printErrorResults(estimatedRa, estimatedDec, correctSunLocation, totalEstimationError);
		(*aux).chronoEnd();
	}
}

void resultsDebugLatex () {
	// cout << "(iterations) errorRa errorDec errorAbsoluto Total time" << endl;
	bool plotLatex = true;
	Auxiliary aux = Auxiliary();
	int i = 0;

	//Decrease range
	// if (plotLatex) cout << "-- Decreasing range method --" << endl;
	// for (string fileName : fileNames) {
	// 	if (!plotLatex) cout << ++i;
	// 	else  cout << fileName;
	// 	mainAlgorithm("dr", fileName, &aux);
	// }
	// (aux).resetTotalsMethod();
	// i = 0;

	//Least Squares
	if (plotLatex) cout << "-- Least Squares method --" << endl;
	
	for (string fileName : fileNames) {
		if (!plotLatex) cout << ++i;
		else  cout << fileName;
		mainAlgorithm("lsiter", fileName, &aux);
	}
	(aux).resetTotalsMethod();
}

void methodPrompt() {
	cout << endl << "### Blind GNSS Search of Extraterrestrial EUV Sources Algorithm ###" << endl << endl;
	string methodId;
	cout << "Input method id (dr/ls/hc/sa/me/lsiter): ";
	cin >> methodId;
	
	string inputDataFile = "ti.2003.301.36000-41400.gz";
	inputDataFile = "ti.2002.196.72230-72250.gz";
	// inputDataFile = "ti.2003.301.gz";
	// INPUT_DATA_FILE = "ti.2006.340.67190s-68500s.flare.gz";
	// INPUT_DATA_FILE = "ti.2016.078.07h32m-09h32m.LARGESIZE.flare.gz";
	Auxiliary aux;
	mainAlgorithm(methodId, inputDataFile, &aux);
}

int main() {
	// methodPrompt();
	iterationsLeastSquares = 1;
	totalEstimationError = -1; //Flag, -1 if decreasing range, LS will change the value
	resultsDebugLatex();
}
