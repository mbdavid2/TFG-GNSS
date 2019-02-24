from bs4 import BeautifulSoup
import urllib.request
import subprocess

listGRBs = []
sortedGRBs = []

def loadContent():
	## Get page ##
	url = "https://swift.gsfc.nasa.gov/archive/grb_table.html/quickview/"
	response = urllib.request.urlopen(url)
	page = response.read()

	## Parse it ##
	soup = BeautifulSoup(page, 'html.parser')
	# print(soup)
	return soup

def printList():
	print("newRA	||	newDec	||	totalDifference")
	for x in listGRBs:
		print(x)

def traverseTable(soup):
	global listGRBs
	table_body = soup.find('table', attrs={'class':'grbtable'})
	rows = table_body.find_all('tr')
	for row in rows:
		cols = row.find_all('td')
		cols = [ele.text.strip() for ele in cols]
		oneGRB = [ele for ele in cols if ele]
		if oneGRB:
			infoGRB = computeNecessaryInfo(oneGRB[0:7])
			listGRBs.append(infoGRB) # Only the necessary data for each GRB¿?¿?¿
	listGRBs = listGRBs[0:4]
	printList()
	
	# print(listGRBs[1][3], listGRBs[2][3])

def computeNecessaryInfo(dataGRB):
	# Gregorian date
	date = dataGRB[0]
	year = "20" + date[0:2]
	month = date[2:4]
	day = date[4:6]
	date = [year, month, day]

	# UT Time
	time = dataGRB[1]
	decTime = int(time[0:2]) + int(time[3:5])/60

	# BAT RA, "clean" the number
	ra = dataGRB[3]
	if (ra[0] == "n"):
		return 0
	ra = (ra.split(":")[0])
	newRA = float(ra[0:len(ra)-2])

	# BAT Dec, "clean" the number
	dec = dataGRB[4]
	if (dec[0] == "n"):
		return 0
	dec = (dec.split(":")[0])
	if (dec[0] == "-"):
		newDec = float(dec[0:len(dec)-3])
		# print("Alert!",)
	else:
		newDec = float(dec[0:len(dec)-2])
		

	# Compute the position of the sun at this date
	sunPosition = planetsV2(year, month, day, decTime)

	# Compare the results of the sun to those of the burst
	difRA = abs(sunPosition[0] - newRA)
	difDec = abs(sunPosition[1] - newDec)
	totalDifference = difRA + difDec

	# Take into consideration the "power" as well

	# it shouldn't return "results", first 
	return [newRA, newDec, totalDifference]

def planetsV2(year, month, day, decTime):
	# bashCommand = 'echo "test1" "test2" "test3" > output.file'
	# process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
	# output, error = process.communicate()
	results = [238, 45, 23]
	return results

def isBetter(newElem, elem):
	"""Returns true if newElem is better than elem"""
	if not elem:
		return True
	info = 0
	results = runPlanetsV2(info)

	# Results is the angle with the Sun, newElem[]
	



def sortingFunction(array, newEle):
	for index, elem in enumerate(array):
		if isBetter(newElem, elem):
			array.insert(index,newEle)
			break
	return array
	
def main():
	soup = loadContent()
	traverseTable(soup)
	# print(listGRBs)

	for newGRB in listGRBs:
		sortingFunction(sortedGRBs, newGRB)



main()
