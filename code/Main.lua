local GPUHandler, Auth, computer, component = require("GPUHandler"), require("Auth"), require("computer"), require("component");
local pim = component.pim;
GPUHandler:drawWaiting();

while (true) do
	local e = {computer.pullSignal(0)};
	local name = pim.getInventoryName();
	if (e[1] ~= "player_on" and e[1] == "player_off" and Auth.player ~= pim.getInventoryName()) then
		Auth:deauth();
	elseif (e[1] == "player_on") then
		if(Auth:auth(e[2])) then 
			Auth:track();
		end	
	end
end