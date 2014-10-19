runScriptFile("gameResource/script/objBase")
configReader = objBase:extend(
{

}
)
function print_table(tableRoot)
	for i,v in pairs(tableRoot) do
		CCLuaLog("" .. i .. ":" .. v)
	end
end
function getTableSize(tableRoot)
	local count = 0
	for i,v in pairs(tableRoot) do
		count = count + 1
	end
	return count
end
function copyTable(beCopy)
	local tempTable = {}
	for i,v in pairs(beCopy) do
		if type(v) == "table" then
			tempTable[i] = copyTable(v)
		else
			tempTable[i] = v
		end
	end
	return tempTable
end
function sleep(timeInSeconds)
	local currentTime = os.clock()
	while true do
		
	end
end
function configReader:init()
	self:loadRoleConfigTable("gameResource/gameConfig/roleConfigTable.ddsc")
	self:loadResourceConfigTable("gameResource/gameConfig/resourceConfigTable.ddsc")
	self:loadSceneConfigTable("gameResource/gameConfig/sceneConfigTable.ddsc")
end
function configReader:instance()
	if self.initFlag == nil then
		self:init()
		self.initFlag = true
	end
	return self
end
function configReader:loadPublicCode(filePath,mapName,helpFunction)
	local tempFileData = CCFileUtils:sharedFileUtils():getFileData(filePath)
	if tempFileData == nil then
		error("\nconnot open file " .. filePath)
		return
	end
	local tempTable = {}
	local maxLen = string.len(tempFileData)
	local currentLen = 1
	while currentLen < maxLen do
		local onceTable = {}
		for i,v in pairs(mapName) do
			local startPoint,_ = string.find(tempFileData,"|",currentLen)
			if startPoint == nil then
				currentLen = maxLen
				break
			end
			local tempResult = nil
			if v[2] == "int" then
				tempResult = tonumber(string.sub(tempFileData,currentLen,(startPoint - 1)))
			elseif v[2] == "string" then
				tempResult = tostring(string.sub(tempFileData,currentLen,(startPoint - 1)))
			elseif v[2] == "enum" then
				tempResult = self:globalEnumMap(string.sub(tempFileData,currentLen,(startPoint - 1)))
			else
				error("\nunknow type")
			end
			currentLen = startPoint + 1
			onceTable[v[1]] = tempResult
		end
		if getTableSize(onceTable) ~= 0 then
			tempTable[helpFunction(onceTable)] = (onceTable)
		end
	end
	return tempTable
end
function configReader:globalEnumMap(beConvert)
	local mapTable = {
		["主角"] = globalGameEnum.CONFIGREADER_ENUM_MAINROLE,
		["召唤兽"] = globalGameEnum.CONFIGREADER_ENUM_NOROLE,
		["白色"] = globalGameEnum.CONFIGREADER_ENUM_WHITE,
		["绿色"] = globalGameEnum.CONFIGREADER_ENUM_GREEN,
		["蓝色"] = globalGameEnum.CONFIGREADER_ENUM_BLUE,
		["紫色"] = globalGameEnum.CONFIGREADER_ENUM_PURPLE,
		["金色"] = globalGameEnum.CONFIGREADER_ENUM_GOLD,
		["明雷"] = globalGameEnum.CONFIGREADER_SCENE_CANSEE,
		["暗雷"] = globalGameEnum.CONFIGREADER_SCENE_CANNOTSEE,
	}
	return mapTable[beConvert]
end
function configReader:loadRoleConfigTable(filePath)
	local function helpFunction(once)
		if getTableSize(once) == 0 then
			return -1
		end
		return once["roleId"]
	end
	local mapName = {
		{"roleId","int"}, 
		{"type","enum"}, 
		{"resourceId","int"}, 
		{"roleName","string"},  
		{"roleColorQuality","enum"},  
		{"physicsAttack","int"},  
		{"magicAttack","int"}, 
		{"hp","int"}, 
		{"physicsDefence","int"}, 
		{"magicDefence","int"}, 
		{"attackValueRange","int"}, 
		{"defenceValueRange","int"}, 
		{"critChance","int"}, 
		{"lowersChance","int"},  
		{"dropChance","int"},  
		{"appearSceneId","int"}, 
	}
	self.roleTableConfig = {}
	self.roleTableConfig = self:loadPublicCode(filePath,mapName,helpFunction)
end
function configReader:getRoleByType(getType)
	local tempTable = {}
	for i,v in pairs(self.roleTableConfig) do
		if v.type == getType then
			table.insert(tempTable,v)
		end
	end
	return tempTable
end
function configReader:getRoleIdBySceneId(sceneId)
	local tempTable = {}
	for i,v in pairs(self.roleTableConfig) do
		if v.appearSceneId == sceneId then
			table.insert(tempTable,v)
		end
	end
	return tempTable
end
function configReader:getRoleConfigById(roleId)
	return self.roleTableConfig[roleId]
end
function configReader:loadResourceConfigTable(filePath)
	local function helpFunction(once)
		if getTableSize(once) == 0 then
			return -1
		end
		return once["resourceId"]
	end
	local mapName = {
		{"resourceId","int"}, 
		{"resourcePath","string"}, 
	}
	self.resourceConfigTable = {}
	self.resourceConfigTable = self:loadPublicCode(filePath,mapName,helpFunction)
end
function configReader:getResourceConfigById(resourceId)
	return self.resourceConfigTable[resourceId]
end
function configReader:loadSceneConfigTable(filePath)
	local function helpFunction(once)
		local function getDataInFlag(str,flag,...)
			local arg = {...}
			local pointStart = 1
			local pointEnd = 1
			local count = 1
			local tempTable = {}
			--while pointStart ~= nil and pointStart <= string.len(str) do
				pointStart,pointEnd = string.find(str,flag,pointStart)
				if pointStart == nil then
					return tempTable
				end
				CCLuaLog(str)
				CCLuaLog(tonumber(string.sub(str,1,pointStart - 1)) .. "1")
				tempTable[arg[count]] = tonumber(string.sub(str,1,pointStart - 1))
				count = count + 1
				CCLuaLog(string.sub(str,pointStart + 1,string.len(str)) .. "2")
				tempTable[arg[count]] = tonumber(string.sub(str,pointStart + 1,string.len(str)))
				count = count + 1
			--end
			return tempTable
		end
		if getTableSize(once) == 0 then
			return -1
		end
		--[[
		local size = {}
		local pointStart,pointEnd = string.find(once["sceneSize"],",")
		if pointStart == 1 or pointEnd == string.len(once["sceneSize"]) then
			error("loadSceneConfigTable:string.find(once['sceneSize'],',')")
		end
		size.width = tonumber(string.sub(once["sceneSize"],1,pointStart - 1))
		size.height = tonumber(string.sub(once["sceneSize"],pointStart + 1,string.len(once["sceneSize"])))
		]]
		once["sceneSize"] = getDataInFlag(once["sceneSize"],",","width","height")
		once["sceneOutPos"] = getDataInFlag(once["sceneOutPos"],",","x","y")
		return once["sceneId"]
	end
	local mapName = {
		{"sceneId","int"}, 
		{"sceneName","string"}, 
		{"sceneResourcePath","string"}, 
		{"sceneOutPos","string"}, 
		{"sceneSize","string"}, --table
		{"hitMonsterChance","int"}, 
		{"sceneMonsterType","enum"}, 
		{"outPointToSceneId","int"}, 
	}
	self.sceneConfigTable = {}
	self.sceneConfigTable = self:loadPublicCode(filePath,mapName,helpFunction)
end
function configReader:getSceneConfigById(sceneId)
	return self.sceneConfigTable[sceneId]
end