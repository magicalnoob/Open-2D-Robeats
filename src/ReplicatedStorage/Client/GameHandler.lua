--- GameHandler.lua
-- Manage game state bois
-- @author Magical_Noob

local SONGS_FOLDER = game.ReplicatedStorage.Songs;

--- Really bad
local UserInputService = game:GetService("UserInputService");
local Config = require(game.ReplicatedStorage.GameConfig);
local SoundHandler = require(script.Parent.SoundHandler);
local Gameplay = script.Parent.Gameplay;
local FastSpawn = require(Gameplay.FastSpawn);
local FastWait = require(Gameplay.FastWait);
local Signal = require(Gameplay.Signal);
local Track = require(Gameplay.Track);

local FORMAT = "%0.1f";
local GameHandler = {};
GameHandler.__index = GameHandler;
GameHandler.BackgroundGui = nil;
GameHandler.NotesGui = nil;

GameHandler.BackgroundMusic = Instance.new("Sound");
GameHandler.Add = 0;
GameHandler.Max = 0;
GameHandler.Combo = 0;
GameHandler.Misses = 0;

GameHandler.ScoreChanged = Signal:new();
GameHandler.DisplayText = Signal:new();

GameHandler.gameTime = 0;
GameHandler.timeScale = 0;
GameHandler.speed = 0.25;
GameHandler.tracks = {};
GameHandler.notes = {};
GameHandler.bound = {};

--- GetSongs
-- @return Song[]
function GameHandler:GetSongs()
	local songInfo = {};
	for _, song in pairs(SONGS_FOLDER:GetChildren())do
		local data = require(song);
		table.insert(
			songInfo,
			{
				Name = song.Name;
				CoverArt = data.AudioCoverImageAssetId;
				Difficulty = data.AudioDifficulty;
			}
		)
	end
	return songInfo;
end

--- SetGameSpeed
-- @param speed: number
function GameHandler:SetGameSpeed(speed)
	self.speed = speed;
end

--- GetPath
-- @param path: string
local function GetPath(path)
	local parent = SONGS_FOLDER;
	for _, str in pairs(path:split("/"))do
		parent = parent:WaitForChild(str, 1);
		if (not parent) then
			return;
		end
	end
	return parent;
end

--- SetRound
-- @param path: string
function GameHandler:SetRound(path)
	--- get the object
	self.notes = {};
	--SoundHandler:PlayMusic(0);
	
	local parent = GetPath(path);
	
	--- load bgm
	local round = require(parent);
	local beatOffset = round.AudioNotePrebufferTime / 1000;
	local resolve = SoundHandler:PlayMusic(round.AudioAssetId);
	self.BackgroundGui.Image = round.AudioCoverImageAssetId;

	--- countdown
	for countdown = 3, 0, -1 do
		self.DisplayText:Fire(countdown);	
		SoundHandler:PlaySound("countdown");
		wait(0.75);
	end
	
	--- init
	self.Add = 0;
	self.Max = 0;
	self.timeScale = 0;
	self.gameTime = 0;
	
	--- load map
	local off = round.AudioTimeOffset;
	local max = 0;
	for _, hitObject in pairs(round.HitObjects) do
		if (hitObject.duration) then
			self:AddNoteInDelay(hitObject.Track-1, hitObject.Time + off, "Slider", hitObject.Duration);
		else
			self:AddNoteInDelay(hitObject.Track-1, hitObject.Time + off, "Note");
		end
		max += 1;
	end
		
	self.Max = max;
	self.timeScale = round.stdtimescale or 1;

	resolve();
	
end

--- OnTrackPressed
-- @param track: number
function GameHandler:OnTrackPressed(track)
	self.tracks[track]:OnTrackCommand();
end

--- OnGuiScaleChanged
function GameHandler:OnGuiScaleChanged()
	--- send tracks information
	local viewport = self.NotesGui.Parent.AbsoluteSize;
	self.BackgroundGui.Size = UDim2.new(0, viewport.X, 0, viewport.Y);
	
	local size = self.NotesGui.AbsoluteSize;
	local screenHeight = size.Y;
	local screenWidth = size.X;

	local offset = screenWidth/4;
	for _, track in pairs(self.tracks)do
		track:OnGuiScaleChanged(screenHeight, screenWidth, offset);
	end
end

--- AddTrack
-- @param num: number
-- @return track: Track
function GameHandler:AddTrack(num, keybind, color)
	local track = Track:new(num, color);
	self.tracks[num] = track;
	self.bound[keybind.Value] = track;
	
	track.Score:Connect(function(add)
		self.Add += add;
		self.Max += Config.MAX_PTS;

		if (add > 0) then
			SoundHandler:PlaySound("hit");
			self.Combo += 1;
		else
			SoundHandler:PlaySound("miss");
			self.Combo = 0;
		end
		
		self.DisplayText:Fire(self.Combo);
	end)
end

--- SetNoteGui
-- @param to: Frame
function GameHandler:SetNoteGui(to)
	--- set important variables
	Track.Notes = to;
	self.NotesGui = to;
	self.BackgroundGui = to:WaitForChild("Background");
	
	--- set sound parents
	SoundHandler:SetParent(to.Parent);
	
	--- hook connections
	self.NotesGui.Changed:Connect(function()
		self:OnGuiScaleChanged();
	end)
end

--- AddNoteInDelay
-- Note add dealy lol
-- @param track: number
-- @param ms: number
function GameHandler:AddNoteInDelay(track, ms, typ, ...)
	local second = (ms/1000) - (1/self.speed);
	table.insert(
		self.notes, 
		{
			Type = typ;
			Time = second; 
			Track = track;
			Args = {...};
		}
	);
end

--- InsertNote
function GameHandler:InsertNote()
	local data = self.notes[1];
	if (data and data.Time <= self.gameTime) then
		self.tracks[data.Track]:OnNoteAdded(data.Type, self.speed, unpack(data.Args));
		table.remove(self.notes, 1);
		
		self:InsertNote();
	end	
end

--- Update
-- @param dt: number
function GameHandler:Update(dt)
	self:InsertNote();
	self.gameTime += (dt * self.timeScale);
	
	for _, track in pairs(self.tracks)do
		track:Update(dt * self.timeScale);
	end
end

--- Bind input
UserInputService.InputBegan:Connect(function(input, processed)
	if (processed) then
		return;
	end

	if (GameHandler.bound[input.KeyCode.Value]) then
		GameHandler.bound[input.KeyCode.Value]:OnTrackCommand();
	end
end)

UserInputService.InputEnded:Connect(function(input, processed)
	if (processed) then
		return;
	end

	if (GameHandler.bound[input.KeyCode.Value]) then
		GameHandler.bound[input.KeyCode.Value]:OnTrackReleased();
	end
end)

--- export
return GameHandler;
