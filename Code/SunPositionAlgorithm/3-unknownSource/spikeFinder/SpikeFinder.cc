#include "SpikeFinder.h"
#include <iostream>
#include <fstream>
#include <queue>

using namespace std;

bool operator<(candidate a, candidate b) { 
	return a.maxMeanVTEC < b.maxMeanVTEC ? true : false; 
}

void SpikeFinder::printTopNCandidates(int n) {
	cout << endl << "[WARNING: PRINTING THE CANDIDATES POPS THEM]" << endl;
	int i = 0;
	if (n == 0) {
		printAllCandidates();
		return;
	}
	while (!candidates.empty() and ++i <= n) {
		cout << i << ": " << candidates.top().epoch << " " << candidates.top().maxMeanVTEC << endl;
		candidates.pop();
	}
}

float SpikeFinder::getBestEpoch() {
	return !candidates.empty() ? candidates.top().epoch : -1.0;
}

void SpikeFinder::printAllCandidates() {
	while (!candidates.empty()) {
		cout << candidates.top().epoch << " " << candidates.top().maxMeanVTEC << endl;
		candidates.pop();
	}
}

void SpikeFinder::insertCandidate (priority_queue<candidate>& candidates, float epoch, float maxMeanVTEC) {
	candidate c;
	c.epoch = epoch;
	c.maxMeanVTEC = maxMeanVTEC;
	c.maxIndividialVTEC = -1;
	c.bestRa = -1;
	c.bestDec = -1;
	c.sumyFortran = -1;
	c.sumy2Fortran = -1;
	candidates.push(c);
}

priority_queue<candidate> SpikeFinder::findQueueBestCandidates (ifstream& data) {
	float epochIn, vtecIn, raIPPIn, latIPPIn;
	float previousEpoch = -1;
	float totalEpochVTEC = 0;
	int n = 0;
	priority_queue<candidate> candidates;

	//Loop
	data >> epochIn >> vtecIn >> raIPPIn >> latIPPIn;
	totalEpochVTEC += vtecIn;
	previousEpoch = epochIn;
	while (data >> epochIn >> vtecIn >> raIPPIn >> latIPPIn) {
		totalEpochVTEC += vtecIn;
		n++;
		if (previousEpoch != epochIn) {
			insertCandidate (candidates, previousEpoch, totalEpochVTEC/n);
			previousEpoch = epochIn;
			totalEpochVTEC = 0;
			n = 0;
		}
	}
	return candidates;
}

// void SpikeFinder::saveInfo(vector<infoIPP>& infoVec, float epoch, float vtec, float ra, float lat) {
// 	infoIPP info;
// 	info.epoch = epoch;
// 	info.vtec = vtec;
// 	info.ra = ra;
// 	info.dec = lat;
// 	infoVec.push_back(info);
// }

candidate SpikeFinder::findSingleBestCandidate (ifstream& data) {
	float epochIn, vtecIn, raIPPIn, latIPPIn;
	float previousEpoch = -1;
	float totalEpochVTEC = 0;
	int n = 0;
	candidate bestCandidate;
	bestCandidate.epoch = 0;
	bestCandidate.maxMeanVTEC = 0;
	bestCandidate.maxIndividialVTEC = 0;
	bestCandidate.bestRa = 0;
	bestCandidate.bestDec = 0;
	double sumyFortran = 0;
	double sumy2Fortran = 0;

	//Loop
	data >> epochIn >> vtecIn >> raIPPIn >> latIPPIn;
	totalEpochVTEC += vtecIn;
	previousEpoch = epochIn;
	while (data >> epochIn >> vtecIn >> raIPPIn >> latIPPIn) {
		sumyFortran += vtecIn;
		sumy2Fortran += vtecIn*vtecIn;
		totalEpochVTEC += vtecIn;
		n++;
		if (previousEpoch != epochIn) {
			float maxMeanVTEC = totalEpochVTEC/n;
			if (maxMeanVTEC > bestCandidate.maxMeanVTEC) {
				bestCandidate.maxMeanVTEC = maxMeanVTEC;
				bestCandidate.epoch = previousEpoch;
			}
			previousEpoch = epochIn;
			totalEpochVTEC = 0;
			n = 0;
			bestCandidate.maxIndividialVTEC = 0;
		}
		if (vtecIn > bestCandidate.maxIndividialVTEC) {
			bestCandidate.bestRa = raIPPIn;
			bestCandidate.bestDec = latIPPIn;
			bestCandidate.maxIndividialVTEC = vtecIn;
		}
	}
	bestCandidate.sumy2Fortran = sumy2Fortran;
	bestCandidate.sumyFortran = sumyFortran;
	return bestCandidate;
}

// type = 0 -> single candidate, type = 1 -> priority queue
// the function does the same, but for future implementations might want to use priority queue
candidate SpikeFinder::getInfoBestCandidate(string fileName, int type) {
	candidate bestCandidate;
	ifstream inputData;
	inputData.open(fileName, ifstream::in);
	if (type == 0) {
		bestCandidate = findSingleBestCandidate(inputData);
	}
	else if (type == 1) {
		bestCandidate = findQueueBestCandidates(inputData).top();
	}
	inputData.close();
	return bestCandidate;
}