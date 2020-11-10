--- SoundHandler.lua
-- Handles sfx and music
-- @author Magical_Noob
local CONFIG = require(script:WaitForChild("Config"));

local SoundHandler = {};
SoundHandler.__index = SoundHandler;
SoundHandler.Parent = nil;

SoundHandler.Cache = {};

--- OneShotAudio
-- @param id: string
function SoundHandler:OneShotAudio(id, volume)
	local sound = Instance.new("Sound", self.Parent);
	sound.SoundId = id;
	sound.PlayOnRemove = true;
	sound.Volume = volume or 1;
	sound:Destroy();
end

--- PlayMusic
-- @param id: string
-- @return callback: function
function SoundHandler:PlayMusic(id)
	self.BackgroundMusic:Stop();
	self.BackgroundMusic.SoundId = id;
	while (not self.BackgroundMusic.IsLoaded) do
		wait();
	end
	
	return function()
		self.BackgroundMusic:Play();
	end
end

--- PlaySound
-- @param name: string
function SoundHandler:PlaySound(name)
	local sndGroup = CONFIG[name];
	if (typeof(sndGroup == "table")) then
		if (sndGroup.random) then
			self:OneShotAudio(
				sndGroup[math.random(1, #sndGroup)], 
				sndGroup.volume
			);
		else
			if (not self.Cache[name]) then
				self.Cache[name] = -1;
			end
			self.Cache[name] = ((self.Cache[name] + 1) % #sndGroup)
			self:OneShotAudio(
				sndGroup[self.Cache[name] + 1], 
				sndGroup.volume
			);
		end
	else
		self:OneShotAudio(sndGroup);
	end
end

--- SetParent
-- @param as: Instance
function SoundHandler:SetParent(as)
	self.Parent = as;
	self.BackgroundMusic = Instance.new("Sound", as);
	self.BackgroundMusic.Volume = 1;
end

return SoundHandler;