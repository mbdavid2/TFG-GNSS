#include <iostream>
#include <iomanip>
#include <sstream>
#include <fstream>
#include "FileManager.h"
#include "../auxiliary/Auxiliary.h"

using namespace std;

const string DATA_FOLDER = "../data/";

void FileManager::setAWKScripts(string filterBasic, string filterTime) {
    filterBasicAWKScript = DATA_FOLDER + filterBasic;
    filterTimeAWKScript = DATA_FOLDER + filterTime;
}

void FileManager::setInputFile(string file) {
    inputFile = DATA_FOLDER + file;
    filteredFile = DATA_FOLDER + "filter_" + file + ".out";
}

void FileManager::filterTiFileByBasicData() {
    if (filteredFile == "" || filterBasicAWKScript == "") {
        cout << "[ERROR] Input files not set properly (1) " << endl;
        exit(0);
    }
    string zcat = "zcat " + inputFile;
    string gawk = " | gawk -f " + filterBasicAWKScript + " > " + filteredFile;
	string command = zcat + gawk;
	system(command.c_str()); 
}

void FileManager::filterUsingAwk(double time) {
    string outputFile = "filteredByTime.out"; //Name used in Fortran compute correlation file
    stringstream stream;
    stream << fixed << setprecision(13) << time;
    string timeS = stream.str();
	string command = "cat " + filteredFile + " | gawk -f " + filterTimeAWKScript + " -v flareTime=" + timeS + " > " + outputFile;
	system(command.c_str()); 
}

int FileManager::filterTiFileByTime(double time) {
    string outputFile = "filteredByTime.out"; //Name used in Fortran compute correlation file
    if (filteredFile == "" || filterTimeAWKScript == "") {
        cout << "[ERROR] Input files not set properly (2) " << endl;
        exit(0);
    } 

    ifstream inputData;
    ofstream writeData;
    double epochIn, vtecIn, raIPPIn, latIPPIn;
    int i = 0;

    inputData.open(filteredFile, ifstream::in);
    writeData.open(outputFile, ifstream::trunc);

    inputData >> epochIn >> vtecIn >> raIPPIn >> latIPPIn;
	while (inputData >> epochIn >> vtecIn >> raIPPIn >> latIPPIn) {
        if (epochIn == time) {
            i++;
            writeData << " " << vtecIn << " " << raIPPIn << " " << latIPPIn << endl;
        }
    }

    inputData.close();
    writeData.close();
    return i; 
}  

void FileManager::discardOutliersLinearFitFortran(int sigma, int iterations) {
    string executeLinearFit = "cat cosineData.out | ./linearFit.x " + to_string(sigma) + " " + to_string(iterations) + " > resultsFitted";
    string filterOutliers = "cat resultsFitted | gawk -e '{/a/; if ($6 == \"T\") {print $1 \" \" $2}}' > cosineDataFitted.out";
    system(executeLinearFit.c_str());
    system(filterOutliers.c_str());
}

string FileManager::getFilteredFile() {
    return filteredFile;
}

