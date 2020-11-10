--- Screen.lua
-- A very bad ui library that sucks
-- @author Magical_Noob
local SCREEN_TYPES = script.Parent:WaitForChild("ScreenTypes");
local BLACKLIST = {
	ClassName = 0;
}

local Screen = {};
Screen.__index = Screen;

--- constructor
-- @param mainArray
function Screen:new()
	return setmetatable(
		{
			Pivot = Vector2.new();
			
			types = {};
			gui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui);
		}
	, Screen);
end

--- SetEnabled
-- @param enabled: boolean
function Screen:SetEnabled(enabled)
	self.gui.Enabled = enabled;
end

--- Make
-- @param array: Map<string|number, any>
-- @param parent: Instance
function Screen:Make(array, parent)
	local instance = Instance.new(array.ClassName, parent or self.gui);
	local final = {instance};

	for property, value in pairs(array)do
		if (BLACKLIST[property]) then
			continue;
		end

		if (typeof(value) == "table") then
			self:Make(value, instance);
			continue;
		end

		--- give property
		instance[property] = value;
	end
	return unpack(final);
end

--- SetFlag
-- @param name: string
-- @param value: any
function Screen:SetFlag(name, value)
	self.gui[name] = value;
end

--- AddObject
-- @param class: string
-- @param ...args: any[]
-- @return object: Object
function Screen:AddObject(class, ...)
	local data = require(SCREEN_TYPES[class]);
	data.__index = data;
	data = setmetatable({}, data);
	
	--- defs
	data.gui = self.gui;
	data.Make = self.Make;
	data:constructor(...);

	--- insert
	table.insert(self.types, data);
	return data;
end

--- FireObjects
-- @param ...args: any[]
function Screen:FireObjects(...)
	for _, typ in pairs(self.types)do
		typ:OnSignalEvent(...);
	end
end

--- FireEventObjects
-- @param ...args: any[]
function Screen:FireEventObjects(event, ...)
	for _, typ in pairs(self.types)do
		if (typ[event]) then
			typ[event](typ, ...);
		end
	end
end

--- Connect
-- @param signal: Signal
function Screen:Connect(signal)
	signal:Connect(function(...)
		self:FireObjects(...);
	end)
end

--- FindFirstObject
-- @param object: string
function Screen:FindFirstObject()
	
end

return Screen;