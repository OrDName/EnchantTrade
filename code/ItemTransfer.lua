local component, status, ItemHandler = require("component"), require("status"), require("ItemHandler");
local pim = component.pim;
local ItemTransfer = {};
ItemTransfer.__index = ItemTransfer;

local compare_pp = ItemHandler.compare_pp;

function ItemTransfer:new(player)
	local obj = {
		player = player,
		status = status.init,
		data = {
			fingerprint = nil,
			qty = 0
		}
	};
	setmetatable(obj, self);
	return obj;
end

function ItemTransfer:resetData()
	self.data = {
		fingerprint = nil,
		qty = 0
	};
end

function ItemTransfer:__tostring()
	return "player: " .. self.player .. ",	status: " .. self.status;
end

function ItemTransfer:findAll(fingerprint)
	local qty = 0;
	for i = 1, 40 do
		local item = pim.getStackInSlot(i);
		if (item and type(item) == "table" and fingerprint and type(fingerprint) == "table") then
			if (compare_pp(item, fingerprint)) then
				qty = qty + item.qty;
			end
		end
	end
	return qty;
end

function ItemTransfer:findItem(fingerprint)
	for i = 1, 40 do
		local item = pim.getStackInSlot(i);
		if (item and type(item) == "table" and fingerprint and type(fingerprint) == "table") then
			if (compare_pp(item, fingerprint)) then
				return true, i;
			end
		end
	end
	return false, -1;
end

function ItemTransfer:transfer(fingerprint, direction, qty)
	self:resetData();
	fingerprint = fingerprint or {id = "empty_shit", dmg = 0.0};
	direction = direction or "DOWN";
	qty = qty or 0;
	self.status = status.start;
	local total, tmp = 0, qty;
	local b, result = true, nil;
	local founded, slot = self:findItem(fingerprint);
	self.data.fingerprint = fingerprint;
	local item = nil;
	while (founded and total < qty) do
		item = pim.getStackInSlot(slot);
		if (not item or not compare_pp(item, fingerprint)) then
			founded, slot = self:findItem(fingerprint);
		end
		b, result = pcall(function() 
			local name = pim.getInventoryName();
			if (name ~= self.player) then
				self.status	= status.fail;
				return "Wrong user! Expected: " .. self.player .. ", got: " .. name;
			end
			return pim.pushItem(direction, slot, tmp); 
		end);
		if (not b or type(result) ~= "number") then
			break;
		end
		tmp = tmp - result;
		total = total + result;
		self.data.qty = total;
	end
	if (item) then
		self.data.fingerprint.nbt_hash = item.nbt_hash;
	end
	self.status = total == qty and status.success or status.fail;
	return total == qty, total, qty - total, founded, b, result;
end

return ItemTransfer;