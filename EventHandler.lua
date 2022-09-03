--- Provides a simple way to define raisable events
--- @class EventHandler
--- @field private handler Dictionary Invokable event handler functions
EventHandler = class()

--- @alias EventCallback fun(sender: any, ...?: any):boolean

--- Constructor
--- @param initialHandler EventCallback An initial handler function
function EventHandler:__init(initialHandler)
    self.handler = Dictionary()
    _= self + initialHandler
end

--- Overloads the + operator for a simple subscription notation. One operand must be a function.
--- @param a EventHandler | EventCallback Function or the EventHandler object
--- @param b EventHandler | EventCallback Function or the EventHandler object
--- @return EventHandler @Updated EventHandler
--- @raise Error if no event handler function was passed
function EventHandler.__add(a, b)
    ---@type EventHandler
    local eventHandler

    if type(a) == "function" then
        b.handler:add(tostring(a), a)
        eventHandler = b
    elseif type(b) == "function" then
        a.handler:add(tostring(b), b)
        eventHandler = a
    else
        error("You need to provide a function")
    end

    return eventHandler
end

--- Overloads the - operator for a simple unsubscription notation. One operand must be a function.
--- @param a EventHandler | EventCallback Function or the EventHandler object
--- @param b EventHandler | EventCallback Function or the EventHandler object
--- @return EventHandler @Udpated EventHandler
--- @raise Error if no event handler function was passed
function EventHandler.__sub(a, b)
    local eventHandler

    if type(a) == "function" then
        b.handler:remove(tostring(a))
        eventHandler = b
    elseif type(b) == "function" then
        a.handler:remove(tostring(b))
        eventHandler = a
    else
        error("You need to provide a function")
    end

    return eventHandler
end

--- Raises the event with the specified sender and event arguments
--- @param sender any Object raising the event
--- @vararg any Event specific arguments to be passed
function EventHandler:__call(sender, ...)
    for _, v in self.handler:getIterator() do
        v(sender, ...)
    end
end

--- Checks whether the event has registered subscribers
--- @return boolean @True if there is at least one subscirber otherwise false
function EventHandler:hasSubscribers()
    return not self.handler:isEmpty()
end

--- Clears the list of all event handlers
function EventHandler:clearAll()
    self.handler:clear()
end
