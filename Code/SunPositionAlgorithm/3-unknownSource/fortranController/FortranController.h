#ifndef FORTRANCONTROLLER_H
#define FORTRANCONTROLLER_H
#include <queue>
#include "../auxiliary/Auxiliary.h"

using namespace std;

class FortranController {

	private:
		

	public:
        void hillClimbing();

        double computeCorrelation(double* ra, double* dec);

        double leastSquares(priority_queue<infoIPP> bestIPPs);
};

#endif