local execute = require("shell").execute

local files = {
  {"https://raw.githubusercontent.com/OrDName/EnchantTrade/refs/heads/main/code/Auth.lua", "Auth.lua"},
  {"https://raw.githubusercontent.com/OrDName/EnchantTrade/refs/heads/main/code/Button.lua", "Button.lua"},
  {"https://raw.githubusercontent.com/OrDName/EnchantTrade/refs/heads/main/code/Exchanger.lua", "Exchanger.lua"},
  {"https://raw.githubusercontent.com/OrDName/EnchantTrade/refs/heads/main/code/GPUHandler.lua", "GPUHandler.lua"},
  {"https://raw.githubusercontent.com/OrDName/EnchantTrade/refs/heads/main/code/ItemHandler.lua", "ItemHandler.lua"},
  {"https://raw.githubusercontent.com/OrDName/EnchantTrade/refs/heads/main/code/ItemTransfer.lua", "ItemTransfer.lua"},
  {"https://raw.githubusercontent.com/OrDName/EnchantTrade/refs/heads/main/code/Logger.lua", "Logger.lua"},
  {"https://raw.githubusercontent.com/OrDName/EnchantTrade/refs/heads/main/code/METransfer.lua", "METransfer.lua"},
  {"https://raw.githubusercontent.com/OrDName/EnchantTrade/refs/heads/main/code/Main.lua", "Main.lua"},
  {"https://raw.githubusercontent.com/OrDName/EnchantTrade/refs/heads/main/code/config.lua", "config.lua"},
  {"https://raw.githubusercontent.com/OrDName/EnchantTrade/refs/heads/main/code/status.lua", "status.lua"},
}

for i = 1, #files do
  execute("wget " .. files[i][1] .. " " .. files[i][2] .. " -fq")
  os.sleep(0.1)
end