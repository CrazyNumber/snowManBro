runScriptFile("gameResource/script/objBase")
gameFight = objBase:extend(
{
	monsterArray = {},
	roelArray = {},
	leftArray = {},
	rightArray = {},
	allEntityIndex = {},
}
)
function gameFight:init()

end
function gameFight:instance()
	if self.initFlag == nil then
		self:init()
		self.initFlag = true
	end
	return self
end
function gameFight:generateMonsterArray()
	local sceneConfig = configReader:instance():getSceneConfigById(gameScene:instance().currentSceneId)
	if sceneConfig == nil then 
		error("gameFight:generateMonsterArray") 
		return 
	end
	local count = math.random(6)
	count = math.random(6)
	if count == 0 then
		count = 1
	end
	local monsterIdTable = configReader:instance():getRoleIdBySceneId(gameScene:instance().currentSceneId)
	local randomNumber = #monsterIdTable
	local monsterArrayTable = {}
	for i = 1,count do
		local number = math.random(randomNumber)
		number = math.random(randomNumber)
		table.insert(monsterArrayTable,monsterIdTable[number])
	end
	return monsterArrayTable
end
function gameFight:generateRoleArray()
	local roleTable = {}
	table.insert(roleTable,globalGameEnum.mainRoleId)
	return roleTable
end
function gameFight:initAllPos()
	--先添加怪物
	local function initFightData(entity)
		local roleConfig = configReader:instance():getRoleConfigById(entity.roleId)
		if roleConfig == nil then
			error("initFightData(entity) config nil")
			return
		end
		entity.physicsAttack = roleConfig.physicsAttack
		entity.magicAttack = roleConfig.magicAttack
		entity.hp = roleConfig.hp
		entity.physicsDefence = roleConfig.physicsDefence
		entity.magicDefence = roleConfig.magicDefence
		entity.attackValueRange = roleConfig.attackValueRange
		entity.defenceValueRange = roleConfig.defenceValueRange
		entity.critChance = roleConfig.critChance
		entity.lowersChance = roleConfig.lowersChance
	end
	local function getStartPoint(count,height,distance)
		local tempSize = height * count + distance * (count - 1)
		local intHalfSize = globalFunction.getIntPart(tempSize/2)
		return globalFunction.getIntPart(tempSize/2) - globalFunction.getIntPart(globalGameEnum.winHeight/2)
	end
	self.leftArray = {}
	self.rightArray = {}
	self.allEntityIndex = {}
	local gridHeight = 60
	local gridDistance = 5
	local leftArrayCount = getTableSize(self.monsterArray)
	local leftStartX = 50,leftStartY = getStartPoint(leftArrayCount,gridHeight,gridDistance)
	for i,v in pairs(self.monsterArray) do
		local entity = entityManager:addEntity(v)
		entity:setPosition(leftStartX,(leftStartY + (i - 1) * gridHeight + (i - 1) * gridDistance))
		entity:setMotionAndDirection(globalGameEnum.MOTION_ALERT,"forever",true,globalGameEnum.DIRECTION_RIGHTBOTTOM)
		initFightData(entity)
		table.insert(self.leftArray,entity)
		table.insert(self.allEntityIndex,entity.entityGuid)
	end
	local rightArrayCount = getTableSize(self.roelArray)
	local rightStartX = 350,rightStartY = getStartPoint(rightArrayCount,gridHeight,gridDistance)
	for i,v in pairs(self.roelArray) do
		local entity = entityManager:addEntity(v)
		entity:setPosition(rightStartX,(rightStartY + (i - 1) * gridHeight + (i - 1) * gridDistance))
		entity:setMotionAndDirection(globalGameEnum.MOTION_ALERT,"forever",true,globalGameEnum.DIRECTION_LEFTTOP)
		initFightData(entity)
		table.insert(self.rightArray,entity)
		table.insert(self.allEntityIndex,entity.entityGuid)
	end
end
function gameFight:startFight()
	local function ajustTableByDeleteKey(ajustTable,key)
		local count = getTableSize(ajustTable)
		for i = key,(count - 1) do
			ajustTable[key] = ajustTable[key + 1]
		end
		ajustTable[count] = nil
	end
	local function checkFightEnd()
	end
	--当前回合数的所有实体都参与计算
	local tempEntityIndexTable = copyTable(self.allEntityIndex)
	while checkFightEnd() do
		while getTableSize(tempEntityIndexTable) > 0 do
			local random = math.random(getTableSize(tempEntityIndexTable))
			ajustTableByDeleteKey(tempEntityIndexTable,random)
			local entity = entityManager:getEntityByGuid(random)

		end
	end
end

function gameFight:onEnter()
	gameScene:instance().tempNormalLayer:setVisible(false)
	gameScene:instance().tempFightLayer:setVisible(true)
	--local x,y = gameScene:instance().mainRoleEntity:getPosition()
	--gameScene:instance():setMainRolePos(x,y)
	local x,y = gameScene:instance().back:getPosition()
	local tempLayer = gameScene:instance().tempFightLayer
	tempLayer:setPosition(ccp(-x,-y))
	self.bg = CCSprite:create("gameResource/gameImageResource/scene/fightBack.png")
	self.bg:setAnchorPoint(ccp(0.0,0.0))
	self.bg:setScaleX(480/640)
	self.bg:setScaleY(320/480)
	tempLayer:addChild(self.bg)
	self.monsterArray = self:generateMonsterArray()
	self.roelArray = self:generateRoleArray()
	self:initAllPos()
	self:startFight()
end
function gameFight:onExit()
	gameScene:instance().tempNormalLayer:setVisible(true)
	gameScene:instance().tempFightLayer:setVisible(false)
	gameScene:instance():sceneChangePosHeartBeat()
	gameScene:instance().sceneState = 0
end