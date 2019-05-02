#include <iostream>
#include <utility>
#include <vector>
#include "HillClimbing.h"
#include "../fortranController/FortranController.h"

typedef pair<double, double> location;

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

void printLocationInfo(location l, double coefficient) {
    cout << l.first << " " << l.second << " " << coefficient << endl;
}

vector<location> getLocalNeighboursList(location current) {
    vector<location> locals = vector<location>();
    //Considering some locations multiple times
    for (double ra = current.first - 1; ra <= current.first + 1; ra++) {
        for (double dec = current.second - 1; dec <= current.second + 1; dec++) {
            locals.push_back(make_pair(ra, dec));
        }
    }
    return locals;
}

location getBestCandidate(vector<location> candidates, FortranController fortranController) {
    location maxCandidate = make_pair(-1, -1);
    double maxCoefficient = -1;
    double pearsonCoefficient = -1;
    for (int i = 0; i < candidates.size(); ++i) {
        pearsonCoefficient = fortranController.computeCorrelation(&candidates[i].first, &candidates[i].second);
        printLocationInfo(candidates[i], pearsonCoefficient);
        if (pearsonCoefficient > maxCoefficient) {
            maxCoefficient = pearsonCoefficient;
            maxCandidate = candidates[i];
        }
    }
    return maxCandidate;
}

void HillClimbing::estimateSourcePosition() {
    FortranController fortranController;
    location current = make_pair(122, -20);
    location best = make_pair(-1, -1);
    int i = 0;
    while (++i < 10) {
        cout << " -> " << current.first << current.second << endl;
        vector<location> candidates = getLocalNeighboursList(current);
        location current = getBestCandidate(candidates, fortranController);
        cout << " -> " << current.first << current.second << endl;
    }
    // cout << current.first << " " << current.second << endl;
    // while (checkLocalOptions(candidate)) {

    // }
}