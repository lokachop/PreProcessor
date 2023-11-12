LeftJam = LeftJam or {}
LeftJam.States = LeftJam.States or {}


LeftJam.States[STATE_GAME] = {}

LeftJam.States[STATE_GAME].init = function()
    --print("Hello!")
    LeftJam.SetPlayerHealth(100)
    LeftJam.InitPlayer()
end

LeftJam.States[STATE_GAME].think = function(dt)
    --print("Brain activation")
    --LeftJam.PlayerThink(dt)

    LeftJam.MapThink(dt)
    LeftJam.CamThink(dt)
    LeftJam.SwitchControllable(dt)
    LeftJam.MapEndThink(dt)
    LeftJam.ButtonThink(dt)
    LeftJam.ElevatorThink(dt)
    LeftJam.PlayerFallVoidDie()
    LeftJam.PlayerAnimThink(dt)

    --LeftJam.DamagePlayer(-dt * 32)
end

LeftJam.States[STATE_GAME].render = function()
    love.graphics.clear(.2, .3, .4)
    love.graphics.setColor(1, 1, 1)
    LeftJam.MapDraw()
    LeftJam.RenderControlSphere()

    love.graphics.setColor(1, 1, 1)
    --LeftJam.PlayerDraw()
end

LeftJam.States[STATE_GAME].exit = function()
    print("Bye!")
end