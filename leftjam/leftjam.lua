LeftJam = LeftJam or {}

local function loadFile(name)
    require("leftjam." .. name)
end

loadFile("player")
loadFile("map")
loadFile("render")
loadFile("states")
loadFile("states.game")
