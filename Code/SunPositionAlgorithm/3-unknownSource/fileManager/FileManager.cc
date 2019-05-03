#include <iostream>
#include <iomanip>
#include <sstream>
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

void FileManager::filterTiFileByTime(double time) {
    if (filteredFile == "" || filterTimeAWKScript == "") {
        cout << "[ERROR] Input files not set properly (2) " << endl;
        exit(0);
    }
    string outputFile = "filteredByTime.out"; //Name used in Fortran compute correlation file
    stringstream stream;
    stream << fixed << setprecision(13) << time;
    string timeS = stream.str();
	string command = "cat " + filteredFile + " | gawk -f " + filterTimeAWKScript + " -v flareTime=" + timeS + " > " + outputFile;
	system(command.c_str()); 
}

string FileManager::getFilteredFile() {
    return filteredFile;
}

