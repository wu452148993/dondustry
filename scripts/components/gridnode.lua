local GridNode = Class(function(self, inst)
    self.inst = inst
    self.range = 5
    --self.onconnectfn = nil
    --self.ondisconnectfn = nil
    --self.nodes = nil
    self.numnodes = 0
    self.connectsacrossplatforms = true
    self.active = false
end)

function GridNode:OnRemoveEntity()
    self.ondisconnectfn = nil
    self:Disconnect()
end

GridNode.OnRemoveFromEntity = GridNode.OnRemoveEntity

function GridNode:IsEnabled()
    return self.nodes ~= nil
end

function GridNode:IsConnected()
    return self.numnodes > 0
end

function GridNode:NumConnectedNodes()
    return self.numnodes
end

function GridNode:ConnectTo(tag)
    if self.nodes == nil then
        self.nodes = {}
    end
    if tag ~= nil then
        local x, y, z = self.inst.Transform:GetWorldPosition()

        local my_platform = nil
        if not self.connectsacrossplatforms then
            my_platform = TheWorld.Map:GetPlatformAtPoint(x, z)
        end

        for i, v in ipairs(TheSim:FindEntities(x, y, z, self.range, { tag })) do
            if v ~= self.inst and v.entity:IsVisible() and v.components.gridnode and v.components.gridnode:IsEnabled() then
                if self.connectsacrossplatforms then
                    self:AddNode(v)
                else
                    local v_position = v:GetPosition()
                    if TheWorld.Map:GetPlatformAtPoint(v_position.x, v_position.z) == my_platform then
                        self:AddNode(v)
                    end
                end
            end
        end
    end
end

function GridNode:Disconnect()
    while self.numnodes > 0 do
        self:RemoveNode(next(self.nodes))
    end
    self.nodes = nil
end

function GridNode:SetRange(range)
    self.range = range
end

function GridNode:SetOnConnectFn(fn)
    self.onconnectfn = fn
end

function GridNode:SetOnDisconnectFn(fn)
    self.ondisconnectfn = fn
end

function GridNode:AddNode(node)
    if self.nodes ~= nil and not self.nodes[node] then
        self.nodes[node] = true
        self.numnodes = self.numnodes + 1
        if self.onconnectfn ~= nil then
            self.onconnectfn(self.inst, node)
        end
        node.components.gridnode:AddNode(self.inst)
    end
end

function GridNode:RemoveNode(node)
    if self.nodes ~= nil and self.nodes[node] then
        self.nodes[node] = nil
        self.numnodes = self.numnodes - 1
        if self.ondisconnectfn ~= nil then
            self.ondisconnectfn(self.inst, node)
        end
        node.components.gridnode:RemoveNode(self.inst)
    end
end

function GridNode:ForEachNode(fn)
    if self.numnodes > 0 then
        for k, v in pairs(self.nodes) do
            fn(self.inst, k)
        end
    end
end

function GridNode:ForAllGridNode(fn)
    local nodelist = {}
    nodelist[self.inst] = true
    self:GetALLNetNode(nodelist)
    for k, v in pairs(nodelist) do
        fn(self.inst, k)
    end
end

function GridNode:GetALLNetNode(nodelist)
    self:ForEachNode(function(inst, node)
        if not nodelist[node] then
            nodelist[node] = true
            node.components.gridnode:GetALLNetNode(nodelist)
        end
    end)
end

return GridNode
