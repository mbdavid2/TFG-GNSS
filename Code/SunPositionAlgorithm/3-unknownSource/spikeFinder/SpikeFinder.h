#ifndef SPIKEFINDER_H
#define SPIKEFINDER_H
#include <iostream>
#include <fstream>
#include <queue>
#include <map>
#include "../auxiliary/Auxiliary.h"

using namespace std;

bool operator<(candidate a, candidate b);

class SpikeFinder {

	private: 

		// Objects
		map<double, priority_queue<infoIPP> > priorityQueuesEpochs;

		priority_queue<candidate> candidates;

		priority_queue<infoIPP> IPPsOfEpoch;

		// Functions
		void insertCandidate(double epoch, double meanVTEC);

		void insertInfoIPP (double epoch, double vtec, double ra, double lat);

		candidate getBestCandidateFromPQ();

		// Printing
		void printAllCandidates();

		void printTopNCandidates(int n);

	public:		
		
		void findQueueBestCandidates (ifstream& data);

		candidate findSingleBestCandidate (ifstream& data);

		candidate computeInfoBestCandidate (string fileName, int type);

		priority_queue<infoIPP> getBestIPPsFromCandidate(candidate c);

		priority_queue<candidate> getPQBestCandidates();

		// Printing
		void printBestIPPsFromCandidate(candidate c);

		void printInfoCandidate(candidate c);
};

#endif





