local Logger, GPUHandler, Exchanger, computer, component, METransfer = require("Logger"), require("GPUHandler"), require("Exchanger"), require("computer"), require("component"), require("METransfer");
local Auth = {};
Auth.__index = Auth;
local pim = component.pim;

function Auth:new()
	local obj = {
		player = "",
		ex0 = nil,
		ind = -1,
		conf = false,
	};
	setmetatable(obj, self);
	return obj;
end

function Auth:auth(name)
	GPUHandler:drawLoading();
	computer.addUser(name);
	self.player = name;
	self.ex0 = Exchanger:new(name);
	os.sleep(1);
	local b = name == pim.getInventoryName() and self.ex0;
	if (not b) then
		self:deauth();
	else
		Logger:log("Auth " .. tostring(self.player));
		GPUHandler:drawMain(self.player);
	end
	return b;
end

function Auth:deauth()
	Logger:log("Deauth " .. tostring(self.player));
	self.player = "";
	self.ex0 = nil;
	self.ind = -1;
	self.conf = false;
	local list = {computer.users()};
	for i, user in pairs(list) do
		computer.removeUser(user);
	end
	GPUHandler:drawWaiting();
end

function Auth:track(x, y, name)
	if (name ~= self.player) then
		return;
	end
	local h = GPUHandler:handleTouch(x, y);
	self.ind = type(h) == "number" and h or self.ind;
	self.conf = type(h) == "boolean" and h or self.conf;
	if (self.conf and self.ind > 0 and self.ind < 5) then
		self.ex0:trade(self.ind, "SOUTH", "UP");
	end
end

local o = Auth:new();

return o;