getgenv().Config = {
	Invite = "neogul",
	Version = "0.0",
}

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/soda100827/neogul/refs/heads/main/uilib.luau"))()

library:init() -- Initalizes Library Do Not Delete This

local Window = library.NewWindow({
	title = "Neogul's Rivals Scripts",
	size = UDim2.new(0, 525, 0, 650)
})

local tabs = {
    Main = Window:AddTab("Main"),
	Settings = library:CreateSettingsTab(Window),
}

-- 1 = Set Section Box To The Left
-- 2 = Set Section Box To The Right

local sections = {
	Combat = tabs.Main:AddSection("Combat", 1),
	Visuals = tabs.Main:AddSection("Visuals", 2),
}

local Combat = sections.Combat
local Visuals = sections.Visuals

Combat:AddToggle({
	enabled = true,
	text = "Toggle1",
	flag = "Toggle_1",
	tooltip = "Tooltip1",
	risky = true, -- turns text to red and sets label to risky
	callback = function(lol)
	    print("Toggle Is Now Set To : ".. tostring(lol))
	end
})

Combat:AddButton({
	enabled = true,
	text = "Button1",
	flag = "Button_1",
	tooltip = "Tooltip1",
	risky = false,
	confirm = false, -- shows confirm button
	callback = function(v)
	    print(v)
	end
})

Combat:AddSeparator({
	text = "Separator"
})

Combat:AddSlider({
	text = "Slider", 
	flag = 'Slider_1', 
	suffix = "", 
	value = 0.000,
	min = 0.1, 
	max = 0.999,
	increment = 0.001,
	tooltip = "Tooltip1",
	risky = false,
	callback = function(v) 
		print("Slider Value Is Now : ".. v)
	end
})

Combat:AddBind({
	text = "Keybind",
	flag = "Key_1",
	nomouse = true,
	noindicator = true,
	tooltip = "Tooltip1",
	mode = "toggle",
	bind = Enum.KeyCode.Q,
	risky = false,
	keycallback = function(v)
	    print("Keybind Changed!")
	end
})

Combat:AddList({
	enabled = true,
	text = "List",
	flag = "List_1",
	multi = false,
	tooltip = "Tooltip1",
    risky = false,
    dragging = false,
    focused = false,
	value = "1",
	values = {
		"1",
		"2",
		"3"
	},
	callback = function(v)
	    print("List Value Is Now : "..v)
	end
})

Combat:AddBox({
    enabled = true,
    focused = true,
    text = "TextBox1",
    input = "PlaceHolder1",
	flag = "Text_1",
	risky = false,
	callback = function(v)
	    print(v)
	end
})

Combat:AddText({
    enabled = true,
    text = "Text1",
    flag = "Text_1",
    risky = false,
})

Combat:AddColor({
    enabled = true,
    text = "ColorPicker1",
    flag = "Color_1",
    tooltip = "ToolTip1",
    color = Color3.new(255, 255, 255),
    trans = 0,
    open = false,
    callback = function()
        
    end
})

library:SendNotification("Notification", 5, Color3.new(255, 0, 0))

--Window:SetOpen(true) -- Either Close Or Open Window