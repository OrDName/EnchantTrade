local GPUHandler, Exchanger, component = require("GPUHandler"), require("Exchanger"), require("component");
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
		-- self.ex0:updateHash(); --20-60 tick cost
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

local o = Auth:new();

return o;