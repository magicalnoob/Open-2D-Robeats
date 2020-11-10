--- Signal.lua
-- simple signal class
-- and i don't use _ for private in
-- closed source stuff
-- FIGHT ME
-- @author Magical_Noob
local Signal = {};
Signal.__index = Signal;

--- constructor
-- Makes a new signal
function Signal:new()
	return setmetatable(
		{
			_bindable = Instance.new("BindableEvent");
			_args = {};
			_len = 0;
		}
	, Signal);
end

--- Connect
-- @param fn: function
function Signal:Connect(fn)
	return self._bindable.Event:Connect(function()
		fn(unpack(self._args, 1, self._len));
	end)
end

--- Fire
-- @param ...args: any[]
function Signal:Fire(...)
	local args = {...};
	self._args = args;
	self._len = #args;
	self._bindable:Fire();
	self._args = {};
	self._len = 0;
end

--- Destroy
function Signal:Destroy()
	self._args = nil;
	self._bindable:Destroy();
	self._len = nil;
end

--- Export
return Signal;