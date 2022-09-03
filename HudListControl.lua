--- Scrollable list gui rendered within world space
--- @class HudListControl
--- @field private scriptedShape ShapeClass Scripted shape instance the control gets attached to
--- @field private character Character Character which is locked to the shape's interactable upon interaction
--- @field private visibleElements table<string> Table of rendered elements
--- @field private elements table<string> Table of all available elements
--- @field private position number Current view pane position witin the list
--- @field private gui GuiInterface Gui object that is rendered
HudListControl = class()

--- Creates handler functions for the scripted shape's events
--- @param self HudListControl HudListControl instance
--- @param scriptedShape ShapeClass Scripted shape whose events are being listened to
local function generateCallbacks(self, scriptedShape)
    scriptedShape.client_onAction = function (_, controllerAction, isPressed)
        self:onAction(controllerAction, isPressed)

        return false
    end
end

--- Constructor
--- @param scriptedShape ShapeClass Scripted shape the Gui gets attached to
--- @param character any Character that gets locked to the scritped shape's interactable
--- @param host Interactable Host interactable to attach the Gui to
--- @param visibleElements any Visible list elements to be initially displayed
--- @param elements any List elements that can be scrolled through
function HudListControl:__init(scriptedShape, character, host, visibleElements, elements)
    self.scriptedShape = scriptedShape
    self.character = character
    self.visibleElements = visibleElements or 5
    self.elements = elements or {}
    self.position = 1
    self.gui = sm.gui.createNameTagGui()
    self.gui:setHost(host)
    self.gui:setRequireLineOfSight(false)
    self.gui:setMaxRenderDistance(15)
    generateCallbacks(self, scriptedShape)
    self:update()
end

--- Event handler function getting called when a player is locked to the interactable
--- @param controllerAction any Player action that has happened
--- @param state boolean Describes whether the action has started or ended: `true` if it has started, `false` if it has ended.
--- @return boolean @True if the action propagates to higher level handlers, false if it is to terminate here
function HudListControl:onAction(controllerAction, state)
    if controllerAction == 20 and state then
        self:scroll(-1)
    elseif controllerAction == 21 and state then
        self:scroll(1)
    end

    return false
end

--- Sets and updates the displayable list elements
--- @param elements table<string> Elements
function HudListControl:setElements(elements)
    assert(type(elements) == "table", "Elements must be a table")

    self.elements = elements
    self:update()
end

--- Changes the view pane's position relatively to its current by the given amount of steps
--- @param steps number Amount of steps to scroll up or down. Positive numbers scroll down, negative scroll up.
function HudListControl:scroll(steps)
    self.position = self.position + steps

    if self.position < 1 or #self.elements < self.visibleElements then
        self.position = 1
    elseif self.position + self.visibleElements > #self.elements then
        self.position = #self.elements - self.visibleElements
    end

    self:update()
end

--- Opens the list Gui
function HudListControl:open()
    self.character:setLockingInteractable(self.scriptedShape.interactable)
    self:update()
    self.gui:open()
end

--- Closes the list Gui
function HudListControl:close()
    self.character:setLockingInteractable(nil)
    self.gui:close()
end

--- Updates the displayed Gui
function HudListControl:update()
    local elementsToDisplay = ((#self.elements > self.visibleElements) and self.visibleElements or #self.elements)
    local str = ""

    for i = 0, elementsToDisplay - 1, 1 do
        str = str .. tostring(self.elements[self.position + i] or "") .. ((i < elementsToDisplay - 1) and "\n" or "") -- No new line feed for the last element
    end

    self.gui:setText("Text", str)
end

--- Returns the current view pane position
--- @return number @Current position
function HudListControl:getPosition()
    return self.position
end

--- Called to destroy the hud list Gui
function HudListControl:destroy()
    self.character:setLockingInteractable(nil)
    self.gui:destroy()
end
