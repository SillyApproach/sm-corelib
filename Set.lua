Set = class()
Set.keyProvider = nil
Set.array = nil
Set.length = nil
Set.serialiserTracker = nil

local function defaultKeyProvider(value)
    local uniqueKey

    if type(value) == "table" then
        uniqueKey = tostring(value)
    else
        uniqueKey = value
    end

    return uniqueKey
end

function Set:__init(keyProvider)
    self.keyProvider = keyProvider or defaultKeyProvider
    self.array = {}
    self.length = 0
    self.serialiserTracker = Set()
end

function Set:add(value)
    local uniqueKey = self.keyProvider(value)
    local isPresent = self.array[uniqueKey] ~= nil

    if not isPresent then
        self.array[uniqueKey] = value
        self.length = self.length + 1
    end

    return not isPresent
end

function Set:tryGet(value)
    return self:contains(value), self.array[self.keyProvider(value)] or value
end

function Set:remove(value)
    local uniqueKey = self.keyProvider(value)
    local isPresent = self.array[uniqueKey] ~= nil

    if isPresent then
        self.array[uniqueKey] = nil
        self.length = self.length - 1
    end

    return isPresent
end

function Set:map(predicate)
    local result = Set()

    for _, value in self:getIterator() do
        if predicate(value) then
            result:add(value)
        end
    end

    return result
end

function Set:contains(value)
    local uniqueKey = self.keyProvider(value)

    return self.array[uniqueKey] ~= nil
end

function Set:getLength()
    return self.length
end

function Set:isEmpty()
    return self.length == 0
end

function Set:getIterator()
    return pairs(self.array)
end

function Set:clone()
    local copy = Set(self.keyProvider)

    for _, value in self:getIterator() do
        copy:add(value)
    end

    return copy
end

function Set:toTable(serialiserUuid)
    serialiserUuid = serialiserUuid or sm.uuid.new()

    if not self.serialiserTracker:add(serialiserUuid) then
        return
    end

    local t = {}

    for _, value in self:getIterator() do
        if value.toTable ~= nil and type(value.toTable) == "function" then
            table.insert(t, value:toTable(serialiserUuid))
        else
            table.insert(t, value)
        end
    end

    self.serialiserTracker:remove(serialiserUuid)
    return t
end
