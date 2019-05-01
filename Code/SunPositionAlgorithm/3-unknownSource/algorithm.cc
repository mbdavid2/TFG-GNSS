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

void multipleEpochsTest(SpikeFinder spikeFinder, priority_queue<candidate> candidates, FileManager fileManager) {
	while (!candidates.empty()) {
		spikeFinder.printInfoCandidate(candidates.top());
		decreaseRangeMethod(fileManager, candidates.top().epoch);
		candidates.pop();
	}
}

void leastSquaresMethod(priority_queue<infoIPP> bestIPPs) {
	FortranController fc;
	fc.leastSquares(bestIPPs);
	cout << endl << "[Least Squres method]" << endl;
	cout << endl << "____________________________________" << endl << endl;
}

void mainAlgorithm() {
	cout << endl << endl << "### Blind GNSS Search of Extraterrestrial EUV Sources Algorithm ###" << endl;
	FileManager fileManager;

	// First filter
	fileManager.setInputFile(ORIGINAL_FILE);
	fileManager.setAWKScripts(FILTER_AWK_SCRIPT, FILTER_TIME_AWK_SCRIPT);	
	fileManager.filterTiFileByBasicData();
	
	// // Find spike (epoch)
	// SpikeFinder spikeFinder;
	// candidate bestCandidate = spikeFinder.computeInfoBestCandidate(fileManager.getFilteredFile(), 1);

	// // Find location using the decreaseRange method
	// decreaseRangeMethod(fileManager, bestCandidate.epoch);

	// Test: multiple epochs
	SpikeFinder spikeFinder;
	candidate bestCandidate = spikeFinder.computeInfoBestCandidate(fileManager.getFilteredFile(), 1);
	priority_queue<candidate> candidates = spikeFinder.getPQBestCandidates();
	multipleEpochsTest(spikeFinder, candidates, fileManager);

	// Find location using the least squares method
	// Get best IPPs from that epoch
	// spikeFinder.printBestIPPsFromCandidate(bestCandidate);
	// priority_queue<infoIPP> bestIPPs = spikeFinder.getBestIPPsFromCandidate(bestCandidate);
	// leastSquaresMethod(bestIPPs);
}

int main() {
	Auxiliary aux;
	aux.chronoStart();
	mainAlgorithm();
	aux.chronoEnd();
}