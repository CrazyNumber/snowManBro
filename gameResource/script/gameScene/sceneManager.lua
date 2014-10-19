runScriptFile("gameResource/script/objBase")
sceneManager = objBase:extend(
{
	currentScene = nil,
}
)
function sceneManager:init()

end
function sceneManager:instance()
	if self.initFlag == nil then
		self:init()
		self.initFlag = true
	end
	return self
end
function sceneManager:changeSceneTo(newScene)
	if newScene == nil then
		return
	end

	if sceneManager.currentScene ~= nil then
		sceneManager.currentScene:onChangingScene(newScene)
		newScene:onChangingScene(sceneManager.currentScene)
		sceneManager.currentScene:onExit()
	end
	newScene:onEnter()
	sceneManager.currentScene = newScene
end
function sceneManager:sceneFactory(sceneEnumCode)
	if sceneEnumCode == nil then return nil end
	if sceneEnumCode == globalGameEnum.SCENE_ENUM_FIRST_GAME_SCENE then
		return firstScene:instance()
	elseif sceneEnumCode == globalGameEnum.SCENE_ENUM_CHOOSE_ROLE_SCENE then
		return chooseRoleScene:instance()
	elseif sceneEnumCode == globalGameEnum.SCENE_ENUM_GAME_SCENE then
		return gameScene:instance()
	end
end

