--- List Gui that can be scrolled through with buttons
--- @class ListControl
--- @field private scriptedShape ShapeClass Scripted shape instance the control gets attached to
--- @field private elements table<string> Available list elements
--- @field private selected number Index of the currently selected element
--- @field private highlighted number Index of the currently highlighted element
--- @field private gui GuiInterface Gui object that is rendered
ListControl = class()

--- Assigns the Gui callback functions for the gui to use
--- @param self ListControl ListControl instance
--- @param scriptedShape ShapeClass Scripted shape instance to attach callbacks to
local function generateCallbacks(self, scriptedShape)
    scriptedShape.gui_listControlScroll = function (shape, buttonName)
        if buttonName == "ScrollUp" then
            self:scroll(-1)
        elseif buttonName == "ScrollDown" then
            self:scroll(1)
        else
            self:scroll(tonumber(buttonName) or 0)
        end
    end

    scriptedShape.gui_listControlConfirm = function (shape, buttonName)
        self:confirm(shape, buttonName)
    end

    scriptedShape.gui_listControlCloseCallback = function (shape)
        self:close()
    end
end

--- Sets the appropriate callbacks for the given Gui buttons
--- @param self ListControl ListControl instance
local function setCallbacks(self)
    for i = -2, 2, 1 do
        self.gui:setButtonCallback(tostring(i), "gui_listControlScroll")
    end

    self.gui:setButtonCallback("ScrollUp", "gui_listControlScroll")
    self.gui:setButtonCallback("ScrollDown", "gui_listControlScroll")
    self.gui:setButtonCallback("0", "gui_listControlConfirm")
    self.gui:setOnCloseCallback("gui_listControlCloseCallback")
end

--- Constructor
--- @param scriptedShape ShapeClass Scripted shape instance to attach the list to
--- @param title string Displayed title of the list
--- @param onConfirmCallback fun(number, any) Callback that is called when an element is selected
--- @param onCloseCallback fun() Callback that is called when the list is closed
function ListControl:__init(scriptedShape, title, elements, onConfirmCallback, onCloseCallback)
    assert(type(elements) == "table", "List must be a table")
    assert(onConfirmCallback ~= nil and type(onConfirmCallback) == "function", "Invalid confirm callback passed.")
    assert(onCloseCallback ~= nil and type(onCloseCallback) == "function", "Invalid close callback passed.")

    self.scriptedShape = scriptedShape
    self.elements = elements or {}
    self.selected = 1
    self.highlighted = 1
    self.gui = sm.gui.createGuiFromLayout("$MOD_DATA/Gui/ListControl.layout")
    self.gui:setText("Title", title)
    self:update()

    self.confirm = function (shape, buttonName)
        self.selected = self.highlighted
        onConfirmCallback(self.selected, self.elements[self.selected])
        self.gui:close()
    end

    self.close = function (shape, buttonName)
        self.highlighted = self.selected
        onCloseCallback()
    end

    generateCallbacks(self, scriptedShape)
    setCallbacks(self)
end


--- Changes the highlighted position relatively to its current by the given amount of steps
--- @param steps number Amount of steps to scroll up or down. Positive numbers scroll down, negative scroll up.
function ListControl:scroll(steps)
    if #self.elements == 0 then
        return
    end

    self.highlighted = self.highlighted + steps

    if self.highlighted < 1 then
        self.highlighted = 1
    elseif self.highlighted > #self.elements then
        self.highlighted = #self.elements
    end

    self:update()
end

--- Jumps to and highlights the given position in the list
--- @param i number
function ListControl:jump(i)
    assert(i > 0 and i <= #self.elements, "Index out of range")

    self.highlighted = i
    self:update()
end

--- Updates the displayed Gui
function ListControl:update()
    for i =-2, 2, 1 do
        local element = self.elements[self.highlighted + i]
        self.gui:setVisible(tostring(i), element ~= nil) -- Hide empty leading and trailing entries
        self.gui:setText(tostring(i), tostring(element) or "")
    end

    self.gui:setVisible("ScrollUp", #self.elements > 1 and self.highlighted > 1) -- Disable when reaching top
    self.gui:setVisible("ScrollDown", #self.elements > 1 and self.highlighted < #self.elements) -- Disable when reaching bottom
end

--- Returns a clone of the list's elements
--- @return table @Elements
function ListControl:getElements()
    local elements = {}

    for i, v in ipairs(self.elements) do
        table.insert(elements, v)
    end

    return elements
end


--- Sets and updates the displayable list elements
--- @param elements table<string> Elements
function ListControl:setElements(elements)
    assert(type(elements) == "table", "List must be a table")

    self.elements = elements or {}
    self.selected = 1
    self.highlighted = 1
    self:update()
end

--- Returns the index and element that has been selected
--- @return number, string @Index and element
function ListControl:getSelected()
    return self.selected, self.elements[self.selected]
end

--- Returns the index and element that is highlighted
--- @return number, string @Index and element
function ListControl:getHighlighted()
    return self.highlighted, self.elements[self.highlighted]
end

--- Opens the list Gui
function ListControl:open()
    self:update()
    self.gui:open()
end

--- Called to destroy the hud list Gui
function ListControl:destroy()
    self.gui:destroy()
end
