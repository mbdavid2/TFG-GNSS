#include <iostream>
#include <fstream>
#include "spikeFinder/SpikeFinder.h"

using namespace std;

const string FILTERED_FILE = "filterTi.2003.301.10h30m-11h30m.out";
const string DATA_FOLDER = "../data/";

// extern "C" double testsun_(int* ra, int* dec);

// const unsigned short int STEP = 10;

// const bool output = false;

// const string spikeFinderFolder = "spikeFinder";

void system(std::string const &s) { 
    std::system(s.c_str());
}

// void findPearsonCoefficients(float epoch) {
// 	cout << "[C++ -> Fortran: Finding the Person coefficients for possible Suns | Epoch = " + to_string(epoch) + "]" << endl;
// 	double pearsonCoefficient;
// 	for (int dec = -90; dec <= 90; dec += STEP) {
// 		if (dec != -90 and dec != 90) {
// 			for (int ra = 0; ra <= 360; ra += STEP) {
// 				pearsonCoefficient = testsun_(&ra, &dec);
// 				if (output) cout << "Generated file for: ra=" << ra << " dec=" << dec << " Pearson coefficient rxy = " << pearsonCoefficient << endl;
// 			}
// 		}
// 		else {
// 			//Do only once
// 			int ra = 0;
// 			pearsonCoefficient = testsun_(&ra, &dec);
// 			if (output) cout << "Generated file for: ra=" << ra << " dec=" << dec << " Pearson coefficient rxy = " << pearsonCoefficient << endl;
// 		}
// 	}
// }

float findSpike() {
	cout << "[C++: Finding a spike in the VTEC distribution]" << endl;
	ifstream inputFile;
	string fileName = DATA_FOLDER + FILTERED_FILE;
	inputFile.open(fileName, ifstream::in);
	SpikeFinder spikeFinder;
	spikeFinder.generateCandidates(inputFile);
	inputFile.close();
	//spikeFinder.printTopNCandidates(5); //Only debug, it pops the candidates!
	float bestEpoch = spikeFinder.getBestEpoch();
	inputFile.close();
	return bestEpoch;
}

// void testInverseFunction() {
// 	ifstream inputFile;
// 	inputFile.open("preProcessedVTEC.out", ifstream::in);
// 	float vtec, raIPP, latIPP;
// 	int n = 0;
// 	inputFile >> raIPP >> latIPP >> vtec;
// 	inputFile.close();
// }

int main() {
	float epoch = findSpike();
	cout << epoch << endl;
	// findPearsonCoefficients(epoch);
	// cout << "[C++ -> R: Computing correlation coefficient for each possible Sun with R]" << endl;
	// system("Rscript correlationR/correlation.r"); 
}