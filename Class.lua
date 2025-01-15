sm._class = sm._class or class
local function emptyCtor() end
local function defaultIndex(self, key) return self[key] end
local function defaultNewindex(self, key, value) self[key] = value end

--- Extends the current class function with a callable constructor.
--- <br>The function is backwards compatible with the default implemenation.
--- @param superType? table Super class to inherit from
--- @return table @Prototype table representing the new class
function class(superType)
    local proxy, newType = sm._class()

    if superType ~= nil then
        newType = superType._type ~= nil and sm._class(superType._type) or sm._class(superType)
    else
        newType = sm._class()
    end

    function proxy:__call(...)
        newType.__init = newType.__init or emptyCtor

        if not newType.__indexDefined then
            newType.__get = type(newType.__index) == "function" and newType.__index or defaultIndex
            newType.__set = newType.__newindex or defaultNewindex
            newType.__index = newType
            newType.__newindex = nil
            newType.__indexDefined = true
        end

        local instance = newType()
        local pInstanceType = sm._class()

        function pInstanceType:__index(key)
            return newType.__get(instance, key)
        end

        function pInstanceType:__newindex(key, value)
            newType.__set(instance, key, value)
        end

        instance:__init(...)

        return pInstanceType()
    end

    function proxy:__index(key)
        if (key == "_type") then
            return newType
        end

        return newType[key]
    end

    function proxy:__newindex(key, value)
        newType[key] = value
    end

    return proxy()
end
