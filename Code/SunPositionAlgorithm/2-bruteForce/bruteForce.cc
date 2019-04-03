#include <iostream>
#include <fstream>
#include "./SpikeFinder/SpikeFinder.h"

using namespace std;

extern "C" float testsun_(int* ra, int* dec);

const unsigned short int STEP = 60;

void findPearsonCoefficients() {
	cout << endl << "[Finding the Person coefficients for possible Suns]" << endl;
	float pearsonCoefficient;
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

void findSpike() {
	cout << endl << "[Finding a spike in the VTEC distribution]" << endl;
	ifstream inputFile;
	inputFile.open("./SpikeFinder/vtecAllDay.out", ifstream::in);
	SpikeFinder spikeFinder;
	spikeFinder.generateCandidates(inputFile);
	spikeFinder.getTopNCandidates(5);
	inputFile.close();
}

int main() {
	findSpike();
	findPearsonCoefficients();
}