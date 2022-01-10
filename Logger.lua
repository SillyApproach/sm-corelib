Logger = class()
Logger.logLevel = nil
Logger.chatLogEnabled = nil

function Logger:__init(logLevel, chatLogEnabled)
    self.logLevel = logLevel or LogLevelEnum.None
    self.chatLogEnabled = chatLogEnabled or false
end

function Logger:isEnabled(logLevel)
    return self.logLevel == logLevel
end

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

function Logger:isChatLogEnabled()
    return self.chatLogEnabled
end

function Logger:toggleChatLog()
    self.chatLogEnabled = not self.chatLogEnabled
end
