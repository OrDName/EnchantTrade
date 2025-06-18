local component, status = require("component"), require("status");
local pim, me = component.pim, component.me_interface;
local METransfer = {};
METransfer.__index = METransfer;

function METransfer:new(player)
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

function METransfer:resetData()
	self.data = {
		fingerprint = nil,
		qty = 0
	};
end

function METransfer:__tostring()
	return "player: " .. self.player .. ",	status: " .. self.status;
end

function METransfer:transfer(fingerprint, direction, qty)
	self:resetData();
	fingerprint = fingerprint or {id = "empty_shit", dmg = 0.0};
	direction = direction or "DOWN";
	qty = qty or 0;
	self.status = status.start;
	local total, tmp = 0, qty;
	local b, result = true, nil;
	self.data.fingerprint = fingerprint;
	while (b and total < qty) do
		b, result = pcall(function()
			local name = pim.getInventoryName();
			if (name ~= self.player) then
				self.status = status.fail;
				return "Wrong user! Expected: " .. self.player .. ", got: " .. name;
			end
			return me.exportItem(fingerprint, direction, tmp);
		end);
		if (not b or type(result) ~= "table") then
			break;
		end
		if (not result.size) then
			break;
		end
		tmp = tmp - result.size;
		total = total + result.size;
		self.data.qty = total; 
	end
	self.status = total == qty and status.success or status.fail;
	return total == qty, total, qty - total, type(result) == "table", b, result;
end

return METransfer;