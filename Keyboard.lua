Keyboard = class()
Keyboard.layout = nil
Keyboard.gui = nil
Keyboard.scriptedShape = nil
Keyboard.buffer = nil
Keyboard.shift = nil

local function generateCallbacks(scriptedShape, instance)
    scriptedShape.gui_keyboardButtonCallback = function (shape, buttonName)
        instance:onButtonClick(buttonName)
    end

    scriptedShape.gui_keyboardConfirm = function (shape, buttonName)
        instance:confirm()
    end

    scriptedShape.gui_keyboardCancel = function (shape, buttonName)
        instance:cancel()
    end

    scriptedShape.gui_keyboardBackspace = function (shape, buttonName)
        instance:backspace()
    end

    scriptedShape.gui_keyboardShift = function (shape, buttonName)
        instance:shiftKeys()
    end

    scriptedShape.gui_keyboardSpacebar = function (shape, buttonName)
        instance:spacebar()
    end

    scriptedShape.gui_keyboardCloseCallback = function (shape)
        instance:close()
    end
end

local function setCallbacks(instance)
    for i = 1, #instance.layout.keys, 1 do
        instance.gui:setText(tostring(i), instance.layout.keys[i][1])
        instance.gui:setButtonCallback(tostring(i), "gui_keyboardButtonCallback")
    end

    instance.gui:setButtonCallback("Confirm", "gui_keyboardConfirm")
    instance.gui:setButtonCallback("Cancel", "gui_keyboardCancel")
    instance.gui:setButtonCallback("Backspace", "gui_keyboardBackspace")
    instance.gui:setButtonCallback("Shift", "gui_keyboardShift")
    instance.gui:setButtonCallback("Space", "gui_keyboardSpacebar")
    instance.gui:setOnCloseCallback("gui_keyboardCloseCallback")
end

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

    generateCallbacks(scriptedShape, self)
    setCallbacks(self)
end

function Keyboard:open(initialBuffer)
    self.buffer = initialBuffer or ""
    self.gui:setText("Textbox", self.buffer)
    self.gui:open()
end

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

function Keyboard:cancel()
    self.gui:close()
end

function Keyboard:backspace()
    self.buffer = self.buffer:sub(1, -2)
    self.gui:setText("Textbox", self.buffer)
end

function Keyboard:shiftKeys()
    self.shift = not self.shift
    self.gui:setButtonState("Shift", self.shift)

    for i = 1, #self.layout.keys, 1 do
        self.gui:setText(tostring(i), self.shift and self.layout.keys[i][2] or self.layout.keys[i][1])
    end
end

function Keyboard:spacebar()
    self.buffer = self.buffer .. " "
    self.gui:setText("Textbox", self.buffer)
end

function Keyboard:destroy()
    self.gui:destroy()
end
