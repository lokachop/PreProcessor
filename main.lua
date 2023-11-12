-- PreProcessor
-- a game jam game
-- made by Lefton
-- uses alot of libraries


math.randomseed(os.time())
LeftJam = LeftJam or {}

LeftJam.GlobalAudioLevel = 0.7

function love.load()
	love.filesystem.load("lvlkui/lvlkui.lua")()
	love.filesystem.load("leftjam/leftjam.lua")()
	CurTime = 0

	--LeftJam.LoadMap("untitled")
	LeftJam.SetState(STATE_MENU)
end

function love.update(dt)
	CurTime = CurTime + dt

	LeftJam.StateThink(dt)

	LvLKUI.TriggerThink(dt)
end

function love.textinput(t)
	LvLKUI.TriggerKeypress(t, false)
end

function love.keypressed(key)
	LvLKUI.TriggerKeypress(key, true)
end

function love.mousepressed(x, y, button)
	LvLKUI.TriggerClick(x, y, button)
end

function love.mousemoved(x, y)
	LvLKUI.TriggerHover(x, y)
end


function love.draw()
	love.graphics.clear()
	love.graphics.setColor(1, 1, 1)

	LeftJam.StateRender()

	LvLKUI.DrawAll()
end