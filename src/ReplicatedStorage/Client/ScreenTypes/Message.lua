--- Message.lua
-- @author Magical_Noob

local DEF_SZ = 86;
local TweenService = game:GetService("TweenService");
local Message = {};
Message.__index = Message;

--- OnMiss
function Message:OnMiss()
	if (not self.Combo) then
		return;
	end
	
	self.Combo = false;
	self.Object.TextTransparency = 0;
	self.Object.TextSize = 96;
	self.Tween:Pause();
	self.MissTween:Cancel();
	self.MissTween:Play();
end

--- OnSignalEvent
-- @param text: string
function Message:OnSignalEvent(text)
	if (text == 0) then
		self:OnMiss();
		return;
	end
	
	self.Combo = true;
	self.MissTween:Pause();
	self.Tween:Cancel();
	
	self.Object.Text = string.format(self.Pattern, text or "start!");
	self.Object.TextTransparency = 0;
	self.Tween:Play();	
end

--- constructor
-- @param pattern: string
function Message:constructor(pattern)
	--- set define
	self.Pattern = pattern;
	
	--- object
	self.Object = self:Make(
		{
			ClassName = "TextLabel";
			Font = Enum.Font.Michroma;
			TextSize = DEF_SZ;
			TextColor3 = Color3.new(1, 1, 1);
			TextTransparency = 1;
			TextStrokeTransparency = 1;
			BackgroundTransparency = 1;
			
			Position = UDim2.new(
				0.5,
				0,
				0.5,
				0
			);
			
			AnchorPoint = Vector2.new(
				0.5, 
				0.5
			)
			
		}
	);
	
	--- tween
	self.Tween = TweenService:Create(
		self.Object, 
		TweenInfo.new(
			0.25, 
			Enum.EasingStyle.Linear, 
			Enum.EasingDirection.In, 
			0, 
			false, 
			0
		),
		{
			TextSize = DEF_SZ;
			TextColor3 = Color3.new(1, 1, 1);
			TextTransparency = 1;
			Position = UDim2.new(0.5, 0, 0.5, 0);
			Rotation = 0;
		}
	);
	
	self.MissTween = TweenService:Create(
		self.Object,
		TweenInfo.new(
			0.75,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.In,
			0,
			false,
			0
		),
		{
			TextSize = DEF_SZ;
			TextColor3 = Color3.new(1, 0, 0);
			Position = UDim2.new(0.5, 15, 0.5, 15);
			TextTransparency = 1;
			Rotation = 45;
		}
	)
end

--- export
return Message;