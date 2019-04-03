#include <iostream>
#include <fstream>
#include <queue>
#include "SpikeFinder.h"

using namespace std;

int main () {
	ifstream inputFile;
	inputFile.open("./vtecAllDay.out", ifstream::in);
	SpikeFinder spikeFinder;
	spikeFinder.printPriorityQueue(inputFile);
	inputFile.close();
}