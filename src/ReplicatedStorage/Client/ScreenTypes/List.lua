--- List.lua
-- @author Magical_Noob

local TextService = game:GetService("TextService");
local List = {};
List.__index = List;

local FONT = Enum.Font.RobotoMono;
local SIZE = 24;

local REF_CONTAINS = {
	OnMouseClick = {
		className = "TextButton";
		listener = "MouseButton1Click";
	}
}

--- OnSignalEvent
function List:OnSignalEvent(ref)
	self.Object.Text = string.format(self.Pattern, ref[self.Ref]);
end

--- GetPosition
-- @return position: UDim2
function List:GetPosition()
	return UDim2.new(
		0, 
		5, 
		0, 
		37 + (24 * (#self.gui:GetChildren()-1))
	);
end

--- GetSize
-- @param font: Enum.Font
-- @param size: number
-- @param text: string
-- @return size: UDim2
function List:GetSize(font, size, text)
	local bounds = TextService:GetTextSize(text, size, font, Vector2.new(1000, size))
	return UDim2.new(
		0,
		bounds.X,
		0,
		bounds.Y
	);
end

--- constructor
-- @param reference: array
-- @param pattern: string
-- @param parent?: Instance
-- @param text?: string
function List:constructor(reference, pattern, parent, text)
	self.Pattern = pattern;
	self.Ref = reference;
	
	local className = "TextLabel";
	local listener;
	local text = string.format(pattern, text or "");
	
	--- get container
	for name, cont in pairs(REF_CONTAINS)do
		if (reference[name]) then
			className = cont.className;
			listener = cont.listener;
			break;
		end
	end
	
	--- make objects
	self.Object = self:Make(
		{
			Parent = parent or self.gui;
			ClassName = className;
			Font = FONT;
			TextSize = SIZE;
			TextColor3 = Color3.new(1, 1, 1);
			BackgroundTransparency = 1;
			
			Position = self:GetPosition();
			Size = self:GetSize(FONT, SIZE, text);
			
			Text = text;
		}
	);
	
	-- wpw 
	self:Make(
		{
			ClassName = "ImageLabel";
			ScaleType = Enum.ScaleType.Crop;
			Image = reference.Image;
			ZIndex = 0;
			
			Parent = self.Object;
			BackgroundTransparency = 1;
		}
	);
	
--#IF
if (not listener) then
	return;
end
--#ENDIF
	
	--- do this
	self.Object[listener]:Connect(function()
		reference.OnMouseClick(reference);
	end);
end

--- export
return List;