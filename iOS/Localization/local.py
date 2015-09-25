#coding=utf-8
import sys
import os
reload(sys)
import re
sys.setdefaultencoding('utf-8')

projectPath = "../KeeFit"
elements = []

def findLocal(path):
	# print path
	fileHandle = open(path)
	fileContent = fileHandle.read()
	allResult = re.findall(r'ArthurLocal\(@"([\w\s\'\?\.]+)"\)',fileContent)
	for localString in allResult:
		elements.append(localString)
		# print localString
	fileHandle.close()

def Traversal(rootDir): 
	for lists in os.listdir(rootDir): 
		path = os.path.join(rootDir, lists)
		if path.endswith('.m') or path.endswith('.mm') or path.endswith('.h'):
			findLocal(path)
		if os.path.isdir(path): 
			Traversal(path)

# 遍历
Traversal(projectPath)

# //去重
elements = list(set(elements))

englishElements = []
chineseElements = []

for element in elements:
	englishElements.append('"' + element + '" = "' + element + '";\n')
	chineseElements.append('"' + element + '" = "' + "Warning" + '";\n')

def writeListToFile(listOfElement, pathOfFile):
	output = open(pathOfFile, 'w')
	output.writelines(listOfElement)
	output.close()

writeListToFile(englishElements, 'local/english.string');
writeListToFile(chineseElements, 'local/chinese.string');

# content = 'self.labelOfDeviceName.text = ArthurLocal(@"Device Name"); ArthurLocal(@"Device")ArthurLocal(@"Device") \nArthurLocal(@"Device")'
# allResult = re.findall(r'ArthurLocal\(@"([\w\s]+)"\)',content)
# print allResult