--- A queue data structure saving and retrieving objects with a first in first out mechanism
--- @class Queue
--- @field private array table<any> Table containing the queue's elements
--- @field private length number Number of elements within the dictionary
Queue = class()

--- Constructor
function Queue:__init()
    self.array = {}
    self.length = 0
end

--- Enqueues an object
--- @param object any Object to enqueue
function Queue:enqueue(object)
    table.insert(self.array, object)
    self.length = self.length + 1
end

--- Dequeues the next object
--- @return any @Deqeueued object
function Queue:dequeue()
    self.length = self.length - 1
    return table.remove(self.array, 1)
end

--- Peek the next available object without modifying the queue
--- @return any @Next available object
function Queue:peek()
    return self.array[1]
end

--- Returns the number of elements in the queue
--- @return number @Number of queued elements
function Queue:getLength()
    return self.length
end

--- Checks whether the queue is empty
--- @return boolean @True if empty otherwise false
function Queue:isEmpty()
    return self:getLength() == 0
end

--- Clears the queue
function Queue:clear()
    if not self:isEmpty() then
        self.array = {}
        self.length = 0
    end
end
