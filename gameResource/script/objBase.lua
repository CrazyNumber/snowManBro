objBase = {}
function objBase:new(o)
	setmetatable(o,self)
	self.__index = self
	return o
end
function objBase:init()
	--do nothing
end
function objBase:instance()
	return self
end
function objBase:extend(object)
	return objBase:new(object)
end