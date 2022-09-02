--[[--
    @type Provides basic methods and events for scripted parts.
    @field events Contains the basic events
    @field lastParentCount Tracks the number of connected parents
    @filed lastChildCount Track the number of connected children
    @field lastColour Tracks the shapes colour
    @field lastChangedTick Tracks the last tick of when the body, that the shape is part of, changed
]]
ScriptedShape = class()

--[[--
    Registers basic events for this type.
    @param self The scripted shape instance
    @local
]]
local function registerEvents(self)
    self.events:add("parentConnectedEvent", EventHandler())
    self.events:add("parentDisconnectedEvent", EventHandler())
    self.events:add("childConnectedEvent", EventHandler())
    self.events:add("childDisconnectedEvent", EventHandler())
    self.events:add("colourChangedEvent", EventHandler())
    self.events:add("bodyChangedEvent", EventHandler())
end

--[[--
    Checks for parent connection changes and raises the respective event.
    @param self The scripted shape instance
    @local
]]
local function checkForParentConnectionChanges(self)
    local parentConnectedEvent = self.events:get("parentConnectedEvent")
    local parentDisconnectedEvent = self.events:get("parentDisconnectedEvent")

    if not (parentConnectedEvent:hasSubscribers() or parentDisconnectedEvent:hasSubscribers()) then
        return
    end

    local currentParentCount = #self.interactable:getParents()

    if currentParentCount ~= self.lastParentCount then
        local eventArgs = { connectionCount = currentParentCount, connections = self.interactable:getParents() }

        if currentParentCount > self.lastParentCount then
            parentConnectedEvent(self, eventArgs)
        else
            parentDisconnectedEvent(self, eventArgs)
        end

        self.lastParentCount = currentParentCount
    end
end

--[[--
    Checks for child connection changes and raises the respective event.
    @param self The scripted shape instance
    @local
]]
local function checkForChildConnectionChanges(self)
    local childConnectedEvent = self.events:get("childConnectedEvent")
    local childDisconnectedEvent = self.events:get("childDisconnectedEvent")

    if not (childConnectedEvent:hasSubscribers() or childDisconnectedEvent:hasSubscribers()) then
        return
    end

    local currentChildCount = #self.interactable:getChildren()

    if currentChildCount ~= self.lastChildCount then
        local eventArgs = { connectionCount = currentChildCount, connections = self.interactable:getChildren() }

        if currentChildCount > self.lastChildCount then
            childConnectedEvent(self, eventArgs)
        else
            childDisconnectedEvent(self, eventArgs)
        end

        self.lastChildCount = currentChildCount
    end
end

--[[--
    Checks for colour changes and raises the respective event.
    @param self The scripted shape instance
    @local
]]
local function checkForColourChanges(self)
    local colourChangedEvent = self.events:get("colourChangedEvent")

    if not colourChangedEvent:hasSubscribers() then
        return
    end

    local currentColour = self.shape:getColor()

    if currentColour ~= self.lastColour then
        colourChangedEvent(self, { colour = currentColour, shape = self.shape })
        self.lastColour = currentColour
    end
end

--[[--
    Checks for changes of the body, that the shape is part of and raises the respective event.
    @param self The scripted shape instance
    @local
]]
local function checkForBodyChanges(self)
    local bodyChangedEvent = self.events:get("bodyChangedEvent")

    if not bodyChangedEvent:hasSubscribers() then
        return
    end

    if self.shape:getBody():hasChanged(self.lastChangedTick) then
        local currentGameTick = sm.game.getCurrentTick()
        bodyChangedEvent(self, { changedTick = currentGameTick, body = self.shape:getBody() })
        self.lastChangedTick = currentGameTick
    end
end

--[[--
    Default constructor.
]]
function ScriptedShape:__init()
    self.lastParentCount = 0
    self.lastChildCount = 0
    self.lastColour = sm.color.new(0, 0, 0)
    self.lastChangedTick = 0
    self.events = Dictionary()
    registerEvents(self)
end

--[[--
    The event handler which is called upon creation of a scripted part
]]
function ScriptedShape:server_onCreate()
    self.lastParentCount = #self.interactable:getParents()
    self.lastChildCount = #self.interactable:getChildren()
    self.lastColour = self.shape:getColor()
    self.lastChangedTick = sm.game.getCurrentTick()
    sm.game.scriptedShapes:registerShape(self)
end

--[[--
    The event handler which is called upon destruction of a scripted part
]]
function ScriptedShape:server_onDestroy()
    sm.game.scriptedShapes:deregisterShape(self)
end

--[[--
    The parts server loop method.
    @param deltaTime Elapsed time since the last call
]]
function ScriptedShape:server_onFixedUpdate(deltaTime)
    checkForParentConnectionChanges(self)
    checkForChildConnectionChanges(self)
    checkForColourChanges(self)
    checkForBodyChanges(self)
end

--[[--
    Returns whether the scripted shape has any data saved onto the world storage
    @return Returns a boolean signifying whether something has been stored
]]
function ScriptedShape:server_hasStoredData()
    local data = self.storage:load()
    local hasData = false

    if data ~= nil then
        hasData = #data > 0

        for k, v in pairs(data) do
            hasData = true
            break
        end
    end

    return hasData
end

--[[--
    Returns a dictionary of the registered events and their event handlers
    @return The registered events
]]
function ScriptedShape:getEvents()
    return self.events:clone()
end
