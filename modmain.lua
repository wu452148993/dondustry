GLOBAL.setmetatable(
	env,
	{
		__index = function(t, k)
			return GLOBAL.rawget(GLOBAL, k)
		end
	}
)


local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local STRINGS = GLOBAL.STRINGS
local TECH = GLOBAL.TECH

PrefabFiles = {
	"winona_battery_low","winona_battery_high",
}

local containers = require "containers"

local params = {}

local function Make3x3Chest()
	local chest = {
		widget = {
			slotpos = {},
			animbank = "ui_chest_3x3",
			animbuild = "ui_chest_3x3",
			pos = GLOBAL.Vector3(0, 200, 0),
			side_align_tip = 160
		},
		type = "chest"
	}

	for y = 2, 0, -1 do
		for x = 0, 2 do
			table.insert(chest.widget.slotpos, GLOBAL.Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
		end
	end

	return chest
end

-- used the same script of the mod "Large Chest" (workshop-396026892) to make this container setup
-- More like a "Copy and Paste" of the function... I've learned a lot reading the scripts from your mod, so, thanks!

local function ItemCheck(item)
    if item == nil then
        return false
    elseif string.sub(item.prefab, -3) ~= "gem" then
        return false, "NOTGEM"
    elseif string.sub(item.prefab, -11, -4) == "precious" then
        return false, "WRONGGEM"
    end
    return true
end

local containers_widgetsetup_old = containers.widgetsetup
function containers.widgetsetup(container, prefab, data, ...)
	local t = params[prefab or container.inst.prefab]
	if t ~= nil then
		for k, v in pairs(t) do
			container[k] = v
		end
		container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
	else
		containers_widgetsetup_old(container, prefab, data, ...)
	end
end

params.battery_continue = Make3x3Chest()
function params.battery_continue.itemtestfn(container, item, slot)
	return ItemCheck(item)
end
