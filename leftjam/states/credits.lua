LeftJam = LeftJam or {}
LeftJam.States = LeftJam.States or {}



local credits_blob = [[
 
 
 
 
 
 
 
 
 
#title#
 
 
 
 
 
An entry to the [game jam name] game jam
By Lefton
 
 
--==Libraries used==--
bump.lua
[https://github.com/kikito/bump.lua]
   
Simple Tiled Implementation
[https://github.com/karai17/Simple-Tiled-Implementation/]
 
LvLKUI
[https://github.com/lokachop/LvLKUI/]
 
 
--==Tools used==--
Tiled
[https://www.mapeditor.org/]
 
LibreSprite
[https://libresprite.github.io]
(which is a fork of Aseprite)
[https://www.aseprite.org/]
 
GIMP
[https://www.gimp.org/]
 
 
 
 
 
Thanks for playing!
]]

-- now to parse it

local credit_time = 0
local scroll_speed = 96

local _font = love.graphics.newFont(26)

local lineData = {}
local lines = string.gmatch(credits_blob, "([^\n]+)")
local lineID = 0
local lineCount = 0
for line in lines do
    lineID = lineID + 1

    if line == "#title#" then
        lineData[lineID] = "title"
    else
        lineData[lineID] = love.graphics.newText(_font, line)
    end
end
lineCount = lineID



local textSpace = 64
LeftJam.States[STATE_CREDITS] = {}

LeftJam.States[STATE_CREDITS].init = function()
    credit_time = 0
end

LeftJam.States[STATE_CREDITS].think = function(dt)
    credit_time = credit_time + dt

    local endTime = ((lineCount * textSpace) / scroll_speed) + 6
    if credit_time > endTime then
        LeftJam.SetState(STATE_MENU)
    end

end

local logo = love.graphics.newImage("assets/preprocessor_logo.png")
logo:setFilter("nearest", "nearest")

LeftJam.States[STATE_CREDITS].render = function()
    love.graphics.clear(0, 0, 0)

    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(1, 1, 1)


    for k, v in ipairs(lineData) do
        if v == "title" then

            local lw, lh = logo:getDimensions()
            local sclMul = 12
            love.graphics.draw(logo, w * .5 - lw * .5 * sclMul, (k * textSpace) - (credit_time * scroll_speed) - lh * .5 * sclMul, 0, sclMul, sclMul)
        else
            local tw, th = v:getDimensions()
            love.graphics.draw(v, w * .5 - tw * .5, (k * textSpace) - (credit_time * scroll_speed))
        end
    end
end

LeftJam.States[STATE_CREDITS].exit = function()
end