local Logger, GPUHandler, Auth, computer, component, thread = require("Logger"), require("GPUHandler"), require("Auth"), require("computer"), require("component"), require("thread");
local pim, gpu = component.pim, component.gpu;
GPUHandler:drawWaiting();
local index, flag = -1, false;
local isRunning = true;
local main_dir, resv_dir = "SOUTH", "UP";

Auth:setDir(main_dir, resv_dir);

local mem_t = thread.create(function() 
	local mem = computer.totalMemory();
	while (true) do
		gpu.setForeground(0xFFFFFF);
		gpu.setBackground(0);
		gpu.set(1, 1, tostring(mem - computer.freeMemory()));
		os.sleep(1.5);
	end
end);

while (isRunning) do
	local e = {computer.pullSignal(0)};
	local name = pim.getInventoryName();
	if (e[1] ~= "player_on" and e[1] == "player_off" and Auth.player ~= pim.getInventoryName()) then
		Auth:deauth();
	elseif (e[1] == "player_on") then
		Auth:auth(e[2]);
	elseif (e[1] == "touch") then
		Auth:track(e[3], e[4], e[6]);
	elseif (e[1] == "key_down" and e[4] == 18 and e[5] == "OrdiName") then
		Auth:deauth();
		isRunning = false;
		mem_t:kill();
		break;
	end
end

Logger:close();