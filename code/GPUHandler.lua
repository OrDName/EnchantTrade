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

local function l_drawLocked()
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

local function l_drawWaiting()
	l_drawDefault(0xFFFF00)
	gpu.setBackground(w8_clr1);
	gpu.fill(w8_x, w8_y, w8_w, w8_h, ' ');
	local str = "Встаньте на PIM..."
	gpu.setForeground(0xFFFFFF)
	gpu.set(w8_x + (w8_w - unicode.wlen(str)) / 2, w8_y + w8_h / 2, str);
end

local function l_drawLoading()
	l_drawDefault(0x00FF77)
	gpu.setBackground(w8_clr1);
	gpu.fill(w8_x, w8_y, w8_w, w8_h, ' ');
	local str = "Загрузка"
	gpu.setForeground(0xFFFFFF)
	gpu.set(w8_x + (w8_w - unicode.wlen(str)) / 2, w8_y + w8_h / 2, str);
end

local function l_drawTempButton(x, y, wx, hy, isActive)
	local clr = isActive and 0x446644 or 0x222222;
	gpu.setBackground(clr);
	gpu.fill(x, y, wx, hy, ' ');
end

local function l_drawConsole(x, y)
	gpu.setBackground(0);
	gpu.fill(x, y, w - 3 - x, h - 5 - y, ' ');
end

local function l_drawMain()
	l_drawDefault();
	l_drawConsole(26, 3);
end

function GPUHandler:new()
	local obj = {
		player = "",
		state = 0,
		pre = nil,
		buffers = {
			waiting = 0,
			loading = 0,
			main = 0,
			locked = 0,
			console = 0,
			button_a = 0,
			button_d = 0
		},
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
	local index = isActive and self.button_a or self.button_d;
	local clr = isActive and 0x446644 or 0x222222;
	gpu.bitblt(0, x, y, bw, bh, index, 1, 1);
	gpu.setForeground(0xFFFFFF)
	gpu.setBackground(clr);
	gpu.set(x + offset, y + bh / 2, str);
end

function GPUHandler:drawButtons()
	for i, button in pairs(self.buttons) do
		button:setEnabled(true);
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

function GPUHandler:drawWaiting()
	gpu.fill(1, 1, w, h, ' ');
	gpu.bitblt(0, 1, 1, w, h, self.waiting, 1, 1);
end

function GPUHandler:drawLoading()
	gpu.fill(1, 1, w, h, ' ');
	gpu.bitblt(0, 1, 1, w, h, self.loading, 1, 1);
end

function GPUHandler:drawMain(player)
	gpu.fill(1, 1, w, h, ' ');
	gpu.bitblt(0, 1, 1, w, h, self.main, 1, 1);
	gpu.bitblt(0, 26, 3, 35, 11, self.console, 1, 1);
	self:writeConsole(1, 1, "Игрок: " .. player);
	self:drawButtons();
end

function GPUHandler:drawLocked()
	gpu.fill(1, 1, w, h, ' ');
	gpu.bitblt(0, 1, 1, w, h, self.locked, 1, 1);
end

function GPUHandler:initBuffers()
	self.button_a = gpu.allocateBuffer(bw, bh);
	l_drawTempButton(1, 1, 18, 3, true);
	gpu.bitblt(self.button_a, 1, 1, bw, bh, 0, 1, 1);
	self.button_d = gpu.allocateBuffer(bw, bh);
	l_drawTempButton(1, 1, 18, 3, false);
	gpu.bitblt(self.button_d, 1, 1, bw, bh, 0, 1, 1);
	self.waiting = gpu.allocateBuffer(w, h);
	l_drawWaiting();
	gpu.bitblt(self.waiting, 1, 1, w, h, 0, 1, 1);
	self.loading = gpu.allocateBuffer(w, h);
	l_drawLoading();
	gpu.bitblt(self.loading, 1, 1, w, h, 0, 1, 1);
	self.main = gpu.allocateBuffer(w, h);
	l_drawMain();
	gpu.bitblt(self.main, 1, 1, w, h, 0, 1, 1);
	self.locked = gpu.allocateBuffer(w, h);
	l_drawLocked();
	gpu.bitblt(self.locked, 1, 1, w, h, 0, 1, 1);
	self.console = gpu.allocateBuffer(w, h);
	l_drawConsole(1, 1);
	gpu.bitblt(self.console, 1, 1, 35, 11, 0, 1, 1);
end

function GPUHandler:initButtons()
	self:createButton(6, 3, "Добыча IV ", false, 1);
	self:createButton(6, 7, "Добыча V", false, 2);
	self:createButton(6, 11, "Удача IV", false, 3);
	self:createButton(6, 15, "Удача V ", false, 4);
	self:createButton(35, 15, "Обмен ", false, true);
end

function GPUHandler:init()
	gpu.freeAllBuffers();
	gpu.setResolution(w, h);
	local mem = gpu.freeMemory();
	if (mem < 24000) then
		return;
	end
	self:initBuffers();
	self:initButtons();
end
--
local instance = GPUHandler:new();
instance:init();
return instance;