LeftJam = LeftJam or {}
LeftJam.States = LeftJam.States or {}



LeftJam.States[STATE_MENU] = {}

local _firstMap = "untitled" -- TODO: change on release
local srcMenu = love.audio.newSource("audio/strategy-games-classic-arcade-game-116828.mp3", "stream")
srcMenu:setLooping(true)
srcMenu:setVolume(LeftJam.GlobalAudioLevel)

local function setupButtons()
	local w, h = love.graphics.getDimensions()

	local panel_so_we_can_wipe_all = LvLKUI.NewElement("panel_wipe_all_menu", "panel")
	panel_so_we_can_wipe_all:SetLabel("Test")
	panel_so_we_can_wipe_all:SetPriority(20)
	panel_so_we_can_wipe_all:SetPos({0, 0})
	panel_so_we_can_wipe_all:SetSize({w, h})
	panel_so_we_can_wipe_all:SetOnPaint(function() end)


	local button_start_gaem = LvLKUI.NewElement("button_start", "button")
	button_start_gaem:SetPriority(40)
	button_start_gaem:SetPos({(w * .5) - ((256 + 196) * .5), h * .35})
	button_start_gaem:SetSize({256 + 196, 64})
	button_start_gaem:SetLabel("Start Game")
	button_start_gaem:SetOnClick(function(elm, mx, my)
		LeftJam.LoadMap(_firstMap)
		LeftJam.SetState(STATE_GAME)
		panel_so_we_can_wipe_all:Remove()
		srcMenu:stop()
	end)
	LvLKUI.PushElement(button_start_gaem, panel_so_we_can_wipe_all)


	local button_credits = LvLKUI.NewElement("button_credits", "button")
	button_credits:SetPriority(40)
	button_credits:SetPos({(w * .5) - ((256 + 196) * .5), h * .5})
	button_credits:SetSize({256 + 196, 64})
	button_credits:SetLabel("Credits")
	button_credits:SetOnClick(function(elm, mx, my)
		LeftJam.SetState(STATE_CREDITS)
		panel_so_we_can_wipe_all:Remove()
		srcMenu:stop()
	end)
	LvLKUI.PushElement(button_credits, panel_so_we_can_wipe_all)

	LvLKUI.PushElement(panel_so_we_can_wipe_all)
end



LeftJam.States[STATE_MENU].init = function()
	setupButtons()
	srcMenu:play()
end

LeftJam.States[STATE_MENU].think = function(dt)
end

local logo = love.graphics.newImage("assets/preprocessor_logo.png")
logo:setFilter("nearest", "nearest")

LeftJam.States[STATE_MENU].render = function()
	love.graphics.clear(.2, .3, .4)
	love.graphics.setColor(1, 1, 1)

	local w, h = love.graphics.getDimensions()
	-- make gradient
	LeftJam.RenderOKLabGradient(0, 0, w, h, {16, 16, 16, 255}, {64, 128, 96}, 128)

	local lw, lh = logo:getDimensions()
	love.graphics.setColor(1, 1, 1, 1)
	local sclMul = 12
	love.graphics.draw(logo, w * .5 - lw * .5 * sclMul, h * .1 - lh * .5 * sclMul, 0, sclMul, sclMul)

end

LeftJam.States[STATE_MENU].exit = function()
end