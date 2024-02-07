--- @class AbstractPaymentProvider : AbstractModule
local module = require("abstract.module"):new()

module.type = "paymentProvider"
module.name = "AbstactPaymentProvider"
module.version = "0.0.1"
module.events = require("lib.event"):new()
module.logger = logger.getLogger("AbstractPaymentProvider")


function module:initHandler()
    self.logger.error("Payment provider didn't implement initHandler!")
end

function module:init()
    self.logger.info("Initializing payment provider...")
    self:initHandler()
    self.events:emit("PaymentInit")
    self.events:on("transaction", function(transaction)
        
    end)
end



return module