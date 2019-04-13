#include "TraverseGlobe.h"
#include <iostream>
#include <vector>

using namespace std;

struct possibleSunInfo {
	double coefficient;
	string location;
};

extern "C" double mainfortran_(int* ra, int* dec, int* writeData);

int writeData = 0;
// const unsigned short int STEP = 100;

void considerPossibleSuns(int step) {
	cout << endl << "[C++ -> Fortran: Computing Person coefficients | Possible Suns with step = " + to_string(step) + "]" << endl; // for possible Suns | Epoch = " + to_string(epoch) + "]" << endl;
	double pearsonCoefficient;
	int i = 0;
	possibleSunInfo bestSun;
	bestSun.coefficient = -23;
	bestSun.location = "salu2";
	for (int dec = -90; dec <= 90; dec += step) {
		if (dec != -90 and dec != 90) {
			for (int ra = 0; ra <= 360; ra += step) {
				pearsonCoefficient = mainfortran_(&ra, &dec, &writeData);
				cout << "\r" << "[" << ++i << " possible Suns considered]";
				if (pearsonCoefficient > bestSun.coefficient) {
					bestSun.coefficient = pearsonCoefficient;
					bestSun.location = "[ra=" + to_string(ra) + ", dec=" + to_string(dec) + "]";
				}
				// cout << "Generated file for: ra=" << ra << " dec=" << dec << " Pearson coefficient rxy = " << pearsonCoefficient << endl;
			}
		}
		else {
			//Do only once
			int ra = 0;
			pearsonCoefficient = mainfortran_(&ra, &dec, &writeData);
			cout << "\r" << "[" << ++i << " possible Suns considered]";
			if (pearsonCoefficient > bestSun.coefficient) {
				bestSun.coefficient = pearsonCoefficient;
				bestSun.location = "[ra=" + to_string(ra) + ", dec=" + to_string(dec) + "]";
			}
			// cout << "Generated file for: ra=" << ra << " dec=" << dec << " Pearson coefficient rxy = " << pearsonCoefficient << endl;
		}
	}
	cout << endl << "[C++: Results]" << endl;
	cout << "   -> Largest correlation coefficient: " << bestSun.coefficient << endl;
	cout << "   -> Estimated Sun's location: " << bestSun.location << endl;
}

void TraverseGlobe::decreasingSTEP () {
	vector<int> steps = {100,60,30,10,5,2};
	int step;
	for (unsigned int i = 0; i < steps.size(); ++i) {
		step = steps[i];
		considerPossibleSuns(step);
	}
}

void TraverseGlobe::initialMeasures () {
	cout << "salu2" << endl;
}

void TraverseGlobe::test(float epoch) {
	system("rm -r results; mkdir -p results/");
	decreasingSTEP();
	// findPearsonCoefficients(epoch);
}