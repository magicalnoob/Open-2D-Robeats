-- @todo Make accuracy score
if (not game:IsLoaded()) then
	game.Loaded:Wait();
end

local App = require(script.Parent.PlayerModule);
App:OnGameLoaded();
App:OnRequestSongList();

--- Make game routine
game:GetService("RunService"):BindToRenderStep(
	"render",
	Enum.RenderPriority.Last.Value,
	function(dt)
		App.GameHandler:Update(dt);
	end
)
