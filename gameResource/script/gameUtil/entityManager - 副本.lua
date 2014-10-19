runScriptFile("gameResource/script/objBase")
wasEntity = objBase:extend(
{

}
)
function wasEntity:new()
	local o = {}
	setmetatable(o,self)
	self.__index = self
	o:init()
	return o
end
function wasEntity:init()
	self.roleId = 0
	self.entityType = nil
	--fight data
	self.entityName = ""
	self.entityColorQuality = nil
	self.physicsAttack = 0
	self.magicAttack = 0
	self.hp = 0
	self.physicsDefence = 0
	self.magicDefence = 0
	self.attackValueRange = 0
	self.defenceValueRange = 0
	self.critChance = 0
	self.lowersCritChance = 0

	self.realObject = nil
	self.actionTable = {}

	self.entityGuid = nil
	self.recordChildTable = {}
end
function wasEntity:setMotionAndDirection(motionCode,playType,renderNow,directionCode)
	if self.realObject ~= nil then
		self.realObject:setCurrentMotion(motionCode,playType,renderNow)
		self.realObject:setDirectionCode(directionCode)
		self.currentMotion = motionCode
		self.directionCode = directionCode
		for i,v in pairs(self.recordChildTable) do
			v:setMotionAndDirection(motionCode,playType,renderNow,directionCode)
		end
	end
end
function wasEntity:addToLayer(layer,zOrder)
	if self.realObject ~= nil and layer ~= nil then
		local tempZOrder = 0
		if zOrder ~= nil then
			tempZOrder = zOrder
		end
		layer:addChild(self.realObject,zOrder)
	end
end
function wasEntity:setPosition(newX,newY)
	if self.realObject ~= nil then 
		self.realObject:setPosition(CCPointMake(newX,newY))
	end
end
function wasEntity:setAnchor(anchorX,anchorY)
	if self.realObject ~= nil then
		self.realObject:setAnchorPoint(CCPointMake(anchorX,anchorY))
	end
end
function wasEntity:getPosition()
	if self.realObject ~= nil then
		return self.realObject:getPosition()
	end
end
function wasEntity:setInterval(interval)
	if self.realObject ~= nil then
		self.realObject:setInterval(interval)
	end
end
function wasEntity:moveTo(newX,newY,takeSecond,callBackFunction)
	if self.realObject ~= nil then
		if self.runingMoveAction ~= nil then
			self.realObject:stopAction(self.runingMoveAction)
			self.runingMoveAction = nil
		end
		local x,y = self.realObject:getPosition()
		if callBackFunction == nil then
			self.runingMoveAction = self.realObject:runAction(CCMoveTo:create(takeSecond, ccp(( newX), (newY))))
		else
			self.runingMoveAction = self.realObject:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(takeSecond, ccp((newX), (newY)), CCCallFunc:create(callBackFunction))))
		end
	end
end

function wasEntity:moveToBySpeedInSeconds(newX,newY,speedInSeconds,callBackFunction)
	local function moveDoneStanding()
		self:setMotionAndDirection(globalGameEnum.MOTION_STANDING,globalGameEnum.MotionPlayForever,true,self.directionCode)
	end
	if self.realObject ~= nil then
		self.realObject:setEntityGuid(self.entityGuid)
		if self.runingMoveAction ~= nil then
			self.realObject:stopAction(self.runingMoveAction)
		end
		local x,y = self.realObject:getPosition()
		local tempMax = math.max(math.abs(newX - x),math.abs(newY - y))
		local tempTime = tempMax/speedInSeconds
		local tempCode = self.directionCode
		self.directionCode = globalFunction.getRoleNoFightDirectionByPosAndDest(x,y,newX,newY)
		if gameScene:instance().mainRoleEntity ~= nil and gameScene:instance().mainRoleEntity.entityGuid == self.entityGuid then
			gameScene:instance():sceneChangePosHeartBeat()
		end
		if self.directionCode == nil then
			self.directionCode = tempCode
			if callBackFunction == nil then
				moveDoneStanding()
			else
				callBackFunction()
			end
		end
		if globalGameEnum.MOTION_WALK ~= self.currentMotion or self.directionCode ~= tempCode then
			self:setMotionAndDirection(globalGameEnum.MOTION_WALK,globalGameEnum.MotionPlayForever,true,self.directionCode)
		end
		if callBackFunction == nil then
			self.runingMoveAction = self.realObject:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(tempTime, ccp(newX, newY)), CCCallFuncN:create(moveDoneStanding)))
		else
			self.runingMoveAction = self.realObject:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(tempTime, ccp(newX, newY)), CCCallFuncN:create(callBackFunction)))
		end
	end
end
function wasEntity:stopMove()
	if self.runingMoveAction ~= nil then
		self.realObject:stopAction(self.runingMoveAction)
		self.runingMoveAction = nil
	end
	self:setMotionAndDirection(globalGameEnum.MOTION_STANDING,globalGameEnum.MotionPlayForever,true,self.directionCode)
end
function wasEntity:addChildEntity(id)
	local childComponent = entityManager:instance():addEntity(id)
	if childComponent ~= nil then
		self.realObject:addChild(childComponent.realObject)
		table.insert(self.recordChildTable,childComponent)
	end
end
entityManager = objBase:extend(
{
	entityGuid = 0,
}
)
function entityManager:init()
	self.entityMapTable = {}
end
function entityManager:instance()
	if self.initFlag == nil then
		self:init()
		self.initFlag = true
	end
	return self
end
function entityManager:getEntityByGuid(mapKey )
	-- body
	return self.entityMapTable[mapKey]
end

function entityManager:addEntity(roleId)
	local entityActionTable = {
		{"Hit",globalGameEnum.MOTION_HIT},
		{"Alert",globalGameEnum.MOTION_ALERT},
		{"Dead",globalGameEnum.MOTION_DEAD},
		{"Defence",globalGameEnum.MOTION_DEFENCE},
		{"Walk",globalGameEnum.MOTION_WALK},
		{"Back",globalGameEnum.MOTION_BACK},
		{"Confure",globalGameEnum.MOTION_CONFURE},
		{"Attack0",globalGameEnum.MOTION_ATTACK0},
		{"Attack1",globalGameEnum.MOTION_ATTACK1},
		{"RunTo",globalGameEnum.MOTION_RUNTO},
		{"Standing",globalGameEnum.MOTION_STANDING},
	}
	local config = configReader:instance():getRoleConfigById(roleId)
	if config == nil then 
		error("" .. roleId .. " have not role config")
	end
	local resourceConfig = configReader:instance():getResourceConfigById(config.resourceId)
	if resourceConfig == nil then 
		error("" .. config.resourceId .. " have not resource config")
	end
	local newEntity = wasEntity:new()
	self.entityMapTable[entityManager.entityGuid] = newEntity
	newEntity.entityGuid = entityManager.entityGuid
	entityManager.entityGuid = entityManager.entityGuid + 1
	
	for i,v in pairs(entityActionTable) do
		if newEntity.realObject == nil then
			newEntity.realObject = CCWasEntity:CreateWithFile(resourceConfig.resourcePath .. v[1] .. ".was",v[2],config.resourceId)
			if newEntity.realObject ~= nil then
				table.insert(newEntity.actionTable,v)
			end
		else
			if newEntity.realObject:insertComponent(resourceConfig.resourcePath .. v[1] .. ".was",v[2],config.resourceId) then
				table.insert(newEntity.actionTable,v)
			end
		end
	end
	if roleId == 100001 then
		newEntity:addChildEntity(1100021)
	elseif roleId == 100002 then
		newEntity:addChildEntity(1100022)
	end
	newEntity.roleId = roleId
	return newEntity
end