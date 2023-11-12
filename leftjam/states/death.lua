LeftJam = LeftJam or {}
LeftJam.States = LeftJam.States or {}


LeftJam.States[STATE_DIE] = {}

LeftJam.States[STATE_DIE].init = function()
    --LeftJam.LoadMap("untitled")
    --LeftJam.InitPlayer()
end

LeftJam.States[STATE_DIE].think = function(dt)
    --print("Brain activation")
    --LeftJam.PlayerThink(dt)

    --LeftJam.MapThink(dt)
    LeftJam.CamThink(dt)
    --LeftJam.SwitchControllable(dt)
    --LeftJam.MapEndThink(dt)
end

LeftJam.States[STATE_DIE].render = function()
    love.graphics.clear(.2, .3, .4)
    love.graphics.setColor(1, 1, 1)
    LeftJam.MapDraw()
    LeftJam.RenderControlSphere()


    -- make gradient
    local w, h = love.graphics.getDimensions()
    LeftJam.RenderOKLabGradient(0, 0, w, h, {24, 24, 24, 242.25}, {128, 64, 32}, 128)
end

LeftJam.States[STATE_DIE].exit = function()
end