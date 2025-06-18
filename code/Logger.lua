local fs = require("filesystem");
local Logger = {};
Logger.__index = Logger;

function Logger:new(path);
	local log_file, str = io.open(path, "a");
	if (not log_file) then
		return nil;
	end
	local obj = {
		file = log_file;
	};
	setmetatable(obj, self);
	return obj;
end

function Logger:timestamp(utc)
	local tmp_file = io.open("/tmp/timestamp.tmp", "w");
	if (not tmp_file) then
		return 0;
	end
	tmp_file:write("");
	local result = fs.lastModified("/tmp/timestamp.tmp");
	tmp_file:close(); 
	fs.remove("/tmp/timestamp.tmp");
	return result / 1000 + 3600 * utc;
end

function Logger:log(str)
	self.file:write("[" .. os.date("%d-%m-%Y %H:%M:%S", timestamp(3)) .. "] " .. str);
end

function Logger:close()
	self.file:close();
end

local instance = Logger:new("/home/trade.log");

return instance;