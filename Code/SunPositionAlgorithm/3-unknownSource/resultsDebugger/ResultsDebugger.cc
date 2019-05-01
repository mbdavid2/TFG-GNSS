#include <iostream>
#include <fstream>
#include <queue>
#include "ResultsDebugger.h"
#include "../auxiliary/Auxiliary.h"

using namespace std;

void ResultsDebugger::plotResults(priority_queue<possibleSunInfo>& bestSuns) {
	ofstream plotData;
	plotData.open("gnuplot.in", ios::trunc);
	while (!bestSuns.empty()) {
		plotData << bestSuns.top().ra << " " << bestSuns.top().dec << " " << bestSuns.top().coefficient << endl;
		bestSuns.pop();
	}
	plotData.close();
	string ranges = "";//set xrange [0:360]; set yrange [-180:180];";// set zrange [-1:1];";
	string command = "gnuplot -e \"set xlabel 'Right Ascension'; set ylabel 'Declination'; set zlabel 'Coefficient'; " + ranges + " set grid; splot 'gnuplot.in' using 1:2:3 with lines; pause -1;\"";
	system(command.c_str());
}

void ResultsDebugger::plotIPPsRaDecVTEC() {
	//Esto como que no es muy interesante no? No dice nada pq son RA i DEC del IPP
	string ranges = "";//set xrange [0:360]; set yrange [-180:180];";// set zrange [-1:1];";
	string command = "gnuplot -e \"set xlabel 'Right Ascension'; set ylabel 'Declination'; set zlabel 'VTEC'; " + ranges +" set grid; splot 'spikeData.out' using 2:3:1 with point; pause -1;\"";
	system(command.c_str());
}

void ResultsDebugger::plotSunsRaDecCoefInterpolate() {
	string ranges = "set zrange [0:1];";//set xrange [0:360]; set yrange [-180:180];";// set zrange [-1:1];";
	string labels = "set xlabel 'Right Ascension'; set ylabel 'Declination'; set zlabel 'Coefficient'; ";
	string command = "gnuplot -e \"" + labels + "set hidden3d; set dgrid3d 35,35 qnorm 2; " + ranges +" set grid; splot 'gnuplot.in' using 1:2:3 with lines; pause -1;\"";
	system(command.c_str());
}

void ResultsDebugger::plotSunsRaDecCoef() {
	string ranges = "";//set xrange [0:360]; set yrange [-180:180];";// set zrange [-1:1];";
	string labels = "set xlabel 'Right Ascension'; set ylabel 'Declination'; set zlabel 'Coefficient'; ";
	string command = "gnuplot -e \"" + labels + ranges +" set grid; splot 'gnuplot.in' using 1:2:3 with points; pause -1;\"";
	system(command.c_str());
}