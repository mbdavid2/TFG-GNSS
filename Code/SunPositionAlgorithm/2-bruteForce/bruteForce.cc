#include <iostream>

using namespace std;

extern "C" float testsun_(int* ra, int* dec);

const unsigned short int STEP = 60;

int main() {
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