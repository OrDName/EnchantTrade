local Button = {};
Button.__index = Button;

function Button:new(x, y, w, h, label, value)
	local obj = {
		x0 = x,
		x1 = x + w,
		y0 = y,
		y1 = y + h,
		label = label,
		value = value,
		isActive = false,
		enabled = false
	}
	setmetatable(obj, self);
	return obj;
end

function Button:setActive(b)
	self.isActive = b;
end

function Button:toggleActive()
	self.isActive = not self.isActive;
end

function Button:getActive()
	return self.isActive;
end

function Button:setEnabled(b)
	self.enabled = b;
end

function Button:toggleEnabled()
	self.enabled = not self.enabled;
end

function Button:getEnabled()
	return self.enabled;
end

function Button:check(x, y)
	return self.enabled and x >= self.x0 and x < self.x1 and y >= self.y0 and y < self.y1;
end

function Button:getValue()
	return self.value;
end

return Button;