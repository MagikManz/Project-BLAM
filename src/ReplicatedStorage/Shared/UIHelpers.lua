local CollectionService = game:GetService("CollectionService")

local Helpers = { }

function Helpers.WaitForTaggedObject(tagName: string, ancestor: any?)
    local taggedItems = CollectionService:GetTagged(tagName)
    for _, item in ipairs(taggedItems) do
        if not ancestor or ancestor:IsAncestorOf(item) then
            return item
        end
    end

    local connection
    local item
    connection = CollectionService:GetInstanceAddedSignal(tagName):Connect(function(taggedItem)
        if ancestor and not ancestor:IsAncestorOf(taggedItem) then return end

        item = taggedItem
        connection:Disconnect()
    end)

    local t = 0
    while not item do
        t += task.wait()
        if t > 4 then
            warn("Global.WaitForTaggedObject Infinite yield possibility on tag", tagName)
            t = 0
        end
    end

    return item
end

function Helpers.GetTaggedObjects(tagName: string, ancestor: any?)
    local taggedItems = CollectionService:GetTagged(tagName)

    local items = { }
    for _, item in ipairs(taggedItems) do
        if not ancestor or ancestor:IsAncestorOf(item) then
            table.insert(items, item)
        end
    end

    return items
end

return table.freeze(Helpers)
