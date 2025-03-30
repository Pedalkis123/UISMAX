-- SMAX V2 UI Library
-- High-performance, tactile UI system for Roblox
-- Version 2.0

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:GetService("SoundService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

-- Color palette
local Colors = {
    -- Core UI colors
    Background = Color3.fromRGB(20, 20, 25),
    Accent = Color3.fromRGB(88, 101, 242), -- Discord-like blue
    Secondary = Color3.fromRGB(45, 45, 55),
    Tertiary = Color3.fromRGB(35, 35, 45),
    
    -- Text colors
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(180, 180, 185),
    
    -- Element colors
    Success = Color3.fromRGB(67, 181, 129), -- Green
    Warning = Color3.fromRGB(240, 171, 0),  -- Yellow
    Danger = Color3.fromRGB(240, 71, 71),   -- Red
    
    -- Element states
    Hover = Color3.fromRGB(55, 55, 65),
    Press = Color3.fromRGB(65, 65, 75),
}

-- Create sound effects
local Sounds = {
    Click = Instance.new("Sound"),
    Hover = Instance.new("Sound"),
    Toggle = Instance.new("Sound"),
    Notification = Instance.new("Sound"),
}

-- Setup sounds
Sounds.Click.SoundId = "rbxassetid://6895079853" -- Softer click
Sounds.Hover.SoundId = "rbxassetid://6895079733" -- Soft hover
Sounds.Toggle.SoundId = "rbxassetid://6895079980" -- Toggle sound
Sounds.Notification.SoundId = "rbxassetid://6895080000" -- Notification sound

-- Set sound properties
for _, sound in pairs(Sounds) do
    sound.Volume = 0.5
    sound.Parent = SoundService
end

-- Main Library
local Library = {
    flags = {},
    toggled = true,
    keybind = Enum.KeyCode.RightShift,
    theme = "dark", -- dark/light
    fontSize = 14,
    objects = {},
    connections = {},
    tabs = {},
    activeTab = nil,
    initialized = false,
    dragSpeed = 0.1, -- Lower = smoother but slower drag
    cornerRadius = UDim.new(0, 4), -- Rounded corners
    sounds = true, -- Enable/disable sound effects
    tabCount = 0,
}

-- Utility Functions
local function playSound(soundName)
    if Library.sounds then
        Sounds[soundName]:Play()
    end
end

local function Shadow(instance)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0.5, 0, 0.5, 2) -- Offset slightly for better shadow effect
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.ZIndex = instance.ZIndex - 1
    shadow.Image = "rbxassetid://6014054875" -- High quality shadow asset
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.65
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(135, 135, 135, 135)
    shadow.Parent = instance
    return shadow
end

local function RoundBox(instance, radius)
    radius = radius or Library.cornerRadius
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius
    corner.Parent = instance
    
    return corner
end

local function Tween(instance, duration, properties)
    local tweenInfo = TweenInfo.new(
        duration, 
        Enum.EasingStyle.Quint,  -- Smoother easing
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function Create(className, properties)
    local instance = Instance.new(className)
    
    for property, value in next, properties do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    
    return instance
end

local function MakeDraggable(frame, handle)
    local dragToggle, dragInput, dragStart, startPos
    local dragSpeed = Library.dragSpeed
    
    handle = handle or frame
    
    local function updateDrag(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        Tween(frame, dragSpeed, {Position = position})
    end
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            updateDrag(input)
        end
    end)
end

-- UI Components
function Library:Init(title)
    if self.initialized then return self end
    self.initialized = true
    title = title or "SMAX V2 Hub"
    
    -- Main GUI Container
    self.main = Create("ScreenGui", {
        Name = "SMAXV2",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Main Container Frame
    self.container = Create("Frame", {
        Parent = self.main,
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -325, 0.5, -200),
        Size = UDim2.new(0, 650, 0, 400), -- Slightly larger than before
        AnchorPoint = Vector2.new(0, 0),
    })
    
    -- Apply rounded corners and shadow
    RoundBox(self.container)
    Shadow(self.container)
    
    -- Title Bar
    self.titleBar = Create("Frame", {
        Parent = self.container,
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40), -- Taller title bar
    })
    
    -- Round only top corners of title bar
    local titleCorners = Create("UICorner", {
        Parent = self.titleBar,
        CornerRadius = Library.cornerRadius
    })
    
    -- Prevent rounded corners on bottom of title bar
    Create("Frame", {
        Parent = self.titleBar,
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 10),
    })
    
    -- Title
    self.title = Create("TextLabel", {
        Parent = self.titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Colors.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Close Button
    self.closeButton = Create("ImageButton", {
        Parent = self.titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -38, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = "rbxassetid://6031094678", -- X icon
        ImageColor3 = Colors.Text,
    })
    
    -- Tab Container (sidebar)
    self.tabContainer = Create("Frame", {
        Parent = self.container,
        BackgroundColor3 = Colors.Tertiary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 160, 1, -40),
    })
    
    -- Create rounded corner on bottom left only
    local leftCorner = Create("UICorner", {
        Parent = self.tabContainer,
        CornerRadius = Library.cornerRadius
    })
    
    -- Create UIListLayout for tab buttons
    self.tabButtonList = Create("UIListLayout", {
        Parent = self.tabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    
    -- Tab Buttons Container
    self.tabButtons = Create("ScrollingFrame", {
        Parent = self.tabContainer,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 10),
        Size = UDim2.new(1, 0, 1, -10),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })
    
    -- UIPadding for tab buttons
    Create("UIPadding", {
        Parent = self.tabButtons,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5)
    })
    
    -- Create Tab Button List Layout
    Create("UIListLayout", {
        Parent = self.tabButtons,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8) -- More padding between tab buttons
    })
    
    -- Content Container
    self.contentContainer = Create("Frame", {
        Parent = self.container,
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 160, 0, 40),
        Size = UDim2.new(1, -160, 1, -40),
        ClipsDescendants = true
    })
    
    -- Create rounded corner on bottom right only
    local rightCorner = Create("UICorner", {
        Parent = self.contentContainer,
        CornerRadius = Library.cornerRadius
    })
    
    -- Container for status info at bottom of sidebar
    self.statusContainer = Create("Frame", {
        Parent = self.tabContainer,
        BackgroundColor3 = Colors.Secondary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -30),
        Size = UDim2.new(1, 0, 0, 30),
    })
    
    -- Keybind reminder text
    self.keybindText = Create("TextLabel", {
        Parent = self.statusContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "Press RightShift to toggle",
        TextColor3 = Colors.TextDark,
        TextSize = 12,
    })
    
    -- Make container draggable from title bar
    MakeDraggable(self.container, self.titleBar)
    
    -- Close button functionality
    self.closeButton.MouseButton1Click:Connect(function()
        playSound("Click")
        self.toggled = false
        Tween(self.container, 0.3, {Position = UDim2.new(0.5, -325, 1.5, 0)})
        wait(0.3)
        self.main.Enabled = false
    })
    
    -- Toggle UI with keybind
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == self.keybind then
            self.toggled = not self.toggled
            
            if self.toggled then
                playSound("Notification")
                self.main.Enabled = true
                self.container.Position = UDim2.new(0.5, -325, 1.5, 0)
                Tween(self.container, 0.3, {Position = UDim2.new(0.5, -325, 0.5, -200)})
            else
                playSound("Click")
                Tween(self.container, 0.3, {Position = UDim2.new(0.5, -325, 1.5, 0)})
                wait(0.3)
                self.main.Enabled = false
            end
        end
    end)
    
    return self
end

-- Function to select a tab
function Library:SelectTab(tabName)
    if not tabName then return end
    
    local targetTab
    for _, tab in pairs(self.tabs) do
        if tab.name == tabName then
            targetTab = tab
            break
        end
    end
    
    if targetTab then
        targetTab:Show()
    end
end

function Library:CreateTab(name)
    self.tabCount = self.tabCount + 1
    
    local tab = {}
    tab.name = name
    tab.elements = {}
    
    -- Tab Button with container for organization
    local buttonContainer = Create("Frame", {
        Parent = self.tabButtons,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        LayoutOrder = self.tabCount
    })
    
    -- Tab Button
    tab.button = Create("TextButton", {
        Parent = buttonContainer,
        BackgroundColor3 = Colors.Tertiary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = name,
        TextColor3 = Colors.Text,
        TextSize = 14,
        AutoButtonColor = false
    })
    
    -- Apply rounded corners to button
    RoundBox(tab.button)
    
    -- Tab Icon (optional)
    local iconIds = {
        ["Auto Farm"] = "6034287525", -- Farm icon
        ["Movement"] = "6034455448", -- Movement icon
        ["Combat"] = "6034509211",   -- Combat icon
        ["Visuals"] = "6031280882",  -- Eye icon
        ["Misc"] = "6031086173",     -- Misc icon
        ["Settings"] = "6031280749"  -- Settings icon
    }
    
    local iconId = iconIds[name] or "6031086173" -- Default to misc icon
    
    tab.icon = Create("ImageLabel", {
        Parent = tab.button,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://" .. iconId,
        ImageColor3 = Colors.Text
    })
    
    -- Adjust text position to account for icon
    tab.button.Text = "  " .. name
    tab.button.TextXAlignment = Enum.TextXAlignment.Center
    
    -- Active indicator for the tab
    tab.activeIndicator = Create("Frame", {
        Parent = tab.button,
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, -10),
        Position = UDim2.new(0, 0, 0, 5),
        Visible = false
    })
    
    -- Round the active indicator
    RoundBox(tab.activeIndicator)
    
    -- Tab Content Container
    tab.contentFrame = Create("Frame", {
        Parent = self.contentContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        Name = "ContentContainer_" .. name
    })
    
    -- Tab Content (Scrolling Frame)
    tab.content = Create("ScrollingFrame", {
        Parent = tab.contentFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Colors.Accent,
        ScrollingEnabled = true,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Name = "Tab_" .. name,
        ClipsDescendants = true,
    })
    
    -- Layout for content
    Create("UIListLayout", {
        Parent = tab.content,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })
    
    Create("UIPadding", {
        Parent = tab.content,
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        PaddingTop = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15)
    })
    
    -- Create an element counter for ordering within the tab
    tab.elementCount = 0
    
    -- Toggle Element
    function tab:AddToggle(options)
        self.elementCount = self.elementCount + 1
        options = options or {}
        local toggle = {}
        
        -- Create section title if specified
        if options.section and options.isFirst then
            local sectionTitle = Create("TextLabel", {
                Parent = tab.content,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                Font = Enum.Font.GothamBold,
                Text = options.section,
                TextColor3 = Colors.Accent,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = self.elementCount
            })
            
            -- Add separator line
            local separator = Create("Frame", {
                Parent = sectionTitle,
                BackgroundColor3 = Colors.Accent,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(1, 0, 0, 1),
                Transparency = 0.7
            })
            
            self.elementCount = self.elementCount + 1
        end
        
        -- Create toggle container
        toggle.container = Create("Frame", {
            Parent = tab.content,
            BackgroundColor3 = Colors.Secondary,
            Size = UDim2.new(1, 0, 0, 40),
            BorderSizePixel = 0,
            LayoutOrder = self.elementCount
        })
        
        -- Add rounded corners
        RoundBox(toggle.container)
        
        -- Toggle text
        toggle.text = Create("TextLabel", {
            Parent = toggle.container,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 0),
            Size = UDim2.new(1, -65, 1, 0),
            Font = Enum.Font.Gotham,
            Text = options.text or "Toggle",
            TextColor3 = Colors.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Toggle switch background
        toggle.background = Create("Frame", {
            Parent = toggle.container,
            BackgroundColor3 = Colors.Tertiary,
            Position = UDim2.new(1, -55, 0.5, -10),
            Size = UDim2.new(0, 40, 0, 20),
            BorderSizePixel = 0
        })
        
        -- Round the toggle background
        RoundBox(toggle.background, UDim.new(0, 10))
        
        -- Toggle indicator
        toggle.indicator = Create("Frame", {
            Parent = toggle.background,
            BackgroundColor3 = Colors.Text,
            Position = UDim2.new(0, 2, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            BorderSizePixel = 0
        })
        
        -- Round the indicator
        RoundBox(toggle.indicator, UDim.new(0, 8))
        
        -- Create ripple effect container
        toggle.ripple = Create("Frame", {
            Parent = toggle.container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 10,
            ClipsDescendants = true
        })
        
        -- Toggle state
        toggle.enabled = options.default or false
        Library.flags[options.flag or options.text] = toggle.enabled
        
        -- Set function
        function toggle:Set(value)
            toggle.enabled = value
            Library.flags[options.flag or options.text] = value
            
            if value then
                Tween(toggle.background, 0.3, {BackgroundColor3 = Colors.Accent})
                Tween(toggle.indicator, 0.3, {
                    Position = UDim2.new(1, -18, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                })
            else
                Tween(toggle.background, 0.3, {BackgroundColor3 = Colors.Tertiary})
                Tween(toggle.indicator, 0.3, {
                    Position = UDim2.new(0, 2, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                })
            end
            
            -- Play toggle sound
            playSound("Toggle")
            
            -- Call callback if provided
            if options.callback then
                options.callback(value)
            end
        end
        
        -- Ripple effect function
        local function createRipple(x, y)
            local ripple = Create("Frame", {
                Parent = toggle.ripple,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.7,
                Position = UDim2.new(0, x, 0, y),
                Size = UDim2.new(0, 0, 0, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                ZIndex = 10,
                BorderSizePixel = 0
            })
            
            RoundBox(ripple, UDim.new(0.5, 0))
            
            -- Animate ripple
            Tween(ripple, 0.5, {
                Size = UDim2.new(0, 100, 0, 100),
                BackgroundTransparency = 1
            })
            
            task.spawn(function()
                wait(0.5)
                ripple:Destroy()
            end)
        end
        
        -- Click detection for entire container and toggle
        local function onClick()
            toggle:Set(not toggle.enabled)
            
            -- Create ripple effect from center of container
            local center = toggle.container.AbsoluteSize
            createRipple(center.X/2, center.Y/2)
        end
        
        toggle.container.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                onClick()
            end
        end)
        
        -- Hover effect
        toggle.container.MouseEnter:Connect(function()
            playSound("Hover")
            Tween(toggle.container, 0.3, {BackgroundColor3 = Colors.Hover})
        end)
        
        toggle.container.MouseLeave:Connect(function()
            Tween(toggle.container, 0.3, {BackgroundColor3 = Colors.Secondary})
        end)
        
        -- Initialize toggle state
        toggle:Set(toggle.enabled)
        
        table.insert(tab.elements, toggle)
        return toggle
    end
    
    -- Slider Element
    function tab:AddSlider(options)
        self.elementCount = self.elementCount + 1
        options = options or {}
        local slider = {}
        
        -- Create section title if specified
        if options.section and options.isFirst then
            local sectionTitle = Create("TextLabel", {
                Parent = tab.content,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                Font = Enum.Font.GothamBold,
                Text = options.section,
                TextColor3 = Colors.Accent,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = self.elementCount
            })
            
            -- Add separator line
            local separator = Create("Frame", {
                Parent = sectionTitle,
                BackgroundColor3 = Colors.Accent,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(1, 0, 0, 1),
                Transparency = 0.7
            })
            
            self.elementCount = self.elementCount + 1
        end
        
        -- Create slider container
        slider.container = Create("Frame", {
            Parent = tab.content,
            BackgroundColor3 = Colors.Secondary,
            Size = UDim2.new(1, 0, 0, 60),
            BorderSizePixel = 0,
            LayoutOrder = self.elementCount
        })
        
        -- Add rounded corners
        RoundBox(slider.container)
        
        -- Slider text
        slider.text = Create("TextLabel", {
            Parent = slider.container,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 8),
            Size = UDim2.new(1, -30, 0, 20),
            Font = Enum.Font.Gotham,
            Text = options.text or "Slider",
            TextColor3 = Colors.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Slider value text
        slider.value = Create("TextLabel", {
            Parent = slider.container,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -55, 0, 8),
            Size = UDim2.new(0, 40, 0, 20),
            Font = Enum.Font.GothamSemibold,
            Text = tostring(options.default or options.min or 0),
            TextColor3 = Colors.Accent,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right
        })
        
        -- Slider track
        slider.track = Create("Frame", {
            Parent = slider.container,
            BackgroundColor3 = Colors.Tertiary,
            Position = UDim2.new(0, 15, 0, 38),
            Size = UDim2.new(1, -30, 0, 6),
            BorderSizePixel = 0
        })
        
        -- Round the track
        RoundBox(slider.track, UDim.new(0, 3))
        
        -- Slider fill
        slider.fill = Create("Frame", {
            Parent = slider.track,
            BackgroundColor3 = Colors.Accent,
            Size = UDim2.new(0, 0, 1, 0),
            BorderSizePixel = 0
        })
        
        -- Round the fill
        RoundBox(slider.fill, UDim.new(0, 3))
        
        -- Slider indicator (knob)
        slider.indicator = Create("Frame", {
            Parent = slider.track,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Colors.Text,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 16, 0, 16),
            BorderSizePixel = 0,
            ZIndex = 2
        })
        
        -- Round the indicator
        RoundBox(slider.indicator, UDim.new(0, 8))
        Shadow(slider.indicator)
        
        -- Slider values
        local min = options.min or 0
        local max = options.max or 100
        local defaultValue = math.clamp(options.default or min, min, max)
        
        -- Set function
        function slider:Set(value)
            value = math.clamp(value, min, max)
            local percent = (value - min) / (max - min)
            
            -- Update fill and knob position
            slider.fill.Size = UDim2.new(percent, 0, 1, 0)
            slider.indicator.Position = UDim2.new(percent, 0, 0.5, 0)
            
            -- Update value text
            slider.value.Text = tostring(math.floor(value))
            
            -- Update flag
            Library.flags[options.flag or options.text] = value
            
            -- Call callback if provided
            if options.callback then
                options.callback(value)
            end
        end
        
        -- Slider interaction
        local dragging = false
        
        slider.track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                
                -- Calculate value from mouse position
                local percent = math.clamp((input.Position.X - slider.track.AbsolutePosition.X) / slider.track.AbsoluteSize.X, 0, 1)
                local value = min + (max - min) * percent
                slider:Set(value)
                
                -- Play sound
                playSound("Click")
                
                -- Highlight effect
                Tween(slider.indicator, 0.2, {Size = UDim2.new(0, 20, 0, 20)})
            end
        end)
        
        slider.track.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                
                -- Return to normal size
                Tween(slider.indicator, 0.2, {Size = UDim2.new(0, 16, 0, 16)})
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                -- Calculate value from mouse position
                local percent = math.clamp((input.Position.X - slider.track.AbsolutePosition.X) / slider.track.AbsoluteSize.X, 0, 1)
                local value = min + (max - min) * percent
                slider:Set(value)
            end
        end)
        
        -- Hover effect
        slider.container.MouseEnter:Connect(function()
            playSound("Hover")
            Tween(slider.container, 0.3, {BackgroundColor3 = Colors.Hover})
        end)
        
        slider.container.MouseLeave:Connect(function()
            Tween(slider.container, 0.3, {BackgroundColor3 = Colors.Secondary})
            
            -- Return to normal size if not dragging
            if not dragging then
                Tween(slider.indicator, 0.2, {Size = UDim2.new(0, 16, 0, 16)})
            end
        end)
        
        -- Initialize slider value
        slider:Set(defaultValue)
        
        table.insert(tab.elements, slider)
        return slider
    end
    
    -- Button Element
    function tab:AddButton(options)
        self.elementCount = self.elementCount + 1
        options = options or {}
        local button = {}
        
        -- Create section title if specified
        if options.section and options.isFirst then
            local sectionTitle = Create("TextLabel", {
                Parent = tab.content,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                Font = Enum.Font.GothamBold,
                Text = options.section,
                TextColor3 = Colors.Accent,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = self.elementCount
            })
            
            -- Add separator line
            local separator = Create("Frame", {
                Parent = sectionTitle,
                BackgroundColor3 = Colors.Accent,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, 0),
                Size = UDim2.new(1, 0, 0, 1),
                Transparency = 0.7
            })
            
            self.elementCount = self.elementCount + 1
        end
        
        -- Create button container
        button.container = Create("TextButton", {
            Parent = tab.content,
            BackgroundColor3 = Colors.Secondary,
            Size = UDim2.new(1, 0, 0, 40),
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = self.elementCount
        })
        
        -- Add rounded corners
        RoundBox(button.container)
        
        -- Button text
        button.text = Create("TextLabel", {
            Parent = button.container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamSemibold,
            Text = options.text or "Button",
            TextColor3 = Colors.Text,
            TextSize = 14
        })
        
        -- Create ripple effect container
        button.ripple = Create("Frame", {
            Parent = button.container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 10,
            ClipsDescendants = true
        })
        
        -- Ripple effect function
        local function createRipple(x, y)
            local ripple = Create("Frame", {
                Parent = button.ripple,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 0.7,
                Position = UDim2.new(0, x, 0, y),
                Size = UDim2.new(0, 0, 0, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                ZIndex = 10,
                BorderSizePixel = 0
            })
            
            RoundBox(ripple, UDim.new(0.5, 0))
            
            -- Animate ripple
            Tween(ripple, 0.5, {
                Size = UDim2.new(0, 250, 0, 250),
                BackgroundTransparency = 1
            })
            
            task.spawn(function()
                wait(0.5)
                ripple:Destroy()
            end)
        end
        
        -- Button interaction
        button.container.MouseButton1Down:Connect(function()
            playSound("Click")
            
            -- Press effect
            Tween(button.container, 0.1, {BackgroundColor3 = Colors.Press})
            Tween(button.text, 0.1, {TextSize = 13})
            
            -- Create ripple effect
            local mouse = UserInputService:GetMouseLocation()
            local x = mouse.X - button.container.AbsolutePosition.X
            local y = mouse.Y - button.container.AbsolutePosition.Y
            createRipple(x, y)
        end)
        
        button.container.MouseButton1Up:Connect(function()
            -- Release effect
            Tween(button.container, 0.1, {BackgroundColor3 = Colors.Hover})
            Tween(button.text, 0.1, {TextSize = 14})
            
            -- Call callback if provided
            if options.callback then
                options.callback()
            end
        end)
        
        -- Button hover effects
        button.container.MouseEnter:Connect(function()
            playSound("Hover")
            Tween(button.container, 0.3, {BackgroundColor3 = Colors.Hover})
        end)
        
        button.container.MouseLeave:Connect(function()
            Tween(button.container, 0.3, {BackgroundColor3 = Colors.Secondary})
            Tween(button.text, 0.1, {TextSize = 14})
        end)
        
        table.insert(tab.elements, button)
        return button
    end
    
    -- Add tab to library tabs
    table.insert(self.tabs, tab)
    
    -- Tab Functions
    function tab:Show()
        playSound("Click")
        
        -- Hide all tabs first
        for _, otherTab in pairs(Library.tabs) do
            if otherTab.contentFrame then
                otherTab.contentFrame.Visible = false
            end
            
            if otherTab.button then
                otherTab.button.BackgroundColor3 = Colors.Tertiary
                Tween(otherTab.button, 0.3, {BackgroundColor3 = Colors.Tertiary})
            end
            
            if otherTab.activeIndicator then
                otherTab.activeIndicator.Visible = false
            end
            
            if otherTab.icon then
                Tween(otherTab.icon, 0.3, {ImageColor3 = Colors.Text})
            end
        end
        
        -- Now show only this tab with animation
        tab.contentFrame.Visible = true
        Tween(tab.button, 0.3, {BackgroundColor3 = Colors.Accent})
        tab.icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
        tab.activeIndicator.Visible = true
        
        -- Animate the active indicator
        tab.activeIndicator.Size = UDim2.new(0, 3, 0, 0)
        tab.activeIndicator.Position = UDim2.new(0, 0, 0.5, 0)
        Tween(tab.activeIndicator, 0.3, {
            Size = UDim2.new(0, 3, 1, -10),
            Position = UDim2.new(0, 0, 0, 5)
        })
        
        -- Set this as active tab
        Library.activeTab = tab
    end
    
    -- Button Hover Effects
    tab.button.MouseEnter:Connect(function()
        if Library.activeTab ~= tab then
            playSound("Hover")
            Tween(tab.button, 0.3, {BackgroundColor3 = Colors.Hover})
        end
    end)
    
    tab.button.MouseLeave:Connect(function()
        if Library.activeTab ~= tab then
            Tween(tab.button, 0.3, {BackgroundColor3 = Colors.Tertiary})
        end
    end)
    
    -- Tab button click handler
    tab.button.MouseButton1Click:Connect(function()
        tab:Show()
    end)
    
    -- Show first tab by default
    if #self.tabs == 1 then
        task.spawn(function()
            task.wait(0.1) -- Small delay to ensure all UI is created
            tab:Show()
        end)
    end

    return tab
end

return Library
