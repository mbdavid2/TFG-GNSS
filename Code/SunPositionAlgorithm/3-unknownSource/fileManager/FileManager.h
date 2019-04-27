#ifndef FILEMANAGER_H
#define FILEMANAGER_H
#include <iostream>
#include "../auxiliary/auxiliary.h"

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

		void filterTiFileByTime(double time);

		void filterTiFileByBasicData();

		string getFilteredFile();
};

#endif






