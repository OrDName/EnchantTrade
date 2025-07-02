local Logger, GPUHandler, Exchanger, computer, component, METransfer = require("Logger"), require("GPUHandler"), require("Exchanger"), require("computer"), require("component"), require("METransfer");
local pim = component.pim;
local Auth = {};
Auth.__index = Auth;

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
	GPUHandler:setButtonsActive(false);
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
	self.ex0:resetResvME();
	self.ex0 = nil;
	self.ind = -1;
	self.conf = false;
	local list = {computer.users()};
	for i, user in pairs(list) do
		computer.removeUser(user);
	end
	GPUHandler:setButtonsState(false);
	GPUHandler:drawWaiting();
end

function Auth:track(x, y, name)
	if (name ~= self.player) then
		return;
	end
	local h = GPUHandler:handleTouch(x, y);
	self.ind = type(h) == "number" and h or self.ind;
	self.conf = type(h) == "boolean" and h or false;
	if (self.ind > 0 and self.ind < 5) then
		local recipe = self.ex0:getRecipe()[self.ind];
		local input = recipe.input;
		local output = recipe.output;
		local qty0, qty1, qty2 = 
			self.ex0:findAll(input[1][1]), 
			self.ex0:findAll(input[2][1]), 
			self.ex0:findAll(input[3][1]);
		local clr0, clr1, clr2 = 
			qty0 >= input[1][2] and 0x00FF00 or 0xFF0000, 
			qty1 >= input[2][2] and 0x00FF00 or 0xFF0000, 
			qty2 >= input[3][2] and 0x00FF00 or 0xFF0000;
		GPUHandler:drawItemList(input[1][1].name_l, input[2][1].name_l, input[3][1].name_l, output[1][1].name_l, input[1][2], input[2][2], input[3][2], clr0, clr1, clr2);
		if (self.conf) then
			self.ex0:trade(self.ind);
			GPUHandler:drawButtonsActive(false);
		end
	end
end

local o = Auth:new();

return o;