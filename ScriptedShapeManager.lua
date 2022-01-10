ScriptedShapeManager = class()
ScriptedShapeManager.shapeMap = nil
ScriptedShapeManager.interactableMap = nil

function ScriptedShapeManager:__init()
    self.shapeMap = Dictionary()
    self.interactableMap = Dictionary()
end

function ScriptedShapeManager:registerShape(scriptedShape)
    self.shapeMap:add(scriptedShape.shape:getId(), scriptedShape)
    self.interactableMap:add(scriptedShape.interactable:getId(), scriptedShape)
end

function ScriptedShapeManager:deregisterShape(scriptedShape)
    self.shapeMap:remove(scriptedShape.shape:getId())
    self.interactableMap:remove(scriptedShape.interactable:getId())
end

function ScriptedShapeManager:getShapeByShapeId(shapeId)
    local _, value = self.shapeMap:tryGet(shapeId)
    return value
end

function ScriptedShapeManager:getShapeByInteractableId(interactableId)
    local _, value = self.interactableMap:tryGet(interactableId)
    return value
end

function ScriptedShapeManager:getShapesByUuid(uuid)
    local shapes = List()
    uuid = type(uuid) == "string" and sm.uuid.new(uuid) or uuid

    for k, scriptedShape in self.shapeMap:getIterator() do
        if scriptedShape.shape:getShapeUuid() == uuid then
            shapes:add(scriptedShape)
        end
    end

    return shapes
end

sm.game.scriptedShapes = ScriptedShapeManager()
