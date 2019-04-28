#include <iostream>
#include <fstream>
#include <queue>
#include "spikeFinder/SpikeFinder.h"
#include "traverseGlobe/TraverseGlobe.h"
#include "fileManager/FileManager.h"
#include "resultsDebugger/ResultsDebugger.h"

using namespace std;

// const string ORIGINAL_FILE = "ti.2003.301.10h30m-11h30m.gz";
const string ORIGINAL_FILE = "ti.2006.340.67190s-68500s.flare.gz";

const string FILTER_AWK_SCRIPT = "filterDataTi.awk";
const string FILTER_TIME_AWK_SCRIPT = "filterDataByTime.awk";

void printSpikeCandidate(candidate c) {
	cout << "  -> Epoch: " << c.epoch << endl;
	cout << "  -> Mean VTEC of epoch: " << c.maxMeanVTEC << endl;
	cout << "  -> Max VTEC of epoch: " << c.maxIndividialVTEC << endl;
	cout << "  -> Ra of max candidate: " << c.bestRa << endl;
	cout << "  -> Dec of max candidate: " << c.bestDec << endl;
}

candidate findSpike(string dataFile) {
	cout << "[C++: Finding a spike in the VTEC distribution]" << endl;
	SpikeFinder spikeFinder;
	candidate bestCandidate = spikeFinder.getInfoBestCandidate(dataFile, 0);
	printSpikeCandidate(bestCandidate);
	return bestCandidate;
}

int main() {
	cout << endl << endl << "### Blind GNSS Search of Extraterrestrial EUV Sources Algorithm ###" << endl;
	FileManager fileManager;

	//First filter
	fileManager.setInputFile(ORIGINAL_FILE);
	fileManager.setAWKScripts(FILTER_AWK_SCRIPT, FILTER_TIME_AWK_SCRIPT);	
	fileManager.filterTiFileByBasicData();
	
	//Find spike
	candidate bestCandidate = findSpike(fileManager.getFilteredFile());

	// Filter by time
	fileManager.filterTiFileByTime(bestCandidate.epoch);

	//Execute main algorithm
	TraverseGlobe traverseGlobe;
	traverseGlobe.estimateSourcePosition(bestCandidate.epoch, bestCandidate.sumyFortran, bestCandidate.sumy2Fortran);
	priority_queue<possibleSunInfo> bestSuns = traverseGlobe.getPriorityQueueBestSuns();

	possibleSunInfo best = bestSuns.top();

	cout << endl << "[Best Sun]" << endl;
	traverseGlobe.printCorrelationResults(best);

	ResultsDebugger resultsDebugger;
	resultsDebugger.plotSunsRaDecCoef();
}