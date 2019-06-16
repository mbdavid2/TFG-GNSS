#include <iostream>
#include <utility>
#include <vector>
#include "HillClimbing.h"
#include "../fortranController/FortranController.h"
#include "../auxiliary/Auxiliary.h"

double heuristic (int x, int y) {
    return x + y;
}

// void checkLocalOptions() {
//     for (candidate : candidates) {
//             if (heuristic(candidate) > currentHeuristic) {
//                 if (heuristic(candidate) > maxHeuristic) {
//                     maxHeuristic = candidate
//                 }
//             }
//         }
// }

void printPossibleSunInfo(possibleSunInfo l) {
    cout << l.ra << " " << l.dec << " " << l.coefficient << endl;
}

void printVector(const vector<possibleSunInfo>& vec) {
    cout << "Neighbours:" << endl;
	for (unsigned int i = 0; i < vec.size(); ++i) {
       cout << "   ";
       printPossibleSunInfo(vec[i]);
    }
}

void writeToFileForOutput(possibleSunInfo candidate, string filename) {
	string data = "echo \"" + to_string(candidate.ra) + " " + to_string(candidate.dec) + " " + to_string(candidate.coefficient) + "\"";
	string command = data + " >> " + filename;
	// cout << command << endl;
	system(command.c_str());
}

vector<possibleSunInfo> getLocalNeighboursList(possibleSunInfo current, FortranController& fortranController) {
    vector<possibleSunInfo> locals = vector<possibleSunInfo>();
    //Considering some possibleSunInfos multiple times
    for (double ra = current.ra - 2; ra <= current.ra + 2; ra += 1) {
        for (double dec = current.dec - 2; dec <= current.dec + 2; dec += 1) {
        	if (current.ra != ra and current.dec != dec) {
	        	possibleSunInfo psi;
	        	psi.ra = ra;
	        	psi.dec = dec;
	        	// psi.coefficient = fortranController.computeCorrelation(&ra, &dec);
	        	writeToFileForOutput(psi, "hillClimbingAll.out");
	            locals.push_back(psi);
	        }
        }
    }
    return locals;
}

possibleSunInfo getBestCandidate(vector<possibleSunInfo> candidates) {
    possibleSunInfo maxCandidate;
    double maxCoefficient = -1;
    for (unsigned int i = 0; i < candidates.size(); ++i) {
        if (candidates[i].coefficient > maxCoefficient) {
            maxCoefficient = candidates[i].coefficient;
            maxCandidate = candidates[i];
        }
    }
    // printpossibleSunInfoInfo(maxCandidate);
    return maxCandidate;
}

void HillClimbing::estimateSourcePosition() {
    string command = "rm hillClimbingPath.out & rm hillClimbingAll.out";
    system(command.c_str());
    FortranController fortranController;
    fortranController.resetConsideredLocations();
    possibleSunInfo current;// = make_pair(122, -20);
    // current.ra = 100;
    // current.dec = -60;
    current.ra = 160;
    current.dec = -20;
    // current.coefficient = fortranController.computeCorrelation(&current.ra, &current.dec);
    possibleSunInfo best;// = make_pair(-1, -1);
    int i = 0;
    while (++i < 100) {
        cout << "Current: ";
        printPossibleSunInfo(current);
        vector<possibleSunInfo> candidates = getLocalNeighboursList(current, fortranController);
        printVector(candidates);
        possibleSunInfo newCandidate = getBestCandidate(candidates);
        if (newCandidate < current) {
        	// current = newCandidate;
            cout << "Can't progress" << endl;
        	break;
        }
        current = newCandidate;
        writeToFileForOutput(current, "hillClimbingPath.out");
        // cout << "Current -> ";
        // printPossibleSunInfo(current);
    }
    fortranController.printNumberOfConsideredLocations();
    cout << "Best: ";
    printPossibleSunInfo(current);
}