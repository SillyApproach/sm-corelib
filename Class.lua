sm._class = sm._class or class
local function emptyCtor() end

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
        local instance = newType()
        instance:__init(...)

        return instance
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
