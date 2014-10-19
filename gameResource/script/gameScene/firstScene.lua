runScriptFile("gameResource/script/objBase")
firstScene = objBase:extend(
{
	ENUM_STATE_SHOWTEXT = 0,
	ENUM_STATE_CLICKEXIT = 1,
	currentState = nil,
	uiJsonFile = "firstScene.ExportJson",
}
)
function firstScene:init()

end
function firstScene:instance()
	if self.initFlag == nil then
		self:init()
		self.initFlag = true
	end
	return self
end
function firstScene:onEnter()
	self.sceneLayer = CCScene:create()
	if self.sceneLayer == nil then
		return
	end
	globalFunction.loadUIFromJson(self,self.sceneLayer,globalGameEnum.uiJsonFilePath .. self.uiJsonFile)
	self.currentState = self.ENUM_STATE_SHOWTEXT
	local function onClickPanelEvent()
		if self.currentState == self.ENUM_STATE_SHOWTEXT then
			local showText = "本程序只供学习交流之用，请勿用做它途！"
			if self.increment ~= nil and string.len(showText) == self.increment*3 then
				self:disableSchedulerCallBack()
				self.currentState = self.ENUM_STATE_CLICKEXIT
				self:showClickExitAnimation()
				return
			end
			if self.increment == nil then
				self.increment = 1
			else
				self.increment = self.increment + 1
			end

			local label = self.touchGroup:getWidgetByName("dynamiscString")
			if label ~= nil then
				label = tolua.cast(label, "Label")
				if label ~= nil then
					label:setText(string.sub(showText, 1, self.increment*3))
				end
			end
		elseif self.currentState ~= nil then
			--CCLuaLog("here")
			if self.actionObject ~= nil then
				self.actionObject:stop()
				self.actionObject:release()
				self.actionObject = nil
			end
			sceneManager:instance():changeSceneTo(sceneManager:instance():sceneFactory(globalGameEnum.SCENE_ENUM_CHOOSE_ROLE_SCENE))
			self.currentState = nil
		end
	end
	local firstSceneWidget = self.touchGroup:getWidgetByName("firstScene")
	if firstSceneWidget ~= nil then
		firstSceneWidget:addTouchEventListener(onClickPanelEvent)
	end
	local firstSceneText = self.touchGroup:getWidgetByName("Label_2")
	if firstSceneText ~= nil then
		firstSceneText:setVisible(false)
	end
	if CCDirector:sharedDirector():getRunningScene() == nil then
		CCDirector:sharedDirector():runWithScene(self.sceneLayer)
	else
		CCDirector:sharedDirector():replaceScene(self.sceneLayer)
	end
	self.callBackId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onClickPanelEvent,0.25,false)
end
function firstScene:showClickExitAnimation()
	local firstSceneText = self.touchGroup:getWidgetByName("Label_2")
	if firstSceneText ~= nil then
		firstSceneText:setVisible(true)
	end
	self.actionObject = ActionManager:shareManager():playActionByName(self.uiJsonFile,"Animation0")
end
function firstScene:disableSchedulerCallBack()
	if self.callBackId ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.callBackId)
		self.callBackId = nil
	end
end
function firstScene:onExit()
	self:disableSchedulerCallBack()
end