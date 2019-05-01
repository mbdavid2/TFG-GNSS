#ifndef FORTRANCONTROLLER_H
#define FORTRANCONTROLLER_H

using namespace std;

class FortranController {

	private:
		

	public:
        void hillClimbing();

        double computeCorrelation(double* ra, double* dec, double* sumy, double* sumy2, int* writeData);

        double leastSquares();
};

#endif