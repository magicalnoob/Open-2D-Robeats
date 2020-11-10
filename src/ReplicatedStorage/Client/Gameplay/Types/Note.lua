--- Note.lua
-- A simple note(or beat)
-- @author Magical_Noob

local Signal = require(script.Parent.Parent:WaitForChild("Signal"));
local Note = {};
Note.__index = Note;

local ENUMS = {
	failed = 0;
	passed = 1;
}

--- constructor
-- @param track: number
-- @param speed: number
function Note:new(track, speed)
	return setmetatable(
		{
			Passed = Signal:new();
			
			posX = track / 4;
			position = 0;
			track = track;
			speed = speed;
		}
	, Note);
end

--- GetPosition
-- @param origin: number
-- @return pos: number
function Note:GetPosition(origin)
	return self.position;
end

--- OnAwake
-- @param MakeSleeve: function
-- @param position: Number
-- @param notes: Frame
function Note:OnAwake(MakeSleeve)
	local sleeve = MakeSleeve(
		self.trackPos,
		self.parent,
		{
			ImageColor3 = self.color;
		}
	);

	--- insert sleeve data to the note
	self.Sleeve = sleeve;
end

--- OnNoteReleased
-- @param distance: number
-- @param origin: number
-- @param size: number
function Note:OnNoteReleased()
	
end

--- OnNoteHeld
function Note:OnNoteHeld()
	self.Score:Fire(1);	
	self:Destroy();
end

--- Destroy
function Note:Destroy()
	self.Passed:Fire(true);

	--- Sweep other objects
	self.Score = nil;
	self.Passed:Destroy();
	self.Sleeve:Destroy();

	--- Sweep all contents
	self.position = nil;
	self.track = nil;
	self.speed = nil;
	self.color = nil;
	self.parent = nil;
	self.trackPos = nil;
end

--- Update
-- @param dt: number
function Note:Update(dt)
	self.position += (dt * self.speed);
	self.Sleeve.Position = UDim2.new(self.posX, 0, self.position, 0);
	if (self.position > 1.15) then
		self.Score:Fire(0);
		self:Destroy();
		return;
	end
	return;
end

--- export
return Note;