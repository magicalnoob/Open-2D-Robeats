--- GameConfig.lua
-- lol game config wow ok
-- @author Magical_Noob

local GameConfig = {};
GameConfig.__index = GameConfig;

GameConfig.NOTE_RANGE = 1.5;
GameConfig.NOTE_FAIL_RANGE = 1.15;
GameConfig.MAX_TRACKS = 4;
GameConfig.MAX_PTS = 4;

GameConfig.TRACK_SETTINGS = {
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

GameConfig.NOTE_SCORES = {
	perfect = {
		range = 25;
		pts_add = 4;
	};
	great = {
		range = 50;
		pts_add = 3;
	};
	mesh = {
		range = 75;
		pts_add = 2;
	};
	bad = {
		range = 100;
		pts_add = 1;
	}
}

return GameConfig;
