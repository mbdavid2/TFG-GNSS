#include <iostream>
#include <fstream>
#include <queue>
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

void printSpikeCandidate(candidate c) {
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
	string command = "cat " + DATA_FOLDER + FILTERED_FILE_TIME + " | gawk -f " + AWK_SCRIPT_TIME + " -v flareTime=" + to_string(time) + " > spikeData.out";
	system(command); 
}

void reFilterTiFile() {
	string command = "zcat " + DATA_FOLDER + ORIGINAL_FILE + " | gawk -f " + DATA_FOLDER + ORIGINAL_AWK_SCRIPT + " > " + DATA_FOLDER + "filterTi.2003.301.10h30m-11h30m.out";
	system(command); 
}

void plotResults(priority_queue<possibleSunInfo>& bestSuns) {
	ofstream plotData;
	plotData.open("gnuplot.in", ios::trunc);
	while (!bestSuns.empty()) {
		plotData << bestSuns.top().ra << " " << bestSuns.top().dec << " " << bestSuns.top().coefficient << endl;
		bestSuns.pop();
	}
	plotData.close();
	string ranges = "";//set xrange [0:360]; set yrange [-180:180];";// set zrange [-1:1];";
	system("gnuplot -e \"set xlabel 'Right Ascension'; set ylabel 'Declination'; set zlabel 'Coefficient'; " + ranges +" set grid; splot 'gnuplot.in' using 1:2:3 with lines; pause -1;\"");
}

void plotIPPsRaDecVTEC() {
	//Esto como que no es muy interesante no? No dice nada pq son RA i DEC del IPP
	string ranges = "";//set xrange [0:360]; set yrange [-180:180];";// set zrange [-1:1];";
	system("gnuplot -e \"set xlabel 'Right Ascension'; set ylabel 'Declination'; set zlabel 'VTEC'; " + ranges +" set grid; splot 'spikeData.out' using 2:3:1 with point; pause -1;\"");
}

void plotSunsRaDecCoefInterpolate() {
	string ranges = "set zrange [0:1];";//set xrange [0:360]; set yrange [-180:180];";// set zrange [-1:1];";
	string labels = "set xlabel 'Right Ascension'; set ylabel 'Declination'; set zlabel 'Coefficient'; ";
	system("gnuplot -e \"" + labels + "set hidden3d; set dgrid3d 35,35 qnorm 2; " + ranges +" set grid; splot 'gnuplot.in' using 1:2:3 with lines; pause -1;\"");
}

void plotSunsRaDecCoef() {
	string ranges = "";//set xrange [0:360]; set yrange [-180:180];";// set zrange [-1:1];";
	string labels = "set xlabel 'Right Ascension'; set ylabel 'Declination'; set zlabel 'Coefficient'; ";
	system("gnuplot -e \"" + labels + ranges +" set grid; splot 'gnuplot.in' using 1:2:3 with points; pause -1;\"");
}


int main() {
	cout << endl << endl << "### Blind GNSS Search of Extraterrestrial EUV Sources Algorithm ###" << endl;
	// reFilterTiFile();
	candidate bestCandidate = findSpike();
	printSpikeCandidate(bestCandidate);
	filterByTime(bestCandidate.epoch);
	TraverseGlobe traverseGlobe;
	traverseGlobe.estimateSourcePosition(bestCandidate.epoch, bestCandidate.sumyFortran, bestCandidate.sumy2Fortran);
	// traverseGlobe.printAllPossibleSunsOrdered();
	priority_queue<possibleSunInfo> bestSuns = traverseGlobe.getPriorityQueueBestSuns();
	// plotResults(bestSuns);
	possibleSunInfo best = bestSuns.top();
	cout << endl << "[Best Sun]" << endl;
	traverseGlobe.printCorrelationResults(best);
	// plotSunsRaDecCoef();
}