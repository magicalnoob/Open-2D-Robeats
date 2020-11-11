--- GameConfig.lua
-- lol game config wow ok
-- @author Magical_Noob

local GameConfig = {};
GameConfig.__index = GameConfig;

GameConfig.NOTE_RANGE = 1.5;
GameConfig.NOTE_FAIL_RANGE = 1.15;
GameConfig.NOTE_SCORES = {
	perfect = 25;
	great = 50;
	meh = 100;
	bad = 150;
}

return GameConfig;
