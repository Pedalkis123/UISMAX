local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

-- Initialize global state
_G.OverHeavenState = _G.OverHeavenState or {
    Connections = {},
    ActiveToggles = {},
    LastWindowPosition = nil,
    Windows = {},
    NotificationHolder = nil,
    Initialized = false
}

-- Create notification holder if it doesn't exist
if not _G.OverHeavenState.NotificationHolder then
    local success, holder = pcall(function()
        local holder = Instance.new("ScreenGui")
        holder.Name = "NotificationHolder"
        
        if syn and syn.protect_gui then
            syn.protect_gui(holder)
        end
        
        holder.Parent = game:GetService("CoreGui")
        return holder
    end)
    
    if success then
        _G.OverHeavenState.NotificationHolder = holder
    else
        warn("Failed to create notification holder:", holder)
    end
end

local OverHeavenLib = {
    Elements = {},
    ThemeObjects = {},
    Connections = _G.OverHeavenState.Connections,
    Flags = {},
    Themes = {
        Default = {
            Main = Color3.fromRGB(25, 25, 25),
            Second = Color3.fromRGB(32, 32, 32),
            Stroke = Color3.fromRGB(60, 60, 60),
            Divider = Color3.fromRGB(60, 60, 60),
            Text = Color3.fromRGB(240, 240, 240),
            TextDark = Color3.fromRGB(150, 150, 150)
        }
    },
    SelectedTheme = "Default",
    Folder = "OverHeavenSettings",
    SaveCfg = false
}

-- Safe instance creation
local function CreateInstance(className, properties)
    local success, instance = pcall(function()
        local obj = Instance.new(className)
        for prop, value in pairs(properties or {}) do
            obj[prop] = value
        end
        return obj
    end)
    
    if success then
        return instance
    else
        warn("Failed to create instance:", className, instance)
        return nil
    end
end

-- Create main GUI
local OverHeaven
local success, result = pcall(function()
    -- Clean up existing GUIs first
    for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if gui.Name == "OverHeaven" then
            gui:Destroy()
        end
    end
    
    local gui = CreateInstance("ScreenGui", {
        Name = "OverHeaven",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    end
    
    gui.Parent = game:GetService("CoreGui")
    return gui
end)

if success then
    OverHeaven = result
else
    warn("Failed to create OverHeaven GUI:", result)
    return
end

function OverHeavenLib:IsRunning()
    return OverHeaven and OverHeaven.Parent ~= nil
end

-- Improved connection management
local function AddConnection(signal, callback)
    if not signal or type(callback) ~= "function" then return end
    
    local success, connection = pcall(function()
        return signal:Connect(callback)
    end)
    
    if success and connection then
        table.insert(OverHeavenLib.Connections, connection)
        return connection
    else
        warn("Failed to create connection")
        return nil
    end
end

-- Window creation
function OverHeavenLib:CreateWindow(config)
    config = config or {}
    config.Name = config.Name or "OverHeaven"
    
    local window = CreateInstance("Frame", {
        Name = "Window",
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        BackgroundColor3 = self.Themes[self.SelectedTheme].Main,
        BorderSizePixel = 0,
        Parent = OverHeaven
    })
    
    if not window then
        warn("Failed to create window frame")
        return nil
    end
    
    -- Add corner
    local corner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = window
    })
    
    -- Add title
    local title = CreateInstance("TextLabel", {
        Name = "Title",
        Text = config.Name,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        TextColor3 = self.Themes[self.SelectedTheme].Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = window
    })
    
    -- Add container
    local container = CreateInstance("ScrollingFrame", {
        Name = "Container",
        Size = UDim2.new(1, -20, 1, -45),
        Position = UDim2.new(0, 10, 0, 40),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        Parent = window
    })
    
    -- Add list layout
    local listLayout = CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = container
    })
    
    -- Make window draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    AddConnection(title.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
        end
    end)
    
    AddConnection(title.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    AddConnection(UserInputService.InputChanged, function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    return {
        Window = window,
        Container = container
    }
end

-- Auto cleanup
task.spawn(function()
    while OverHeavenLib:IsRunning() do
        task.wait(1)
    end
    
    for _, connection in pairs(OverHeavenLib.Connections) do
        if typeof(connection) == "RBXScriptConnection" and connection.Connected then
            connection:Disconnect()
        end
    end
    
    table.clear(OverHeavenLib.Connections)
end)

local function AddDraggingFunctionality(DragPoint, Main)
    if not DragPoint or not Main then return end
    
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        if not dragging then return end
        
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                 startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                                 
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(Main, tweenInfo, {Position = position}):Play()
    end
    
    AddConnection(DragPoint.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            
            AddConnection(input.Changed, function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    AddConnection(DragPoint.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    AddConnection(UserInputService.InputChanged, function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Safe element creation
local function Create(Name, Properties, Children)
    local success, Object = pcall(function()
        local obj = Instance.new(Name)
        
        -- Apply properties
        for prop, value in next, Properties or {} do
            pcall(function() obj[prop] = value end)
        end
        
        -- Add children
        for _, child in next, Children or {} do
            if child then
                pcall(function() child.Parent = obj end)
            end
        end
        
        return obj
    end)
    
    if success then
        return Object
    else
        warn("Failed to create object:", Name, Object)
        return nil
    end
end

-- Improved element system
local function CreateElement(ElementName, ElementFunction)
    if type(ElementName) ~= "string" or type(ElementFunction) ~= "function" then
        warn("Invalid element creation parameters")
        return
    end
    
    OverHeavenLib.Elements[ElementName] = function(...)
        local success, result = pcall(ElementFunction, ...)
        if success and result then
            return result
        else
            warn("Failed to create element:", ElementName, result)
            return nil
        end
    end
end

local function MakeElement(ElementName, ...)
    if not OverHeavenLib.Elements[ElementName] then
        warn("Element does not exist:", ElementName)
        return nil
    end
    
    return OverHeavenLib.Elements[ElementName](...)
end

local function SetProps(Element, Props)
    if not Element then return Element end
    
    for Property, Value in next, Props do
        pcall(function()
            Element[Property] = Value
        end)
    end
    
    return Element
end

local function SetChildren(Element, Children)
    if not Element then return Element end
    
    for _, Child in next, Children do
        pcall(function()
            Child.Parent = Element
        end)
    end
    
    return Element
end

local function Round(Number, Factor)
	local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local function ReturnProperty(Object)
    if not Object then return nil end
    
    if Object:IsA("Frame") or Object:IsA("TextButton") then
        return "BackgroundColor3"
    elseif Object:IsA("ScrollingFrame") then
        return "ScrollBarImageColor3"
    elseif Object:IsA("UIStroke") then
        return "Color"
    elseif Object:IsA("TextLabel") or Object:IsA("TextBox") then
        return "TextColor3"
    elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
        return "ImageColor3"
    end
    return nil
end

local function AddThemeObject(Object, Type)
    if not Object or not Type then return Object end
    
    if not OverHeavenLib.ThemeObjects[Type] then
        OverHeavenLib.ThemeObjects[Type] = {}
    end
    
    local property = ReturnProperty(Object)
    if property then
        table.insert(OverHeavenLib.ThemeObjects[Type], Object)
        pcall(function()
            Object[property] = OverHeavenLib.Themes[OverHeavenLib.SelectedTheme][Type]
        end)
    end
    
    return Object
end

local function SetTheme()
    for Name, Type in pairs(OverHeavenLib.ThemeObjects) do
        for _, Object in pairs(Type) do
            local property = ReturnProperty(Object)
            if property then
                pcall(function()
                    Object[property] = OverHeavenLib.Themes[OverHeavenLib.SelectedTheme][Name]
                end)
            end
        end
    end
end

local function PackColor(Color)
    if not Color then return {R = 0, G = 0, B = 0} end
    return {
        R = math.clamp(Color.R * 255, 0, 255),
        G = math.clamp(Color.G * 255, 0, 255),
        B = math.clamp(Color.B * 255, 0, 255)
    }
end

local function UnpackColor(Color)
    if not Color then return Color3.new() end
    return Color3.fromRGB(
        math.clamp(Color.R, 0, 255),
        math.clamp(Color.G, 0, 255),
        math.clamp(Color.B, 0, 255)
    )
end

local function LoadCfg(Config)
    if not Config then return end
    
    local success, Data = pcall(function()
        return HttpService:JSONDecode(Config)
    end)
    
    if not success then
        warn("Failed to decode config:", Data)
        return
    end
    
    for flagName, value in pairs(Data) do
        if OverHeavenLib.Flags[flagName] then
            task.spawn(function()
                pcall(function()
                    if OverHeavenLib.Flags[flagName].Type == "Colorpicker" then
                        OverHeavenLib.Flags[flagName]:Set(UnpackColor(value))
                    else
                        OverHeavenLib.Flags[flagName]:Set(value)
                    end
                end)
            end)
        end
    end
end

local function SaveCfg(Name)
    if not Name or not OverHeavenLib.Folder then return end
    
    local Data = {}
    for flagName, flag in pairs(OverHeavenLib.Flags) do
        if flag.Save then
            if flag.Type == "Colorpicker" then
                Data[flagName] = PackColor(flag.Value)
            else
                Data[flagName] = flag.Value
            end
        end
    end
    
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(Data)
    end)
    
    if success then
        pcall(function()
            writefile(OverHeavenLib.Folder .. "/" .. Name .. ".txt", encoded)
        end)
    else
        warn("Failed to save config:", encoded)
    end
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
		CornerRadius = UDim.new(0, 0) -- Set all corners to 0
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

CreateElement("RoundFrame", function(Color, Scale, Offset)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(0, 0) -- Square corners
		})
	})
	return Frame
end)

CreateElement("Button", function()
	local Button = Create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
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
	Parent = OverHeaven
})

function OverHeavenLib:MakeNotification(NotificationConfig)
    NotificationConfig = NotificationConfig or {}
    NotificationConfig.Name = NotificationConfig.Name or "Notification"
    NotificationConfig.Content = NotificationConfig.Content or "Content"
    NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://4384403532"
    NotificationConfig.Time = NotificationConfig.Time or 5
    
    task.spawn(function()
        pcall(function()
            local NotificationParent = SetProps(MakeElement("TFrame"), {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = NotificationHolder
            })
            
            if not NotificationParent then return end
            
            local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
                Parent = NotificationParent, 
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(1, -55, 0, 0),
                BackgroundTransparency = 0,
                AutomaticSize = Enum.AutomaticSize.Y
            }), {
                MakeElement("Stroke", Color3.fromRGB(93, 93, 93), 1.2),
                MakeElement("Padding", 12, 12, 12, 12),
                SetProps(MakeElement("Image", NotificationConfig.Image), {
                    Size = UDim2.new(0, 20, 0, 20),
                    ImageColor3 = Color3.fromRGB(240, 240, 240),
                    Name = "Icon"
                }),
                SetProps(MakeElement("Label", NotificationConfig.Name, 15), {
                    Size = UDim2.new(1, -30, 0, 20),
                    Position = UDim2.new(0, 30, 0, 0),
                    Font = Enum.Font.GothamBold,
                    Name = "Title"
                }),
                SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 25),
                    Font = Enum.Font.GothamSemibold,
                    Name = "Content",
                    AutomaticSize = Enum.AutomaticSize.Y,
                    TextColor3 = Color3.fromRGB(200, 200, 200),
                    TextWrapped = true
                })
            })
            
            if not NotificationFrame then return end
            
            -- Animate in
            TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()
            
            -- Wait for display duration
            task.wait(NotificationConfig.Time - 0.88)
            
            -- Animate out
            pcall(function()
                TweenService:Create(NotificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
                TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
                task.wait(0.3)
                TweenService:Create(NotificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
                TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
                TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
                
                NotificationFrame:TweenPosition(UDim2.new(1, 20, 0, 0), 'In', 'Quint', 0.8, true)
                task.wait(1.35)
                NotificationFrame:Destroy()
            end)
        end)
    end)
end

-- Tab creation
function OverHeavenLib:CreateTab(window, config)
    if not window or not window.Container then return nil end
    
    config = config or {}
    config.Name = config.Name or "New Tab"
    
    local tab = CreateInstance("Frame", {
        Name = "Tab",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = self.Themes[self.SelectedTheme].Second,
        BorderSizePixel = 0,
        Parent = window.Container
    })
    
    if not tab then return nil end
    
    -- Add corner
    local corner = CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = tab
    })
    
    -- Add title
    local title = CreateInstance("TextLabel", {
        Name = "Title",
        Text = config.Name,
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.Themes[self.SelectedTheme].Text,
        TextSize = 14,
        Font = Enum.Font.GothamSemibold,
        Parent = tab
    })
    
    -- Add container for tab content
    local container = CreateInstance("ScrollingFrame", {
        Name = "Container",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = tab
    })
    
    -- Add list layout
    local listLayout = CreateInstance("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = container
    })
    
    return {
        Tab = tab,
        Container = container
    }
end

-- Initialize library
function OverHeavenLib:Init()
    if _G.OverHeavenState.Initialized then return end
    
    -- Create config folder
    pcall(function()
        if self.SaveCfg and not isfolder(self.Folder) then
            makefolder(self.Folder)
        end
    end)
    
    -- Create main window
    local window = self:CreateWindow({
        Name = "OverHeaven"
    })
    
    if not window then
        warn("Failed to create main window")
        return
    end
    
    -- Create default tab
    local tab = self:CreateTab(window, {
        Name = "Main"
    })
    
    if not tab then
        warn("Failed to create default tab")
        return
    end
    
    _G.OverHeavenState.Initialized = true
end

-- Destroy library
function OverHeavenLib:Destroy()
    -- Clean up connections
    for _, connection in pairs(self.Connections) do
        if typeof(connection) == "RBXScriptConnection" and connection.Connected then
            connection:Disconnect()
        end
    end
    
    -- Clear tables
    table.clear(self.Connections)
    table.clear(self.Elements)
    table.clear(self.ThemeObjects)
    table.clear(self.Flags)
    
    -- Destroy GUI
    if OverHeaven then
        OverHeaven:Destroy()
    end
    
    -- Reset state
    _G.OverHeavenState.Initialized = false
end

return OverHeavenLib
