Keypad = class()
Keypad.layout = nil
Keypad.gui = nil
Keypad.scriptedShape = nil
Keypad.buffer = nil
Keypad.hasDecimalPoint = nil
Keypad.negative = nil

local function generateCallbacks(self, scriptedShape)
    scriptedShape.gui_keypadButtonCallback = function (shape, buttonName)
        self:onButtonClick(buttonName)
    end

    scriptedShape.gui_keypadConfirm = function (shape, buttonName)
        self:confirm()
    end

    scriptedShape.gui_keypadCancel = function (shape, buttonName)
        self:cancel()
    end

    scriptedShape.gui_keypadClear = function (shape, buttonName)
        self:clear()
    end

    scriptedShape.gui_keypadBackspace = function (shape, buttonName)
        self:backspace()
    end

    scriptedShape.gui_keypadNegate = function (shape, buttonName)
        self:negate()
    end

    scriptedShape.gui_keypadDecimalPoint = function (shape, buttonName)
        self:decimalPoint()
    end

    scriptedShape.gui_keypadCloseCallback = function (shape)
        self:close()
    end
end

local function setCallbacks(self)
    for i = 0, 9, 1 do
        self.gui:setButtonCallback(tostring(i), "gui_keypadButtonCallback")
    end

    self.gui:setButtonCallback("Confirm", "gui_keypadConfirm")
    self.gui:setButtonCallback("Cancel", "gui_keypadCancel")
    self.gui:setButtonCallback("Clear", "gui_keypadClear")
    self.gui:setButtonCallback("Backspace", "gui_keypadBackspace")
    self.gui:setButtonCallback("Negate", "gui_keypadNegate")
    self.gui:setButtonCallback("DecimalPoint", "gui_keypadDecimalPoint")
    self.gui:setOnCloseCallback("gui_keypadCloseCallback")
end

function Keypad:__init(scriptedShape, title, onConfirmCallback, onCloseCallback)
    assert(onConfirmCallback ~= nil and type(onConfirmCallback) == "function", "Invalid confirm callback passed.")
    assert(onCloseCallback ~= nil and type(onCloseCallback) == "function", "Invalid close callback passed.")

    self.scriptedShape = scriptedShape
    self.buffer = ""
    self.hasDecimalPoint = false
    self.negative = false
    self.gui = sm.gui.createGuiFromLayout("$MOD_DATA/Gui/Keypad.layout")
    self.gui:setText("Title", title)

    self.confirm = function (shape, buttonName)
        onConfirmCallback(tonumber(self.buffer) or 0)
        self.gui:close()
    end

    self.close = function (shape, buttonName)
        onCloseCallback()
        self.buffer = ""
        self.hasDecimalPoint = false
        self.negative = false
    end

    generateCallbacks(self, scriptedShape)
    setCallbacks(self)
end

function Keypad:open(initialBuffer)
    if initialBuffer ~= nil and type(initialBuffer) == "number" then
        self.buffer = tostring(initialBuffer)
        self.hasDecimalPoint = initialBuffer % 1 ~= 0
        self.negative = initialBuffer < 0
    else
        self.buffer = "0"
    end

    self.gui:setText("Textbox", self.buffer)
    self.gui:open()
end

function Keypad:onButtonClick(buttonName)
    if self.buffer == "0" then
        self.buffer = buttonName
    elseif self.buffer == "-0" then
        self.buffer = "-" .. buttonName
    else
        self.buffer = self.buffer .. buttonName
    end

    self.gui:setText("Textbox", self.buffer)
end

function Keypad:cancel()
    self.gui:close()
end

function Keypad:clear()
    self.buffer = "0"
    self.hasDecimalPoint = false
    self.gui:setText("Textbox", self.buffer)
end

function Keypad:backspace()
    local tempBuffer = self.buffer:sub(1, -2)

    if self.hasDecimalPoint and tempBuffer:find(".", 1, true) == nil then
        self.hasDecimalPoint = false
    end

    self.buffer = #tempBuffer > 0 and tempBuffer or "0"
    self.gui:setText("Textbox", self.buffer)
end

function Keypad:negate()
    local number = tonumber(self.buffer) or 0
    number = number * -1
    self.hasDecimalPoint = number % 1 ~= 0
    self.negative = number < 0
    self.buffer = tostring(number)
    self.gui:setText("Textbox", self.buffer)
end

function Keypad:decimalPoint()
    if not self.hasDecimalPoint then
        self.hasDecimalPoint = true
        self.buffer = self.buffer .. "."
    end

    self.gui:setText("Textbox", self.buffer)
end

function Keypad:destroy()
    self.gui:destroy()
end
