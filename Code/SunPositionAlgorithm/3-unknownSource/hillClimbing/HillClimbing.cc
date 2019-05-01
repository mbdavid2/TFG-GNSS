#include <iostream>
#include <utility>
#include <vector>
#include "HillClimbing.h"

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

vector<location> getLocalNeighboursList(location current) {
    vector<location> locals;
    //Considering some locations multiple times
    for (double ra = current.first - 1; ra <= current.first + 1; ra++) {
        for (double dec = current.second - 1; dec <= current.second + 1; dec++) {
            locals.push_back(make_pair(ra, dec));
        }
    }
    return locals;
}

location getBestCandidate(vector<location> candidates) {
    location maxCandidate = make_pair(-1, -1);
    double maxCoefficient = -1;
    double pearsonCoefficient = -1;
    for (int i = 0; i < candidates.size(); ++i) {
        // pearsonCoefficient = callFunction();
        if (pearsonCoefficient > maxCoefficient) {
            maxCoefficient = pearsonCoefficient;
            maxCandidate = candidates[i];
        }
    }
    return maxCandidate;
}

void HillClimbing::hillClimbing() {
    location current = make_pair(192, -20);
    location best = make_pair(-1, -1);
    while (best != current) {
        vector<location> candidates = getLocalNeighboursList(current);
        location best = getBestCandidate(candidates);
    }
    // while (checkLocalOptions(candidate)) {

    // }
}