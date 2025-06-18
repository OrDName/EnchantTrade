local component = require("component");
local me = component.me_interface;
local TankHash = {};
TankHash.__index = TankHash;

local reference = {
	{name = nil},
	{name = "xpjuice"}
}

function TankHash:new() 
	obj = {
		{id = "OpenBlocks:tank", dmg = 0.0, nbt_hash = "", name = "Резервуар"}, --Empty OB tank
		{id = "OpenBlocks:tank", dmg = 0.0, nbt_hash = "", name = "Резервуар (Жидкий опыт)"} -- Xp OB tank
	}
	setmetatable(obj, self);
	return obj;
end

function TankHash:update()
	for i, item in pairs(me.getItemsInNetwork()) do
		if (item) then
			local tank = item.fluid;
			if (tank) then
				for j = 1, #reference do
					if (tank.name == reference[j].name) then
						self[j].nbt_hash = me.getAvailableItems()[i].fingerprint.nbt_hash;
						break
					end
				end
			end
		end
	end
end

return TankHash;