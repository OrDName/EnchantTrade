local GPUHandler, TankHash, EnchantHash, ItemTransfer, METransfer, status = require("GPUHandler"), require("TankHash"), require("EnchantHash"), require("ItemTransfer"), require("METransfer"), require("status");
local Exchanger = {};
Exchanger.__index = Exchanger;
local ench_hash, tank_hash = EnchantHash:new(), TankHash:new();

ench_hash:update();
tank_hash:update();

local items = {
	{id = "dwcity:Dark_element", dmg = 0.0, name = "Элемент тьмы"},
	{id = "dwcity:Power_seal", dmg = 0.0, name = "Печать силы"}
};

local recipe = {
	{input = {items[1], ench_hash[1], tank_hash[2], 28}, output = {ench_hash[2], tank_hash[1]}}, -- Loot 4
	{input = {items[2], ench_hash[2], tank_hash[2], 140}, output = {ench_hash[3], tank_hash[1]}}, -- 5
	{input = {items[1], ench_hash[4], tank_hash[2], 28}, output = {ench_hash[5], tank_hash[1]}}, -- Luck 4
	{input = {items[2], ench_hash[5], tank_hash[2], 140}, output = {ench_hash[6], tank_hash[1]}}, -- 5
}

function Exchanger:new(player)
	local obj = {
		player = player,
		pim0 = ItemTransfer:new(player);
		me0 = METransfer:new(player);
	}
	setmetatable(obj, self)
	return obj;
end

function Exchanger:updateHash()
	ench_hash:update();
	tank_hash:update();
end

function Exchanger:findAll(fingerprint)
	return self.pim0:findAll(fingerprint);
end

function Exchanger:getRecipe()
	return recipe;
end

function Exchanger:getItems()
	return items;
end

function Exchanger:getEnch()
	return ench_hash;
end

function Exchanger:getTank()
	return tank_hash;
end

function Exchanger:trade(index)
	index = index or 1;
	local chosen = recipe[index];
	local p00, p01, p02, p03, p04, p05 = self.pim0:transfer(chosen.input[1], "DOWN", 1);
	local seal, seal_status = self.pim0.data, self.pim0.status;
	local p10, p11, p12, p13, p14, p15 = self.pim0:transfer(chosen.input[2], "DOWN", 1);
	local book, book_status = self.pim0.data, self.pim0.status;
	local p20, p21, p22, p23, p24, p25 = self.pim0:transfer(chosen.input[3], "DOWN", chosen.input[4]);
	local tank, tank_status = self.pim0.data, self.pim0.status;
	if (seal_status == status.success and book_status == status.success and tank_status == status.success) then
		self.me0:transfer(chosen.output[1], "UP", 1);
		self.me0:transfer(chosen.output[2], "UP", tank.qty)
	else
		local m0 = self.me0:transfer(seal.fingerprint, "UP", seal.qty);	
		local m1 = self.me0:transfer(book.fingerprint, "UP", book.qty);
		local m2 = self.me0:transfer(tank.fingerprint, "UP", tank.qty);
	end
end

return Exchanger;