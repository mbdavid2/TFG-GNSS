from bs4 import BeautifulSoup
import urllib.request
import subprocess
import math

def loadContentSwift():
	## Get page ##
	url = "https://swift.gsfc.nasa.gov/archive/grb_table.html/quickview/"
	response = urllib.request.urlopen(url)
	page = response.read()

	## Parse it ##
	soup = BeautifulSoup(page, 'html.parser')
	# print(soup)
	return soup

def prettyPrintList(listToPrint):
	#print(["Name", "TotalScore", "[Year, Month, Day, DecTime]", "dotProduct", "Ra", "Dec", "SunRa", "SunDec", "UVOT", "BAT"])
	print("Name Ra Dec UVOT BAT Date Angle Score")
	listToPrint.pop()
	for x in listToPrint:
		date = str(x[2][0]) + " " + str(x[2][1]) + " " + str(x[2][2]) + " " + str(x[2][3])
		print(x[0], x[4], x[5], x[8], x[9], date, x[3], x[1])

def traverseTableAndSort(soup, sort):
	listGRBs = [["Name", 0, "Date", 0, "Ra", "Dec", "SunRa", "SunDec", "UVOT magnitude", "BAT fluence"]]
	table_body = soup.find('table', attrs={'class':'grbtable'})
	rows = table_body.find_all('tr')
	for row in rows:
		cols = row.find_all('td')
		cols = [ele.text.strip() for ele in cols]
		oneGRB = [ele for ele in cols if ele]
		if oneGRB:
			infoGRB = computeNecessaryInfo(oneGRB)
			insertNewGRB(listGRBs, infoGRB, sort)
	return listGRBs

def computeNecessaryInfo(dataGRB):
	# Gregorian date
	date = dataGRB[0]
	year = "20" + date[0:2]
	month = date[2:4]
	day = date[4:6]

	# UT Time
	time = dataGRB[1]
	decTime = int(time[0:2]) + int(time[3:5])/60

	date = [year, month, day, decTime]

	# BAT RA, "clean" the number
	ra = dataGRB[3]
	if (ra[0] == "n"):
		newRA = 0
	else:
		ra = (ra.split(":")[0])
		newRA = float(ra[0:len(ra)-2])

	# BAT Dec, "clean" the number
	dec = dataGRB[4]
	if (dec[0] == "n"):
		newDec = 0
	else:
		dec = (dec.split(":")[0])
		if (dec[0] == "-"):
			newDec = float(dec[0:len(dec)-3])
		else:
			newDec = float(dec[0:len(dec)-2])
		
	# Compute the position of the sun at this date
	sunPosition = planetsV2(year, month, day, decTime)

	# Compare the results of the sun to those of the burst, dotProduct
	scorePos = scorePosition([sunPosition[0], sunPosition[1], newRA, newDec])

	# Take into consideration the "power" as well
	scorePow = scorePower(dataGRB[14], dataGRB[6])

	# Function to calculate power: add both¿?¿ (if we multiply sometimes = 0)
	totalScore = scorePos + scorePow

	# Return score and parameters
	result = [dataGRB[0], totalScore, date, scorePos, newRA, newDec, sunPosition[0], sunPosition[1], dataGRB[14], dataGRB[6]]
	# print(result)
	return result

def scorePower(magnitudeUVOT, fluenceBAT):
	# Clean both parameters (strings) and equal to 0 if n/a
	if magnitudeUVOT[0] != "n":
		magnitudeUVOT = float((magnitudeUVOT)[2:len(magnitudeUVOT)-1])
	else:
		magnitudeUVOT = 0

	if fluenceBAT[0] == "n":
		fluenceBAT = 0
	else:
		fluenceBAT = float(fluenceBAT)

	# Order by magnitudeUVOT, if nonexistent, order by fluenceBAT
	# print(magnitudeUVOT, fluenceBAT)
	if magnitudeUVOT != 0:
		return magnitudeUVOT
	else:
		return fluenceBAT
	
	# Another possibility: combination of both:
	# return magnitudeUVOT + fluenceBAT
	
def scorePosition(listOfCoords):
	# If Ra and/or Dec are n/a, return 0, else, compute the dotProduct
	if listOfCoords[2] == 0 or listOfCoords[3] == 0:
		return 0

	# [sunRa, sunDec, grbRa, grbDec] -> all to radian
	coords = list(map((lambda degree: degree*math.pi/180), listOfCoords))

	coordSun = [math.cos(coords[1])*math.cos(coords[0]), math.cos(coords[1])*math.sin(coords[0]), math.sin(coords[1])]
	coordGRB = [math.cos(coords[3])*math.cos(coords[2]), math.cos(coords[3])*math.sin(coords[2]), math.sin(coords[3])]

	angle = math.acos(coordSun[0]*coordGRB[0] + coordSun[1]*coordGRB[1] + coordSun[2]*coordGRB[2])
	angle = angle*180/math.pi

	return angle

def planetsV2(year, month, day, decTime):
	bashCommand = ("echo \"" 
				+ year + " " 
				+ month + " " 
				+ day + " " 
				+ str(decTime) + " "
				+ "0 0 Sun\""
				+ " | ./a.out")
	results = subprocess.check_output(bashCommand, shell=True)
	results = results.split()[0:2]
	results = list(map(float, results))
	return results
	
def insertNewGRB(listGRBs, newEle, sort):
	# print(newEle)
	for index, elem in enumerate(listGRBs):
		# print(elem)
		if sort == 0:
			if elem[1] <= newEle[1]:
				listGRBs.insert(index,newEle)
				break
		else:
			if elem[3] <= newEle[3]:
				listGRBs.insert(index,newEle)
				break
		if index == len(listGRBs)-1:
			listGRBs.insert(index,newEle)
			break
	
def main():
	ans = input("Sort only by angle? [y/n]: ")
	if ans == "y" or ans == "Y":
		sort = 1
	else:
		sort = 0
	soup = loadContentSwift()
	listGRBs = traverseTableAndSort(soup, sort)
	prettyPrintList(listGRBs)
	## TODO: Automatically write it to ../results/ when we're sure it works properly
	## TODO: remove log file created by planets_v2 script
main()
