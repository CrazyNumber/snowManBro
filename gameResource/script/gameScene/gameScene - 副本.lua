runScriptFile("gameResource/script/objBase")
gameScene = objBase:extend(
	{
		moveSize = {},
		mainRoleEntity = nil,
		npcTable = {},
		heartFunction = nil,
		moveSpeed = 150,
		heartBeatCount = 0,
	}
)
function gameScene:init()

end
function gameScene:instance()
	if self.initFlag == nil then
		self:init()
		self.initFlag = true
	end
	return self
end

function gameScene:setMainRolePos(x,y)
	local function changePos(pos,size,max)
		local temp = 0
		if pos < size then
		elseif pos > (max - size) then
			temp = max - size
		else
			temp = pos - size/2
		end
		return temp
	end
	if x > 0 and x < self.moveSize.width and y > 0 and y < self.moveSize.height then
		self.mainRoleEntity:setPosition(x,y)
		local backX = 0
		local backY = 0
		backX = changePos(x,globalGameEnum.winWidth,self.moveSize.width)
		backY = changePos(y,globalGameEnum.winHeight,self.moveSize.height)
		self.back:setPosition(CCPointMake(-backX,-backY))
	end
end

function gameScene:sceneChangePosHeartBeat()
	local function changePos(pos,size,max)
		if pos > 0 then
			return 0
		elseif pos < -(max - size) then
			return -(max - size)
		else
			return pos
		end
		return pos
	end
	if self.mainRoleEntity ~= nil then
		local x,y = self.mainRoleEntity:getPosition()
		local backX,backY = self.back:getPosition()

		local newX = globalGameEnum.winWidth/2 - x
		local newY = globalGameEnum.winHeight/2 - y
		newX = changePos(newX,globalGameEnum.winWidth,self.moveSize.width)
		newY = changePos(newY,globalGameEnum.winHeight,self.moveSize.height)
		if self.backRunAction ~= nil then
			self.back:stopAction(self.backRunAction)
			self.backRunAction = nil
		end
		self.backRunAction = self.back:runAction(CCMoveTo:create(0.5, ccp(( newX), (newY))))
		self.heartBeatCount = 0
	end
end
function gameScene:onEnter()
	local function sceneOutToHeartBeat(currentSceneId,mainRole,npcTable)
		local sceneConfig = configReader:instance():getSceneConfigById(currentSceneId)
		if sceneConfig == nil then return end
		if getTableSize(sceneConfig.sceneOutPos) == 0 then
			return
		end
		local size = 100
		local x,y = self.mainRoleEntity:getPosition()
		if x >= sceneConfig.sceneOutPos.x and x <= (sceneConfig.sceneOutPos.x + size) and y >= sceneConfig.sceneOutPos.y and y <= (sceneConfig.sceneOutPos.y + size) then
			self.currentSceneId = sceneConfig.outPointToSceneId
			sceneManager:instance():changeSceneTo(sceneManager:instance():sceneFactory(globalGameEnum.SCENE_ENUM_GAME_SCENE))
		end
	end
	local function canNotSeeMonsterHeartBeat(currentSceneId,mainRole,npcTable)
		local sceneConfig = configReader:instance():getSceneConfigById(currentSceneId)
		if sceneConfig == nil then return end
		local chance = math.random(100)
		chance = math.random(100)
		if chance <= sceneConfig.hitMonsterChance then
			self.sceneState = 1
			if self.backRunAction ~= nil then
				self.back:stopAction(self.backRunAction)
				self.backRunAction = nil
			end
			self.mainRoleEntity:stopMove()
			gameFight:instance():onEnter()
		end
	end
	local function onHeartBeat()
		if self.sceneState == 1 then
			return
		end
		if self.monsterHeartFunction ~= nil then
			self.monsterHeartFunction(self.currentSceneId,self.mainRoleEntity,self.npcTable)
		end
		if self.sceneOutPointHeartBeat ~= nil then
			self.sceneOutPointHeartBeat(self.currentSceneId,self.mainRoleEntity,self.npcTable)
		end
		if self.heartBeatCount > 5 then
			self:sceneChangePosHeartBeat()
		else
			self.heartBeatCount = self.heartBeatCount + 1
		end
	end
	local function onLayerTouch(eventType,x,y)
		local function changePos(pos,size,max)
			if pos < 0 then
				return 0
			elseif pos > max then
				return max
			else
				return pos
			end
		end
	    if eventType == "ended" then
	    	local layerX,layerY = self.back:getPosition()
	    	local tempX = changePos(-layerX + x,globalGameEnum.winWidth,self.moveSize.width)
	    	local tempY = changePos(-layerY + y,globalGameEnum.winHeight,self.moveSize.height)
	    	self.mainRoleEntity:moveToBySpeedInSeconds(tempX,tempY,self.moveSpeed)
	    end
	    return true
	end
	if globalGameEnum.mainRoleId == nil then
		return
	end
	local sceneLayer = CCScene:create()
	if sceneLayer == nil then
		return
	end
	local tempLayer = CCLayer:create()
	sceneLayer:addChild(tempLayer)
	tempLayer:setTouchMode(kCCTouchesAllAtOnce)
	tempLayer:setTouchEnabled(true)
	tempLayer:registerScriptTouchHandler(onLayerTouch)
	tempLayer:setPosition(CCPointMake(0.0,0.0))
	if self.currentSceneId == nil then
		self.currentSceneId = 50000
	end

	local sceneConfig = configReader:instance():getSceneConfigById(self.currentSceneId)
	if sceneConfig == nil then return end
	self.back = CCSprite:create(sceneConfig.sceneResourcePath)
	self.back:setAnchorPoint(CCPointMake(0.0,0.0))
	
	tempLayer:addChild(self.back,-10)
	self.back:setPosition(CCPointMake(0.0,0.0))
	local x,y = self.back:getPosition()
	self.tempNormalLayer = CCNode:create()
	self.back:addChild(self.tempNormalLayer)
	self.tempFightLayer = CCNode:create()
	self.back:addChild(self.tempFightLayer)
	--CCLuaLog("" .. x .. ":" .. y)
	self.mainRoleEntity = entityManager:addEntity(globalGameEnum.mainRoleId)
	self.mainRoleEntity:addToLayer(self.tempNormalLayer,0)
	self.mainRoleEntity:setMotionAndDirection(globalGameEnum.MOTION_STANDING,globalGameEnum.MotionPlayForever,true,globalGameEnum.DIRECTION_BOTTOM)
	self.mainRoleEntity:setInterval(0.15)
	--设置场景大小
	self.moveSize.width = sceneConfig.sceneSize.width
	self.moveSize.height = sceneConfig.sceneSize.height
	--初始化相关npc，设置主角当前位置。
	if sceneConfig.sceneMonsterType == globalGameEnum.CONFIGREADER_SCENE_CANSEE then
		--暂时不支持
	elseif sceneConfig.sceneMonsterType == globalGameEnum.CONFIGREADER_SCENE_CANNOTSEE then
		local randomX = math.random(self.moveSize.width)
		randomX = math.random(self.moveSize.width)
		local randomY = math.random(self.moveSize.height)
		randomY = math.random(self.moveSize.height)
		self:setMainRolePos(randomX,randomY)
		self.monsterHeartFunction = canNotSeeMonsterHeartBeat
		self.sceneOutPointHeartBeat = sceneOutToHeartBeat
		--添加出口
		if getTableSize(sceneConfig.sceneOutPos) ~= 0 then
			self.outPointEffect = CCWasEntity:CreateWithFile("gameResource/gameImageResource/scene/jumpScene.was",globalGameEnum.MOTION_EFFECT,1)
			self.outPointEffect:setDirectionCode(globalGameEnum.DIRECTION_EFFECT)
			self.outPointEffect:setPosition(CCPointMake(sceneConfig.sceneOutPos.x,sceneConfig.sceneOutPos.y))
			self.tempNormalLayer:addChild(self.outPointEffect)
		end
	end

	self.npcTable = configReader:instance():getRoleIdBySceneId(sceneConfig.sceneId)
	self.heartBeatId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onHeartBeat,0.1,false)
	
	--初始化相关怪物信息，获取该场景可能遇到的怪物。如果场景是明雷，则创建npc并挂接心跳，如果是暗雷，设置遇怪心跳。
	if CCDirector:sharedDirector():getRunningScene() == nil then
		CCDirector:sharedDirector():runWithScene(sceneLayer)
	else
		CCDirector:sharedDirector():replaceScene(sceneLayer)
	end
end
function gameScene:onExit()
	if self.heartBeatId ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.heartBeatId)
		self.heartBeatId = nil
	end
	self.moveSize = {}
	self.mainRoleEntity = nil
	self.npcTable = {}
	self.heartFunction = nil
	self.moveSpeed = 150
	self.heartBeatCount = 0
	self.back = nil
end