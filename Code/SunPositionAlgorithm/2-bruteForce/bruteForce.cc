#include <iostream>
#include <fstream>
#include "spikeFinder/SpikeFinder.h"

using namespace std;

extern "C" double testsun_(int* ra, int* dec);

const unsigned short int STEP = 30;

const string spikeFinderFolder = "spikeFinder";

void system(std::string const &s) { 
    std::system(s.c_str());
}

void findPearsonCoefficients(float epoch) {
	cout << endl << "[C++ -> Fortran: Finding the Person coefficients for possible Suns | Epoch = " + to_string(epoch) + "]" << endl;
	double pearsonCoefficient;
	for (int dec = -90; dec <= 90; dec += STEP) {
		if (dec != -90 and dec != 90) {
			for (int ra = 0; ra <= 360; ra += STEP) {
				pearsonCoefficient = testsun_(&ra, &dec);
				cout << "Generated file for: ra=" << ra << " dec=" << dec << " Pearson coefficient rxy = " << pearsonCoefficient << endl;
			}
		}
		else {
			//Do only once
			int ra = 0;
			pearsonCoefficient = testsun_(&ra, &dec);
			cout << "Generated file for: ra=" << ra << " dec=" << dec << " Pearson coefficient rxy = " << pearsonCoefficient << endl;
		}
	}
}

float findSpike() {
	cout << endl << "[C++: Finding a spike in the VTEC distribution]" << endl;
	ifstream inputFile;
	inputFile.open(spikeFinderFolder + "/processedVTEC.out", ifstream::in);
	SpikeFinder spikeFinder;
	spikeFinder.generateCandidates(inputFile);
	//spikeFinder.printTopNCandidates(5); //Only debug
	float bestEpoch = spikeFinder.getBestEpoch();
	inputFile.close();
}

void filterDataByEpoch(float epoch) {
	cout << endl << "[AWK: Filtering all data by epoch: " << epoch << "]" << endl;
	string command = "zcat ../data/ti.2003.301.10h30m-11h30m.gz | gawk -v flareTime=" + to_string(epoch) + " -f processDataSun.awk  > outputTi.out";
	system(command); 
}

int main() {
	float epoch = findSpike();
	filterDataByEpoch(epoch);
	findPearsonCoefficients(epoch);
	cout << endl << "[C++ -> R: Computing each Correlation with R]" << endl;
	system("Rscript correlationR/correlation.r"); 
}