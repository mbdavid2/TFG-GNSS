#include <iostream>
#include <fstream>
#include <queue>

using namespace std;

// struct infoIPP {
// 	float epoch;
// 	float vtec;
// 	float ra;
// 	float dec;
// };

struct candidate { 
	float epoch; 
	float maxMeanVTEC;
	float maxIndividialVTEC;
	float bestRa;
	float bestDec;
	double sumyFortran;
	double sumy2Fortran;
	// vector<infoIPP> infoAllRows;
};

bool operator<(candidate a, candidate b);

class SpikeFinder {

	private: 
		// void saveInfo(vector<infoIPP>& infoVec, float epoch, float vtec, float ra, float lat);

		void insertCandidate(priority_queue<candidate>& candidates, float epoch, float meanVTEC);

	public:
		priority_queue<candidate> candidates;

		float getBestEpoch();

		void printTopNCandidates(int n);

		void printAllCandidates();

		priority_queue<candidate> findQueueBestCandidates (ifstream& data);

		candidate findSingleBestCandidate (ifstream& data);

		candidate getInfoBestCandidate (string fileName, int type);
};






