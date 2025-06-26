local items = {
	{id = "dwcity:Dark_element", dmg = 0.0, name_l = "Элемент тьмы"},
	{id = "dwcity:Power_seal", dmg = 0.0, name_l = "Печать силы"},
	{id = "OpenBlocks:tank", dmg = 0.0, fluid_container = {contents = nil}, name_l = "Резервуар"},
	{id = "OpenBlocks:tank", dmg = 0.0, fluid_container = {contents = {amount = 16000, id = 65, name = "xpjuice"}}, name_l = "Резервуар (Жидкий опыт)"},
	{id = "minecraft:enchanted_book", dmg = 0.0, enchanted_book = {name = "enchantment.lootBonus", level = 3.0}, name_l = "Добыча III"},
	{id = "minecraft:enchanted_book", dmg = 0.0, enchanted_book = {name = "enchantment.lootBonus", level = 4.0}, name_l = "Добыча IV"},
	{id = "minecraft:enchanted_book", dmg = 0.0, enchanted_book = {name = "enchantment.lootBonus", level = 5.0}, name_l = "Добыча V"},
	{id = "minecraft:enchanted_book", dmg = 0.0, enchanted_book = {name = "enchantment.lootBonusDigger", level = 3.0}, name_l = "Удача III"},
	{id = "minecraft:enchanted_book", dmg = 0.0, enchanted_book = {name = "enchantment.lootBonusDigger", level = 4.0}, name_l = "Удача IV"},
	{id = "minecraft:enchanted_book", dmg = 0.0, enchanted_book = {name = "enchantment.lootBonusDigger", level = 5.0}, name_l = "Удача V"},
};

local recipe = {
	{input = {{items[1], 1}, {items[5], 1}, {items[4], 28}}, output = {{items[6], 1}, {items[3], 0}}}, -- Loot 4
	{input = {{items[2], 1}, {items[6], 1}, {items[4], 140}}, output = {{items[7], 1}, {items[3], 0}}}, -- 5
	{input = {{items[1], 1}, {items[8], 1}, {items[4], 28}}, output = {{items[9], 1}, {items[3], 0}}}, -- Luck 4
	{input = {{items[2], 1}, {items[9], 1}, {items[4], 140}}, output = {{items[10], 1}, {items[3], 0}}}, -- 5
}

function compare_pp(i0, i1)
	if (not i0.id or not i1.id or i0.id ~= i1.id or i0.dmg ~= i1.dmg) then
		return false;
	end
	local i0_qty, i1_qty = i0.qty or 1, i1.qty or 1;
	local fluid, ench = true, true;
	local f0, f1, e0, e1 = i0.fluid_container, i1.fluid_container, i0.enchanted_book, i1.enchanted_book;
	if (f0 and f1 and f0.contents and f1.contents) then
		fluid = f0.contents.name == f1.contents.name and ((f0.contents.amount / i0_qty) == (f1.contents.amount / i1_qty));
	end
	if (e0 and e1 and e0[1] and e1[1]) then
		ench = (e0[1].name == e1[1].name) and (e0[1].level == e1[1].level);
	end
	return fluid and ench;
end

function compare_mp(i0, i1)
	if (not i0.name or not i1.id or i0.name ~= i1.id or i0.damage ~= i1.dmg) then
		return false;
	end
	local i0_qty, i1_qty = i0.size or 1, i1.qty or 1;
	local fluid, ench = true, true;
	local f0, f1, e0, e1 = i0.fluid, i1.fluid_container, i0.enchantments, i1.enchanted_book;
	if (f0 and f1 and f0.name and f1.contents) then
		fluid = f0.name == f1.contents.name and ((f0.amount / i0_qty) == (f1.contents.amount / i1_qty));
	end
	if (e0 and e1 and e0[1] and e1[1]) then
		ench = (e0[1].name == e1[1].name) and (e0[1].level == e1[1].level);
	end
	return fluid and ench;
end

function getRecipe()
	return recipe;
end