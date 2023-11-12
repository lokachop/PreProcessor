LeftJam = LeftJam or {}
-- this file handles thep layer and the camera

local TARGET_BODY = 2
local TARGET_ARM_LEFT = 1
local TARGET_ARM_RIGHT = 3

local SELECTED_TARGET = 2


local PHYSVOID = 5120000
local CONNECTION_DIST = 512
local controllables = {}


LeftJam.PlayerHealth = 100
function LeftJam.DamagePlayer(delta)
    LeftJam.PlayerHealth = math.max(math.min(LeftJam.PlayerHealth + delta, 100), 0)
    print("hp; ", LeftJam.PlayerHealth)


    if LeftJam.PlayerHealth <= 0 then -- we died
        LeftJam.SetupDieUI()
        LeftJam.SetState(STATE_DIE)

    end
end

function LeftJam.SetPlayerHealth(hp)
    LeftJam.PlayerHealth = hp
end

function LeftJam.GetPlayerHealth()
    return LeftJam.PlayerHealth
end

function LeftJam.NewControllable(id, params)
    params = params or {}

    controllables[id] = {
        posX = 0,
        posY = 0,
        velX = 0,
        velY = 0,
        rSeed = math.random(),
        controlled = false,
        _isLokaObject = true,
    }

    for k, v in pairs(params) do
        controllables[id][k] = v
    end

    -- all jank no good

    if params["childDocked"] then
        controllables[id].parent = controllables[TARGET_BODY]
        controllables[TARGET_BODY].children[id] = controllables[id]
    end
end

-- https://love2d.org/forums/viewtopic.php?t=1951
-- ALSO REALLY SLOW btw BUT ITS 48HRRR 
local function dist2D(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2

    return math.sqrt(dx * dx + dy * dy)
end

local function isGrounded(self)
    local world = LeftJam.BumpWorld


    local gcvX = self.posX
    local gcvY = self.posY + self.sizeY

    local velY = self.velY
    local propSize = math.max((velY * .0025) + 8, 8)


    local relaHeight = 0
    local items, len = world:queryRect(gcvX, gcvY, self.sizeX, propSize)
    if len > 0 then
        relaHeight = items[1].y - self.posY
    end

    return len > 0, relaHeight
end


local daccel = 512
local stop_val = 1
local hover_alt = 28.5
local function genericPhysics(self, dt) -- applies generic physics movement
    local accelInv = self.velX > 0 and 1 or -1

    accelInv = math.max(math.min((math.abs(self.velX) ^ 2) * accelInv, daccel), -daccel)

    self.velX = self.velX - accelInv * dt * .5


    local nx, ny = self.posX + (self.velX * dt), self.posY + (self.velY * dt)

    local world = LeftJam.BumpWorld
    local ax, ay, cols, len = world:move(self, nx, ny)

    for k, v in ipairs(cols) do
        local norm = v.normal
        if norm.x ~= 0 then
            self.velX = 0
        end

        if norm.y ~= 0 then
            self.velY = 0
        end
    end

    self.posX = ax
    self.posY = ay


    self.velY = self.velY + 24
    self.velX = self.velX - accelInv * dt * .5


    if math.abs(self.velX) < stop_val then
        self.velX = 0
    end

    -- check if the pos is grounded
    local ground, relaHeight = isGrounded(self)
    if ground then
        local deltaAlt = relaHeight - hover_alt
        self.posY = self.posY + deltaAlt


        self.velY = 0
        self.grounded = true
    else
        self.grounded = false
    end

end

function LeftJam.InitPlayer()
    -- get the bumpworld of the current map's entities
    local world = LeftJam.BumpWorld

    -- teleport the player to the spawnpoint
    local sp = LeftJam.MapSpawnPoint
    local sx, sy = sp[1], sp[2]

    for k, v in ipairs(controllables) do

        v.posX = sx
        v.posY = sy
        local pPhysX = v.posX
        local pPhysY = v.posY
        if v["physicsVoid"] then
            pPhysX = PHYSVOID
            pPhysY = PHYSVOID
        end


        -- add the collider
        -- they0re all teleported but they should ease out to their docked positions
        world:add(v, pPhysX, pPhysY, v.sizeX, v.sizeY)


        LeftJam.EntLayer[k] = v
    end

end


local function new_lp_tex(path)
    local imga = love.graphics.newImage(path)
    imga:setFilter("nearest", "nearest")
    return imga
end


-- rendering
local tex_torso = new_lp_tex("dev_assets/dev_player_torso.png")



LeftJam.NewControllable(TARGET_BODY, {
    ["sizeX"] = 12,
    ["sizeY"] = 23,

    ["tex"] = tex_torso,

    ["theParent"] = true, -- redundant but cool
    ["children"] = {},
    ["controlled"] = true,
    ["canMove"] = function(self)
        local children = self.children
        --local l1 = children["TARGET_LEGS"].isDocked

        return true
    end,
    ["moveFunc"] = function(self, dt)
        genericPhysics(self, dt)

        local canMove = self:canMove()
        if not canMove then
            return
        end

        if not self.controlled then
            return
        end


        local daddMax = 16
        local daddTarget = 128 + 8
        if love.keyboard.isDown("d") then
            local dadd = math.max(math.min(daddTarget - self.velX, daddMax), -daddMax)
            self.velX = math.min(self.velX + dadd, daddTarget)
        end

        if love.keyboard.isDown("a") then
            local dadd = math.max(math.min(daddTarget - math.abs(self.velX), daddMax), -daddMax)
            self.velX = math.max(self.velX - dadd, -daddTarget)
        end

        if (love.keyboard.isDown("w") or love.keyboard.isDown("space")) and self.grounded then
            self.velY = -256 - 128
        end


    end,
})


local function length2D(x, y)
    return math.sqrt(x * x + y * y)
end

local function moveTowards2D(ax, ay, bx, by, delta)
    local dx = bx - ax
    local dy = by - ay

    local len = length2D(dx, dy)

    if (len <= delta) or len == 0 then
        return bx, by
    end

    return ax + (dx / len) * delta, ay + (dy / len) * delta
end


local function limbDock(self, dt, velMin, velMax)
    velMin = velMin or 96
    velMax = velMax or 256

    self.realcdX = self.cdX + math.sin(CurTime * 0.855 + (self.rSeed * math.pi)) * 3 * self.rSeed
    self.realcdY = self.cdY + math.cos(CurTime * 1.4653 + (self.rSeed * math.pi)) * 3 * self.rSeed

    local dx, dy = self.realcdX, self.realcdY

    local parent = self.parent
    local fx, fy = dx + parent.posX, dy + parent.posY

    local deltaDist = dist2D(self.posX, self.posY, fx, fy)
    deltaDist = math.max(math.min(deltaDist + velMin, velMax), velMin)

    local mx, my = moveTowards2D(self.posX, self.posY, fx, fy, dt * deltaDist)
    self.posX = mx
    self.posY = my

    --local world = LeftJam.BumpWorld
    --world:update(self, self.posX, self.posY)

end


local tex_arm = new_lp_tex("dev_assets/dev_player_arm.png")


local function armCanMove(self, nx, ny)
    local parent = self.parent
    local px, py = parent.posX, parent.posY

    local dist = dist2D(nx, ny, px, py)
    if dist > CONNECTION_DIST then
        return false
    else
        return true
    end
end

local function armMove(self, dt)
    if (not self.controlled) and self.isDocked then
            if self.lastDockFlag then
                self.lastDockFlag = false
                LeftJam.BumpWorld:update(self, PHYSVOID, PHYSVOID)
            end


            limbDock(self, dt, 96, 256)
            return
        end

        if not self.controlled then
            return
        end

        local _mvVel = 128
        local nx = self.posX
        local ny = self.posY

        local parent = self.parent
        local px, py = parent.posX, parent.posY

        local dist = dist2D(nx, ny, px, py)
        local deltaDist = 1 - (dist / CONNECTION_DIST)

        local changed = false
        if love.keyboard.isDown("d") then
            nx = nx + (dt * _mvVel * deltaDist)
            changed = true
        end

        if love.keyboard.isDown("a") then
            nx = nx - (dt * _mvVel * deltaDist)
            changed = true
        end

        if love.keyboard.isDown("w") then
            ny = ny - (dt * _mvVel * deltaDist)
            changed = true
        end

        if love.keyboard.isDown("s") then
            ny = ny + (dt * _mvVel * deltaDist)
            changed = true
        end

        if not changed then
            return
        end

        if not self.lastDockFlag then
            self.lastDockFlag = true
            self.posY = self.posY - 24
        end

        if not self:canMove(nx, ny) then
            return
        end

        if changed and self.isDocked then
            self.isDocked = false
        end

        local world = LeftJam.BumpWorld
        world:update(self, self.posX, self.posY)

        local found = false
        local border_pardon = 4
        local items, len = world:queryRect(nx - border_pardon, ny - border_pardon, self.sizeX + (border_pardon * 2), self.sizeY + (border_pardon * 2))
        for k, v in ipairs(items) do
            if not v._isLokaObject then
                found = true
                break
            end
        end



        if found then
            self.isGlued = true
            world:update(self, self.posX, self.posY)


            local ax, ay, cols, len = world:move(self, nx, ny)
            self.posX = ax
            self.posY = ay
            self._colourTint = {0.5, 1, 0.5}
        else
            self.isGlued = false
            world:update(self, PHYSVOID, PHYSVOID)

            self.posX = nx
            self.posY = ny
            self._colourTint = {1, 0.5, 0.5}
        end


end


LeftJam.NewControllable(TARGET_ARM_LEFT, {
    ["sizeX"] = 16,
    ["sizeY"] = 7,

    ["tex"] = tex_arm,

    ["isDocked"] = true,
    ["childDocked"] = true,
    ["lastDockFlag"] = false,
    ["isGlued"] = false,
    ["cdX"] = 0,
    ["cdY"] = 12,

    ["physicsVoid"] = true,
    ["_colourTint"] = {1, 1, 1},

    ["canMove"] = armCanMove,
    ["moveFunc"] = armMove,
})

LeftJam.NewControllable(TARGET_ARM_RIGHT, {
    ["sizeX"] = 16,
    ["sizeY"] = 7,

    ["tex"] = tex_arm,

    ["isDocked"] = true,
    ["childDocked"] = true,
    ["lastDockFlag"] = false,
    ["isGlued"] = false,
    ["cdX"] = -2,
    ["cdY"] = 10,

    ["physicsVoid"] = true,
    ["_colourTint"] = {1, 1, 1},

    ["canMove"] = armCanMove,
    ["moveFunc"] = armMove,
})



local camX, camY = 0, 0
local camZoom = 1

function LeftJam.GetCamOffset()
    return camX, camY
end

function LeftJam.GetCamZoom()
    return camZoom
end

function LeftJam.GetCamParameteri()
    return camX, camY, camZoom
end

function LeftJam.GetPlayer()
    return controllables[TARGET_BODY]
end

function LeftJam.SetCamPos(x, y)
    camX, camY = -x, -y
end

function LeftJam.CamThink(dt)
    local w, h = love.graphics.getDimensions()

    local target = controllables[SELECTED_TARGET]

    local tPosX = -target.posX
    local tPosY = -target.posY

    local tVelX = -target.velX
    local tVelY = -target.velY

    local fx = tPosX + tVelX * .2
    local fy = tPosY + tVelY * .1


    local dx = camX - fx
    local dy = camY - fy

    local lenCam = length2D(dx, dy)

    local dtMul = dt * lenCam * 8.5

    camX, camY = moveTowards2D(camX, camY, fx, fy, dtMul)

    camZoom = 2

end


local function switchToTarget(target)
    local curr = controllables[SELECTED_TARGET]
    curr.controlled = false

    if curr._colourTint then
        curr._colourTint = {1, 1, 1}
    end

    SELECTED_TARGET = target
    local new = controllables[SELECTED_TARGET]
    new.controlled = true
end

local escToggleFlag = false
local tabToggleFlag = false
local fToggleFlag = false
function LeftJam.SwitchControllable(dt)
    local escdown = love.keyboard.isDown("escape")
    if escdown and not escToggleFlag then
        switchToTarget(TARGET_BODY)
        escToggleFlag = true
    elseif not escdown and escToggleFlag then
        escToggleFlag = false
    end


    local tdown = love.keyboard.isDown("tab")
    if tdown and not tabToggleFlag then
        local max = #controllables
        switchToTarget(((SELECTED_TARGET + 0) % max) + 1)
        tabToggleFlag = true
    elseif not tdown and tabToggleFlag then
        tabToggleFlag = false
    end

    if SELECTED_TARGET ~= TARGET_BODY then
        return
    end



    local fdown = love.keyboard.isDown("f")
    if fdown and not fToggleFlag then
        for i = 1, #controllables do
            if not controllables[i].theParent then
                controllables[i].isDocked = true
            end
        end

        fToggleFlag = true
    elseif not fdown and fToggleFlag then
        fToggleFlag = false
    end
end

function LeftJam.RenderControlSphere()
    if (SELECTED_TARGET ~= TARGET_ARM_LEFT) and (SELECTED_TARGET ~= TARGET_ARM_RIGHT) then
        return
    end


    local cx, cy, cz = LeftJam.GetCamParameteri()

    local w, h = love.graphics.getDimensions()
    local wd, hd = w / cz, h / cz


    love.graphics.push()
        love.graphics.translate(-w * .5, -h * .5)
        love.graphics.scale(cz, cz)
        love.graphics.translate(w * .5, h * .5)
        love.graphics.translate(cx, cy)


        local playerEnt = LeftJam.GetPlayer()
        local plyX, plyY = playerEnt.posX, playerEnt.posY

        love.graphics.setColor(1, 0.25, 0.25, 0.25)
        love.graphics.circle("fill", plyX, plyY, CONNECTION_DIST)

        --love.graphics.setColor(1, 1, 1, 1)
        --love.graphics.circle("fill", plyX + 6, plyY, 1)

    love.graphics.pop()
end