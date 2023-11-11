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
	buttonNext:SetLabel("Next Level")
	buttonNext:SetColourOverride({0.25, 0.5, 0.25}, {0.1, 0.25, 0.1}, {0.5, 1, 0.5})
	buttonNext:SetOnClick(function(elm, mx, my)
		LeftJam.LoadMap(map)
		LeftJam.SetState(STATE_GAME)
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
		print("you pressed This!")
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



