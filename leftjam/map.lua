LeftJam = LeftJam or {}
local sti = require("sti")
local bump = require("bump")


LeftJam.CurrMap = nil
LeftJam.EntLayer = nil
LeftJam.BumpWorld = nil
LeftJam.MapSpawnPoint = nil


LeftJam.EndVolume = {}

local mapObjectTypes = {
    ["PlayerSpawn"] = function(ent)
        LeftJam.MapSpawnPoint = {ent.x, ent.y}
        LeftJam.SetCamPos(ent.x, ent.y)
    end,
    ["EndPoint"] = function(ent)
        for k, v in pairs(ent) do
            print(k, v)
        end

        LeftJam.EndVolume = {
            pos = {ent.x, ent.y},
            sz = {ent.width, ent.height},
        }
    end
}

function LeftJam.MapEndThink(dt)
    
end


function LeftJam.LoadMap(name)
    LeftJam.BumpWorld = bump.newWorld(64) -- this makes A LOT of memory leaks i think since the last one isnt cleaned but no TIME :(

    LeftJam.CurrMap = sti("maps/" .. name .. ".lua", {"bump"})
    LeftJam.EntLayer = LeftJam.CurrMap:addCustomLayer("EntLayer", 3)

    LeftJam.CurrMap:bump_init(LeftJam.BumpWorld)
    LeftJam.CurrMap:removeLayer("CollisionLayer")


    -- setup entities
    for k, v in pairs(LeftJam.CurrMap.objects) do
        if mapObjectTypes[v.name] then
            mapObjectTypes[v.name](v)
        end
    end

    -- setup the ent layer render
    LeftJam.EntLayer.draw = function(self)
        for k, v in pairs(self) do
            if type(v) ~= "table" then
                goto _cont
            end

            if not v._isLokaObject then
                goto _cont
            end

            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(v.tex, math.floor(v.posX), math.floor(v.posY))

            ::_cont::
        end
    end


    LeftJam.EntLayer.update = function(self, dt)
        for k, v in pairs(self) do
            if type(v) ~= "table" then
                goto _cont
            end

            if not v._isLokaObject then
                goto _cont
            end


            v.moveFunc(v, dt)

            ::_cont::
        end
    end
end

function LeftJam.MapThink(dt)
    LeftJam.CurrMap:update(dt)
end

function LeftJam.MapDraw()
    local cx, cy, cz = LeftJam.GetCamParameteri()

    local w, h = love.graphics.getDimensions()
    local wd, hd = w / cz, h / cz


    LeftJam.CurrMap:draw(cx + wd * .5, cy + hd * .5, cz)

    --LeftJam.CurrMap:bump_draw(cx + wd * .5, cy + hd * .5, cz, cz)
end