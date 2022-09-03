--- A registry tracking shapes within the world
--- @class ScriptedShapeRegistry
ScriptedShapeRegistry = class()

--- Constructor
function ScriptedShapeRegistry:__init()
    self.shapeMap = Dictionary()
    self.interactableMap = Dictionary()
end

--- Registers a newly created shape
--- @param scriptedShape ShapeClass Scripted shape instance to register
function ScriptedShapeRegistry:registerShape(scriptedShape)
    self.shapeMap:add(scriptedShape.shape:getId(), scriptedShape)
    self.interactableMap:add(scriptedShape.interactable:getId(), scriptedShape)
end

--- Deregisters a shape that has been destroyed
--- @param scriptedShape ShapeClass Scritped shape instance to deregister
function ScriptedShapeRegistry:deregisterShape(scriptedShape)
    self.shapeMap:remove(scriptedShape.shape:getId())
    self.interactableMap:remove(scriptedShape.interactable:getId())
end

--- Searches and returns a shape by the given shape id if found
--- @param shapeId number Shape id
--- @return ShapeClass | nil @Instance of shape
function ScriptedShapeRegistry:getShapeByShapeId(shapeId)
    local _, value = self.shapeMap:tryGet(shapeId)
    return value
end

--- Searches and returns a shape by the given interactable id if found
--- @param interactableId number Interactable id
--- @return ShapeClass | nil @Instance of shape
function ScriptedShapeRegistry:getShapeByInteractableId(interactableId)
    local _, value = self.interactableMap:tryGet(interactableId)
    return value
end

--- Returns all registered shapes of the specified Uuid
--- @param uuid Uuid Uuid to search for
--- @return List<ShapeClass> @All shapes matching the passed Uuid
function ScriptedShapeRegistry:getShapesByUuid(uuid)
    local shapes = List()
    uuid = type(uuid) == "string" and sm.uuid.new(uuid) or uuid

    for k, scriptedShape in self.shapeMap:getIterator() do
        if scriptedShape.shape:getShapeUuid() == uuid then
            shapes:add(scriptedShape)
        end
    end

    return shapes
end

sm.game.scriptedShapes = ScriptedShapeRegistry()
