--- FastSpawn
-- Spawn but fast uisng bindable event
-- @author Magical_Noob
local FastSpawn = {};
FastSpawn.__index = FastSpawn;

--- Spawn
-- @param fn: function
function FastSpawn:Spawn(fn)
	local bind = Instance.new("BindableEvent");
	bind.Event:Connect(fn);
	bind:Fire();
	bind:Destroy();
end

--- export
return FastSpawn;