#ifndef RESULTSDEBUGGER_H
#define RESULTSDEBUGGER_H
#include <iostream>
#include <queue>
#include "../auxiliary/Auxiliary.h"

using namespace std;

class ResultsDebugger {

	private:
        

	public:
		void plotResults(priority_queue<possibleSunInfo>& bestSuns);

		void plotIPPsRaDecVTEC();

		void plotSunsRaDecCoefInterpolate();

		void plotSunsRaDecCoef();
};

#endif




