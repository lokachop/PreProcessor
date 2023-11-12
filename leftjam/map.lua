LeftJam = LeftJam or {}
local sti = require("sti")
local bump = require("bump")

LeftJam.CurrMapName = nil
LeftJam.CurrMap = nil
LeftJam.EntLayer = nil
LeftJam.BumpWorld = nil
LeftJam.MapSpawnPoint = nil
LeftJam.TexBackGround = nil

LeftJam.EndVolume = {}

LeftJam.ID2Elevator = {}
LeftJam.Elevators = {}
LeftJam.Buttons = {}
LeftJam.Text = {}

--[[
    MAP CONFIG HERE
]]--
local mapConfig = {
    ["untitled"] = {
        ["song"] = "chucks-egg-classic-arcade-game-116841.mp3",
        ["nextMap"] = "shit",
        --["backgroundCol"] = {.05, .1, .15},
        ["backgroundTex"] = "dev_assets/background.png"
    },
    ["shit"] = {
        ["song"] = "dizzy-keys-classic-arcade-game-116845.mp3",
        ["backgroundCol"] = {.2, .3, .4}
    },
    ["map_0"] = {
        ["song"] = "strategy-games-classic-arcade-game-116828.mp3",
        ["nextMap"] = "map_2",
        ["backgroundCol"] = {.149, 0.254, .149},
        --["backgroundTex"] = "assets/backgroundtest.png"
    },
    ["map_2"] = {
        ["song"] = "dizzy-keys-classic-arcade-game-116845.mp3",
        ["nextMap"] = "map_3",
        ["backgroundCol"] = {0, 0, 0}
    },
    ["map_3"] = {
        ["song"] = "chucks-egg-classic-arcade-game-116841.mp3",
        ["nextMap"] = "map_4",
        ["backgroundTex"] = "assets/background_c.png"
    },
    ["map_4"] = {
        ["song"] = "dizzy-keys-classic-arcade-game-116845.mp3",
        ["nextMap"] = "map_5",
        ["backgroundCol"] = {.149, 0.254, .149}
    },
    ["map_5"] = {
        ["song"] = "strategy-games-classic-arcade-game-116828.mp3",
        ["backgroundTex"] = "assets/background_d.png"
    },
}

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

        LeftJam.Elevators[#LeftJam.Elevators + 1] = {
            ["_isElevator"] = true,
            ["_travelFrac"] = 0,
            ["_isMoving"] = false,
            ["state"] = false,
            ["startPos"] = {ent.x, ent.y},
            ["endPos"] = {destObj.x, destObj.y},
            ["travelTime"] = travelTime,
            ["x"] = ent.x,
            ["velX"] = 0,
            ["y"] = ent.y,
            ["w"] = ent.width,
            ["h"] = ent.height,
            ["onTrigger"] = function(self, triggerFlag)
                self.state = triggerFlag
                --return true -- return if we can be triggered again0
            end,

            ["sourceSound"] = love.audio.newSource("audio/elevator.wav", "static"),
            ["activeSound"] = false,
        }
        local source = LeftJam.Elevators[#LeftJam.Elevators].sourceSound
        source:setLooping(true)
        source:setVolume(LeftJam.GlobalAudioLevel)

        LeftJam.ID2Elevator[ent.id] = LeftJam.Elevators[#LeftJam.Elevators]

        -- now init the bump.lua collisions
        local bumpWorld = LeftJam.BumpWorld
        bumpWorld:add(LeftJam.Elevators[#LeftJam.Elevators], ent.x, ent.y, ent.width, ent.height)
    end,
    ["Button"] = function(ent)
        local prop = ent.properties

        local destID = (prop.TriggerOnPressed or prop.triggerOnPressed).id
        local destObj = LeftJam.GetElevatorByID(destID)

        LeftJam.Buttons[#LeftJam.Buttons + 1] = {
            ["_flagHeld"] = false,
            ["x"] = ent.x,
            ["y"] = ent.y,
            ["w"] = ent.width,
            ["h"] = ent.height,
            ["heldPress"] = true,
            ["pressTarget"] = destObj,

            ["sourceSoundYes"] = love.audio.newSource("audio/button_yes.wav", "static"),
            ["sourceSoundNo"] = love.audio.newSource("audio/button_no.wav", "static"),
        }

        local source = LeftJam.Buttons[#LeftJam.Buttons].sourceSoundYes
        source:setVolume(LeftJam.GlobalAudioLevel)

        source = LeftJam.Buttons[#LeftJam.Buttons].sourceSoundNo
        source:setVolume(LeftJam.GlobalAudioLevel)
    end,
    ["Text"] = function(ent)
        local message = ent.text

        LeftJam.Text[#LeftJam.Text + 1] = {
            ["msg"] = message,
            ["x"] = ent.x,
            ["y"] = ent.y,
            ["w"] = ent.width,
            ["h"] = ent.height,
        }

    end
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
            local source = v.sourceSoundYes
            source:play()

            local target = v.pressTarget
            target.onTrigger(target, true)

            v._flagHeld = true
        elseif not hit and v._flagHeld then
            local source = v.sourceSoundNo
            source:play()

            local target = v.pressTarget

            target.onTrigger(target, false)
            v._flagHeld = false
        end

        local rx, ry = LeftJam.LocalizePosition(v.x + (v.w * .5), v.y)
        local _div = 64

        v.sourceSoundYes:setPosition(rx / _div, ry / _div, 0)
        v.sourceSoundNo:setPosition(rx / _div, ry / _div, 0)
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

        if fracChanged and not v.activeSound then
            local source = v.sourceSound
            source:play()

            v.activeSound = true
        elseif not fracChanged and v.activeSound then
            local source = v.sourceSound
            source:stop()

            v.activeSound = false
        end

        if v.activeSound then
            local rx, ry = LeftJam.LocalizePosition(v.x + (v.w * .5), v.y)
            local _div = 64

            local source = v.sourceSound
            source:setPosition(rx / _div, ry / _div, 0)
        end


        -- the fraction has updated, move us
        if fracChanged then
            v._isMoving = true
            local srcX, srcY = v.startPos[1], v.startPos[2]
            local dstX, dstY = v.endPos[1], v.endPos[2]

            local xc = lerp(v._travelFrac, srcX, dstX)
            local yc = lerp(v._travelFrac, srcY, dstY)

            local actSign = v.state and 1 or -1

            local fract = (1 / v.travelTime)
            local xChange = (dstX - srcX) * fract * dt

            v.velX = xChange * actSign

            v.x = xc
            v.y = yc

            bumpWorld:update(v, xc, yc)
        else
            v._isMoving = false
        end

    end
end

-- setup UI for next map

local triggeredMaps = {}

local srcWin = love.audio.newSource("audio/win.wav", "static")
srcWin:setVolume(LeftJam.GlobalAudioLevel)


function LeftJam.MapEndThink(dt)
    local ply = LeftJam.GetPlayer()
    local pX, pY = ply.x, ply.y

    local endVolume = LeftJam.EndVolume
    local exitPos = endVolume.pos
    local size = endVolume.sz

    local in_zone = inrange2D(pX, pY, exitPos[1], exitPos[2], exitPos[1] + size[1], exitPos[2] + size[2])

    if in_zone then
        if triggeredMaps[LeftJam.CurrMapName] then
            return
        end
        srcWin:play()

        local mapData = mapConfig[LeftJam.CurrMapName]

        -- TODO: implement MAP LOADING
        local nextMap = mapData.nextMap
        if nextMap then
            LeftJam.SetState(STATE_NEXT_MAP)
            LeftJam.SetupNextMapUI(nextMap)
            triggeredMaps[LeftJam.CurrMapName] = true
            -- normal
        else
            LeftJam.SetState(STATE_NEXT_MAP)
            LeftJam.SetupNextMapUI("credits")
            triggeredMaps[LeftJam.CurrMapName] = true
            -- credits
        end
    end

end



local srcMapSong = nil

function LeftJam.StopMapSounds()
    for k, v in ipairs(LeftJam.Elevators) do
        if v.activeSound then
            v.sourceSound:stop()
        end
    end

    if srcMapSong then
        srcMapSong:stop()
    end
end

function LeftJam.LoadMap(name)
    LeftJam.StopMapSounds()

    triggeredMaps = {}
    LeftJam.EndVolume = {}

    LeftJam.Elevators = {}
    LeftJam.Buttons = {}
    LeftJam.Text = {}
    LeftJam.CurrMapName = name

    LeftJam.BumpWorld = bump.newWorld(64) -- this makes A LOT of memory leaks i think since the last one isnt cleaned but no TIME :(

    LeftJam.CurrMap = sti("maps/" .. name .. ".lua", {"bump"})
    LeftJam.EntLayer = LeftJam.CurrMap:addCustomLayer("EntLayer", 3)

    LeftJam.CurrMap:bump_init(LeftJam.BumpWorld)
    LeftJam.CurrMap:removeLayer("CollisionLayer")

    -- audio
    local mapData = mapConfig[LeftJam.CurrMapName]
    srcMapSong = love.audio.newSource("audio/" .. mapData.song, "stream")
    srcMapSong:setLooping(true)
    srcMapSong:setVolume(LeftJam.MusicAudioLevel)
    srcMapSong:play()


    if mapData.backgroundTex then
        LeftJam.TexBackGround = love.graphics.newImage(mapData.backgroundTex)
    end

    -- setup entities
    for k, v in pairs(LeftJam.CurrMap.objects) do
        if mapObjectTypes[v.type] then
            mapObjectTypes[v.type](v)
        elseif v.shape == "text" then
            mapObjectTypes["Text"](v)
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

            if v.quad then
                local xc = math.floor(v.x) + (v.flipped and v.sizeX or 0)
                local yc = math.floor(v.y)
                love.graphics.draw(v.tex, v.quad, xc, yc, 0, v.flipped and -1 or 1, 1)
            else
                love.graphics.draw(v.tex, math.floor(v.x), math.floor(v.y))
            end

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


local texElevator = love.graphics.newImage("assets/elevator.png")
texElevator:setFilter("nearest", "nearest")
texElevator:setWrap("repeat")

local quadElevator = love.graphics.newQuad(0, 0, 32, 32, texElevator)

local function pushCamera()
    local w, h = love.graphics.getDimensions()
    local cx, cy, cz = LeftJam.GetCamParameteri()
    love.graphics.push()
        love.graphics.translate(-w * .5, -h * .5)
        love.graphics.scale(cz, cz)
        love.graphics.translate(w * .5, h * .5)
        love.graphics.translate(math.floor(cx), math.floor(cy))




end


local function renderElevators()
    pushCamera()
        for k, v in ipairs(LeftJam.Elevators) do
            quadElevator:setViewport(0, 0, v.w, v.h)

            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(texElevator, quadElevator, v.x, v.y)
        end

    love.graphics.pop()
end


local fontText = love.graphics.newFont("fonts/consola.ttf", 16, "mono", 2)
local function renderText()
    pushCamera()
        for k, v in ipairs(LeftJam.Text) do
            love.graphics.printf(v.msg, fontText, v.x, v.y, v.w, "center")
        end
    love.graphics.pop()
end

function LeftJam.MapDraw()
    love.graphics.setColor(1, 1, 1)
    local w, h = love.graphics.getDimensions()

    local mapData = mapConfig[LeftJam.CurrMapName]
    if mapData and mapData.backgroundCol then
        local col = mapData.backgroundCol
        love.graphics.setColor(col[1], col[2], col[3])
        love.graphics.rectangle("fill", 0, 0, w, h)
    elseif mapData and mapData.backgroundTex then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(LeftJam.TexBackGround, 0, 0)
    end

    local cx, cy, cz = LeftJam.GetCamParameteri()
    local wd, hd = w / cz, h / cz



    love.graphics.setColor(1, 1, 1)
    LeftJam.CurrMap:draw(cx + wd * .5, cy + hd * .5, cz)
    renderElevators()

    renderText()

    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1)
    --LeftJam.CurrMap:bump_draw(cx + wd * .5, cy + hd * .5, cz, cz)
end