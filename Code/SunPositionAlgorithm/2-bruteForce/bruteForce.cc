#include <iostream>
#include <fstream>
#include <chrono>
#include "spikeFinder/SpikeFinder.h"

using namespace std;
using namespace std::chrono;

typedef high_resolution_clock::time_point clockTime;

extern "C" double testsun_(int* ra, int* dec);

//Global variables
clockTime startTime;

const unsigned short int STEP = 10;

const bool outputEachFile = false;
const bool userStep = false;

const string spikeFinderFolder = "spikeFinder";

void system(std::string const &s) { 
    std::system(s.c_str());
}

void printExecutionTime(clockTime start_time, clockTime end_time) {
    // auto execution_time_ns = duration_cast<nanoseconds>(end_time - start_time).count();
    auto execution_time_ms = duration_cast<microseconds>(end_time - start_time).count();
    auto execution_time_sec = duration_cast<seconds>(end_time - start_time).count();
    auto execution_time_min = duration_cast<minutes>(end_time - start_time).count();
    // auto execution_time_hour = duration_cast<hours>(end_time - start_time).count();

    cout << "   -> Execution Time: ";
    // if(execution_time_hour > 0)
    // cout << "" << execution_time_hour << " Hours, ";
    if(execution_time_min > 0)
    	cout << "" << execution_time_min % 60 << "m ";
    if(execution_time_sec > 0)
    	cout << "" << execution_time_sec % 60 << "s ";
    if(execution_time_ms > 0)
    	cout << "" << execution_time_ms % long(1E+3) << "ms ";
    // if(execution_time_ns > 0)
    // cout << "" << execution_time_ns % long(1E+6) << " NanoSeconds, ";
	cout << endl;
}

void chronoStart() {
	startTime = high_resolution_clock::now();
}

void chronoEnd() {
	clockTime now = high_resolution_clock::now();
	printExecutionTime (startTime, now);
}

void findPearsonCoefficients(float epoch, int step) {
	cout << "[C++ -> Fortran: Finding the Person coefficients for possible Suns]" << endl; // | Epoch = " + to_string(epoch) + "]" << endl;
	double pearsonCoefficient;
	double maxCoefficient = -23;
	string location = "salu2";
	int i = 0;
	// int step = 10;
	// if (userStep) {
	// 	cout << "   -> Input degree step: ";
	// 	cin >> step;
	// }
	// else  {
	// 	step = STEP;
	// }
	for (int dec = -90; dec <= 90; dec += step) {
		if (dec != -90 and dec != 90) {
			for (int ra = 0; ra <= 360; ra += step) {
				pearsonCoefficient = testsun_(&ra, &dec);
				cout << "\r" << "[" << ++i << " possible Suns considered]";
				if (pearsonCoefficient > maxCoefficient) {
					maxCoefficient = pearsonCoefficient;
					location = "[ra=" + to_string(ra) + ", dec=" + to_string(dec) + "]";
				}
				if (outputEachFile) cout << "Generated file for: ra=" << ra << " dec=" << dec << " Pearson coefficient rxy = " << pearsonCoefficient << endl;
			}
		}
		else {
			//Do only once
			int ra = 0;
			pearsonCoefficient = testsun_(&ra, &dec);
			cout << "\r" << "[" << ++i << " possible Suns considered]";
			if (pearsonCoefficient > maxCoefficient) {
				maxCoefficient = pearsonCoefficient;
				location = "[ra=" + to_string(ra) + ", dec=" + to_string(dec) + "]";
			}
			if (outputEachFile) cout << "Generated file for: ra=" << ra << " dec=" << dec << " Pearson coefficient rxy = " << pearsonCoefficient << endl;
		}
	}
	cout << endl << "[C++: Results]" << endl;
	cout << "   -> Step used: " << step << endl;
	cout << "   -> Largest correlation coefficient: " << maxCoefficient << endl;
	cout << "   -> Estimated Sun's location: " << location << endl;
}

float findSpike() {
	cout << "[C++: Finding a spike in the VTEC distribution]" << endl;
	ifstream inputFile;
	inputFile.open(spikeFinderFolder + "/processedVTEC.out", ifstream::in);
	SpikeFinder spikeFinder;
	spikeFinder.generateCandidates(inputFile);
	//spikeFinder.printTopNCandidates(5); //Only debug, it pops the candidates
	float bestEpoch = spikeFinder.getBestEpoch();
	cout << "   -> Spike found: " << bestEpoch << endl;
	inputFile.close();
	return bestEpoch;
}

void filterDataByEpoch(float epoch) {
	cout << "[AWK: Filtering all data by best epoch: " << epoch << "]" << endl;
	string command = "zcat ../data/ti.2003.301.10h30m-11h30m.gz | gawk -v flareTime=" + to_string(epoch) + " -f processDataSun.awk  > outputTi.out";
	system(command); 
}

void computeCorrelationCoefficientsUsingR() {
	cout << "[C++ -> R: Computing correlation coefficient for each possible Sun with R]" << endl;
	system("Rscript correlationR/correlation.r"); 
}

void chronoDifferentSteps (float epoch) {
	for (double step = 100; step >= 1; step /= 2) {
		chronoStart();
		findPearsonCoefficients(epoch, step);
		chronoEnd();
	}
}

int main() {
	cout << endl << "#### Brute force algorithm ####" << endl;
	float epoch = findSpike();
	filterDataByEpoch(epoch);
	// findPearsonCoefficients(epoch);
	chronoDifferentSteps(epoch);

	//computeCorrelationCoefficientsUsingR();
}