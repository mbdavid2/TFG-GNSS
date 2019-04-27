#ifndef SPIKEFINDER_H
#define SPIKEFINDER_H
#include <iostream>
#include <fstream>
#include <queue>

using namespace std;

// struct infoIPP {
// 	double epoch;
// 	double vtec;
// 	double ra;
// 	double dec;
// };

struct candidate { 
	double epoch; 
	double maxMeanVTEC;
	double maxIndividialVTEC;
	double bestRa;
	double bestDec;
	double sumyFortran;
	double sumy2Fortran;
	// vector<infoIPP> infoAllRows;
};

bool operator<(candidate a, candidate b);

class SpikeFinder {

	private: 
		// void saveInfo(vector<infoIPP>& infoVec, double epoch, double vtec, double ra, double lat);

		void insertCandidate(priority_queue<candidate>& candidates, double epoch, double meanVTEC);

	public:
		priority_queue<candidate> candidates;

		double getBestEpoch();

		void printTopNCandidates(int n);

		void printAllCandidates();

		priority_queue<candidate> findQueueBestCandidates (ifstream& data);

		candidate findSingleBestCandidate (ifstream& data);

		candidate getInfoBestCandidate (string fileName, int type);
};

#endif





