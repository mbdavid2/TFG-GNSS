#include <iostream>
#include <iomanip>
#include <sstream>
#include <fstream>
#include "FileManager.h"
#include "../auxiliary/Auxiliary.h"

using namespace std;

const string DATA_FOLDER_SCRIPTS = "../data/";
const string DATA_FOLDER_TI_FILES = "../data/filteredFiles/";
// const string DATA_FOLDER_TI_FILES = "/home/mbdavid2/Documents/dataTi/";

const string SCRIPT_GET_CORRECT_LOCATION = "obtainCorrectSunPosition.awk";

bool fileExists(string fileName) {
    ifstream infile(fileName);
    return infile.good();
}

void FileManager::setAWKScripts(string filterBasic, string filterTime) {
    filterBasicAWKScript = DATA_FOLDER_SCRIPTS + filterBasic;
    filterTimeAWKScript = DATA_FOLDER_SCRIPTS + filterTime;
    if (!fileExists(filterBasicAWKScript) or !fileExists(filterTimeAWKScript)) {
        cout << endl << "ERROR: File doesn't exist: " << filterBasicAWKScript << " || " << filterTimeAWKScript << endl;
        exit(1);
    }
}

void FileManager::setInputFile(string file) {
    inputFile = DATA_FOLDER_TI_FILES + file;
    filteredFile = DATA_FOLDER_TI_FILES + "filter_" + file + ".out";
    if (!fileExists(inputFile)) {
        cout << endl << "ERROR: File doesn't exist: " << inputFile << endl;
        exit(1);
    }
}

possibleSunInfo FileManager::getCorrectSunLocation() {
    string resultGawkFilterSun = "firstLineData.out";
    //Extract first line of gz file
    string cat = "zcat " + inputFile;
    string gawk = " | gawk -f " + DATA_FOLDER_SCRIPTS + SCRIPT_GET_CORRECT_LOCATION + " -v flareTime=" + epochFlare + " > " + resultGawkFilterSun;
    // string gawk = " | gawk 'NR==1{print $47 \" \" $48}' > " + resultGawkFilterSun; //TODO: deberia cogerse solo el del tiempo que estamos estudiando
    string command = cat + gawk;
    system(command.c_str());  

    //Read first line
    ifstream inputData;
    double correctRa, correctDec;

    inputData.open(resultGawkFilterSun, ifstream::in);
    inputData >> correctRa >> correctDec;
    inputData.close();

    possibleSunInfo correctSun;
    correctSun.ra = correctRa;
    correctSun.dec = correctDec;
    return correctSun;
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
    epochFlare = stream.str();
	string command = "cat " + filteredFile + " | gawk -f " + filterTimeAWKScript + " -v flareTime=" + epochFlare + " > " + outputFile;
	system(command.c_str()); 
}

int FileManager::filterTiFileByTime(double time) {
    stringstream stream;
    stream << fixed << setprecision(13) << time;
    epochFlare = stream.str();
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

