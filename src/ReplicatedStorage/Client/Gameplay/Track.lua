--- Track.lua
-- A track that handles notes
-- Also handles mostly the entire game lol
-- @author Magical_Noob
local Signal = require(script.Parent:WaitForChild("Signal"));
local TypesFolder = script.Parent:WaitForChild("Types");

local MAX_TRACKS = 4;
local NOTE_IMAGE = "rbxassetid://5935157727";
local MISS_RANGE = 1.5;

local TYPES = {};
local ROTATIONS = {
	90,
	0,
	180,
	-90	
};

local Track = {};
Track.__index = Track;

--- GetColor
-- @param col: Color3 | BrickColor | null
-- @return color: Color3
local function GetColor(col)
	if (not col) then
		return BrickColor.Random().Color;
	end
	if (typeof(col) == "BrickColor") then
		col = col.Color;
	end
	return col;
end

--- MakeSleeve
-- @param position: Vector3
-- @param parent: Instance
-- @param properties: Map<string, any>
-- @return sleeve: ImageLabel
local function MakeSleeve(position, parent, properties)
	-- new sleeve
	local sleeve = Instance.new("ImageLabel", parent);
	sleeve.Image = NOTE_IMAGE;
	sleeve.ImageRectSize = Vector2.new(144, 144);
	sleeve.ImageRectOffset = Vector2.new(0, 0)
	sleeve.AnchorPoint = Vector2.new(0, 0.5);
	sleeve.Size = UDim2.new(1/MAX_TRACKS, 0, 1/MAX_TRACKS, 0);
	sleeve.SizeConstraint = Enum.SizeConstraint.RelativeXX;
	sleeve.BackgroundTransparency = 1;
	sleeve.Rotation = ROTATIONS[position+1];
	sleeve.ZIndex = 75;
	
	for name, value in pairs(properties or {})do
		sleeve[name] = value;
	end
	
	return sleeve;
end

--- constructor
-- @param position: number
function Track:new(position, color)
	return setmetatable(
		{
			Notes = nil;
			Result = Signal:new();
			Score = Signal:new();
			
			position = position;
			color = GetColor(color);
			
			trackElement = MakeSleeve(
				position, 
				self.Notes,
				{
					Position = UDim2.new(position/4, 0, 1, 0);
					AnchorPoint = Vector2.new(0, 1);
					ImageRectOffset = Vector2.new(144, 0);
					ZIndex = 100;
				}
			);
			
			yPosition = 0;
			yScale = 0;
			notes = {};
		}
	, Track);
end

--- OnNoteAdded
-- @param speed: number
function Track:OnNoteAdded(typ, speed, ...)
	local note;
	
	--- check if type exists
	if (TYPES[typ]) then
		note = TYPES[typ]:new(self.position, speed, ...);
	else
		return;
	end
	
	--- init note
	note.trackPos = self.position;
	note.parent = self.Notes;
	note.color = self.color;
	
	note.Score = self.Score;	
	note.Passed:Connect(function(...)
		table.remove(self.notes, 1);
		self.removed += 1;
	end)
	
	--- insert the note
	table.insert(self.notes, note);	
	note:OnAwake(MakeSleeve);
end

--- OnTrackReleased
function Track:OnTrackReleased()
	self.trackElement.ImageRectOffset = Vector2.new(144, 0);
	
	if (not self.notes[1]) then
		return;
	end
	
	local distance = math.abs(self.notes[1]:GetPosition(self.yPosition) - self.yPosition);
	if (distance <= self.yScale) then
		--- successful hit
		local data = self.notes[1];
		data:OnNoteReleased(distance, self.yPosition, self.yScale);		
	end
	
end

--- OnTrackCommand
function Track:OnTrackCommand()
	self.trackElement.ImageRectOffset = Vector2.new(0, 0);

	if (not self.notes[1]) then
		self.Score:Fire(0);
		return;
	end
	
	local distance = math.abs(self.notes[1]:GetPosition(self.yPosition) - self.yPosition);
	if (distance > self.yScale)	then
		self.Score:Fire(0);
	else
		--- successful hit		
		local data = self.notes[1];
		data:OnNoteHeld(distance, self.yPosition, self.yScale);	
	end
	
end

--- OnGuiScaleChanged
-- @param screenHeight: number
-- @param screenWidth: number
-- @param size: number
function Track:OnGuiScaleChanged(screenHeight, screenWidth, size)
	self.yPosition = (screenHeight - (size/2)) / screenHeight;
	self.yScale = ((size)*MISS_RANGE)/screenHeight;
end

--- Update
-- @param dt: number
function Track:Update(dt)
	self.removed = 0;	
	for i = 1, #self.notes do
		local note = self.notes[i - self.removed];
		note:Update(dt);
	end
end

--- init
for _, noteType in pairs(TypesFolder:GetChildren())do
	TYPES[noteType.Name] = require(noteType);
end

--- export
return Track;