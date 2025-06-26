local ItemHandler, Logger, GPUHandler, ItemTransfer, METransfer, status, config = require("ItemHandler"), require("Logger"), require("GPUHandler"), require("ItemTransfer"), require("METransfer"), require("status"), require("config");
local Exchanger = {};
Exchanger.__index = Exchanger;

local recipe = ItemHandler.getRecipe();
local compare_pp, compare_mp = ItemHandler.compare_pp, ItemHandler.compare_mp;

function Exchanger:new(player)
	local obj = {
		player = player,
		pim0 = ItemTransfer:new(player),
		me_main = METransfer:new(player, config.me_main),
		me_resv = METransfer:new(player, config.me_resv),
	}
	if (not obj.pim0 or not obj.me_main or not obj.me_resv) then
		return nil;
	end
	setmetatable(obj, self)
	return obj;
end

function Exchanger:findAll(fingerprint)
	return self.pim0:findAll(fingerprint);
end

function Exchanger:getRecipe()
	return recipe;
end

function Exchanger:b3validate(f)
	local me = self.me_resv.me;
	local b = {false, false, false};
	for i, item in pairs(me.getItemsInNetwork()) do
		if (b[1] and b[2] and b[3]) then
			break;
		end
		if (item) then
			for j = 1, 3 do
				if (compare_mp(item, f[j].fingerprint) and item.size == f[j].qty) then
					b[j] = true;
					break;
				end
			end
		end
	end
	return b[1] and b[2] and b[3];
end

function Exchanger:trade(index)
	index = index or 1;
	Logger:log("Exchanger | Player: " .. self.player .. " item index: " .. tostring(index));
	local chosen = recipe[index];
	local p00, p01, p02, p03, p04, p05 = self.pim0:transfer(chosen.input[1][1], "DOWN", chosen.input[1][2]);
	local seal, seal_status = self.pim0.data, self.pim0.status;
	local p10, p11, p12, p13, p14, p15 = self.pim0:transfer(chosen.input[2][1], "DOWN", chosen.input[2][2]);
	local book, book_status = self.pim0.data, self.pim0.status;
	local p20, p21, p22, p23, p24, p25 = self.pim0:transfer(chosen.input[3][1], "DOWN", chosen.input[3][2]);
	local tank, tank_status = self.pim0.data, self.pim0.status;
	if (seal_status == status.success and book_status == status.success and tank_status == status.success and self:b3validate({seal, book, tank})) then
		self.me_main:transfer(chosen.output[1][1], config.dir_main, chosen.output[1][2]);
		self.me_main:transfer(chosen.output[2][1], config.dir_main, tank.qty);
		Logger:log("Exchanger | Player: " .. self.player .. " success");
		self.me_resv:transfer(seal.fingerprint, "DOWN", seal.qty);
		self.me_resv:transfer(book.fingerprint, "DOWN", book.qty);
		self.me_resv:transfer(tank.fingerprint, "DOWN", tank.qty);
	else
		local m0 = self.me_resv:transfer(seal.fingerprint, config.dir_resv, seal.qty);	
		local m1 = self.me_resv:transfer(book.fingerprint, config.dir_resv, book.qty);
		local m2 = self.me_resv:transfer(tank.fingerprint, config.dir_resv, tank.qty);
		Logger:log("Exchanger | Player: " .. self.player .. " rollback " .. tostring(seal.qty) .. " " .. tostring(book.qty) .. " " .. tostring(tank.qty));
	end
end

return Exchanger;