import pickle
from time import sleep    
from selenium import webdriver
import selenium.webdriver.support.ui as ui
from selenium.webdriver.common.keys import Keys

# def login(n):
# 	print("Login page or can I proceed? (y/n)")
# 	a = input()
# 	if a == "y":
# 		print("Continue")
# 	else:
# 		if n > 5:
# 			print("Aborting...")
# 			quit()
# 		else:
# 			login(n+1)

def automatedLogin(browser):
	try:
		print("Starting automatic login")
		urlLogin = "http://winddat.aqu.cat/admin/login/auth"
		browser.get(urlLogin)
		usr = "username"
		pwd = "pass"
		usrForm = browser.find_element_by_name("j_username")
		pwdForm = browser.find_element_by_name("j_password")
		usrForm.send_keys(usr)
		pwdForm.send_keys(pwd)
		elem = browser.find_element_by_css_selector("button")
		elem.click()
		print("Automatic login succesful")
	except:
		print("Automatic login unsuccesful")


def loadLogin(browser):
	try:
		loadCookies(browser)
		browser.refresh()
	except:
		#print("No cookies saved, login required")
		automatedLogin(browser)

def getScriptOpenNewTab(linkText):
	return "window.open('" + linkText + "', 'new_window')"

def closeCurrentTab(browser):
	browser.execute_script("window.close();")

def buildImage(link, browser):
	for i in range(0, len(link)-1):
		if (link[i-1] == "w" and link[i] == "/"):
			tmpImg = "http://winddat.aqu.cat/admin/segell/core" + link[i:]
			break
	print("Link of svg:", tmpImg)
	script = getScriptOpenNewTab(tmpImg)
	browser.execute_script(script)
	sleep(1) #Just in case

def getImage(link, browser):
	print("Getting long links")
	sleep(2)
	ca = browser.find_element_by_xpath("//ul[contains(@id,down)]/li[1]/a[normalize-space(.)='ca']")
	curr = len(browser.window_handles) - 1
	browser.switch_to_window(browser.window_handles[curr])
	print(ca.get_attribute("href"))
	quit()

def getDirectImage(link, browser):
	for i in range(0, len(link)-1):
		if (link[i-1] == "w" and link[i] == "/"):
			code = link[i+1:-8]
			tmpImg = "http://winddat.aqu.cat/admin/segell/core" + link[i:]
			break
	print("Link of svg:", tmpImg) #Cat
	linkImgCa = tmpImg
	linkImgEs = tmpImg[:-2] + "es"
	linkImgEn = tmpImg[:-2] + "en"
	return [linkImgCa, linkImgEs, linkImgEn, code]

def writeHTML(images):
	code = images[3]
	# Ca
	link = "http://estudis.aqu.cat/euc/ca/estudi/" + code
	caHTML = "<a href=\"" + link + "\" target=\"_blank\"><img src=\"" + images[0] + "\"/></a>"

	# Es
	link = "http://estudis.aqu.cat/euc/es/estudi/" + code
	esHTML = "<a href=\"" + link + "\" target=\"_blank\"><img src=\"" + images[1] + "\"/></a>"

	# En
	link = "http://estudis.aqu.cat/euc/en/estudi/" + code
	enHTML = "<a href=\"" + link + "\" target=\"_blank\"><img src=\"" + images[2] + "\"/></a>"

	# Write contents to file
	with open('images.html', 'a') as file:
		file.write(caHTML)
		file.write('\n\n\n\n')
		file.write(esHTML)
		file.write('\n\n\n\n')
		file.write(enHTML)
		file.write('\n\n\n\n')



def singlePage(link, browser):
	script = getScriptOpenNewTab(link)
	browser.execute_script(script)
	curr = len(browser.window_handles) - 1
	browser.switch_to_window(browser.window_handles[curr])
	

	# Build and get image:
	# print("Building image for", link)
	# buildImage(link, browser)
	# browser.execute_script(script)
	# getImage(link, browser)

	print("Getting image for", link)
	images = getDirectImage(link, browser)
	writeHTML(images)
	print("Done donete with", link)
	browser.switch_to_window(browser.window_handles[curr-1])


def traverseTable(browser):
	# Load the list
	urlList = "http://winddat.aqu.cat/admin/novaAcreditacio/list"
	browser.get(urlList)
	print("Starting table traversal")

	# Traverse the elements of the table
	table = browser.find_element_by_id("taules_tb")
	rows = table.find_elements_by_tag_name("tr")
	for row in rows:
		cols = row.find_elements_by_tag_name("td")
		for col in cols:
			link = col.find_element_by_tag_name("a")
			linkText = link.get_attribute("href")
			print("Current element:", linkText)
			singlePage(linkText, browser)
			break # because only using col[0] doesn't work :/


def loadCookies(browser):
	for cookie in pickle.load(open("cookies.pkl", "rb")):
		browser.add_cookie(cookie)
	#print("Cookies loaded correctly")
   

def storeCookies(browser):
	pickle.dump(browser.get_cookies(), open("cookies.pkl","wb"))
	#print("Cookies stored correctly")

def main():
	browser = webdriver.Chrome('./chromedriver')
	loadLogin(browser)
	traverseTable(browser)
	with open('images.html', 'a') as file:
		file.seek(0)
		file.truncate()
	storeCookies(browser)
	print(input())


def testing():
	browser = webdriver.Chrome('./chromedriver')
	browser.get('https://www.google.com?q=python#q=python')
	first_result = ui.WebDriverWait(browser, 15).until(lambda browser: browser.find_element_by_class_name('rc'))
	first_link = first_result.find_element_by_tag_name('a')


	script = getScriptOpenNewTab(first_link.get_attribute("href"))
	browser.execute_script(script)


	curr = len(browser.window_handles)
	print("new tab opened, length:", curr)


	browser.switch_to_window(browser.window_handles[curr-1])
	sleep(2)
	print("Try close it")
	browser.execute_script("window.close();")

	browser.switch_to_window(browser.window_handles[curr-2])

	print("Try to open it again")
	browser.execute_script(script)
	# script = getScriptOpenNewTab(urlList)
	# browser.execute_script(script)
	sleep(8)

main()
# testing()

