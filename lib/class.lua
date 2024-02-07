local Class = {}


function Class:constructor(...)
    -- Unimplemented!
end

function Class:new(...)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    self.constructor(obj, ...)
    return obj
end

return Class
