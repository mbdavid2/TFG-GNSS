#include <iostream>

using namespace std;

extern "C" void test_(int* ra, int* dec);

const unsigned short int STEP = 60;

int main() {
	for (int dec = -90; dec <= 90; dec += STEP) {
		if (dec != -90 and dec != 90) {
			for (int ra = 0; ra <= 360; ra += STEP) {
				test_(&ra, &dec);
				cout << dec << " " << ra << " file generated" << endl;
			}
		}
		else {
			//Do only once
			int ra = 0;
			cout << dec << " " << 0 << endl;
		}
	}
}