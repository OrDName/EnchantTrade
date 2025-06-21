local component, config = require("component"), require("config");
local me = component.proxy(config.me_main);
local EnchantHash = {};
EnchantHash.__index = EnchantHash;

local reference = {
	{name = "enchantment.lootBonus", id = 21, lvl = 3},
	{name = "enchantment.lootBonus", id = 21, lvl = 4},
	{name = "enchantment.lootBonus", id = 21, lvl = 5},
	{name = "enchantment.lootBonusDigger", id = 35, lvl = 3},
	{name = "enchantment.lootBonusDigger", id = 35, lvl = 4},
	{name = "enchantment.lootBonusDigger", id = 35, lvl = 5}
}

function EnchantHash:new()
	obj = {
		{id = "minecraft:enchanted_book", dmg = 0.0, nbt_hash = "", name = "Добыча III"}, -- Loot 3
		{id = "minecraft:enchanted_book", dmg = 0.0, nbt_hash = "", name = "Добыча IV"}, -- 4
		{id = "minecraft:enchanted_book", dmg = 0.0, nbt_hash = "", name = "Добыча V"}, -- 5
		{id = "minecraft:enchanted_book", dmg = 0.0, nbt_hash = "", name = "Удача III"}, --Luck 3
		{id = "minecraft:enchanted_book", dmg = 0.0, nbt_hash = "", name = "Удача IV"}, -- 4
		{id = "minecraft:enchanted_book", dmg = 0.0, nbt_hash = "", name = "Удача V"} -- 5d
	}
	setmetatable(obj, self);
	return obj;
end

function EnchantHash:getReference()
	return reference;
end

function EnchantHash:update()
	for i, item in pairs(me.getItemsInNetwork()) do
		if (item) then
			if (item.enchantments) then
				for j = 1, #reference do
					local tmp = reference[j];
					if (item.enchantments[1].name == tmp.name and item.enchantments[1].level == tmp.lvl) then
						self[j].nbt_hash = me.getAvailableItems()[i].fingerprint.nbt_hash;
						break;
					end
				end
			end
		end
	end
end

return EnchantHash;