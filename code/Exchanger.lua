local Logger, GPUHandler, TankHash, EnchantHash, ItemTransfer, METransfer, status = require("Logger"), require("GPUHandler"), require("TankHash"), require("EnchantHash"), require("ItemTransfer"), require("METransfer"), require("status");
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
		pim0 = ItemTransfer:new(player),
		me_main = METransfer:new(player, "19e93c34-147d-4ce2-a810-accbc54e8015"),
		me_resv = METransfer:new(player, "28b60e49-316b-4bf7-a296-b700ce275ba4"),
	}
	if (not obj.pim0 or not obj.me_main or not obj.me_resv) then
		return nil;
	end
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

local function compareItems(item0, item1)
	return item0.id == item1.id and item0.dmg == item1.dmg and item0.nbt_hash == item1.nbt_hash;
end

function Exchanger:validate(f)
	local me = self.me_resv.me;
	local b = {false, false, false};
	for i, item in pairs(me.getAvailableItems()) do
		if (b[1] and b[2] and b[3]) then
			break;
		end
		if (item) then
			for j = 1, 3 do
				if (compareItems(item.fingerprint, f[j].fingerprint) and item.size == f[j].qty) then
					b[j] = true;
					break;
				end
			end
		end
	end
	return b[1] and b[2] and b[3];
end

function Exchanger:trade(index, main_dir, resv_dir)
	index = index or 1;
	Logger:log("Exchanger | Player: " .. self.player .. " item index: " .. tostring(index));
	local chosen = recipe[index];
	local p00, p01, p02, p03, p04, p05 = self.pim0:transfer(chosen.input[1], "DOWN", 1);
	local seal, seal_status = self.pim0.data, self.pim0.status;
	local p10, p11, p12, p13, p14, p15 = self.pim0:transfer(chosen.input[2], "DOWN", 1);
	local book, book_status = self.pim0.data, self.pim0.status;
	local p20, p21, p22, p23, p24, p25 = self.pim0:transfer(chosen.input[3], "DOWN", chosen.input[4]);
	local tank, tank_status = self.pim0.data, self.pim0.status;
	if (seal_status == status.success and book_status == status.success and tank_status == status.success and self:validate({seal, book, tank})) then
		self.me_main:transfer(chosen.output[1], main_dir, 1);
		self.me_main:transfer(chosen.output[2], main_dir, tank.qty);
		Logger:log("Exchanger | Player: " .. self.player .. " success");
		self.me_resv:transfer(seal.fingerprint, "DOWN", seal.qty);
		self.me_resv:transfer(book.fingerprint, "DOWN", book.qty);
		self.me_resv:transfer(tank.fingerprint, "DOWN", tank.qty);
	else
		local m0 = self.me_resv:transfer(seal.fingerprint, resv_dir, seal.qty);	
		local m1 = self.me_resv:transfer(book.fingerprint, resv_dir, book.qty);
		local m2 = self.me_resv:transfer(tank.fingerprint, resv_dir, tank.qty);
		Logger:log("Exchanger | Player: " .. self.player .. " rollback " .. tostring(seal.qty) .. " " .. tostring(book.qty) .. " " .. tostring(tank.qty));
	end
end

return Exchanger;