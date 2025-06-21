local GPUHandler, Auth, computer, component = require("GPUHandler"), require("Auth"), require("computer"), require("component");
local pim = component.pim;
GPUHandler:drawWaiting();
local index, flag = -1, false;
local isRunning = true;

while (isRunning) do
	local e = {computer.pullSignal(0)};
	local name = pim.getInventoryName();
	if (e[1] ~= "player_on" and e[1] == "player_off" and Auth.player ~= pim.getInventoryName()) then
		Auth:deauth();
	elseif (e[1] == "player_on") then
		Auth:auth(e[2]);
	elseif(e[1] == "touch") then
		Auth:track(e[3], e[4], e[6]);
	end
end

Logger:close();