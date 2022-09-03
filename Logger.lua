--- Provides facilities to log messages with customisable log levels
--- @class Logger
--- @field private logLevel LogLevelEnum Log level to log at
--- @field private chatLogEnabled boolean Whether to print logs to the chat
Logger = class()

function Logger:__init(logLevel, chatLogEnabled)
    self.logLevel = logLevel or LogLevelEnum.None
    self.chatLogEnabled = chatLogEnabled or false
end

--- Whether the logger has been set to log at the given log level
--- @param logLevel LogLevelEnum Log level to check against
--- @return boolean @True if the logger logs at the given log level otherwise false
function Logger:isEnabled(logLevel)
    return self.logLevel == logLevel
end

--- Logs a message at the given log level
--- @param logLevel LogLevelEnum Log level to log at
--- @param message string Message to log
function Logger:log(logLevel, message)
    if logLevel.level < self.logLevel.level then
        return
    end

    local logMessage = ("[%s] %s"):format(logLevel.name, message)

    if logLevel == LogLevelEnum.Warning then
        sm.log.warning(logMessage)
    elseif logLevel == LogLevelEnum.Error then
        sm.log.error(logMessage)
    else
        sm.log.info(logMessage)
    end

    if self.chatLogEnabled and not sm.isServerMode() then
        sm.gui.chatMessage(("%s[%s] %s"):format(logLevel.logColour, logLevel.name, message))
    end
end

--- Returns whether logs are printed in the chat
--- @return boolean @True if enabled otherwise false
function Logger:isChatLogEnabled()
    return self.chatLogEnabled
end

--- Toggles log printing in the chat
function Logger:toggleChatLog()
    self.chatLogEnabled = not self.chatLogEnabled
end
