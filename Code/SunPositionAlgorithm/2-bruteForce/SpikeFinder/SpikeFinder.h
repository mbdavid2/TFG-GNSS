#include <iostream>
#include <fstream>
#include <queue>

using namespace std;

struct candidate { 
	float epoch; 
	float meanVTEC; 
};

bool operator<(candidate a, candidate b);

class SpikeFinder {

public:
	priority_queue<candidate> candidates;

	void getTopNCandidates(int n);

	void printAllCandidates();

	void insertCandidate (float epoch, float meanVTEC);

	void generateCandidates (ifstream& data);
};






