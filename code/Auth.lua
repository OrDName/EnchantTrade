local GPUHandler, Exchanger, computer, component, METransfer = require("GPUHandler"), require("Exchanger"), require("computer"), require("component"), require("METransfer");
local Auth = {};
Auth.__index = Auth;
local pim = component.pim;

function Auth:new()
	local obj = {
		player = "",
		ex0 = nil,
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
		GPUHandler:drawMain(self.player);
	end
	return b;
end

function Auth:deauth()
	self.player = "";
	self.ex0 = nil;
	local list = {computer.users()};
	for i, user in pairs(list) do
		computer.removeUser(user);
	end
	GPUHandler:drawWaiting();
end

function Auth:track()
	while (self.player == pim.getInventoryName()) do
		local e = {computer.pullSignal(0)};
		if (e[1] == "touch") then
			local name, x, y = e[6], e[3], e[4]; 
			print(GPUHandler:handleTouch(x, y));
		end
	end
end

local o = Auth:new();

return o;