local GPUHandler, Auth, computer, component = require("GPUHandler"), require("Auth"), require("computer"), require("component");
local pim = component.pim;
GPUHandler:drawWaiting();

while (true) do
	local e = {computer.pullSignal(0)};
	local name = pim.getInventoryName();
	if (e[1] ~= "player_on" and e[1] == "player_off" and Auth.player ~= pim.getInventoryName()) then
		Auth:deauth();
	elseif (e[1] == "player_on") then
		Auth:auth(e[2])
	elseif(e[1] == "touch" and e[6] == Auth.player) then
		local x, y = e[3], e[4]; 
		print(GPUHandler:handleTouch(x, y));
	end
end