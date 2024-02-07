-- This module provides functionality for managing modules in a project.
-- It allows adding, removing, discovering, dispatching events, and finding modules based on their type.

local logger = logger.getLogger("MM")

local mm = {}
-- We will use this to store all the modules
mm.modules = {}

--- Adds a module to the list of modules.
--- @param module The module to be added.
function mm.addModule(module)
    table.insert(mm.modules, module)
end

--- Removes a module from the list of modules.
--- @param module The module to be removed.
function mm.removeModule(module)
    for i, m in ipairs(mm.modules) do
        if m == module then
            table.remove(mm.modules, i)
            return
        end
    end
end

--- Discovers modules in the /modules directory and adds them to the list of modules.
function mm.discover()
    logger.info("Discovering modules...")
    -- does /modules exist?
    if not fs.exists("/modules") then
        logger.info("Modules directory does not exist, creating it...")
        fs.makeDir("/modules")
    end
    local files = fs.list("/modules")
    for i, file in ipairs(files) do
        if fs.isDir("/modules/"..file) then
            logger.info("Discovered module: "..file)
            local module = require("modules."..file)
            mm.addModule(module)
        else
            if file:sub(-4) == ".lua" then
                logger.info("Discovered module: "..file:sub(1, -5))
                local module = require("modules."..file:sub(1, -5))
                mm.addModule(module)
            end
        end
    end
end

--- Dispatches a global event to all modules.
--- @param event The name of the event.
--- @param ... Additional arguments to be passed to the event handlers.
function mm.dispatchEvent(event, ...)
    logger.debug("Dispatching global event: "..event)
    for i, module in ipairs(mm.modules) do
        if module[event] then
            module[event](module, ...)
        end
    end
end

--- Finds a module based on its type.
--- @param moduletype The type of the module to find.
--- @return The module with the specified type, or nil if not found.
function mm.findModuleFor(moduletype)
    for i, module in ipairs(mm.modules) do
        if module.type == moduletype then
            return module
        end
    end
    return nil
end

return mm