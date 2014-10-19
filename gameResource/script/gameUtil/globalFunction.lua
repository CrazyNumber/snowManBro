runScriptFile("gameResource/script/objBase")
globalFunction = objBase:extend(
{

}
)
function globalFunction.loadUIFromJson(object,fatherLayer,jsonFile)
	if object == nil or fatherLayer == nil or jsonFile == nil then
		return
	end
	object.touchGroup = TouchGroup:create()
	if object.touchGroup == nil then
		return
	end
	fatherLayer:addChild(object.touchGroup)
	local wndWidget = GUIReader:shareReader():widgetFromJsonFile(jsonFile)
	if wndWidget == nil then
		return
	end
	object.touchGroup:addWidget(wndWidget)
end
function globalFunction.setListenEventCallBack(touchGroup,name,callBack)
	local tempObject = touchGroup:getWidgetByName(name)
	if tempObject ~= nil then
		tempObject:addTouchEventListener(callBack)
	else
		error("\nsetListenEventCallBack .. tempObject is nil")
	end
end
function globalFunction.setWidgetTouchEnabled(touchGroup,name,enabledFlag)
	local tempObject = touchGroup:getWidgetByName(name)
	if tempObject ~= nil then
		tempObject:setTouchEnabled(enabledFlag)
	else
		error("\nsetWidgetEnabled .. tempObject is nil")
	end
end
function globalFunction.getIntPart(floatNumber)
	if floatNumber <= 0 then
	   return math.ceil(floatNumber)
	end
	if math.ceil(floatNumber) == floatNumber then
	   floatNumber = math.ceil(floatNumber)
	else
	   floatNumber = math.ceil(floatNumber) - 1
	end
	return floatNumber
end
function globalFunction.getRoleNoFightDirectionByPosAndDest(x,y,destX,destY)
	local angle = globalFunction.getTwoPointAngle(x,y,destX,destY)
	CCLuaLog("" .. globalFunction.getIntPart(x) .. ":" .. globalFunction.getIntPart(y) .. ":" .. globalFunction.getIntPart(destX) .. ":" .. globalFunction.getIntPart(destY) .. "|" .. globalFunction.getIntPart(angle))
	if angle <= 30 and angle ~= 0 then
		return globalGameEnum.DIRECTION_TOP
	elseif angle > 30 and angle <= 60 then
		return globalGameEnum.DIRECTION_RIGHTTOP
	elseif angle > 60 and angle <= 90 then
		return globalGameEnum.DIRECTION_RIGHT
	elseif angle > 90 and angle <= 120 then
		return globalGameEnum.DIRECTION_RIGHT
	elseif angle > 120 and angle <= 150 then
		return globalGameEnum.DIRECTION_RIGHTBOTTOM
	elseif angle > 150 and angle <= 180 then
		return globalGameEnum.DIRECTION_BOTTOM
	elseif angle > 180 and angle <= 210 then
		return globalGameEnum.DIRECTION_BOTTOM
	elseif angle > 210 and angle <= 240 then
		return globalGameEnum.DIRECTION_LEFTBOTTOM
	elseif angle > 240 and angle <= 270 then
		return globalGameEnum.DIRECTION_LEFT
	elseif angle > 270 and angle <= 300 then
		return globalGameEnum.DIRECTION_LEFT
	elseif angle > 300 and angle <= 330 then
		return globalGameEnum.DIRECTION_LEFTTOP
	elseif angle > 330 and angle <= 360 then
		return globalGameEnum.DIRECTION_TOP
	end
	return nil
end
function globalFunction.getRoleFightDirectionByPosAndDest(x,y,destX,destY)
	
end

function globalFunction.getTwoPointAngle(x,y,destX,destY)
	local angle = math.atan((math.abs(destY - y)/math.abs(destX - x)))*180/math.pi
	if destX > x and destY > y then--第一象限
		return (90 - angle)
	elseif destX ~= x and destY == y then 
		if destX > x then
			return 90
		elseif destX < x then
			return 270
		end
	elseif destX == x and destY ~= y then  
		if destY > y then
			return 360
		elseif destY < y then
			return 180
		end
	elseif destX > x and destY < y then--第二象限
		return 90 + angle
	elseif destX < x and destY > y then 
		return angle + 270
	elseif destX == x and destY == y then
		return 0
	else
		angle = 90 - angle
		return angle + 180
	end
end