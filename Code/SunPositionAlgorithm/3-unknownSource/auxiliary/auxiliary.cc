#include <iostream>
#include "auxiliary.h"

bool operator<(possibleSunInfo a, possibleSunInfo b) { 
	return a.coefficient < b.coefficient ? true : false; 
}