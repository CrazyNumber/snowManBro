runScriptFile("gameResource/script/objBase")
chooseRoleScene = objBase:extend(
{
	uiJsonFile = "enterGame_1.ExportJson",
	centerPointX = 240,
	centerPointY = 160,
	incrementX = 360,
	incrementY = 80,
}
)
function chooseRoleScene:init()

end
function chooseRoleScene:instance()
	if self.initFlag == nil then
		self:init()
		self.initFlag = true
	end
	return self
end
function chooseRoleScene:onEnter()
	local function relativeEntityPos( )
		local function doneFunction(sender)
			local entityGuid = sender:getEntityGuid()
			local entity = entityManager:instance():getEntityByGuid(entityGuid)
			entity:setMotionAndDirection(globalGameEnum.MOTION_STANDING,globalGameEnum.MotionPlayForever,true,globalGameEnum.DIRECTION_BOTTOM)
		end
		local speed = 1000
		for i,v in pairs(self.beSelectTable) do
			if self.centerIndex == i then
				v:moveToBySpeedInSeconds(self.centerPointX,self.centerPointY,speed,doneFunction)
			elseif i < self.centerIndex then
				v:moveToBySpeedInSeconds(self.centerPointX - self.incrementX,self.centerPointY + self.incrementY,speed,doneFunction)
			elseif i > self.centerIndex then
				v:moveToBySpeedInSeconds(self.centerPointX + self.incrementX,self.centerPointY + self.incrementY,speed,doneFunction)
			end
		end
	end
	local function updateAllButton()
		if self.touchGroup ~= nil then
			globalFunction.setWidgetTouchEnabled(self.touchGroup,"switchLeftButton",not (self.centerIndex == 1))
			globalFunction.setWidgetTouchEnabled(self.touchGroup,"switchRightButton",not (self.centerIndex == getTableSize(self.beSelectTable)))
		end
	end
	local function onClickLeftArrow(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local flag = false
			if self.centerIndex ~= 1 then
				self.centerIndex = self.centerIndex - 1
				flag = true
			end
			if flag == true then
				relativeEntityPos()
				updateAllButton()
			end
		end
	end
	local function onClickRightArrow(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local flag = false
			if self.centerIndex < getTableSize(self.beSelectTable) then
				self.centerIndex = self.centerIndex + 1
				flag = true
			end
			if flag == true then
				relativeEntityPos()
				updateAllButton()
			end
		end
	end
	local function onEnterGame(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			sceneManager:instance():changeSceneTo(sceneManager:instance():sceneFactory(globalGameEnum.SCENE_ENUM_GAME_SCENE))
		end
	end
	local function onTouch(eventType,x,y)
        if eventType == "began" then
            self.rememberTouchBeganX = x
        elseif eventType == "ended" then
            if self.rememberTouchBeganX > x then
            	onClickLeftArrow(nil,TOUCH_EVENT_ENDED)
            elseif self.rememberTouchBeganX < x then
            	onClickRightArrow(nil,TOUCH_EVENT_ENDED)
            end
        end
        return true
	end
	self.sceneLayer = CCScene:create()
	if self.sceneLayer == nil then
		return
	end
	local tempLayer = CCLayer:create()
	self.sceneLayer:addChild(tempLayer)
	tempLayer:setTouchMode(kCCTouchesAllAtOnce)
	tempLayer:setTouchEnabled(true)
	--self.sceneLayer:retain()
	globalFunction.loadUIFromJson(self,self.sceneLayer,globalGameEnum.uiJsonFilePath .. self.uiJsonFile)
	globalFunction.setListenEventCallBack(self.touchGroup,"switchLeftButton",onClickLeftArrow)
	globalFunction.setListenEventCallBack(self.touchGroup,"switchRightButton",onClickRightArrow)
	globalFunction.setListenEventCallBack(self.touchGroup,"enterGameButton",onEnterGame)
	local roleTable = configReader:instance():getRoleByType(globalGameEnum.CONFIGREADER_ENUM_MAINROLE)
	--self.touchGroup:setTouchPriority(-1)
	self.beSelectTable = {}
	for i,v in pairs(roleTable) do
		local selectRoleEntity = entityManager:addEntity(v.roleId)
		selectRoleEntity:addToLayer(self.sceneLayer,100)
		table.insert(self.beSelectTable,selectRoleEntity)
	end
	self.centerIndex = 1
	for i,v in pairs(self.beSelectTable) do
		if self.centerIndex == i then
			v:setPosition(self.centerPointX,self.centerPointY)
		elseif i < self.centerIndex then
			v:setPosition(self.centerPointX - self.incrementX,self.centerPointY + self.incrementY)
		elseif i > self.centerIndex then
			v:setPosition(self.centerPointX + self.incrementX,self.centerPointY + self.incrementY)
		end
		v:setMotionAndDirection(globalGameEnum.MOTION_STANDING,globalGameEnum.MotionPlayForever,true,globalGameEnum.DIRECTION_BOTTOM)
	end
	updateAllButton()
	tempLayer:registerScriptTouchHandler(onTouch)

	if CCDirector:sharedDirector():getRunningScene() == nil then
		CCDirector:sharedDirector():runWithScene(self.sceneLayer)
	else
		CCDirector:sharedDirector():replaceScene(self.sceneLayer)
	end
end
function chooseRoleScene:onExit()
	globalGameEnum.mainRoleId = self.beSelectTable[self.centerIndex].roleId
end
