local GPUHandler, Auth, computer, component = require("GPUHandler"), require("Auth"), require("computer"), require("component");
local pim = component.pim;
GPUHandler:drawWaiting();

while (true) do
	local e = {computer.pullSignal(0)};
	local name = pim.getInventoryName();
	if (e[1] ~= "player_on" and e[1] == "player_off" and Auth.player ~= pim.getInventoryName()) then
		Auth:deauth();
		print("d");
	elseif (e[1] == "player_on") then
		print("a");
		os.sleep(1)
		Auth:auth(e[2]);	
	end
end