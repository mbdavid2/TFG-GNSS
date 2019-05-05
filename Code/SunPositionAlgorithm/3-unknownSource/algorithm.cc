#include <iostream>
#include <fstream>
#include <queue>
#include "spikeFinder/SpikeFinder.h"
#include "traverseGlobe/TraverseGlobe.h"
#include "fileManager/FileManager.h"
#include "resultsDebugger/ResultsDebugger.h"
#include "hillClimbing/HillClimbing.h"
#include "auxiliary/Auxiliary.h"
#include "fortranController/FortranController.h"

using namespace std;

const string ORIGINAL_FILE = "ti.2003.301.10h30m-11h30m.gz";
// const string ORIGINAL_FILE = "ti.2006.340.67190s-68500s.flare.gz";

const string FILTER_AWK_SCRIPT = "filterDataTi.awk";
const string FILTER_TIME_AWK_SCRIPT = "filterDataByTime.awk";

// spikeFinder findSpike(string dataFile) {
// 	cout << "[C++: Finding a spike in the VTEC distribution]" << endl;
// 	SpikeFinder spikeFinder;
// 	candidate bestCandidate = spikeFinder.computeInfoBestCandidate(dataFile, 1);
// 	spikeFinder.printInfoCandidate(bestCandidate);
// 	return return spikeFinder;
// }

void decreaseRangeMethod(FileManager fileManager, double epoch) {
	// Filter by time
	fileManager.filterTiFileByTime(epoch);

	// Execute main algorithm
	TraverseGlobe traverseGlobe;
	traverseGlobe.estimateSourcePosition(epoch, 0, 0); //TODO: quitar estos ceros del sumfortran
	priority_queue<possibleSunInfo> bestSuns = traverseGlobe.getPriorityQueueBestSuns();

	possibleSunInfo best = bestSuns.top();

	cout << endl << "[Decrease range method]" << endl;
	traverseGlobe.printCorrelationResults(best);
	cout << endl << "____________________________________" << endl << endl;
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

void leastSquaresMethod(int numRows) {
	FortranController fc;
	cout << endl << "[Least Squres method]" << endl;
	string fileNameString = "filteredByTime.out";
	const char* inputFileName = fileNameString.c_str();
	fc.leastSquares(inputFileName, numRows);
	cout << endl << "____________________________________" << endl << endl;
}

void hillClimbingMethod() {
	HillClimbing hillClimbing;
	hillClimbing.estimateSourcePosition();
}

void mainAlgorithm() {
	cout << endl << endl << "### Blind GNSS Search of Extraterrestrial EUV Sources Algorithm ###" << endl << endl;
	FileManager fileManager;

	// First filter
	fileManager.setInputFile(ORIGINAL_FILE);
	fileManager.setAWKScripts(FILTER_AWK_SCRIPT, FILTER_TIME_AWK_SCRIPT);	
	fileManager.filterTiFileByBasicData();

	// Find spike
	SpikeFinder spikeFinder;
	candidate bestCandidate = spikeFinder.computeInfoBestCandidate(fileManager.getFilteredFile(), 1);

	// Filter by time
	int numRows = fileManager.filterTiFileByTime(bestCandidate.epoch);

	///////////

	// Find location using the decreaseRange method
	decreaseRangeMethod(fileManager, bestCandidate.epoch);

	// Hill Climbing
	// hillClimbingMethod();

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
	// leastSquaresMethod(numRows); //TODO: como obtenemos el numero de lineas al hacer el filtrado??
}

int main() {
	Auxiliary aux;
	aux.chronoStart();
	mainAlgorithm();
	aux.chronoEnd();

	// ResultsDebugger resultsDebugger;
	// // resultsDebugger.plotSunsRaDecCoefAllSunsAndHillClimbingPath();
	// resultsDebugger.plotSunsRaDecCoefHillClimbingAllConsideredAndPath();
}