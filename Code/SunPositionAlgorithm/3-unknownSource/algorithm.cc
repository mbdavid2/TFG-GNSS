#include <iostream>
#include <fstream>
#include "spikeFinder/SpikeFinder.h"
#include "traverseGlobe/TraverseGlobe.h"

using namespace std;

const string ORIGINAL_FILE = "ti.2003.301.10h30m-11h30m.gz";
const string FILTERED_FILE_TIME = "filterTi.2003.301.10h30m-11h30m.out";
const string ORIGINAL_AWK_SCRIPT = "filterDataTi.awk";
const string AWK_SCRIPT_TIME = "filterDataByTime.awk";
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
	string fileName = DATA_FOLDER + FILTERED_FILE_TIME;
	candidate bestCandidate = spikeFinder.getInfoBestCandidate(fileName, 0);
	return bestCandidate;
}

void filterByTime(float time) {
	string command = "cat " + DATA_FOLDER + FILTERED_FILE_TIME + " | gawk -f " + DATA_FOLDER + AWK_SCRIPT_TIME + " -v flareTime=" + to_string(time) + " > spikeData.out";
	system(command); 
}

void reFilterTiFile() {
	string command = "zcat " + DATA_FOLDER + ORIGINAL_FILE + " | gawk -f " + DATA_FOLDER + ORIGINAL_AWK_SCRIPT + " > " + DATA_FOLDER + "filterTi.2003.301.10h30m-11h30m.out";
	system(command); 
}

int main() {
	cout << endl << endl << "### Blind GNSS Search of Extraterrestrial EUV Sources Algorithm ###" << endl;
	// reFilterTiFile();
	candidate bestCandidate = findSpike();
	printCandidate(bestCandidate);
	filterByTime(bestCandidate.epoch);
	TraverseGlobe traverseGlobe;
	traverseGlobe.test(bestCandidate.epoch);
	cout << endl << "### Real Sun's location [ra=212.338, dec=-13.060] ###" << endl;
}