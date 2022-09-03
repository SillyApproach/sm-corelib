--- Provides functionalities to map keys to values
--- @class Dictionary
--- @field private array table<any, any> Table containing the dictionary's elements
--- @field private length number Number of elements within the dictionary
--- @field private serialiserTracker Set A set tracking serialisation, preventing recursive calls
Dictionary = class()

--- Constructor
function Dictionary:__init()
    self.array = {}
    self.length = 0
    self.serialiserTracker = Set()
end

--- Adds an object with the specified key
--- @param key any The entry's key
--- @param value any Object to be associated with the key
--- @raise Error when a key is already in use
function Dictionary:add(key, value)
    assert(not self:containsKey(key), "Key is already in use.")

    self.array[key] = value
    self.length = self.length + 1
end

--- Tries adding an object with the specified key
--- @param key any The entry's key
--- @param value any Object to be associated with the key
--- @return boolean @Whether the key value pair was successfully added
function Dictionary:tryAdd(key, value)
    local kvPairAdded = false

    if not self:containsKey(key) then
        self.array[key] = value
        self.length = self.length + 1
        kvPairAdded = true
    end

    return kvPairAdded
end

--- Gets the object associated with the key
--- @param key any Key to look for
--- @return any @Object associated with the key
--- @raise Error if there is no entry with the specified key
function Dictionary:get(key)
    assert(self:containsKey(key), "Key not found.")

    return self.array[key]
end

--- Tries to get the object associated with the key
--- @param key any Key to look for
--- @return boolean, any @Whether the key exists and the respective value on success
function Dictionary:tryGet(key)
    return self:containsKey(key), self.array[key]
end

--- Sets the value associated with the key
--- @param key any The entry's key
--- @param value any Value to set
--- @raise Error if there is no entry with the specified key
function Dictionary:update(key, value)
    assert(self:containsKey(key), "Key not found.")

    self.array[key] = value
end

--- Removes the object associated with the key
--- @param key any Key to look for
--- @return boolean @True if sucessfully removed otherwise false
function Dictionary:remove(key)
    local removed = false

    if self:containsKey(key) then
        self.array[key] = nil
        self.length = self.length - 1
        removed = true
    end

    return removed
end

--- Returns the iterator function for the dictionary
--- @usage for k, v in myDictionary:getIterator() do end
--- @generic T, K, V
--- @return (fun(table: table<K, V>, index?: K) : K, V), T @Iterator function
function Dictionary:getIterator()
    return pairs(self.array)
end

--- Returns the number of objects in the dictionary
--- @return number @Current number of objects
function Dictionary:getLength()
    return self.length
end

--- Checks whether the dictionary is empty
--- @return boolean @True if the dictionary is empty otherwise false
function Dictionary:isEmpty()
    return self:getLength() == 0
end

--- Returns a shallow copy
--- @return Dictionary @Shallow copy
function Dictionary:clone()
    local dict = Dictionary()

    for k, v in self:getIterator() do
        dict:add(k, v)
    end

    return dict
end

--- Clears the dictionary
function Dictionary:clear()
    if not self:isEmpty() then
        self.array = {}
        self.length = 0
    end
end

--- Checks for the existence of the specified key
--- @param key any Key to check for
--- @return boolean @True if the key has an entry otherwise false
function Dictionary:containsKey(key)
    assert(key ~= nil, "Key can't be nil.")

    return self.array[key] ~= nil
end

--- Checks for the existence of the specified object
--- @param value any Object to check for
--- @return boolean @True if there is an entry for the specified object otherwise false
function Dictionary:containsValue(value)
    local contains = false

    for k, v in self:getIterator() do
        contains = v == value

        if contains then
            break
        end
    end

    return contains
end

--- Generates a List with a copy of all the keys in the dictionary
--- @return List @List of all current keys
function Dictionary:getKeys()
    local keys = List()

    for k, v in self:getIterator() do
        keys:add(k)
    end

    return keys
end

--- Generates a List with a copy of all the objects in the dictionary
--- @return List @List of all current objects
function Dictionary:getValues()
    local values = List()

    for k, v in self:getIterator() do
        values:add(v)
    end

    return values
end

--- Converts all it's members to simple Lua tables and returns it
--- @generic K, V
--- @return table<K, V> @Generated associative array
function Dictionary:toTable(serialiserUuid)
    serialiserUuid = serialiserUuid or sm.uuid.new()

    if not self.serialiserTracker:add(serialiserUuid) then
        return
    end

    local t = {}

    for k, v in self:getIterator() do
        if v.toTable ~= nil and type(v.toTable) == "function" then
            t[k] = v:toTable(serialiserUuid)
        else
            t[k] = v
        end
    end

    self.serialiserTracker:remove(serialiserUuid)
    return t
end
