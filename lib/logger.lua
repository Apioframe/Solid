--- Creates a logger object with the given name.
---@param name string The name of the logger.
---@return table The logger object.
function getLogger(name)
    local ret = {
        logFile = nil,
        parent = nil,
        name = name,
        logLevel = 0,
    }

    --- Sets the log file for the logger.
    ---@param logFileName string The name of the log file.
    function ret.setFile(logFileName)
        ret.logFile = fs.open(logFileName, "w")
    end

    --- Automatically sets the log file based on the current date and time.
    ---@param level number The log level.
    function ret.autoFile(level)
        local logFileName = "/logs/"..name.."_latest.log"
        if fs.exists(logFileName) then
            fs.move(logFileName, "/logs/"..name.."_"..os.date("%Y-%m-%d_%H-%M-%S")..".log")
        end
        ret.logFile = fs.open(logFileName, "w")
    end

    --- Writes data to the log file.
    ---@param data string The data to write.
    function ret.writeToFile(data)
        if ret.logFile ~= nil then
            ret.logFile.writeLine(data)
            ret.logFile.flush()
        end
    end

    --- Sets the parent logger for the current logger.
    ---@param parent table The parent logger object.
    function ret.setParent(parent)
        ret.parent = parent
    end

    --- Writes data to the root log file.
    ---@param data string The data to write.
    function ret.writeIntoRootFile(data)
        if ret.parent ~= nil then
            ret.parent.writeIntoRootFile(data)
        else
            ret.writeToFile(data)
        end
    end

    --- Gets the full log prefix for the logger.
    ---@return string The full log prefix.
    function ret.getFullLogPrefix()
        if ret.parent ~= nil then
            return ret.parent.getFullLogPrefix().."/"..ret.name
        else
            return ret.name
        end
    end

    --- Logs a message with the specified level.
    ---@param level number The log level.
    ---@param data string The data to log.
    function ret.log(level, data)
        if level == nil then
            level = 1
        end

        term.write("["..os.date("%H:%M:%S").."] ")
        local levele = ""
        if level == 0 then
            term.setTextColor(colors.cyan)
            term.write("[DEBUG] ")
            levele = "DEBUG"
        elseif level == 1 then
            term.setTextColor(colors.green)
            term.write("[INFO] ")
            levele = "INFO"
        elseif level == 2 then
            term.setTextColor(colors.yellow)
            term.write("[WARN] ")
            levele = "WARN"
        elseif level == 3 then
            term.setTextColor(colors.red)
            term.write("[ERROR] ")
            levele = "ERROR"
        end

        term.setTextColor(colors.green)
        term.write("["..ret.getFullLogPrefix().."] > ")
        term.setTextColor(colors.white)
        print(data)

        if level >= ret.logLevel then
            ret.writeIntoRootFile("["..os.date("%H:%M:%S").."] ["..levele.."] ["..ret.getFullLogPrefix().."] > "..data)
        end
    end

    --- Creates a child logger with the given name.
    ---@param name string The name of the child logger.
    ---@return table The child logger object.
    function ret.getLogger(name)
        local newLogger = getLogger(name)
        newLogger.setParent(ret)
        return newLogger
    end

    --- Logs a message with the INFO level.
    ---@param data string The data to log.
    function ret.info(data)
        ret.log(1, data)
    end

    --- Logs a message with the DEBUG level.
    ---@param data string The data to log.
    function ret.debug(data)
        ret.log(0, data)
    end

    --- Logs a message with the WARN level.
    ---@param data string The data to log.
    function ret.warn(data)
        ret.log(2, data)
    end

    --- Logs a message with the ERROR level.
    ---@param data string The data to log.
    function ret.error(data)
        ret.log(3, data)
    end

    return ret
end

return getLogger