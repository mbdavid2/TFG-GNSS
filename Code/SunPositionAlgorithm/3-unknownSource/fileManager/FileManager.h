#ifndef FILEMANAGER_H
#define FILEMANAGER_H
#include <iostream>
#include "../auxiliary/Auxiliary.h"

using namespace std;

class FileManager {

	private:
		string inputFile;
		string filteredFile;
		string dataFolder;
		string filterBasicAWKScript;
		string filterTimeAWKScript;

	public:

		void setInputFile(string file);

		void setAWKScripts(string filterBasic, string filterTime);

		int filterTiFileByTime(double time);

		void filterUsingAwk(double time);

		void filterTiFileByBasicData();

		void discardOutliersLinearFitFortran(int sigma, int iterations);

		string getFilteredFile();
};

#endif






