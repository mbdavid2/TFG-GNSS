#include <iostream>
#include "FileManager.h"
#include "../auxiliary/auxiliary.h"

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
    string outputFile = "spikeData.out";
	string command = "cat " + filteredFile + " | gawk -f " + filterTimeAWKScript + " -v flareTime=" + to_string(time) + " > " + outputFile;
	system(command.c_str()); 
}

string FileManager::getFilteredFile() {
    return filteredFile;
}

