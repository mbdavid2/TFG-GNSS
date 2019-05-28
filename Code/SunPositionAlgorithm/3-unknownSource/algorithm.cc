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

string INPUT_DATA_FILE; //= "ti.2003.301.10h30m-11h30m.gz";
// const string INPUT_DATA_FILE = "ti.2006.340.67190s-68500s.flare.gz";

const string FILTER_AWK_SCRIPT = "filterDataTi.awk";
const string FILTER_TIME_AWK_SCRIPT = "filterDataByTime.awk";

int iterationsLeastSquares;

// spikeFinder findSpike(string dataFile) {
// 	cout << "[C++: Finding a spike in the VTEC distribution]" << endl;
// 	SpikeFinder spikeFinder;
// 	candidate bestCandidate = spikeFinder.computeInfoBestCandidate(dataFile, 1);
// 	spikeFinder.printInfoCandidate(bestCandidate);
// 	return return spikeFinder;leastSquares
// }

void decreaseRangeMethod(FileManager fileManager, double epoch) {
	// Filter by time
	fileManager.filterTiFileByTime(epoch);

	// Execute main algorithm
	TraverseGlobe traverseGlobe;
	traverseGlobe.estimateSourcePosition(epoch, 0, 0); //TODO: quitar estos ceros del sumfortran
	priority_queue<possibleSunInfo> bestSuns = traverseGlobe.getPriorityQueueBestSuns();

	possibleSunInfo best = bestSuns.top();

	// traverseGlobe.printCorrelationResults(best, INPUT_DATA_FILE);
	Auxiliary aux;
	aux.printErrorResults(best.ra, best.dec, INPUT_DATA_FILE);

}

void multipleEpochsTest(SpikeFinder spikeFinder, priority_queue<candidate> candidates, FileManager fileManager, int n) {
	int i = 0;
	while (!candidates.empty() && ++i <= n) {
		spikeFinder.printInfoCandidate(candidates.top());
		cout << candidates.top().epoch;
		decreaseRangeMethod(fileManager, candidates.top().epoch);
		candidates.pop();
	}
}

void leastSquaresMethod(int numRows, int iterationsLeastSquares) {
	FortranController fc;
	string fileNameString = "filteredByTime.out";
	//Discarding outliers by using the Sun's location? (before filtering the Sun hemisphere)
	// fc.discardOutliersLinearFit(raSun, decSun);
	double ra, dec;
	fc.leastSquares(fileNameString.c_str(), numRows, iterationsLeastSquares, &ra, &dec);
	Auxiliary aux;
	aux.printErrorResults(ra, dec, INPUT_DATA_FILE);
}

void hillClimbingMethod() {
	HillClimbing hillClimbing;
	hillClimbing.estimateSourcePosition();
}

void simulatedAnnealingMethod() {
	SimulatedAnnealing simulatedAnnealing;
	simulatedAnnealing.estimateSourcePositionSA();
}

void iterateOverMultipleEpochs() {
	FileManager fileManager;
	fileManager.setInputFile(INPUT_DATA_FILE);
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

void mainAlgorithm(string methodId) {
	FileManager fileManager;

	// First filter
	fileManager.setInputFile(INPUT_DATA_FILE);
	fileManager.setAWKScripts(FILTER_AWK_SCRIPT, FILTER_TIME_AWK_SCRIPT);
	fileManager.filterTiFileByBasicData();

	// Find spike
	SpikeFinder spikeFinder;
	candidate bestCandidate = spikeFinder.computeInfoBestCandidate(fileManager.getFilteredFile(), 1);
	// cout << "[Best epoch: " << bestCandidate.epoch << "]" << endl;

	// Filter by time
	int numRows = fileManager.filterTiFileByTime(bestCandidate.epoch);
	// fileManager.filterTiFileByTime(bestCandidate.epoch);

	// Simulated Annealing
	if (methodId == "sa") {
		cout << "[Simulated Annealing method]" << endl;
		simulatedAnnealingMethod();
	}

	// Multiple epochs LS
	if (methodId == "me") {
		cout << "[Least Squares (multiple epochs)]" << endl;
		iterateOverMultipleEpochs();
		return;
	}

	// Find location using the decreaseRange method
	if (methodId == "dr") {
		// cout << "[Decrease range method]" << endl;
		decreaseRangeMethod(fileManager, bestCandidate.epoch);
	}

	// Hill Climbing
	if (methodId == "hc") {
		cout << "[Hill Climbing method]" << endl;
		hillClimbingMethod();
	}

	//Least squares
	if (methodId == "ls") {
		// cout << "[Least Squares method]" << endl;

		leastSquaresMethod(numRows, iterationsLeastSquares); //TODO: como obtenemos el numero de lineas al hacer el filtrado??
	}

	// Test: multiple epochs
	// SpikeFinder spikeFinder;
	// // candidate bestCandidate = spikeFinder.computeInfoBestCandidate(fileManager.getFilteredFile(), 1);
	// spikeFinder.computeInfoBestCandidate(fileManager.getFilteredFile(), 1);
	// priority_queue<candidate> candidates = spikeFinder.getPQBestCandidates();
	// multipleEpochsTest(spikeFinder, candidates, fileManager, 15);

	// Find location using the least squares method
	// Get best IPPs from that epoch
	// spikeFinder.printBestIPPsFromCandidate(bestCandidate);
	// priority_queue<infoIPP> bestIPPs = spikeFinder.getBestIPPsFromCandidate(bestCandidate);
}

void methodPrompt() {
	cout << endl << "### Blind GNSS Search of Extraterrestrial EUV Sources Algorithm ###" << endl << endl;
	string methodId;
	cout << "Input method id (dr/ls/hc/sa/me): ";
	cin >> methodId;

	Auxiliary aux;
	cout << "-- ti.2003.301.10h30m-11h30m.gz | ra=212.338, dec=-13.060 --" << endl;
	aux.chronoStart();
	INPUT_DATA_FILE = "ti.2003.301.10h30m-11h30m.gz";
	mainAlgorithm(methodId);
	aux.chronoEnd();

	// cout << endl << "_______________________________________________________" << endl << endl;

	// cout << "-- ti.2006.340.67190s-68500s.flare.gz | ra=253.182, dec=-22.542 --" << endl;
	// aux.chronoStart();
	// INPUT_DATA_FILE = "ti.2006.340.67190s-68500s.flare.gz";
	// mainAlgorithm(methodId);
	// aux.chronoEnd();

	// cout << endl << "_______________________________________________________" << endl << endl;

	// cout << "-- ti.2016.078.07h32m-09h32m.LARGESIZE.flare.gz | ra=¿?¿?, dec=¿?¿?¿ --" << endl;
	// aux.chronoStart();
	// INPUT_DATA_FILE = "ti.2016.078.07h32m-09h32m.LARGESIZE.flare.gz";
	// mainAlgorithm(methodId);
	// aux.chronoEnd();

	// plot 'cosineData.out' using 1:2 with points, 'cosineDataFitted.out' using 1:2 with points


	// ResultsDebugger resultsDebugger;
	// resultsDebugger.plotSunsRaDecCoefAllSunsAndHillClimbingPath();
	// resultsDebugger.plotSunsRaDecCoefHillClimbingAllConsideredAndPath();
}

void resultsDebugForReport() {

	cout << "(iterations) errorRa errorDec errorAbsolutoTotal time" << endl;
	Auxiliary aux;

	// //Single ls
	// aux.chronoStart();
	// mainAlgorithm("ls");
	// aux.chronoEnd();

	//Ls with iterations
	for (int i = 0; i < 15; i++) {
		iterationsLeastSquares = i;
		cout << i << " ";
		aux.chronoStart();
		mainAlgorithm("ls");
		aux.chronoEnd();
	}

	// aux.chronoStart();
	// mainAlgorithm("dr");
	// aux.chronoEnd();
}

int main() {
	INPUT_DATA_FILE = "ti.2003.301.10h30m-11h30m.gz";
	resultsDebugForReport();

	// INPUT_DATA_FILE = "ti.2006.340.67190s-68500s.flare.gz";
	// resultsDebugForReport();
	iterationsLeastSquares = 10;
	methodPrompt();
}
