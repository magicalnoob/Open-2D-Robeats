-- @todo Make accuracy score

if (not game:IsLoaded()) then
	game.Loaded:Wait();
end

local KEYS = {
	{
		Enum.KeyCode.A,
		BrickColor.new("Bright red")
	},
	{
		Enum.KeyCode.S,
		BrickColor.new("Bright green")
	},
	{
		Enum.KeyCode.L,
		BrickColor.new("Bright green")
	},
	{
		Enum.KeyCode.Semicolon,
		BrickColor.new("Bright red")
	}
};

--- BTW I DO USE ROBEAT'S CONVERTOR
--- CUZ I DONT WANT TO SPEND 50 HOURS ON 
--- TS OR C# FOR STRING PATTERNS

local Client = game.ReplicatedStorage:WaitForChild("Client");
local Screen = require(Client:WaitForChild("Screen"));
local GameHandler = require(Client:WaitForChild("GameHandler"));
local UserInputService = game:GetService("UserInputService");

--- Create gui
local Message = Screen:new();
local GameFrame = Screen:new();
Message:SetFlag("DisplayOrder", 10);
GameFrame:SetFlag("IgnoreGuiInset", true);

do --- Create note frame
	local NoteFrame = GameFrame:Make(
		{
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

		}
	);

	GameHandler:SetNoteGui(NoteFrame);
end

--- Song selection
do	
	local function ChooseMap(data)
		GameHandler:SetRound(data.Name)
	end
	
	local Songs = GameHandler:GetSongs();		
	for _, song in pairs(Songs)do
		song.OnMouseClick = ChooseMap;
		GameFrame:AddObject(
			"List",
		
			song,
			"%s",
			nil,		
			song.Name
		);
	end	
end

--- Init gmae
GameHandler:SetGameSpeed(1.5);

--- Create tracks
GameHandler:AddTrack(0, unpack(KEYS[1]));
GameHandler:AddTrack(1, unpack(KEYS[2]));
GameHandler:AddTrack(2, unpack(KEYS[3]));
GameHandler:AddTrack(3, unpack(KEYS[4]));

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

--- Bind for accuracy
Message:Connect(GameHandler.DisplayText);
Message:AddObject("Message", "%s");

--- Make game routine
game:GetService("RunService"):BindToRenderStep(
	"render",
	Enum.RenderPriority.Last.Value,
	function(dt)
		GameHandler:Update(dt);
	end
)
