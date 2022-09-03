--- Stack implementation providing typical stack operations
--- @class Stack
--- @field private array table<any> Table containing the stack's elements
--- @field private length number Current number of elements
Stack = class()

--- Constructor
function Stack:__init()
    self.array = {}
    self.length = 0
end

--- Pushes an element onto the stack
--- @param object any Element to push onto the stack
function Stack:push(object)
    table.insert(self.array, object)
    self.length = self.length + 1
end

--- Pops the next element from the stack
--- @return any @Next available element
function Stack:pop()
    self.length = self.length - 1
    return table.remove(self.array)
end

--- Returns the number of elements within the stack
--- @return number
function Stack:getLength()
    return self.length
end

--- Returns the next available element on the stack without modifying it
--- @return any @Next available element
function Stack:peek()
    return self.array[self:getLength()]
end

--- Checks whether the stack is empty
--- @return boolean @True if empty otherwise false
function Stack:isEmpty()
    return self:getLength() == 0
end

--- Checks whether the given element is stored within the stack
--- @param object any Element to search for
--- @return boolean @True if the element is found otherwise false
function Stack:contains(object)
    local contains = false

    for i, v in ipairs(self.array) do
        contains = object == v

        if contains then
            break
        end
    end

    return contains
end

--- Clears the stack
function Stack:clear()
    if not self:isEmpty() then
        self.array = {}
        self.length = 0
    end
end
