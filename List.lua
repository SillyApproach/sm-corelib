--- Provides functionalities to manage lists of objects
--- @class List
--- @field private array table<number, any> Table containing the list's elements
--- @field private length number Number of elements within the list
--- @field private serialiserTracker Set A set tracking serialisation, preventing recursive calls
List = class()

--- Constructor
--- @param size? number Initial size of the list
function List:__init(size)
    self.array = {}
    self.length = 0
    self.serialiserTracker = Set()
    size = type(size) == "number" and size or 0

    for i = 1, size, 1 do
        self:add(0)
    end
end

--- Checks whether the list contains the specified object
--- @param object any Object to check for
--- @return boolean @True if the list contains the specified object otherwise false
function List:contains(object)
    return self:indexOf(object) > 0
end

--- Adds the passed object to the list
--- @param object any The object to add
function List:add(object)
    self:insert(nil, object)
end

--- Inserts the passed object at the specified position in the list
--- @param i number Position in the list to insert the object
--- @param object any Object to insert
function List:insert(i, object)
    if not i then
        table.insert(self.array, object)
        self.length = self.length + 1
    elseif i > 0 and i <= self:getLength() then
        table.insert(self.array, i, object)
        self.length = self.length + 1
    end
end

--- Updates the value at the given index
--- @param i number Position in the list to update
--- @param object any New value for the given index
function List:update(i, object)
    assert(i > 0 and i <= self:getLength(), "Index out of bounds.")
    assert(object ~= nil, "Value can't be nil.")

    self.array[i] = object
end

--- Adds a range of objects to the end of the list.
--- <br>The range can be either a List object or a simple Lua table.
--- @param range List | table<number, any> Range to add
function List:addRange(range)
    if range.getIterator and type(range.getIterator) == "function" then
        for _, v in range:getIterator() do
            self:add(v)
        end
    else
        for _, v in ipairs(range) do
            self:add(v)
        end
    end
end

--- Removes the passed object from the list
--- @param object any Object to remove from the list
function List:remove(object)
    local i = self:indexOf(object)

    if i > 0 then
        self:removeAt(i)
    end
end

--- Removes an object at the specified position.
--- @param i number Position of the object to be removed
--- @raise Error if the index is out of bounds
function List:removeAt(i)
    assert(i > 0 and i <= self:getLength(), "Index out of bounds.")

    table.remove(self.array, i)
    self.length = self.length - 1
end

--- Removes all objects satisfying the passed matching expression.
--- @param match fun(number, any) : boolean Function which constitutes the matching expression
--- @return number @Number of matched items that have been removed
--- @raise Error if no matching expression has been passed
function List:removeAll(match)
    assert(match ~= nil, "Match can't be nil.")
    assert(type(match) == "function", "Argument of type function expected.")

    local removedItems = 0

    for i, v in self:getIterator() do
        if match(i, v) then
            self:removeAt(i)
            removedItems = removedItems + 1
        end
    end

    return removedItems
end

--- Clears the list from all its members and sets the length to zero
function List:clear()
    if not self:isEmpty() then
        self.array = {}
        self.length = 0
    end
end

--- Returns the length of the list.
--- @return number @Length of the list as number
function List:getLength()
    return self.length
end

--- Returns the first element of the list.
--- @return any @The object at first position
function List:getFirst()
    return self:getAt(1)
end

--- Returns the last element of the list.
--- @return any @Object at the last position
function List:getLast()
    return self:getAt(self:getLength())
end

--- Returns the object at the specified position.
--- @param i number Position of the object
--- @return any @Object at the specified position
--- @raise Error if the index is out of bounds
function List:getAt(i)
    assert(i > 0 and i <= self:getLength(), "Index out of range.")

    return self.array[i]
end

--- Looks for the passed object and returns its index if found.
--- @param object any Object to look for
--- @return number @Object's position in the list or -1 if there was no match
function List:indexOf(object)
    local index = -1

    for i, v in self:getIterator() do
        if object == v then
            index = i
            break
        end
    end

    return index
end

--- Creates a range of elements as List for the passed index and count.
--- @param index number Start position of the range
--- @param count number Number of elements for the range
--- @return List @Elements of specified range
--- @raise Error of either the index or the count of elements are out of range
function List:getRange(index, count)
    assert(index > 0 and index <= self:getLength(), "Index out of range.")
    assert(count >= 0 and index + count <= self:getLength(), "Index out of range.")

    local list = List()

    for i = index, index + (count - 1), 1 do
        list:add(self:getAt(i))
    end

    return list
end

--- Gets the iterator function for the list.
--- @generic T, V
--- @return (fun(table: V[], i: integer) : integer, V), T, integer @Iterator function
function List:getIterator()
    return ipairs(self.array)
end

--- Converts all it's members to simple Lua tables and returns an array of them.
--- @return table<number, any> @Generated simple table
function List:toTable(serialiserUuid)
    serialiserUuid = serialiserUuid or sm.uuid.new()

    if not self.serialiserTracker:add(serialiserUuid) then
        return
    end

    local t = {}

    for _, v in self:getIterator() do
        if v.toTable ~= nil and type(v.toTable) == "function" then
            table.insert(t, v:toTable(serialiserUuid))
        else
            table.insert(t, v)
        end
    end

    self.serialiserTracker:remove(serialiserUuid)
    return t
end

--- Reverses the list's order
function List:reverse()
    local stack = Stack()

    for _, v in self:getIterator() do
        stack:push(v)
    end

    for i, _ in self:getIterator() do
        self.array[i] = stack:pop()
    end
end

--- Clones the whole list and returns a shallow copy
--- @return List @Copy of the list
function List:clone()
    return self:getRange(1, self:getLength())
end

--- Checks whether the list is empty
--- @return boolean @True if the list is empty otherwise false
function List:isEmpty()
    return self:getLength() == 0
end

--- Creates a List of the objects satisfying the passed match expression
--- @local
--- @param self List List instance to look into
--- @param match fun(i: number, value: any) Match expression function
--- @param returnOnFirstOccurrence boolean Whether to stop the search at the first occurrence
--- @return List @Matching objects
--- @raise Error when no match expression has been passed
local function find(self, match, returnOnFirstOccurrence)
    assert(match ~= nil, "Match can't be nil.")
    assert(type(match) == "function", "Argument of type function expected.")

    local result = List()

    for i, v in self:getIterator() do
        if match(i, v) then
            result:add(v)

            if returnOnFirstOccurrence then
                break
            end
        end
    end

    return result
end

--- Search for the first occurrence of an object satisfying the match expression
--- @param match fun(i: number, value: any) Match expression function
--- @return any @First element satisfying the match expression
function List:find(match)
    return find(self, match, true):getFirst()
end

--- Search for the last occurrence of an object satisfying the match expression
--- @param match fun(i: number, value: any) Match expression function
--- @return any @Last element satisfying the match expression
function List:findLast(match)
    return find(self, match, false):getLast()
end

--- Search for all objects satisfying the match expression
--- @param match fun(i: number, value: any) Match expression function
--- @return List @Matching objects
function List:findAll(match)
    return find(self, match, false)
end

--- Search for an object satisfying the match expression and return its index
--- @param startIndex number Position to start the search from
--- @param elements number Range's amount of elements
--- @param match fun(i: number, value: any) Match expression function
--- @param returnOnFirstOccurrence boolean Whether to stop the search at the first occurrence
--- @return number @Index of the matched object or -1 if not found
--- @raise Error when no match expression has been passed
local function findIndexInRange(self, startIndex, elements, match, returnOnFirstOccurrence)
    assert(startIndex > 0 and startIndex <= self:getLength()
            and startIndex + elements <= self:getLength(),
            "Index out of range.")
    assert(match ~= nil, "Match can't be nil.")
    assert(type(match) == "function", "Argument of type function expected.")

    local index = -1

    for i = startIndex, startIndex + elements, 1 do
        if match(i, self:getAt(i)) then
            index = self:indexOf(self:getAt(i))

            if returnOnFirstOccurrence then
                break
            end
        end
    end

    return index
end

--- Searches and returns the index of the first occurence of an object satisfying the match expression
--- @param match fun(i: number, value: any) Match expression function
--- @return number @Index of the matched object or -1 if not found
--- @raise Error when no match expression has been passed
function List:findIndex(match)
    return findIndexInRange(self, 1, self:getLength(), match, true)
end

--- Searches and returns the index of the last occurence of an object satisfying the match expression
--- @param match fun(i: number, value: any) Match expression function
--- @return number @Index of the matched object or -1 if not found
--- @raise Error when no match expression has been passed
function List:findLastIndex(match)
    return findIndexInRange(self, 1, self:getLength(), match, false)
end

--- Searches from the specified position and returns the index of the first occurence of an object satisfying the match expression
--- @param index number Position to start from
--- @param match fun(i: number, value: any) Match expression function
--- @return number @Index of the matched object or -1 if not found
--- @raise Error when the index is out of bounds
function List:findIndexAfter(index, match)
    return findIndexInRange(self, index, self:getLength() - index + 1, match, true)
end

--- Searches and returns the index of the first occurence of an object satisfying the match expression in the specified range
--- @param index number Position to start from
--- @param elements number Range's amount of elements
--- @param match fun(i: number, value: any) Match expression function
--- @return number @Index of the matched object or -1 if not found
--- @raise Error when the range is out of bounds
function List:findIndexInRange(index, elements, match)
    return findIndexInRange(self, index, elements, match, true)
end

--- Checks whether the list contains an object satisfying the match expression
--- @param match fun(i: number, value: any) Match expression function
--- @return boolean @True on the first occurrence otherwise false
function List:exists(match)
    return self:find(match) ~= nil
end
