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

void printpossibleSunInfoInfo(possibleSunInfo l) {
    cout << l.ra << " " << l.dec << " " << l.coefficient << endl;
}

vector<possibleSunInfo> getLocalNeighboursList(possibleSunInfo current) {
    vector<possibleSunInfo> locals = vector<possibleSunInfo>();
    //Considering some possibleSunInfos multiple times
    for (double ra = current.ra - 1; ra <= current.ra + 1; ra++) {
        for (double dec = current.dec - 1; dec <= current.dec + 1; dec++) {
        	possibleSunInfo psi;
        	psi.ra = ra;
        	psi.dec = dec;
        	psi.coefficient = -1;
            locals.push_back(psi);
        }
    }
    return locals;
}

possibleSunInfo getBestCandidate(vector<possibleSunInfo> candidates, FortranController fortranController) {
    possibleSunInfo maxCandidate;
    double maxCoefficient = -1;
    for (int i = 0; i < candidates.size(); ++i) {
        candidates[i].coefficient = fortranController.computeCorrelation(&candidates[i].ra, &candidates[i].dec);
        if (candidates[i].coefficient > maxCoefficient) {
            maxCoefficient = candidates[i].coefficient;
            maxCandidate = candidates[i];
        }
    }
    // printpossibleSunInfoInfo(maxCandidate);
    return maxCandidate;
}

void HillClimbing::estimateSourcePosition() {
    FortranController fortranController;
    possibleSunInfo current;// = make_pair(122, -20);
    possibleSunInfo best;// = make_pair(-1, -1);
    int i = 0;
    while (++i < 10) {
        cout << "Current -> " << current.ra << current.dec << endl;
        vector<possibleSunInfo> candidates = getLocalNeighboursList(current);
        possibleSunInfo newCandidate = getBestCandidate(candidates, fortranController);
        if (newCandidate == current) {
        	current = newCandidate;
        	break;
        }
        current = newCandidate;
        cout << "Current -> " << current.ra << current.dec << endl;
    }
    cout << "Finished -> " << current.ra << current.dec << endl;
}