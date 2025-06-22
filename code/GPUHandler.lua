local component, unicode, Button = require("component"), require("unicode"), require("Button");
local gpu = component.gpu;
local GPUHandler = {};
GPUHandler.__index = GPUHandler;
local w, h = 64, 19;
local bw, bh = 18, 3;
local w8_x, w8_y, w8_w, w8_h = 20, 8, 26, 5;
local w8_clr0, w8_clr1 = 0x555555, 0x222222;
local bg0, bg1 = 0x333333, 0x111111;

local function l_drawDefault(bg_0, bg_1)
	bg_0 = bg_0 or bg0;
	bg_1 = bg_1 or bg1;
	local pre = gpu.setBackground(bg_0);
	gpu.fill(1, 1, w, h, ' ');
	gpu.setBackground(bg_1);
	gpu.fill(3, 2, w - 4, h - 2, ' ');
end

function GPUHandler:new()
	local obj = {
		player = "",
		state = 0,
		pre = nil,
		buttons = {}
	};
	setmetatable(obj, self);
	return obj;
end

function GPUHandler:createButton(x, y, str, isActive, value)
	table.insert(self.buttons, Button:new(x, y, bw, bh, str, value));
end

function GPUHandler:drawButton(x, y, str, isActive)
	local offset = math.ceil((bw - unicode.wlen(str)) / 2);
	local clr = isActive and 0x446644 or 0x222222;
	gpu.setBackground(clr);
	gpu.setForeground(0xFFFFFF);
	gpu.fill(x, y, bw, bh, ' ');
	gpu.set(x + offset, y + bh / 2, str);
end

function GPUHandler:drawButtons()
	for i, button in pairs(self.buttons) do
		button:setEnabled(true);
		self:drawButton(button.x0, button.y0, button.label, button:getActive())
	end
end

function GPUHandler:drawButtonsActive(active)
	for i, button in pairs(self.buttons) do
		button:setEnabled(true);
		button:setActive(active);
		self:drawButton(button.x0, button.y0, button.label, button:getActive())
	end
end

function GPUHandler:handleTouch(x, y)
	for i, button in pairs(self.buttons) do
		if (button:check(x, y)) then
			if (not self.pre) then
				self.pre = i;
			elseif (self.pre ~= i) then
				local pre = self.buttons[self.pre];
				pre:setActive(false);
				self:drawButton(pre.x0, pre.y0, pre.label, pre:getActive());
				self.pre = i;
			end
			button:toggleActive();
			self:drawButton(button.x0, button.y0, button.label, button:getActive());
			return button:getActive() and button:getValue() or false;
		end
	end
	return false;
end

function GPUHandler:fillConsole(x, y, wc, hc, char)
	gpu.setBackground(0);
	gpu.fill(26 + x - 1, 3 + y - 1, wc, hc, char);
end

function GPUHandler:writeConsole(x, y, str, frg)
	frg = frg or 0xFFFFFF;
	gpu.setBackground(0);
	gpu.setForeground(frg);
	gpu.set(26 + x - 1, 3 + y - 1, str);
end

function GPUHandler:setButtonsState(b)
	for i, button in pairs(self.buttons) do
		button:setEnabled(b);
	end
end

function GPUHandler:setButtonsActive(b)
	for i, button in pairs(self.buttons) do
		button:setActive(b);
	end
end

function GPUHandler:drawWaiting()
	l_drawDefault(0xFFFF00)
	gpu.setBackground(w8_clr1);
	gpu.fill(w8_x, w8_y, w8_w, w8_h, ' ');
	local str = "Встаньте на PIM..."
	gpu.setForeground(0xFFFFFF)
	gpu.set(w8_x + (w8_w - unicode.wlen(str)) / 2, w8_y + w8_h / 2, str);
end

function GPUHandler:drawLoading()
	l_drawDefault(0x00FF77)
	gpu.setBackground(w8_clr1);
	gpu.fill(w8_x, w8_y, w8_w, w8_h, ' ');
	local str = "Загрузка"
	gpu.setForeground(0xFFFFFF)
	gpu.set(w8_x + (w8_w - unicode.wlen(str)) / 2, w8_y + w8_h / 2, str);
end

function GPUHandler:drawMain(player)
	l_drawDefault();
	gpu.setBackground(0);
	gpu.fill(26, 3, w - 29, h - 8, ' ');
	self:writeConsole(1, 1, "Игрок: " .. player);
	self:drawButtons();
end

function GPUHandler:drawLocked()
	local lck_c = 0xFF0000;
	local lck_x, lck_y = 28, 10;
	l_drawDefault(lck_c);
	gpu.setBackground(lck_c);
	gpu.fill(lck_x, lck_y, 10, 5, ' ');
	gpu.fill(lck_x + 1, lck_y - 2, 2, 2, ' ');
	gpu.fill(lck_x + 7, lck_y - 2, 2, 2, ' ');
	gpu.fill(lck_x + 3, lck_y - 3, 4, 1, ' ');
	gpu.setBackground(bg1);
	gpu.fill(lck_x + 3, lck_y + 2, 4, 1, ' ')
	gpu.fill(lck_x + 4, lck_y + 3, 2, 1, ' ');
end

function GPUHandler:drawItemList(item0, item1, item2, item_out, qty0, qty1, qty2, clr0, clr1, clr2)
	self:fillConsole(1, 2, 35, 6, ' ');
	self:writeConsole(1, 2, "Выбрано: " .. tostring(item_out));
	self:writeConsole(1, 3, "Треубется:");
	self:writeConsole(1, 4, "[Предмет] (Количество)");
	self:writeConsole(1, 5, "- " .. tostring(item0) .. " (" .. tostring(qty0) .. ")", clr0);
	self:writeConsole(1, 6, "- " .. tostring(item1) .. " (" .. tostring(qty1) .. ")", clr1);
	self:writeConsole(1, 7, "- " .. tostring(item2) .. " (" .. tostring(qty2) .. ")", clr2);
end

function GPUHandler:initButtons()
	self:createButton(6, 3, "Добыча IV ", false, 1);
	self:createButton(6, 7, "Добыча V", false, 2);
	self:createButton(6, 11, "Удача IV", false, 3);
	self:createButton(6, 15, "Удача V ", false, 4);
	self:createButton(35, 15, "Обмен ", false, true);
end

function GPUHandler:init()
	gpu.setResolution(w, h);
	self:initButtons();
end

local instance = GPUHandler:new();
instance:init();
return instance;