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

candidate findSpike(string dataFile) {
	cout << "[C++: Finding a spike in the VTEC distribution]" << endl;
	SpikeFinder spikeFinder;
	candidate bestCandidate = spikeFinder.computeInfoBestCandidate(dataFile, 1);
	spikeFinder.printInfoCandidate(bestCandidate);
	spikeFinder.printBestIPPsFromCandidate(bestCandidate);
	return bestCandidate;
}

void mainAlgorithm() {
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
	traverseGlobe.estimateSourcePosition(bestCandidate.epoch, 0, 0); //TODO: quitar estos ceros del sumfortran
	priority_queue<possibleSunInfo> bestSuns = traverseGlobe.getPriorityQueueBestSuns();

	possibleSunInfo best = bestSuns.top();

	cout << endl << "[Best Sun]" << endl;
	traverseGlobe.printCorrelationResults(best);

	// ResultsDebugger resultsDebugger;
	// resultsDebugger.plotSunsRaDecCoef();
}

int main() {
	Auxiliary aux;
	aux.chronoStart();
	mainAlgorithm();
	aux.chronoEnd();




	// HillClimbing hillClimbing;
	// hillClimbing.hillClimbing();
}