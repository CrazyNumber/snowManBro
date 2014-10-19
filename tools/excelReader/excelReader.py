#! /usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import xlrd

from xml.dom import minidom

def readXmlConfigFile(fileName):
    tempDoc = minidom.parse(fileName)
    if tempDoc == None:
        print "open file " + fileName + " error!"
        return
    generateTable = {}
    doc = tempDoc.getElementsByTagName("convertFile")[0]
    mainNodes = doc.getElementsByTagName('configStructure')
    for node in mainNodes:
        convertFileName = node.getAttribute("convertFileName")
        outFileName = node.getAttribute("outFileName")
        childNodes = node.getElementsByTagName("readColumn")
        generateTable[convertFileName] = {}
        generateTable[convertFileName]["convertFileName"] = convertFileName
        generateTable[convertFileName]["outFileName"] = outFileName
        tempTable = {}
        for childNode in childNodes:
            headName = childNode.getAttribute("headName")
            outType = childNode.getAttribute("type")
            tempTable[headName] = outType
        generateTable[convertFileName]["readColumn"] = tempTable
    return generateTable
def readOneFile(fileName,generateName,readColumnTable):
    def checkNeedRead(beCheck,table):
        for i in table:
            if i.encode("gb2312") == str(beCheck.encode("gb2312")):
                return True
        return False
    #只会读取第一个sheet的数据
    data = xlrd.open_workbook(fileName)
    if data == None:
        print "open file " + fileName + " error!"
        return
    table = data.sheets()[0]
    lineCount = table.nrows#行数
    lineElementCount = table.ncols#列数
    generateFileHandle = open(generateName,"w")
    for k in range(lineCount):
        for i in range(lineElementCount):
            lineElementTable = table.col_values(i)
            if not checkNeedRead(lineElementTable[0],readColumnTable):
                continue
            tempType = readColumnTable[lineElementTable[0]]
            if k == 0:
                break
            tempValue = lineElementTable[k]
            tempStr = None
            if tempValue == None or tempValue == '':
                tempValue = "0"
            if tempType == "string":
                #print type(tempValue)
                #print (tempValue)
                #tempValue = str(tempValue)
                if type(tempValue) == float:
                    tempValue = str(tempValue)
                tempStr = (tempValue).encode("utf-8")
            elif tempType == "int":
                tempValue = int(tempValue)
                tempStr = str(tempValue)
            elif tempType == "float":
                tempValue = float(tempValue)
                tempStr = str(tempValue)
            generateFileHandle.write(str(tempStr))
            generateFileHandle.write("|")
def generateConfigFile():
    convertTable = readXmlConfigFile("convertTable.xml")
    for oneFile in convertTable.items():
        tempOneFile = oneFile[1]
        readOneFile("../../gameExcelConfig/" + tempOneFile["convertFileName"],
                    "../../gameResource/gameConfig/" + tempOneFile["outFileName"],
                    tempOneFile["readColumn"])
generateConfigFile()
