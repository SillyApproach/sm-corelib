HudListControl = class()

local function generateCallbacks(self, scriptedShape)
    scriptedShape.client_onAction = function (_, controllerAction, isPressed)
        self:onAction(controllerAction, isPressed)

        return false
    end
end

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

function HudListControl:onAction(controllerAction, state)
    if controllerAction == 20 and state then
        self:scroll(-1)
    elseif controllerAction == 21 and state then
        self:scroll(1)
    end

    return false
end

function HudListControl:setElements(elements)
    assert(type(elements) == "table", "Elements must be a table")

    self.elements = elements
    self:update()
end

function HudListControl:scroll(direction)
    self.position = self.position + direction

    if self.position < 1 or #self.elements < self.visibleElements then
        self.position = 1
    elseif self.position + self.visibleElements > #self.elements then
        self.position = #self.elements - self.visibleElements
    end

    self:update()
end

function HudListControl:open()
    self.character:setLockingInteractable(self.scriptedShape.interactable)
    self:update()
    self.gui:open()
end

function HudListControl:close()
    self.character:setLockingInteractable(nil)
    self.gui:close()
end

function HudListControl:update()
    local elementsToDisplay = ((#self.elements > self.visibleElements) and self.visibleElements or #self.elements)
    local str = ""

    for i = 0, elementsToDisplay - 1, 1 do
        str = str .. tostring(self.elements[self.position + i] or "") .. ((i < elementsToDisplay - 1) and "\n" or "") -- No new line feed for the last element
    end

    self.gui:setText("Text", str)
end

function HudListControl:getPosition()
    return self.position
end

function HudListControl:destroy()
    self.character:setLockingInteractable(nil)
    self.gui:destroy()
end
