local component, Logger, handler, Exchanger, event, computer, fs = require("component"), require("Logger"), require("GPUHandler"), require("Exchanger"), require("event"), require("computer"), require("filesystem");
local pim, gpu = component.pim, component.gpu;
local isRunning = true;
local mainThreads = {};
local current_player = "";
local s0 = handler:new();
local ex0 = nil;
s0:init();
s0:drawWaiting();
local ind, submit = -1, false;

function clearUsers()
	local list = {computer.users()};
	for i, user in pairs(list) do
		computer.removeUser(user);
	end
end

function drawItems(index)
	local recipe = ex0:getRecipe()[index];
	local input = recipe.input;
	local output = recipe.output;
	local qty0, qty1, qty2 = ex0:findAll(input[1]), ex0:findAll(input[2]), ex0:findAll(input[3]);
	s0:fillConsole(1, 2, 35, 6, ' ');
	s0:writeConsole(1, 2, "Выбрано: " .. tostring(output[1].name));
	s0:writeConsole(1, 3, "Треубется:");
	s0:writeConsole(1, 4, "[Предмет] (Количество)");
	s0:writeConsole(1, 5, "- " .. tostring(input[1].name) .. " (" .. tostring(1) .. ")", qty0 >= 1 and 0x00FF00 or 0xFF0000);
	s0:writeConsole(1, 6, "- " .. tostring(input[2].name) .. " (" .. tostring(1) .. ")", qty1 >= 1 and 0x00FF00 or 0xFF0000);
	s0:writeConsole(1, 7, "- " .. tostring(input[3].name) .. " (" .. tostring(input[4]) .. ")", qty2 >= input[4] and 0x00FF00 or 0xFF0000);
end

function login(player)
	s0:drawLoading()
	ex0 = Exchanger:new(player);
	ex0:updateHash();
	os.sleep()
	ind, submit = -1, false;
	current_player = player;
	computer.addUser(player);
	s0:drawMain(player);
	s0:setButtonsState(true);
	Logger:log("Main | Login: " .. player);
end

function logout()
	Logger:log("Main | Logout: " .. current_player);
	clearUsers();
	current_player = "";
	require("component").gpu.fill(1,1,64,19,' ');
	os.sleep(0.7);
	s0:drawWaiting();
	s0:setButtonsState(false);
	ex0 = nil;
end

while (isRunning) do
	local ev = {computer.pullSignal(0)};
	if (ev[1] == "player_on") then
		login(ev[2])
	elseif (ev[1] == "player_off") then
		logout();
	elseif (ev[1] == "touch") then
		if (ev[6] == current_player) then
			local x, y = ev[3], ev[4];
			local r = s0:handleTouch(x, y)
			ind = type(r) == "number" and r or ind;
			submit = type(r) == "boolean" and r or false;
			if (ind >= 1 and ind <= 4) then
				if (submit) then 
					Logger:log("Main | Chosen index: " .. tostring(ind));
					ex0:trade(ind);
				end 
				drawItems(ind);
			end
		end
	end
end

Logger:close();