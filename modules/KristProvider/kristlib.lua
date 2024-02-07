--- API for interacting with the Krist blockchain.
local api = {}
local url = "https://krist.dev"

--- Makes a transaction on the Krist blockchain.
--- @param privateKey string The private key of the sender.
--- @param targetAddress string The address of the recipient.
--- @param value number The amount to send.
--- @param metadata string (optional) Additional metadata for the transaction.
--- @return string The response from the server.
api.makeTransaction = function(privateKey, targetAddress, value, metadata)
    if metadata == nil then
        metadata = ""
    end
    local transactionData = {
        private_key = privateKey,
        to = targetAddress,
        amount = value,
        metadata = metadata
    }
    local request = http.post(url .. "/transactions/", textutils.serialiseJSON(transactionData), {["Content-Type"] = "application/json"})
    return request.readAll()
end

--- Retrieves information about a specific address on the Krist blockchain.
--- @param address string The address to retrieve information for.
--- @return string The address information.
api.getAddress = function(address)
    local request = http.get(url .. "/addresses/" .. address)
    local data = textutils.unserialiseJSON(request.readAll())
    return data.address
end

--- Splits a string into a table of substrings based on a separator.
--- @param inputStr string The input string to split.
--- @param sep string (optional) The separator to split the string on. Defaults to whitespace.
--- @return table The table of substrings.
function splitString(inputStr, sep)
    if sep == nil then
        sep = "%s"
    end
    local substrings = {}
    for str in string.gmatch(inputStr, "([^" .. sep .. "]+)") do
        table.insert(substrings, str)
    end
    return substrings
end

--- Parses metadata string into a table.
--- @param meta string The metadata string to parse.
--- @return table The parsed metadata table.
api.parseMetadata = function(meta)
    local parsedMetadata = {}
    local substrings = splitString(meta, ";")
    for _, v in ipairs(substrings) do
        local keyValue = splitString(v, "=")
        if keyValue[2] ~= nil then
            parsedMetadata[keyValue[1]] = keyValue[2]
        else
            if keyValue[1]:match("^.+@.+%.kst$") then
                local nameParts = splitString(keyValue[1], "@")
                parsedMetadata["metaname"] = nameParts[1]
            end
        end
    end
    return parsedMetadata
end

--- Establishes a WebSocket connection to the Krist server.
--- @return table The WebSocket connection.
api.websocket = function()
    local fr = http.post(url .. "/ws/start", "{}", {["Content-Type"] = "application/json"})
    local data = textutils.unserialiseJSON(fr.readAll())
    
    if data then
        local socketUrl = data.url
        local socket = http.websocket(socketUrl)
        return {
            socket = socket,
            subscribe = function(self, event)
                self.socket.send(textutils.serialiseJSON({type = "subscribe", event = event, id = 1}))
            end
        }
    else
        logger.error("Failed to establish WebSocket connection.")
        return {
            socket = nil,
            subscribe = function(self, event)
                logger.warn("Failed to subscribe to event: "..event)
            end
        }
    end
end

return api