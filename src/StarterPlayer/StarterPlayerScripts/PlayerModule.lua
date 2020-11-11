--- PlayerModule.lua
-- SPACE CRAFT MAGIC WOOOOO
-- @author Magical_Noob
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Client = ReplicatedStorage:WaitForChild("Client");

local NOTE_FRAME = {
	ClassName = "Frame";
	SizeConstraint = Enum.SizeConstraint.RelativeYY;
	Size = UDim2.new(0.5, 0, 1, 0);
	Position = UDim2.new(0.5, 0, 0, 0);
	AnchorPoint = Vector2.new(0.5, 0);
	BackgroundTransparency = 0.5;
	BackgroundColor3 = Color3.new(0, 0, 0);
	BorderSizePixel = 0;
	ZIndex = 50;
	{
		ClassName = "ImageLabel";
		Name = "Background";
		ImageTransparency = 0.5;
		AnchorPoint = Vector2.new(0.5, 0);
		Position = UDim2.new(0.5, 0, 0, 0);
		Size = UDim2.new(10, 0, 1, 0);
		ScaleType = Enum.ScaleType.Crop;
		ZIndex = -2;
		BackgroundColor3 = Color3.new(0, 0, 0);
	}
};

local App = {};
App.__index = App;

--- OnGameLoaded
function App:OnGameLoaded()
	self.Screen = require(Client.Screen);
	self.GameHandler = require(Client.GameHandler);
	self.Config = require(ReplicatedStorage.GameConfig);
	
	--- Create note gui and frame
	local GameFrame = self.Screen:new();
	GameFrame:SetFlag("DisplayOrder", 10);
	GameFrame:SetFlag("IgnoreGuiInset", true);

	local MessageFrame = self.Screen:new();
	MessageFrame:SetFlag("DisplayOrder", 20);
	MessageFrame:SetFlag("IgnoreGuiInset", true);
	MessageFrame:Connect(self.GameHandler.DisplayText);
	MessageFrame:AddObject("Message", "%s");

	--- Set up the game frame
	self.GameFrame = GameFrame;
	self.GameHandler:SetNoteGui(GameFrame:Make(NOTE_FRAME));
	self.GameHandler:SetGameSpeed(1.5);

	--- Add tracks
	for I = 0, self.Config.MAX_TRACKS - 1 do
		self.GameHandler:AddTrack(I, unpack(self.Config.TRACK_SETTINGS[I+1]));
	end

end

--- OnRequestSongList
function App:OnRequestSongList()
	local gameHandler = self.GameHandler;
	local function ChooseMap(data)
		--- Weird hack to set the round
		gameHandler:SetRound(data.Name)
	end
	
	local Songs = gameHandler:GetSongs();		
	for _, song in pairs(Songs)do
		song.OnMouseClick = ChooseMap;
		self.GameFrame:AddObject(
			"List",

			song,
			"%s",
			nil,		
			song.Name
		);
	end	
end

return App;
