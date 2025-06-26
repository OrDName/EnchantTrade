local ItemHandler = {};
ItemHandler.__index = ItemHandler;

local component = require("component");
local me = component.proxy(require("config").me_main);

local items = {
	{id = "dwcity:Dark_element", dmg = 0.0, name_l = "Элемент тьмы", nbt_hash = nil},
	{id = "dwcity:Power_seal", dmg = 0.0, name_l = "Печать силы", nbt_hash = nil},
	{id = "OpenBlocks:tank", dmg = 0.0, fluid_container = {contents = nil}, name_l = "Резервуар", nbt_hash = nil},
	{id = "OpenBlocks:tank", dmg = 0.0, fluid_container = {contents = {amount = 16000, id = 65, name = "xpjuice"}}, name_l = "Резервуар (Жидкий опыт)", nbt_hash = nil},
	{id = "minecraft:enchanted_book", dmg = 0.0, enchanted_book = {{name = "enchantment.lootBonus", level = 3.0}}, name_l = "Добыча III", nbt_hash = nil},
	{id = "minecraft:enchanted_book", dmg = 0.0, enchanted_book = {{name = "enchantment.lootBonus", level = 4.0}}, name_l = "Добыча IV", nbt_hash = nil},
	{id = "minecraft:enchanted_book", dmg = 0.0, enchanted_book = {{name = "enchantment.lootBonus", level = 5.0}}, name_l = "Добыча V", nbt_hash = nil},
	{id = "minecraft:enchanted_book", dmg = 0.0, enchanted_book = {{name = "enchantment.lootBonusDigger", level = 3.0}}, name_l = "Удача III", nbt_hash = nil},
	{id = "minecraft:enchanted_book", dmg = 0.0, enchanted_book = {{name = "enchantment.lootBonusDigger", level = 4.0}}, name_l = "Удача IV", nbt_hash = nil},
	{id = "minecraft:enchanted_book", dmg = 0.0, enchanted_book = {{name = "enchantment.lootBonusDigger", level = 5.0}}, name_l = "Удача V", nbt_hash = nil},
};

local recipe = {
	{input = {{items[1], 1}, {items[5], 1}, {items[4], 28}}, output = {{items[6], 1}, {items[3], 0}}}, -- Loot 4
	{input = {{items[2], 1}, {items[6], 1}, {items[4], 140}}, output = {{items[7], 1}, {items[3], 0}}}, -- 5
	{input = {{items[1], 1}, {items[8], 1}, {items[4], 28}}, output = {{items[9], 1}, {items[3], 0}}}, -- Luck 4
	{input = {{items[2], 1}, {items[9], 1}, {items[4], 140}}, output = {{items[10], 1}, {items[3], 0}}}, -- 5
}

local function compare_fluids(f0, f1, i0_qty, i1_qty)
	if (not f0.contents and not f1.contents) then
		return true;
	elseif (f0.contents and not f1.contents or not f0.contents and f1.contents) then
		return false;
	elseif (f0.contents and f1.contents) then
		return f0.contents.name == f1.contents.name and ((f0.contents.amount / i0_qty) == (f1.contents.amount / i1_qty));
	end
end

local function compare_fluids_mp(f0, f1, i0_qty, i1_qty)
	if (not f0.name and not f1.contents) then
		return true;
	elseif (f0.name and not f1.contents or not f0.name and f1.contents) then
		return false;
	elseif (f0.name and f1.contents) then
		return f0.name == f1.contents.name and ((f0.amount / i0_qty) == (f1.contents.amount / i1_qty));
	end
end

local function compare_fluids_mm(f0, f1, i0_qty, i1_qty)
	if (not f0.name and not f1.name) then
		return true;
	elseif (f0.name and not f1.name or not f0.name and f1.name) then
		return false;
	elseif (f0.name and f1.name) then
		return f0.name == f1.name and ((f0.amount / i0_qty) == (f1.amount / i1_qty));
	end
end

function ItemHandler.compare_pp(i0, i1)
	local i0_qty, i1_qty = i0.qty or 1, i1.qty or 1;
	local fluid, ench = false, false;
	local f0, f1, e0, e1 = i0.fluid_container, i1.fluid_container, i0.enchanted_book, i1.enchanted_book;
	if (not f0 and not f1 and not e0 and not e1) then
		return i0.id == i1.id and i0.dmg == i1.dmg;
	end
	if (f0 and f1) then
		fluid = compare_fluids(f0, f1, i0_qty, i1_qty);
	end
	if (e0 and e1 and e0[1] and e1[1]) then
		ench = (e0[1].name == e1[1].name) and (e0[1].level == e1[1].level);
	end
	return i0.id == i1.id and i0.dmg == i1.dmg and (fluid or ench);
end

function ItemHandler.compare_mp(i0, i1)
	local i0_qty, i1_qty = i0.size or 1, i1.qty or 1;
	local fluid, ench = false, false;
	local f0, f1, e0, e1 = i0.fluid, i1.fluid_container, i0.enchantments, i1.enchanted_book;
	if (not f0 and not f1 and not e0 and not e1) then
		return i0.name == i1.id and i0.damage == i1.dmg;
	end
	if (f0 and f1) then
		fluid = compare_fluids_mp(f0, f1, i0_qty, i1_qty);
	end
	if (e0 and e1 and e0[1] and e1[1]) then
		ench = (e0[1].name == e1[1].name) and (e0[1].level == e1[1].level);
	end
	return i0.name == i1.id and i0.damage == i1.dmg and (fluid or ench);
end

function ItemHandler.compare_mm(i0, i1)
	local i0_qty, i1_qty = i0.size or 1, i1.size or 1;
	local fluid, ench = false, false;
	local f0, f1, e0, e1 = i0.fluid, i1.fluid, i0.enchantments, i1.enchantments;
	if (not f0 and not f1 and not e0 and not e1) then
		return i0.name == i1.name and i0.damage == i1.damage;
	end
	if (f0 and f1) then
		fluid = compare_fluids_mm(f0, f1, i0_qty, i1_qty);
	end
	if (e0 and e1 and e0[1] and e1[1]) then
		ench = (e0[1].name == e1[1].name) and (e0[1].level == e1[1].level);
	end
	return i0.name == i1.name and i0.damage == i1.damage and (fluid or ench);
end

function ItemHandler.updateHash(t_r)
	print("UPDATING HASH");
	for i, item in pairs(me.getAvailableItems("ALL")) do
		for j, fing in pairs(t_r) do
			if (ItemHandler.compare_pp(item.item, fing.output[1][1])) then
				fing.output[1][1].nbt_hash = item.fingerprint.nbt_hash;
			end
		end
	end
end

function ItemHandler.getRecipe()
	return recipe;
end

return ItemHandler;