--- @class AbstractModule
local module = {}

module.type = "module"
module.name = "AbstractModule"
module.version = "0.0.1"
module.events = require("lib.event"):new()



function module:new(...)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    obj.events = require("lib.event"):new()
    return obj
end

return module