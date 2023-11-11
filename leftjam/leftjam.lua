LeftJam = LeftJam or {}

local function loadFile(name)
    require("leftjam." .. name)
end


loadFile("util")
loadFile("ui")
loadFile("player")
loadFile("map")
loadFile("states")
loadFile("states.game")
loadFile("states.nextmap")
loadFile("states.mainmenu")
loadFile("states.credits")