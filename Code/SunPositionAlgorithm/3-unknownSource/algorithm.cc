#include <iostream>
#include <fstream>
#include "spikeFinder/SpikeFinder.h"
#include "traverseGlobe/TraverseGlobe.h"

using namespace std;

const string FILTERED_FILE = "filterTi.2003.301.10h30m-11h30m.out";
const string AWK_SCRIPT = "filterDataByTime.awk";
const string DATA_FOLDER = "../data/";

void system(std::string const &s) { 
    std::system(s.c_str());
}

void printCandidate(candidate c) {
	cout << "  -> Epoch: " << c.epoch << endl;
	cout << "  -> Mean VTEC of epoch: " << c.maxMeanVTEC << endl;
	cout << "  -> Max VTEC of epoch: " << c.maxIndividialVTEC << endl;
	cout << "  -> Ra of max candidate: " << c.bestRa << endl;
	cout << "  -> Dec of max candidate: " << c.bestDec << endl;
}

candidate findSpike() {
	cout << "[C++: Finding a spike in the VTEC distribution]" << endl;
	SpikeFinder spikeFinder;
	string fileName = DATA_FOLDER + FILTERED_FILE;
	candidate bestCandidate = spikeFinder.getInfoBestCandidate(fileName, 0);
	return bestCandidate;
}

void filterByTime(float time) {
	string command = "cat " + DATA_FOLDER + FILTERED_FILE + " | gawk -f " + DATA_FOLDER + AWK_SCRIPT + " -v flareTime=" + to_string(time) + " > spikeData.out";
	// cout << command << endl;
	system(command); 
}

int main() {
	cout << endl << endl << "### Blind GNSS Search of Extraterrestrial EUV Sources Algorithm ###" << endl;
	candidate bestCandidate = findSpike();
	printCandidate(bestCandidate);
	filterByTime(bestCandidate.epoch);
	TraverseGlobe traverseGlobe;
	traverseGlobe.test(bestCandidate.epoch);
	



	// findPearsonCoefficients(epoch);
	// cout << "[C++ -> R: Computing correlation coefficient for each possible Sun with R]" << endl;
	// system("Rscript correlationR/correlation.r"); 
}