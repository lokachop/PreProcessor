LeftJam = LeftJam or {}
STATE_INVALID = -128
STATE_MENU = 0
STATE_GAME = 1
STATE_NEXT_MAP = 2
STATE_CREDITS = 3
STATE_DIE = 4

LeftJam.States = {}
LeftJam.State = STATE_INVALID

function LeftJam.SetState(new)
	if LeftJam.States[LeftJam.State] and LeftJam.States[LeftJam.State].exit then
		LeftJam.States[LeftJam.State].exit()
	end

	LeftJam.State = new

	if LeftJam.States[new] and LeftJam.States[new].init then
		LeftJam.States[new].init()
	end
end


function LeftJam.StateThink(dt)
	if LeftJam.States[LeftJam.State].think then
		LeftJam.States[LeftJam.State].think(dt)
	end
end

function LeftJam.StateRender()
	if LeftJam.States[LeftJam.State].render then
		LeftJam.States[LeftJam.State].render()
	end
end