#include "SpikeFinder.h"
#include <iostream>
#include <fstream>
#include <queue>
#include <map>

using namespace std;

const int MAX_STORED_IPPS = 10;

bool operator<(candidate a, candidate b) { 
	return a.maxMeanVTEC < b.maxMeanVTEC ? true : false; 
}

//Min heap
bool operator<(infoIPP a, infoIPP b) { 
	return a.vtec > b.vtec ? true : false; 
}

void SpikeFinder::printInfoCandidate(candidate c) {
	cout << "[Epoch candidate]" << endl;
	cout << "  -> Epoch: " << c.epoch << endl;
	cout << "  -> Mean VTEC of epoch: " << c.maxMeanVTEC << endl;
	// cout << "  -> Max VTEC of epoch: " << c.maxIndividialVTEC << endl;
	// cout << "  -> Ra of max candidate: " << c.bestRa << endl;
	// cout << "  -> Dec of max candidate: " << c.bestDec << endl;
}

void SpikeFinder::printAllCandidates() {
	while (!candidates.empty()) {
		cout << candidates.top().epoch << " " << candidates.top().maxMeanVTEC << endl;
		candidates.pop();
	}
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

priority_queue<candidate> SpikeFinder::getPQBestCandidates() {
	return candidates;
}

priority_queue<infoIPP> SpikeFinder::getBestIPPsFromCandidate(candidate c) {
	return priorityQueuesEpochs[c.epoch];
}

void SpikeFinder::printBestIPPsFromCandidate(candidate c) {
	cout << "[Best IPPs from candidate with epoch: " << c.epoch << "]" << endl;
	cout << "    Vtec   |   Ra   |   Dec " << endl;
	priority_queue<infoIPP> epochIPPs = priorityQueuesEpochs[c.epoch];
	int i = MAX_STORED_IPPS;
	while (!epochIPPs.empty()) {
		infoIPP info = epochIPPs.top();
		cout << "  " << --i << ": " << info.vtec << " " << info.ra << " " << info.dec << endl;
		epochIPPs.pop();
	}
}

void SpikeFinder::insertCandidate (double epoch, double maxMeanVTEC) {
	candidate c;
	c.epoch = epoch;
	c.maxMeanVTEC = maxMeanVTEC;
	c.maxIndividialVTEC = -1;
	c.bestRa = -1;
	c.bestDec = -1;
	candidates.push(c);
}

void SpikeFinder::insertInfoIPP (double epoch, double vtec, double ra, double lat) {
	infoIPP c;
	c.epoch = epoch;
	c.vtec = vtec;
	c.ra = ra;
	c.dec = lat;
	IPPsOfEpoch.push(c);
	if (IPPsOfEpoch.size() > MAX_STORED_IPPS) IPPsOfEpoch.pop();
}

candidate SpikeFinder::getBestCandidateFromPQ() {
	if (!candidates.empty()) return candidates.top();
	else {
		candidate nothing;
		nothing.epoch = -1;
		return nothing;
	}
}

void SpikeFinder::findQueueBestCandidates (ifstream& data) {
	double epochIn, vtecIn, raIPPIn, latIPPIn;
	double previousEpoch = -1;
	double totalEpochVTEC = 0;
	int n = 0;

	//Loop
	data >> epochIn >> vtecIn >> raIPPIn >> latIPPIn;
	totalEpochVTEC += vtecIn;
	previousEpoch = epochIn;
	while (data >> epochIn >> vtecIn >> raIPPIn >> latIPPIn) {
		insertInfoIPP(epochIn, vtecIn, raIPPIn, latIPPIn);
		totalEpochVTEC += vtecIn;
		n++;
		if (previousEpoch != epochIn) {
			priorityQueuesEpochs[previousEpoch] = IPPsOfEpoch;
			IPPsOfEpoch = priority_queue<infoIPP> ();
			insertCandidate(previousEpoch, totalEpochVTEC/n);
			previousEpoch = epochIn;
			totalEpochVTEC = 0;
			n = 0;
		}
	}
}

candidate SpikeFinder::findSingleBestCandidate (ifstream& data) {
	double epochIn, vtecIn, raIPPIn, latIPPIn;
	double previousEpoch = -1;
	double totalEpochVTEC = 0;
	int n = 0;
	candidate bestCandidate;
	bestCandidate.epoch = 0;
	bestCandidate.maxMeanVTEC = 0;
	bestCandidate.maxIndividialVTEC = 0;
	bestCandidate.bestRa = 0;
	bestCandidate.bestDec = 0;

	//Loop
	data >> epochIn >> vtecIn >> raIPPIn >> latIPPIn;
	totalEpochVTEC += vtecIn;
	previousEpoch = epochIn;
	while (data >> epochIn >> vtecIn >> raIPPIn >> latIPPIn) {
		totalEpochVTEC += vtecIn;
		n++;
		if (previousEpoch != epochIn) {
			double maxMeanVTEC = totalEpochVTEC/n;
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
	return bestCandidate;
}

// type = 0 -> single candidate, type = 1 -> priority queue
// the function does the same, but for future implementations might want to use priority queue
candidate SpikeFinder::computeInfoBestCandidate(string fileName, int type) {
	candidate bestCandidate;
	ifstream inputData;
	inputData.open(fileName, ifstream::in);
	if (type == 0) {
		bestCandidate = findSingleBestCandidate(inputData);
	}
	else if (type == 1) {
		findQueueBestCandidates(inputData);
		bestCandidate = getBestCandidateFromPQ();
	}
	inputData.close();
	return bestCandidate;
}