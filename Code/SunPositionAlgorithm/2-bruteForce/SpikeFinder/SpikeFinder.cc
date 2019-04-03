#include "SpikeFinder.h"
#include <iostream>
#include <fstream>
#include <queue>

using namespace std;

priority_queue<candidate> candidates;

bool operator<(candidate a, candidate b) { 
	return a.meanVTEC < b.meanVTEC ? true : false; 
}

void SpikeFinder::getTopNCandidates(int n) {
	int i = 0;
	if (n == 0) {
		printAllCandidates();
		return;
	}
	while (!candidates.empty() and ++i <= n) {
		cout << i << ": " << candidates.top().epoch << " " << candidates.top().meanVTEC << endl;
		candidates.pop();
	}
}

void SpikeFinder::printAllCandidates() {
	while (!candidates.empty()) {
		cout << candidates.top().epoch << " " << candidates.top().meanVTEC << endl;
		candidates.pop();
	}
}

void SpikeFinder::insertCandidate (float epoch, float meanVTEC) {
	candidate c;
	c.epoch = epoch;
	c.meanVTEC = meanVTEC;
	candidates.push(c);
}

void SpikeFinder::generateCandidates (ifstream& data) {
	float epoch, vtec;
	float previousEpoch = -1;
	float totalEpochVTEC = 0;
	int n = 0;
	data >> epoch >> vtec;
	totalEpochVTEC += vtec;
	previousEpoch = epoch;
	while (data >> epoch >> vtec) {
		totalEpochVTEC += vtec;
		n++;
		if (previousEpoch != epoch) {
			insertCandidate (previousEpoch, totalEpochVTEC/n);

			//New one
			previousEpoch = epoch;
			totalEpochVTEC = 0;
			n = 0;
		}
	}
}