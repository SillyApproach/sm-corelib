--- An on-screen keyboard
--- @class Keyboard
--- @field private layout table<number, string> Keyboard layout being rendered and used for input
--- @field private gui GuiInterface Gui object that is rendered
--- @field private scriptedShape ShapeClass Scripted shape instance the keyboard gets attached to
--- @field private buffer string Buffered keyboard text during typing
--- @field private shift boolean Whether the shift key is pressed and the alternative characters used
Keyboard = class()

--- Assigns the Gui callback functions for the gui to use
--- @param self Keyboard Keyboard instance
--- @param scriptedShape ShapeClass Scripted shape instance to attach callbacks to
local function generateCallbacks(self, scriptedShape)
    scriptedShape.gui_keyboardButtonCallback = function (shape, buttonName)
        self:onButtonClick(buttonName)
    end

    scriptedShape.gui_keyboardConfirm = function (shape, buttonName)
        self:confirm()
    end

    scriptedShape.gui_keyboardCancel = function (shape, buttonName)
        self:cancel()
    end

    scriptedShape.gui_keyboardBackspace = function (shape, buttonName)
        self:backspace()
    end

    scriptedShape.gui_keyboardShift = function (shape, buttonName)
        self:shiftKeys()
    end

    scriptedShape.gui_keyboardSpacebar = function (shape, buttonName)
        self:spacebar()
    end

    scriptedShape.gui_keyboardCloseCallback = function (shape)
        self:close()
    end
end

--- Sets the appropriate callbacks for the given Gui buttons
--- @param self Keyboard Keyboard instance
local function setCallbacks(self)
    for i = 1, #self.layout.keys, 1 do
        self.gui:setText(tostring(i), self.layout.keys[i][1])
        self.gui:setButtonCallback(tostring(i), "gui_keyboardButtonCallback")
    end

    self.gui:setButtonCallback("Confirm", "gui_keyboardConfirm")
    self.gui:setButtonCallback("Cancel", "gui_keyboardCancel")
    self.gui:setButtonCallback("Backspace", "gui_keyboardBackspace")
    self.gui:setButtonCallback("Shift", "gui_keyboardShift")
    self.gui:setButtonCallback("Space", "gui_keyboardSpacebar")
    self.gui:setOnCloseCallback("gui_keyboardCloseCallback")
end

--- Constructor
--- @param scriptedShape ShapeClass Scripted shape instance to attach the keyboard to
--- @param title string Displayed title of the  keyboard
--- @param onConfirmCallback fun(string) Callback that is called when the keyboard input is finalised
--- @param onCloseCallback fun() Callback that is called when the keyboard is closed
function Keyboard:__init(scriptedShape, title, onConfirmCallback, onCloseCallback)
    assert(onConfirmCallback ~= nil and type(onConfirmCallback) == "function", "Invalid confirm callback passed.")
    assert(onCloseCallback ~= nil and type(onCloseCallback) == "function", "Invalid close callback passed.")

    self.scriptedShape = scriptedShape
    self.buffer = ""
    self.shift = false
    self.gui = sm.gui.createGuiFromLayout("$MOD_DATA/Gui/Keyboard.layout")
    self.gui:setText("Title", title)
    self.layout = sm.json.open("$MOD_DATA/Gui/KeyboardLayouts/default.json")

    self.confirm = function (shape, buttonName)
        onConfirmCallback(self.buffer)
        self.gui:close()
    end

    self.close = function (shape, buttonName)
        onCloseCallback()
        self.buffer = ""
    end

    generateCallbacks(self, scriptedShape)
    setCallbacks(self)
end

--- Opens the on-screen keyboard
--- @param initialText string Initial text to show in the keyboard's text field
function Keyboard:open(initialText)
    self.buffer = initialText or ""
    self.gui:setText("Textbox", self.buffer)
    self.gui:open()
end

--- Called when a button is clicked
--- @param buttonName string Name of the clicked button
function Keyboard:onButtonClick(buttonName)
    local keyToAppend

    if self.shift then
        keyToAppend = self.layout.keys[tonumber(buttonName)][2]
        self:shiftKeys()
    else
        keyToAppend = self.layout.keys[tonumber(buttonName)][1]
    end

    self.buffer = self.buffer .. keyToAppend
    self.gui:setText("Textbox", self.buffer)
end

--- Called when the cancel button is clicked, cancelling the input and closing the keyboard.
function Keyboard:cancel()
    self.gui:close()
end

--- Called when the backspace button is clicked, erasing the latest buffered character
function Keyboard:backspace()
    self.buffer = self.buffer:sub(1, -2)
    self.gui:setText("Textbox", self.buffer)
end

--- Called when the shift button is clicked, thereby changing to the alternative shifted keyboard input
function Keyboard:shiftKeys()
    self.shift = not self.shift
    self.gui:setButtonState("Shift", self.shift)

    for i = 1, #self.layout.keys, 1 do
        self.gui:setText(tostring(i), self.shift and self.layout.keys[i][2] or self.layout.keys[i][1])
    end
end

--- Called when then spacebar button is clicked appending a single space to the buffer
function Keyboard:spacebar()
    self.buffer = self.buffer .. " "
    self.gui:setText("Textbox", self.buffer)
end

--- Destroys and closes the on-screen keyboard and its Gui
function Keyboard:destroy()
    self.gui:destroy()
end
