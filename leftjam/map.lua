LeftJam = LeftJam or {}
local sti = require("sti")
local bump = require("bump")

LeftJam.CurrMapName = nil
LeftJam.CurrMap = nil
LeftJam.EntLayer = nil
LeftJam.BumpWorld = nil
LeftJam.MapSpawnPoint = nil


LeftJam.EndVolume = {}

LeftJam.ID2Elevator = {}
LeftJam.Elevators = {}
LeftJam.Buttons = {}

function LeftJam.GetMapObjectByID(id)
    return LeftJam.CurrMap.objects[id]
end


function LeftJam.GetElevatorByID(id)
    return LeftJam.ID2Elevator[id]
end


local mapObjectTypes = {
    ["PlayerSpawn"] = function(ent)
        LeftJam.MapSpawnPoint = {ent.x, ent.y}
        LeftJam.SetCamPos(ent.x, ent.y)
    end,
    ["EndPoint"] = function(ent)
        LeftJam.EndVolume = {
            pos = {ent.x, ent.y},
            sz = {ent.width, ent.height},
        }
    end,
    ["Elevator"] = function(ent)
        local prop = ent.properties
        local destID = prop.destinationObj.id
        local travelTime = prop.travelTime

        local destObj = LeftJam.GetMapObjectByID(destID)


        print(ent.x, ent.y)
        print(destObj.x, destObj.y)
        --for k, v in pairs(destObj) do
        --    print("[" .. k .. "]: " .. tostring(v))
        --end

        LeftJam.Elevators[#LeftJam.Elevators + 1] = {
            ["_travelFrac"] = 0,
            ["state"] = false,
            ["startPos"] = {ent.x, ent.y},
            ["endPos"] = {destObj.x, destObj.y},
            ["travelTime"] = travelTime,
            ["x"] = ent.x,
            ["y"] = ent.y,
            ["onTrigger"] = function(self, triggerFlag)
                print("triggered!", tostring(triggerFlag))
                self.state = triggerFlag
                --return true -- return if we can be triggered again
            end,
        }

        LeftJam.ID2Elevator[ent.id] = LeftJam.Elevators[#LeftJam.Elevators]

        -- now init the bump.lua collisions
        local bumpWorld = LeftJam.BumpWorld
        bumpWorld:add(LeftJam.Elevators[#LeftJam.Elevators], ent.x, ent.y, ent.width, ent.height)
    end,
    ["Button"] = function(ent)
        local prop = ent.properties
        local destID = prop.TriggerOnPressed.id
        local destObj = LeftJam.GetElevatorByID(destID)

        LeftJam.Buttons[#LeftJam.Buttons + 1] = {
            ["_flagHeld"] = false,
            ["x"] = ent.x,
            ["y"] = ent.y,
            ["w"] = ent.width,
            ["h"] = ent.height,
            ["heldPress"] = true,
            ["pressTarget"] = destObj,
        }
    end,
}

local function inrange(a, min, max)
    return (a >= min) and (a <= max)
end

local function inrange2D(x, y, minX, minY, maxX, maxY)
    return inrange(x, minX, maxX) and inrange(y, minY, maxY)
end

local function lerp(t, a, b)
    return a * (1 - t) + b * t
end

local mapTree = {
    ["untitled"] = "shit"
}

function LeftJam.ButtonThink(dt)
    local bumpWorld = LeftJam.BumpWorld
    for k, v in ipairs(LeftJam.Buttons) do
        local hit = false
        local cols, len = bumpWorld:queryRect(v.x, v.y, v.w, v.h)
        for k2, v2 in ipairs(cols) do
            if v2._isLokaObject then
                hit = true
                break
            end
        end

        if hit and (not v._flagHeld) then
            local target = v.pressTarget
            target.onTrigger(target, true)

            v._flagHeld = true
        elseif not hit and v._flagHeld then
            local target = v.pressTarget

            target.onTrigger(target, false)
            v._flagHeld = false
        end
    end
end

function LeftJam.ElevatorThink(dt)
    local bumpWorld = LeftJam.BumpWorld

    for k, v in ipairs(LeftJam.Elevators) do
        local fracChanged = false
        if v.state == true and v._travelFrac < 1 then
            local sDiv = 1 / v.travelTime
            v._travelFrac = math.min(v._travelFrac + (sDiv * dt), 1)
            fracChanged = true
        elseif v.state == false and v._travelFrac > 0 then
            local sDiv = 1 / v.travelTime
            v._travelFrac = math.max(v._travelFrac - (sDiv * dt), 0)
            fracChanged = true
        end


        -- the fraction has updated, move us
        if fracChanged then
            local srcX, srcY = v.startPos[1], v.startPos[2]
            local dstX, dstY = v.endPos[1], v.endPos[2]

            local xc = lerp(v._travelFrac, srcX, dstX)
            local yc = lerp(v._travelFrac, srcY, dstY)

            v.x = xc
            v.y = yc

            bumpWorld:update(v, xc, yc)
        end

    end
end


-- setup UI for next map

local triggeredMaps = {}

function LeftJam.MapEndThink(dt)
    local ply = LeftJam.GetPlayer()
    local pX, pY = ply.posX, ply.posY

    local endVolume = LeftJam.EndVolume
    local exitPos = endVolume.pos
    local size = endVolume.sz

    local in_zone = inrange2D(pX, pY, exitPos[1], exitPos[2], exitPos[1] + size[1], exitPos[2] + size[2])

    if in_zone then
        if triggeredMaps[LeftJam.CurrMapName] then
            return
        end

        -- TODO: implement MAP LOADING
        local nextMap = mapTree[LeftJam.CurrMapName]
        if nextMap then
            LeftJam.SetState(STATE_NEXT_MAP)
            LeftJam.SetupNextMapUI(nextMap)
            triggeredMaps[LeftJam.CurrMapName] = true
            -- normal
        else
            -- credits
        end
    end

end


function LeftJam.LoadMap(name)
    LeftJam.EndVolume = {}

    LeftJam.Elevators = {}
    LeftJam.Buttons = {}
    LeftJam.CurrMapName = name

    LeftJam.BumpWorld = bump.newWorld(64) -- this makes A LOT of memory leaks i think since the last one isnt cleaned but no TIME :(

    LeftJam.CurrMap = sti("maps/" .. name .. ".lua", {"bump"})
    LeftJam.EntLayer = LeftJam.CurrMap:addCustomLayer("EntLayer", 3)

    LeftJam.CurrMap:bump_init(LeftJam.BumpWorld)
    LeftJam.CurrMap:removeLayer("CollisionLayer")


    -- setup entities
    for k, v in pairs(LeftJam.CurrMap.objects) do
        if mapObjectTypes[v.type] then
            mapObjectTypes[v.type](v)
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

            if v._colourTint then
                love.graphics.setColor(v._colourTint[1], v._colourTint[2], v._colourTint[3])
            else
                love.graphics.setColor(1, 1, 1)
            end
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

    LeftJam.CurrMap:bump_draw(cx + wd * .5, cy + hd * .5, cz, cz)
end