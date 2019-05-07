#include <iostream>
#include <utility>
#include <vector>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <gsl/gsl_siman.h>
#include "SimulatedAnnealing.h"
#include "../fortranController/FortranController.h"
#include "../auxiliary/Auxiliary.h"

/* set up parameters for this simulated annealing run */

/* how many points do we try before stepping */
#define N_TRIES 200

/* how many iterations for each T? */
#define ITERS_FIXED_T 50

/* max step size in random walk */
#define STEP_SIZE 1.0

/* Boltzmann constant */
#define K 1.0

/* initial temperature */
#define T_INITIAL 0.008

/* damping factor for temperature */
#define MU_T 1.003
#define T_MIN 2.0e-6

gsl_siman_params_t params
  = {N_TRIES, ITERS_FIXED_T, STEP_SIZE,
     K, T_INITIAL, MU_T, T_MIN};

double energyFunc(void *xp) {
  possibleSunInfo x = * ((possibleSunInfo *) xp);
  FortranController fc;
  return fc.computeCorrelation(&x.ra, &x.dec);
}

double metricFunc(void *xp, void *yp) {
  possibleSunInfo x = *((possibleSunInfo *) xp);
  possibleSunInfo y = *((possibleSunInfo *) yp);

  return fabs(x.ra - y.ra) + fabs(x.dec - y.dec);
}

void printFunc(void *xp) {
  possibleSunInfo x = *((possibleSunInfo *) xp);
  cout << x.ra << " " << x.dec << endl;
}

//This function type should modify the configuration xp using a 
//random step taken from the generator r, up to a maximum distance of step_size:
void stepFunc(const gsl_rng * r, void *xp, double step_size) {
  possibleSunInfo oldX = *((possibleSunInfo *) xp);
  possibleSunInfo newX;

  double u = gsl_rng_uniform(r);
  newX.ra = u * 2 * step_size - step_size + oldX.ra;
  newX.dec = u * 2 * step_size - step_size + oldX.dec;

  newX.ra = newX.ra >= 0 ? newX.ra : 0;
  newX.ra = newX.ra <= 360 ? newX.ra : 360;
  newX.dec = newX.dec >= -90 ? newX.dec : -90;
  newX.dec = newX.dec <= 90 ? newX.dec : 90;

  printFunc(&newX);

  memcpy(xp, &newX, sizeof(newX));
}




void SimulatedAnnealing::estimateSourcePositionSA() {
    const gsl_rng_type * T;
    gsl_rng * r;

    possibleSunInfo initial;
    initial.ra = 160;
    initial.dec = -20;

    gsl_rng_env_setup();

    T = gsl_rng_default;
    r = gsl_rng_alloc(T);

    gsl_siman_solve(r, &initial, energyFunc, stepFunc, metricFunc, printFunc,
                  NULL, NULL, NULL,
                  sizeof(possibleSunInfo), params);

    gsl_rng_free (r);
}


















// double heuristic (int x, int y) {
//     return x + y;
// }

// void printPossibleSunInfo(possibleSunInfo l) {
//     cout << l.ra << " " << l.dec << " " << l.coefficient << endl;
// }

// void printVector(const vector<possibleSunInfo>& vec) {
//     cout << "Neighbours:" << endl;
// 	for (unsigned int i = 0; i < vec.size(); ++i) {
//        cout << "   ";
//        printPossibleSunInfo(vec[i]);
//     }
// }

// void writeToFileForOutput(possibleSunInfo candidate, string filename) {
// 	string data = "echo \"" + to_string(candidate.ra) + " " + to_string(candidate.dec) + " " + to_string(candidate.coefficient) + "\"";
// 	string command = data + " >> " + filename;
// 	// cout << command << endl;
// 	system(command.c_str());
// }

// vector<possibleSunInfo> getLocalNeighboursList(possibleSunInfo current, FortranController& fortranController) {
//     vector<possibleSunInfo> locals = vector<possibleSunInfo>();
//     //Considering some possibleSunInfos multiple times
//     for (double ra = current.ra - 2; ra <= current.ra + 2; ra += 1) {
//         for (double dec = current.dec - 2; dec <= current.dec + 2; dec += 1) {
//         	if (current.ra != ra and current.dec != dec) {
// 	        	possibleSunInfo psi;
// 	        	psi.ra = ra;
// 	        	psi.dec = dec;
// 	        	psi.coefficient = fortranController.computeCorrelation(&ra, &dec);
// 	        	writeToFileForOutput(psi, "hillClimbingAll.out");
// 	            locals.push_back(psi);
// 	        }
//         }
//     }
//     return locals;
// }

// possibleSunInfo getBestCandidate(vector<possibleSunInfo> candidates) {
//     possibleSunInfo maxCandidate;
//     double maxCoefficient = -1;
//     for (unsigned int i = 0; i < candidates.size(); ++i) {
//         if (candidates[i].coefficient > maxCoefficient) {
//             maxCoefficient = candidates[i].coefficient;
//             maxCandidate = candidates[i];
//         }
//     }
//     // printpossibleSunInfoInfo(maxCandidate);
//     return maxCandidate;
// }

// void SimulatedAnnealing::estimateSourcePosition() {
//     string command = "rm hillClimbingPath.out & rm hillClimbingAll.out";
//     system(command.c_str());
//     FortranController fortranController;
//     fortranController.resetConsideredLocations();
//     possibleSunInfo current;// = make_pair(122, -20);
//     // current.ra = 100;
//     // current.dec = -60;
//     current.ra = 160;
//     current.dec = -20;
//     current.coefficient = fortranController.computeCorrelation(&current.ra, &current.dec);
//     possibleSunInfo best;// = make_pair(-1, -1);
//     int i = 0;
//     while (++i < 100) {
//         cout << "Current: ";
//         printPossibleSunInfo(current);
//         vector<possibleSunInfo> candidates = getLocalNeighboursList(current, fortranController);
//         printVector(candidates);
//         possibleSunInfo newCandidate = getBestCandidate(candidates);
//         if (newCandidate < current) {
//             // current = newCandidate;
//             cout << "Can't progress" << endl;
//             break;
//         }
//         current = newCandidate;
//         writeToFileForOutput(current, "hillClimbingPath.out");
//         // cout << "Current -> ";
//         // printPossibleSunInfo(current);
//     }
//     fortranController.printNumberOfConsideredLocations();
//     cout << "Best: ";
//     printPossibleSunInfo(current);
// }