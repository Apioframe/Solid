
--- @class EventEmitter
local EventEmitter = {}

--- Create a new event emitter
--- @return EventEmitter
function EventEmitter:new()
    local obj = {}
    obj.listeners = {}

    setmetatable(obj, self)
    self.__index = self

    return obj
end

--- Register a listener for an event
--- @param event string
--- @param listener function
function EventEmitter:on(event, listener)
    if self.listeners[event] == nil then
        self.listeners[event] = {}
    end
    table.insert(self.listeners[event], listener)
end

--- Remove a listener for an event
--- @param event string
--- @param listener function
function EventEmitter:off(event, listener)
    if self.listeners[event] ~= nil then
        for i = 1, #self.listeners[event] do
            if self.listeners[event][i] == listener then
                table.remove(self.listeners[event], i)
                break
            end
        end
    end
end

--- Emit an event
--- @param event string
--- @vararg any
function EventEmitter:emit(event, ...)
    if self.listeners[event] ~= nil then
        for i = 1, #self.listeners[event] do
            self.listeners[event][i](...)
        end
    end
end

return EventEmitter

