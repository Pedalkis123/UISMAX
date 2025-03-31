local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

-- Define custom icons for the UI
local CustomIcons = {
    Combat = "rbxassetid://10723415903",
    Boss = "rbxassetid://10734990932", 
    Movement = "rbxassetid://11570895523",
    Utility = "rbxassetid://10709806833",
    ESP = "rbxassetid://10723376320",
    Scripts = "rbxassetid://10723345761",
    Info = "rbxassetid://10734992142"
}

local NexusUI = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Themes = {
		Default = {
			Main = Color3.fromRGB(25, 25, 25),
			Second = Color3.fromRGB(32, 32, 32),
			Stroke = Color3.fromRGB(60, 60, 60),
			Divider = Color3.fromRGB(60, 60, 60),
			Text = Color3.fromRGB(240, 240, 240),
			TextDark = Color3.fromRGB(150, 150, 150)
		},
		Neon = {
			Main = Color3.fromRGB(20, 20, 30),
			Second = Color3.fromRGB(30, 30, 45),
			Stroke = Color3.fromRGB(80, 100, 255),
			Divider = Color3.fromRGB(80, 100, 255),
			Text = Color3.fromRGB(220, 230, 255),
			TextDark = Color3.fromRGB(130, 170, 255)
		},
		Cyberpunk = {
			Main = Color3.fromRGB(15, 15, 20),
			Second = Color3.fromRGB(25, 25, 35),
			Stroke = Color3.fromRGB(255, 80, 120),
			Divider = Color3.fromRGB(0, 220, 220),
			Text = Color3.fromRGB(240, 240, 255),
			TextDark = Color3.fromRGB(0, 220, 220)
		},
		Quantum = {
			Main = Color3.fromRGB(10, 15, 20),
			Second = Color3.fromRGB(20, 25, 35),
			Stroke = Color3.fromRGB(0, 180, 120),
			Divider = Color3.fromRGB(0, 180, 120),
			Text = Color3.fromRGB(220, 255, 240),
			TextDark = Color3.fromRGB(40, 160, 120)
		},
		Synth = {
			Main = Color3.fromRGB(20, 15, 25),
			Second = Color3.fromRGB(35, 25, 40),
			Stroke = Color3.fromRGB(180, 80, 255),
			Divider = Color3.fromRGB(60, 30, 80),
			Text = Color3.fromRGB(235, 220, 255),
			TextDark = Color3.fromRGB(180, 120, 255)
		}
	},
	SelectedTheme = "Neon", -- Default to the futuristic Neon theme
	Folder = nil,
	SaveCfg = false,
	Version = "2.0.0"
}

--Feather Icons https://github.com/evoincorp/lucideblox/tree/master/src/modules/util - Created by 7kayoh
local Icons = {}

local Success, Response = pcall(function()
	Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")).icons
end)

if not Success then
	warn("\nOrion Library - Failed to load Feather Icons. Error code: " .. Response .. "\n")
end	

local function GetIcon(IconName)
	if Icons[IconName] ~= nil then
		return Icons[IconName]
	else
		return nil
	end
end   

local Orion = Instance.new("ScreenGui")
Orion.Name = "Orion"
if syn then
	syn.protect_gui(Orion)
	Orion.Parent = game.CoreGui
else
	Orion.Parent = gethui() or game.CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
else
	for _, Interface in ipairs(game.CoreGui:GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
end

function NexusUI:IsRunning()
	if gethui then
		return Orion.Parent == gethui()
	else
		return Orion.Parent == game:GetService("CoreGui")
	end

end

local function AddConnection(Signal, Function)
	if (not NexusUI:IsRunning()) then
		return
	end
	local SignalConnect = Signal:Connect(Function)
	table.insert(NexusUI.Connections, SignalConnect)
	return SignalConnect
end

task.spawn(function()
	while (NexusUI:IsRunning()) do
		wait()
	end

	for _, Connection in next, NexusUI.Connections do
		Connection:Disconnect()
	end
end)

local function AddDraggingFunctionality(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		DragPoint.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position

				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		DragPoint.InputChanged:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				DragInput = Input
			end
		end)
		UserInputService.InputChanged:Connect(function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)}):Play()
			end
		end)
	end)
end   

local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do
		Object[i] = v
	end
	for i, v in next, Children or {} do
		v.Parent = Object
	end
	return Object
end

local function CreateElement(ElementName, ElementFunction)
	NexusUI.Elements[ElementName] = function(...)
		return ElementFunction(...)
	end
end

local function MakeElement(ElementName, ...)
	local NewElement = NexusUI.Elements[ElementName](...)
	return NewElement
end

local function SetProps(Element, Props)
	table.foreach(Props, function(Property, Value)
		Element[Property] = Value
	end)
	return Element
end

local function SetChildren(Element, Children)
	table.foreach(Children, function(_, Child)
		Child.Parent = Element
	end)
	return Element
end

local function Round(Number, Factor)
	local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then
		return "BackgroundColor3"
	end 
	if Object:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	end 
	if Object:IsA("UIStroke") then
		return "Color"
	end 
	if Object:IsA("TextLabel") or Object:IsA("TextBox") then
		return "TextColor3"
	end   
	if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
		return "ImageColor3"
	end   
end

local function AddThemeObject(Object, Type)
	if not NexusUI.ThemeObjects[Type] then
		NexusUI.ThemeObjects[Type] = {}
	end    
	table.insert(NexusUI.ThemeObjects[Type], Object)
	Object[ReturnProperty(Object)] = NexusUI.Themes[NexusUI.SelectedTheme][Type]
	return Object
end    

local function SetTheme()
	for Name, Type in pairs(NexusUI.ThemeObjects) do
		for _, Object in pairs(Type) do
			Object[ReturnProperty(Object)] = NexusUI.Themes[NexusUI.SelectedTheme][Name]
		end    
	end    
end

local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
	local Data = HttpService:JSONDecode(Config)
	table.foreach(Data, function(a,b)
		if NexusUI.Flags[a] then
			spawn(function() 
				if NexusUI.Flags[a].Type == "Colorpicker" then
					NexusUI.Flags[a]:Set(UnpackColor(b))
				else
					NexusUI.Flags[a]:Set(b)
				end    
			end)
		else
			warn("Orion Library Config Loader - Could not find ", a ,b)
		end
	end)
end

local function SaveCfg(Name)
	local Data = {}
	for i,v in pairs(NexusUI.Flags) do
		if v.Save then
			if v.Type == "Colorpicker" then
				Data[i] = PackColor(v.Value)
			else
				Data[i] = v.Value
			end
		end	
	end
	writefile(NexusUI.Folder .. "/" .. Name .. ".txt", tostring(HttpService:JSONEncode(Data)))
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Up,Enum.KeyCode.Left,Enum.KeyCode.Down,Enum.KeyCode.Right,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape}

local function CheckKey(Table, Key)
	for _, v in next, Table do
		if v == Key then
			return true
		end
	end
end

CreateElement("Corner", function(Scale, Offset)
	local Corner = Create("UICorner", {
		CornerRadius = UDim.new(0, 0) -- Changed to 0 for sharp corners
	})
	return Corner
end)

CreateElement("Stroke", function(Color, Thickness)
	local Stroke = Create("UIStroke", {
		Color = Color or Color3.fromRGB(255, 255, 255),
		Thickness = Thickness or 1
	})
	return Stroke
end)

CreateElement("List", function(Scale, Offset)
	local List = Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(Scale or 0, Offset or 0)
	})
	return List
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
	local Padding = Create("UIPadding", {
		PaddingBottom = UDim.new(0, Bottom or 4),
		PaddingLeft = UDim.new(0, Left or 4),
		PaddingRight = UDim.new(0, Right or 4),
		PaddingTop = UDim.new(0, Top or 4)
	})
	return Padding
end)

CreateElement("TFrame", function()
	local TFrame = Create("Frame", {
		BackgroundTransparency = 1
	})
	return TFrame
end)

CreateElement("Frame", function(Color)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	})
	return Frame
end)

CreateElement("RoundFrame", function(Color, Scale, Offset, Glow)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(Scale or 0, Offset or 0) -- Sharp corners
		})
	})
	
	-- Add glow effect if specified
	if Glow then
		local GlowFrame = Create("ImageLabel", {
			BackgroundTransparency = 1,
			Image = "rbxassetid://7547168008", -- Bloom effect
			ImageColor3 = Color,
			ImageTransparency = 0.5,
			Position = UDim2.fromScale(-0.5, -0.5),
			Size = UDim2.fromScale(2, 2),
			ZIndex = -1,
			Parent = Frame
		})
	end
	
	return Frame
end)

CreateElement("Button", function()
	local Button = Create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	
	-- Add ripple effect
	local Ripple = Create("Frame", {
		Name = "Ripple",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.8,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0, 0),
		ZIndex = 2,
		Visible = false,
		Parent = Button
	})
	
	Create("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = Ripple
	})
	
	Button.MouseButton1Down:Connect(function(X, Y)
		local AbsolutePos = Button.AbsolutePosition
		local AbsoluteSize = Button.AbsoluteSize
		
		Ripple.Position = UDim2.fromOffset(X - AbsolutePos.X, Y - AbsolutePos.Y)
		Ripple.Visible = true
		
		-- Expand ripple effect
		TweenService:Create(Ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(AbsoluteSize.X * 1.5, AbsoluteSize.X * 1.5)
		}):Play()
		
		delay(0.5, function()
			Ripple.Visible = false
			Ripple.Size = UDim2.fromScale(0, 0)
			Ripple.BackgroundTransparency = 0.8
		end)
	end)
	
	return Button
end)

CreateElement("ScrollFrame", function(Color, Width)
	local ScrollFrame = Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = Color,
		BorderSizePixel = 0,
		ScrollBarThickness = Width,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})
	return ScrollFrame
end)

CreateElement("Image", function(ImageID)
	local ImageNew = Create("ImageLabel", {
		Image = ImageID,
		BackgroundTransparency = 1
	})

	if GetIcon(ImageID) ~= nil then
		ImageNew.Image = GetIcon(ImageID)
	end	

	return ImageNew
end)

CreateElement("ImageButton", function(ImageID)
	local Image = Create("ImageButton", {
		Image = ImageID,
		BackgroundTransparency = 1
	})
	return Image
end)

CreateElement("Label", function(Text, TextSize, Transparency)
	local Label = Create("TextLabel", {
		Text = Text or "",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = Transparency or 0,
		TextSize = TextSize or 15,
		Font = Enum.Font.Gotham,
		RichText = true,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	return Label
end)

CreateElement("GradientFrame", function(ColorFrom, ColorTo, Rotation)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	})
	
	local Gradient = Create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, ColorFrom or Color3.fromRGB(50, 50, 80)),
			ColorSequenceKeypoint.new(1, ColorTo or Color3.fromRGB(20, 20, 40))
		}),
		Rotation = Rotation or 45,
		Parent = Frame
	})
	
	return Frame
end)

CreateElement("SlicedFrame", function(Color, Image, SliceScale)
	local Frame = Create("ImageLabel", {
		BackgroundTransparency = 1,
		Image = Image or "rbxassetid://7957105852", -- UI asset
		ImageColor3 = Color or Color3.fromRGB(30, 30, 40),
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(100, 100, 100, 100),
		SliceScale = SliceScale or 0.01 -- Minimal slice for sharp appearance
	})
	
	return Frame
end)

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
	SetProps(MakeElement("List"), {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 5)
	})
}), {
	Position = UDim2.new(1, -25, 1, -25),
	Size = UDim2.new(0, 300, 1, -25),
	AnchorPoint = Vector2.new(1, 1),
	Parent = Orion
})

function NexusUI:MakeNotification(NotificationConfig)
	spawn(function()
		NotificationConfig.Name = NotificationConfig.Name or "Notification"
		NotificationConfig.Content = NotificationConfig.Content or "Test notification"
		NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://7733658504"
		NotificationConfig.Time = NotificationConfig.Time or 5
		NotificationConfig.Type = NotificationConfig.Type or "Info" -- Info, Success, Warning, Error
		
		-- Select notification color based on type
		local TypeColors = {
			Info = Color3.fromRGB(80, 100, 255),
			Success = Color3.fromRGB(0, 220, 120),
			Warning = Color3.fromRGB(255, 150, 0),
			Error = Color3.fromRGB(255, 60, 80)
		}
		
		local TypeColor = TypeColors[NotificationConfig.Type] or TypeColors.Info
		
		local NotificationParent = SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = NotificationHolder
		})
		
		local NotificationFrame = SetChildren(SetProps(MakeElement("SlicedFrame", TypeColor), {
			Parent = NotificationParent, 
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, -55, 0, 0),
			BackgroundTransparency = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			ZIndex = 100
		}), {
			-- Create a sleek glow effect
			SetProps(Create("ImageLabel", {
				BackgroundTransparency = 1,
				Image = "rbxassetid://7547168008",
				ImageColor3 = TypeColor,
				ImageTransparency = 0.6,
				Position = UDim2.fromScale(-0.5, -0.5),
				Size = UDim2.fromScale(2, 2),
				ZIndex = 99
			})),
			SetProps(MakeElement("Stroke", TypeColor, 1.2), {
				Name = "Stroke",
				Transparency = 0.4
			}),
			MakeElement("Padding", 12, 12, 12, 12),
			SetProps(MakeElement("Image", NotificationConfig.Image), {
				Size = UDim2.new(0, 24, 0, 24),
				ImageColor3 = TypeColor,
				Name = "Icon",
				ZIndex = 101
			}),
			SetProps(MakeElement("Label", NotificationConfig.Name, 16), {
				Size = UDim2.new(1, -36, 0, 20),
				Position = UDim2.new(0, 36, 0, 0),
				Font = Enum.Font.GothamBold,
				Name = "Title",
				ZIndex = 101
			}),
			SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 25),
				Font = Enum.Font.GothamSemibold,
				Name = "Content",
				AutomaticSize = Enum.AutomaticSize.Y,
				TextColor3 = Color3.fromRGB(220, 220, 230),
				TextWrapped = true,
				ZIndex = 101
			}),
			-- Add progress bar
			SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(50, 50, 60), 0, 4), {
				Size = UDim2.new(1, 0, 0, 4),
				Position = UDim2.new(0, 0, 1, -6),
				Name = "ProgressBar",
				ZIndex = 101
			}), {
				SetProps(MakeElement("RoundFrame", TypeColor, 0, 4), {
					Size = UDim2.new(1, 0, 1, 0),
					Name = "Fill",
					ZIndex = 102
				})
			})
		})
		
		-- Smooth slide-in animation
		TweenService:Create(NotificationFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
		
		-- Progress bar animation
		TweenService:Create(NotificationFrame.ProgressBar.Fill, TweenInfo.new(NotificationConfig.Time, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()
		
		-- After time passed, fade out
		wait(NotificationConfig.Time - 1)
		TweenService:Create(NotificationFrame.Icon, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.8}):Play()
		TweenService:Create(NotificationFrame.Stroke, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
		TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0.7}):Play()
		TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0.7}):Play()
		
		-- Slide out animation and cleanup
		wait(0.5)
		TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(1, 0, 0, 0)}):Play()
		wait(1)
		NotificationParent:Destroy()
	end)
end    

function NexusUI:Init()
	if NexusUI.SaveCfg then	
		pcall(function()
			if isfile(NexusUI.Folder .. "/" .. game.GameId .. ".txt") then
				LoadCfg(readfile(NexusUI.Folder .. "/" .. game.GameId .. ".txt"))
				NexusUI:MakeNotification({
					Name = "Configuration",
					Content = "Auto-loaded configuration for the game " .. game.GameId .. ".",
					Time = 5
				})
			end
		end)		
	end	
end	

function NexusUI:MakeWindow(WindowConfig)
	local FirstTab = true
	local Minimized = false
	local Loaded = false
	local UIHidden = false

	WindowConfig = WindowConfig or {}
	WindowConfig.Name = WindowConfig.Name or "Orion Library"
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
	WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
	WindowConfig.HidePremium = WindowConfig.HidePremium or false
	if WindowConfig.IntroEnabled == nil then
		WindowConfig.IntroEnabled = true
	end
	WindowConfig.IntroText = WindowConfig.IntroText or "Orion Library"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	NexusUI.Folder = WindowConfig.ConfigFolder
	NexusUI.SaveCfg = WindowConfig.SaveConfig

	if WindowConfig.SaveConfig then
		if not isfolder(WindowConfig.ConfigFolder) then
			makefolder(WindowConfig.ConfigFolder)
		end	
	end

	-- Update the layout for the tab holder
	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
		Size = UDim2.new(0, 100, 1, -50), -- Narrower width for vertical tab layout
		Position = UDim2.new(0, 0, 0, 50)
	}), {
		MakeElement("List"),
		MakeElement("Padding", 8, 0, 0, 8)
	}), "Divider")

	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
	end)

	local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18)
		}), "Text")
	})

	local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18),
			Name = "Ico"
		}), "Text")
	})

	local DragPoint = SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 50)
	})

	local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("Frame", Color3.fromRGB(255, 255, 255)), {
		Size = UDim2.new(1, 0, 1, -50),
		Position = UDim2.new(0, 0, 0, 50)
	}), {
		TabHolder,
		-- Add a vertical divider between tab holder and content
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(0, 100, 0, 0),
			Name = "VerticalDivider",
		}), "Stroke")
	}), "Main")

	local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {
		Size = UDim2.new(1, -30, 0, 25),
		Position = UDim2.new(0, 25, 0, 15),
		Font = Enum.Font.GothamBold,
		Name = "WindowTitle"
	}), "Text")

	local WindowTopBar = SetChildren(SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 50),
		Name = "TopBar"
	}), {
		WindowName,
		SetChildren(SetProps(MakeElement("TFrame"), {
			Position = UDim2.new(1, -62, 0, 14),
			Size = UDim2.new(0, 60, 0, 25)
		}), {
			UIListLayout = SetProps(Create("UIListLayout"), {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			MinimizeBtn,
			CloseBtn
		})
	})

	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("Frame", Color3.fromRGB(255, 255, 255)), {
		Parent = Orion,
		Position = UDim2.new(0, 100, 0, 100),
		Size = UDim2.new(0, 450, 0, 600), -- Vertical rectangular window (taller and narrower)
		ClipsDescendants = true
	}), {
		WindowTopBar,
		WindowStuff,
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 0, 50),
			Name = "Line",
			Visible = true
		}), "Stroke")
	}), "Main")

	-- Get a reference to the UICorner and set it to sharp corners (if it exists)
	local MainCorner = MainWindow:FindFirstChild("UICorner")
	if MainCorner then
		MainCorner.CornerRadius = UDim.new(0, 0)
	else
		-- Add a UICorner with zero radius if it doesn't exist
		local Corner = Create("UICorner", {
			CornerRadius = UDim.new(0, 0)
		})
		Corner.Parent = MainWindow
	end

	if WindowConfig.ShowIcon then
		WindowName.Position = UDim2.new(0, 50, 0, -24)
		local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0, 25, 0, 15)
		})
		WindowIcon.Parent = MainWindow.TopBar
	end	

	AddDraggingFunctionality(DragPoint, MainWindow)

	AddConnection(CloseBtn.MouseButton1Up, function()
		MainWindow.Visible = false
		UIHidden = true
		NexusUI:MakeNotification({
			Name = "Interface Hidden",
			Content = "Tap RightShift to reopen the interface",
			Time = 5
		})
		WindowConfig.CloseCallback()
	end)

	AddConnection(UserInputService.InputBegan, function(Input)
		if Input.KeyCode == Enum.KeyCode.RightShift and UIHidden then
			MainWindow.Visible = true
		end
	end)

	AddConnection(MinimizeBtn.MouseButton1Up, function()
		if Minimized then
			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 450, 0, 600)}):Play() -- Vertical size when restored
			MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
			wait(.02)
			MainWindow.ClipsDescendants = false
			WindowStuff.Visible = true
			MainWindow.Line.Visible = true
		else
			MainWindow.ClipsDescendants = true
			MainWindow.Line.Visible = false
			MinimizeBtn.Ico.Image = "rbxassetid://7072720870"

			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WindowName.TextBounds.X + 140, 0, 50)}):Play()
			wait(0.1)
			WindowStuff.Visible = false	
		end
		Minimized = not Minimized    
	end)

	local function LoadSequence()
		MainWindow.Visible = false
		local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
			Parent = Orion,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.4, 0),
			Size = UDim2.new(0, 28, 0, 28),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 1
		})

		local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 18), {
			Parent = Orion,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			TextTransparency = 1,
			Font = Enum.Font.GothamBold
		})

		TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
		wait(0.6)
		TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
		wait(0.3)
		LoadSequenceLogo:Destroy()
	end

	if WindowConfig.IntroEnabled then
		LoadSequence()
	end
	
	local TabFunction = {}
	
	function TabFunction:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Name = TabConfig.Name or "Unnamed Tab"
		TabConfig.Icon = TabConfig.Icon or ""
		TabConfig.PremiumOnly = TabConfig.PremiumOnly or false
		
		-- Use custom icons if available
		if CustomIcons[TabConfig.Name] then
			TabConfig.Icon = CustomIcons[TabConfig.Name]
		end

		local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
			Size = UDim2.new(1, 0, 0, 40), -- Taller tabs for vertical layout
			Parent = TabHolder
		}), {
			AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 20, 0, 20),
				Position = UDim2.new(0, 10, 0.5, 0),
				ImageTransparency = 0.4,
				Name = "Ico"
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {
				Size = UDim2.new(1, -35, 1, 0),
				Position = UDim2.new(0, 35, 0, 0),
				Font = Enum.Font.GothamSemibold,
				TextTransparency = 0.4,
				Name = "Title"
			}), "Text")
		})

		if GetIcon(TabConfig.Icon) ~= nil then
			TabFrame.Ico.Image = GetIcon(TabConfig.Icon)
		end	

		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 5), {
			Size = UDim2.new(0, 350, 1, -50), -- Width adjusted for tab container
			Position = UDim2.new(0, 100, 0, 50), -- Position to the right of tab holder
			Parent = MainWindow,
			Visible = false,
			Name = "ItemContainer"
		}), {
			MakeElement("List", 0, 6),
			MakeElement("Padding", 15, 10, 10, 15)
		}), "Divider")

		AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
		end)

		if FirstTab then
			FirstTab = false
			TabFrame.Ico.ImageTransparency = 0
			TabFrame.Title.TextTransparency = 0
			TabFrame.Title.Font = Enum.Font.GothamBlack
			Container.Visible = true
		end    

		AddConnection(TabFrame.MouseButton1Click, function()
			for _, Tab in next, TabHolder:GetChildren() do
				if Tab:IsA("TextButton") then
					Tab.Title.Font = Enum.Font.GothamSemibold
					Tab.Title.TextTransparency = 0.4
					Tab.Ico.ImageTransparency = 0.4
				end
			end

			for _, ItemContainer in next, MainWindow:GetChildren() do
				if ItemContainer.Name == "ItemContainer" then
					ItemContainer.Visible = false
				end
			end

			TabFrame.Title.Font = Enum.Font.GothamBlack
			TabFrame.Ico.ImageTransparency = 0
			TabFrame.Title.TextTransparency = 0
			Container.Visible = true
		end)

		local function GetElements(ItemParent)
			local Elements = {}
			
			function Elements:AddSection(SectionConfig)
				SectionConfig.Name = SectionConfig.Name or "Section"
				
				local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
					Size = UDim2.new(1, 0, 0, 26),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 14), {
						Size = UDim2.new(1, -12, 0, 16),
						Position = UDim2.new(0, 0, 0, 3),
						Font = Enum.Font.GothamSemibold
					}), "TextDark"),
					SetChildren(SetProps(MakeElement("TFrame"), {
						AnchorPoint = Vector2.new(0, 0),
						Size = UDim2.new(1, 0, 1, -24),
						Position = UDim2.new(0, 0, 0, 23),
						Name = "Holder"
					}), {
						MakeElement("List", 0, 6)
					}),
				})
				
				AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
					SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
					SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
				end)
				
				local SectionFunction = {}
				for i, v in next, GetElements(SectionFrame.Holder) do
					SectionFunction[i] = v 
				end
				return SectionFunction
			end
		end

		local ElementFunction = {}

		function ElementFunction:AddSection(SectionConfig)
			SectionConfig.Name = SectionConfig.Name or "Section"

			local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 0, 26),
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 14), {
					Size = UDim2.new(1, -12, 0, 16),
					Position = UDim2.new(0, 0, 0, 3),
					Font = Enum.Font.GothamSemibold
				}), "TextDark"),
				SetChildren(SetProps(MakeElement("TFrame"), {
					AnchorPoint = Vector2.new(0, 0),
					Size = UDim2.new(1, 0, 1, -24),
					Position = UDim2.new(0, 0, 0, 23),
					Name = "Holder"
				}), {
					MakeElement("List", 0, 6)
				}),
			})

			AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
				SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
			end)

			local SectionFunction = {}
			for i, v in next, GetElements(SectionFrame.Holder) do
				SectionFunction[i] = v 
			end
			return SectionFunction
		end	

		for i, v in next, GetElements(Container) do
			ElementFunction[i] = v 
		end

		if TabConfig.PremiumOnly then
			for i, v in next, ElementFunction do
				ElementFunction[i] = function() end
			end    
			Container:FindFirstChild("UIListLayout"):Destroy()
			Container:FindFirstChild("UIPadding"):Destroy()
			SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 1, 0),
				Parent = ItemParent
			}), {
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://3610239960"), {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 15, 0, 15),
					ImageTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Unauthorised Access", 14), {
					Size = UDim2.new(1, -38, 0, 14),
					Position = UDim2.new(0, 38, 0, 18),
					TextTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4483345875"), {
					Size = UDim2.new(0, 56, 0, 56),
					Position = UDim2.new(0, 84, 0, 110),
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Premium Features", 14), {
					Size = UDim2.new(1, -150, 0, 14),
					Position = UDim2.new(0, 150, 0, 112),
					Font = Enum.Font.GothamBold
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "This part of the script is locked to Sirius Premium users. Purchase Premium in the Discord server (discord.gg/sirius)", 12), {
					Size = UDim2.new(1, -200, 0, 14),
					Position = UDim2.new(0, 150, 0, 138),
					TextWrapped = true,
					TextTransparency = 0.4
				}), "Text")
			})
		end
		return ElementFunction   
	end  
	
	NexusUI:MakeNotification({
		Name = "UI Library Upgrade",
		Content = "New UI Library Available at sirius.menu/discord and sirius.menu/rayfield",
		Time = 5
	})
	

	
	return TabFunction
end   

function NexusUI:Destroy()
	Orion:Destroy()
end

return NexusUI
