local getLogger = require("lib.logger")

-- undeafen so we can communicate
local logger = getLogger("main")
_G.logger = logger

logger.info("Hello world! Solid is starting up!")
local mm = require("moduleManager")

logger.info("Discovering modules...")
mm.discover()
mm.dispatchEvent("init")
logger.info("Getting parallels, and starting event loop")
local parallels = {}
for i, module in ipairs(mm.modules) do
    if module.getParallels then
        local moduleParallels = module:getParallels()
        for j, parallel in ipairs(moduleParallels) do
            table.insert(parallels, parallel)
        end
    end
end

parallel.waitForAll(table.unpack(parallels))