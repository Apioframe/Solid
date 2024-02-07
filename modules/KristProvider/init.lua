local current_dir = (...):gsub("%.init$", "")
local kristlib = require(current_dir.."/kristlib")

--- @class KristProvider : AbstractPaymentProvider
local module = require("abstract.paymentProvider"):new()
module.name = "KristProvider"
module.version = "0.0.1"

module.socket = nil

--- Initializes the handler for the module
function module:initHandler()
    self.socket = kristlib.websocket()
    self.events:on("socket_data", function(data)
        self.logger.info("Received data: "..data)
        local jsondata = textutils.unserializeJSON(data)
        if jsondata then
            if jsondata.type == "transaction" then
                self.events:emit("transaction", jsondata)
            end
        end
    end)
end

--- Retrieves the parallel functions for the module
function module:getParallels()
    return {
        function()
            self.socket:subscribe("transactions")
            while true do
                local data = self.socket.socket.receive()
                if data then
                    self.events:emit("socket_data", data)
                end
            end
        end
    }
end

return module