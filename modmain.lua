local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local STRINGS = GLOBAL.STRINGS
local TECH = GLOBAL.TECH

PrefabFiles = {
	"winona_battery_high",
	"winona_battery_low",
	"winona_catapult",
	"winona_spotlight"
}

Assets = {

}
--AddMinimapAtlas("minimap/xhx.xml")

AddComponentPostInit("circuitnode", function(self)

	self.numactivenodes = 0 --电网有没有电值
	self.numnetnodes = 0
	function self:ConnectToNet(tag)
		if self.neighbors == nil then
			self.neighbors = {}
		end
		if tag ~= nil then
			local x, y, z = self.inst.Transform:GetWorldPosition()

			local my_platform = nil
			if not self.connectsacrossplatforms then
				my_platform = GLOBAL.TheWorld.Map:GetPlatformAtPoint(x, z)
			end

			for i, v in ipairs(GLOBAL.TheSim:FindEntities(x, y, z, self.range, { tag })) do
				if v ~= self.inst and v.entity:IsVisible() and v.components.circuitnode and v.components.circuitnode:IsEnabled() then
					if self.connectsacrossplatforms then
						self:AddNetNode(v)
					else
						local v_position = v:GetPosition()
						if GLOBAL.TheWorld.Map:GetPlatformAtPoint(v_position.x, v_position.z) == my_platform then
							self:AddNetNode(v)
						end
					end
				end
			end
		end
		return
	end

	function self:AddNetNode(node)
		if self.neighbors ~= nil and not self.neighbors[node] then
			self.neighbors[node] = true
			self.numnetnodes = self.numnetnodes + 1
			node.components.circuitnode:AddNetNode(self.inst)
		end
	end


	function self:ForEachNetNode(fn)
		local netlist = {}
		netlist[self.inst] = true
		self.inst.components.circuitnode:GetALLNetNode(netlist)
		for k, v in pairs(netlist) do
			fn(self.inst, k)
		end
	end


	function self:GetALLNetNode(netlist)
		if self.numnetnodes > 0 then
			for k, v in pairs(self.neighbors) do
				if not netlist[k] then
					netlist[k] = true
					k.components.circuitnode:GetALLNetNode(netlist)
				end
			end
		end
	end

	function self:DisconnectNet()
		while self.numnetnodes > 0 do
			self:RemoveNetNode(GLOBAL.next(self.neighbors))
		end
		self.neighbors = nil
	end

	function self:RemoveNetNode(netnode)
		if self.neighbors ~= nil and self.neighbors[netnode] then
			self.neighbors[netnode] = nil
			self.numnetnodes = self.numnetnodes - 1
			netnode.components.circuitnode:RemoveNetNode(self.inst)
		end
	end

	local oldOnRemoveEntity = self.OnRemoveEntity --self.<functionName>
	function self:OnRemoveEntity()
		self:DisconnectNet()
		oldOnRemoveEntity(self)
	end

	function self:AddActiveNodes()
		self:ForEachNetNode(function(inst, netnode)
			netnode.components.circuitnode.numactivenodes = netnode.components.circuitnode.numactivenodes + 1
			print("AddActiveNodes, numactivenodes:",netnode.components.circuitnode.numactivenodes)
		end)
	end

	function self:SubActiveNodes()
		self:ForEachNetNode(function(inst, netnode)
			netnode.components.circuitnode.numactivenodes = netnode.components.circuitnode.numactivenodes - 1
			print("SubActiveNodes, numactivenodes:",netnode.components.circuitnode.numactivenodes)
		end)
	end
end)