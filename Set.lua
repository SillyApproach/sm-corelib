--- A data structure saving unique elements only once.
--- <br>Can be used to implement mathematical sets and query their elements with a predicate function.
--- @class Set
--- @field private keyProvider KeyProvider Function generating keys for added elements
--- @field private array table<K, V> Table containing the set's elements
--- @field private length number Current number of elements
--- @field private serialiserTracker Set A set tracking serialisation, preventing recursive calls
Set = class()

--- @generic K, V
--- @alias KeyProvider fun(value: any): K
--- @alias Predicate fun(value: V): boolean

--- Default key provider if none is passed
--- @param value any Value to generate key for
--- @return any @Generated key
local function defaultKeyProvider(value)
    return value
end

--- Constructor
--- @param keyProvider KeyProvider
function Set:__init(keyProvider)
    self.keyProvider = keyProvider or defaultKeyProvider
    self.array = {}
    self.length = 0
    self.serialiserTracker = Set()
end

--- Adds a new value to the set
--- @param value any Value to add
--- @return boolean @True if value could be added, false if a similar keyed value exists
function Set:add(value)
    local uniqueKey = self.keyProvider(value)
    local isPresent = self.array[uniqueKey] ~= nil

    if not isPresent then
        self.array[uniqueKey] = value
        self.length = self.length + 1
    end

    return not isPresent
end

--- Tries to obtain the value if it exists
--- @param value any Value to obtain
--- @return boolean @True if the set contains the value
--- @return any @Queried value if it is an element of this set
function Set:tryGet(value)
    return self:contains(value), self.array[self.keyProvider(value)] or value
end

--- Removes the given value from the set
--- @param value any Value to remove
--- @return boolean @True if the value was an element of the set and successfully removed
function Set:remove(value)
    local uniqueKey = self.keyProvider(value)
    local isPresent = self.array[uniqueKey] ~= nil

    if isPresent then
        self.array[uniqueKey] = nil
        self.length = self.length - 1
    end

    return isPresent
end

--- Maps the set's values according to the condition given by the prdicate `func`
--- @param predicate Predicate Predicate defining matching criteria for values
--- @return Set @Set with the matched values
function Set:map(predicate)
    local result = Set()

    for _, value in self:getIterator() do
        if predicate(value) then
            result:add(value)
        end
    end

    return result
end

--- Checks whether a value is an element of the set
--- @param value any Element to check for
--- @return boolean @True if the value is element of the set otherwise false
function Set:contains(value)
    local uniqueKey = self.keyProvider(value)

    return self.array[uniqueKey] ~= nil
end

--- Returns the number of objects in the set
--- @return number @Current number of objects
function Set:getLength()
    return self.length
end

--- Checks whether the set is empty
--- @return boolean @True if it is emtpy otherwise false
function Set:isEmpty()
    return self.length == 0
end

--- Gets the iterator function for the set
--- @usage for k, v in mySet:getIterator() do end
--- @return function @Iterator function
function Set:getIterator()
    return pairs(self.array)
end

--- Clones the whole set and returns a copy
--- This is a shallow copy, only the element's references are copied
--- @return Set @Shallow copy of the set
function Set:clone()
    local copy = Set(self.keyProvider)

    for _, value in self:getIterator() do
        copy:add(value)
    end

    return copy
end

--- Converts all it's members to pure Lua tables and returns that table
--- @return table @Generated pure Lua table
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
