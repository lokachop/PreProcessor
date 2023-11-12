LeftJam = LeftJam or {}
LvLKUI = LvLKUI or {}


function LeftJam.SetupNextMapUI(map)
	local w, h = love.graphics.getDimensions()
	local frameNextMap = LvLKUI.NewElement("frame_map", "frame")
	frameNextMap:SetLabel("Next Map")
	frameNextMap:SetPriority(20)
	frameNextMap:SetPos({(w * .5) - (256 * .5), (h * .5) - (96 * .5)})
	frameNextMap:SetSize({256, 96 + 48})
	frameNextMap:SetCloseDisabled(true)

	local buttonNext = LvLKUI.NewElement("button_next", "button")
	buttonNext:SetPriority(40)
	buttonNext:SetPos({128 - (128 * .5), 24 + 8 + 16})
	buttonNext:SetSize({128, 32})
	buttonNext:SetLabel(map == "credits" and "Credits" or "Next Level")
	buttonNext:SetColourOverride({0.25, 0.5, 0.25}, {0.1, 0.25, 0.1}, {0.5, 1, 0.5})
	buttonNext:SetOnClick(function(elm, mx, my)
		if map == "credits" then
			LeftJam.SetState(STATE_CREDITS)
		else
			LeftJam.LoadMap(map)
			LeftJam.SetState(STATE_GAME)
		end
		frameNextMap:Remove()
	end)
	LvLKUI.PushElement(buttonNext, frameNextMap)

	local buttonMenu = LvLKUI.NewElement("button_menu", "button")
	buttonMenu:SetPriority(40)
	buttonMenu:SetPos({128 - (128 * .5), 24 + 8 + 64})
	buttonMenu:SetSize({128, 32})
	buttonMenu:SetLabel("Main Menu")
	buttonMenu:SetColourOverride({0.5, 0.25, 0.25}, {0.25, 0.1, 0.1}, {1, 0.5, 0.5})
	buttonMenu:SetOnClick(function(elm, mx, my)
		frameNextMap:Remove()
		LeftJam.SetState(STATE_MENU)
	end)
	LvLKUI.PushElement(buttonMenu, frameNextMap)

	local labelNext = LvLKUI.NewElement("label_next", "label")
	labelNext:SetPriority(30)
	labelNext:SetPos({128, 24 + 8})
	labelNext:SetSize({128, 32})
	labelNext:SetLabel("Good Job!")
	labelNext:SetAlignMode({1, 1})
	LvLKUI.PushElement(labelNext, frameNextMap)


	LvLKUI.PushElement(frameNextMap)
end



function LeftJam.SetupDieUI()
	local w, h = love.graphics.getDimensions()
	local frameDie = LvLKUI.NewElement("frame_die", "frame")
	frameDie:SetLabel("You Died!")
	frameDie:SetPriority(20)
	frameDie:SetPos({(w * .5) - (256 * .5), (h * .5) - (96 * .5)})
	frameDie:SetSize({256, 96 + 48})
	frameDie:SetCloseDisabled(true)

	local buttonNext = LvLKUI.NewElement("button_next", "button")
	buttonNext:SetPriority(40)
	buttonNext:SetPos({128 - (128 * .5), 24 + 8 + 16})
	buttonNext:SetSize({128, 32})
	buttonNext:SetLabel("Retry")
	buttonNext:SetColourOverride({0.25, 0.5, 0.25}, {0.1, 0.25, 0.1}, {0.5, 1, 0.5})
	buttonNext:SetOnClick(function(elm, mx, my)
		LeftJam.LoadMap(LeftJam.CurrMapName)
		LeftJam.SetState(STATE_GAME)
		frameDie:Remove()
	end)
	LvLKUI.PushElement(buttonNext, frameDie)

	local buttonMenu = LvLKUI.NewElement("button_menu", "button")
	buttonMenu:SetPriority(40)
	buttonMenu:SetPos({128 - (128 * .5), 24 + 8 + 64})
	buttonMenu:SetSize({128, 32})
	buttonMenu:SetLabel("Main Menu")
	buttonMenu:SetColourOverride({0.5, 0.25, 0.25}, {0.25, 0.1, 0.1}, {1, 0.5, 0.5})
	buttonMenu:SetOnClick(function(elm, mx, my)
		frameDie:Remove()
		LeftJam.SetState(STATE_MENU)
	end)
	LvLKUI.PushElement(buttonMenu, frameDie)

	local labelNext = LvLKUI.NewElement("label_next", "label")
	labelNext:SetPriority(30)
	labelNext:SetPos({128, 24 + 8})
	labelNext:SetSize({128, 32})
	labelNext:SetLabel("You Died!")
	labelNext:SetAlignMode({1, 1})
	LvLKUI.PushElement(labelNext, frameDie)


	LvLKUI.PushElement(frameDie)
end


