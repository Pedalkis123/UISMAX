-- Modern UI Library for Roblox
-- Fast, efficient, and tactile design
-- Author: Your GitHub Username

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Library = {
    flags = {},
    toggled = true,
    keybind = Enum.KeyCode.RightShift,
    callback = nil,
    objects = {},
    connections = {}
}

-- Utility Functions
local function Tween(obj, info, props)
    local tween = TweenService:Create(obj, TweenInfo.new(unpack(info)), props)
    tween:Play()
    return tween
end

local function Create(class, props)
    local inst = Instance.new(class)
    for prop, value in next, props do
        if prop ~= "Parent" then
            inst[prop] = value
        end
    end
    if props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

-- UI Components
function Library:Init(title)
    if self.initialized then return self end
    self.initialized = true

    -- Main GUI Container
    self.main = Create("ScreenGui", {
        Name = "ModernUI",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })

    -- Main Frame
    self.container = Create("Frame", {
        Parent = self.main,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
    })

    -- Make Draggable
    local dragging, dragInput, dragStart, startPos
    
    self.container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.container.Position
        end
    end)

    self.container.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging then
            local delta = dragInput.Position - dragStart
            self.container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Title Bar
    self.titleBar = Create("Frame", {
        Parent = self.container,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
    })

    Create("TextLabel", {
        Parent = self.titleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Tab Container
    self.tabContainer = Create("Frame", {
        Parent = self.container,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(0, 150, 1, -30),
    })

    self.tabButtons = Create("ScrollingFrame", {
        Parent = self.tabContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 0,
        ScrollingEnabled = true,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })

    -- Content Container
    self.contentContainer = Create("Frame", {
        Parent = self.container,
        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 150, 0, 30),
        Size = UDim2.new(1, -150, 1, -30),
    })

    return self
end

function Library:CreateTab(name)
    local tab = {}
    
    -- Tab Button
    tab.button = Create("TextButton", {
        Parent = self.tabButtons,
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 35),
        Font = Enum.Font.GothamSemibold,
        Text = name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        AutoButtonColor = false
    })

    -- Tab Content
    tab.content = Create("ScrollingFrame", {
        Parent = self.contentContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 4,
        ScrollingEnabled = true,
        Visible = false,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    })

    -- Layout for content
    Create("UIListLayout", {
        Parent = tab.content,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    Create("UIPadding", {
        Parent = tab.content,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10)
    })

    -- Tab Functions
    function tab:Show()
        for _, v in pairs(Library.contentContainer:GetChildren()) do
            if v:IsA("ScrollingFrame") then
                v.Visible = false
            end
        end
        tab.content.Visible = true
        tab.button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    end

    tab.button.MouseButton1Click:Connect(function()
        tab:Show()
    end)

    -- Show first tab by default
    if #self.tabButtons:GetChildren() == 1 then
        tab:Show()
    end

    function tab:AddToggle(options)
        options = options or {}
        local toggle = {}
        
        -- Create toggle container
        toggle.container = Create("Frame", {
            Parent = tab.content,
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            Size = UDim2.new(1, 0, 0, 35),
            BorderSizePixel = 0
        })

        -- Toggle text
        toggle.text = Create("TextLabel", {
            Parent = toggle.container,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -60, 1, 0),
            Font = Enum.Font.Gotham,
            Text = options.text or "Toggle",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        -- Toggle button
        toggle.button = Create("Frame", {
            Parent = toggle.container,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Position = UDim2.new(1, -50, 0.5, -10),
            Size = UDim2.new(0, 40, 0, 20),
            BorderSizePixel = 0
        })

        toggle.indicator = Create("Frame", {
            Parent = toggle.button,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Position = UDim2.new(0, 2, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            BorderSizePixel = 0
        })

        -- Toggle state
        toggle.enabled = options.default or false
        Library.flags[options.flag or options.text] = toggle.enabled

        function toggle:Set(value)
            toggle.enabled = value
            Library.flags[options.flag or options.text] = value
            
            if value then
                Tween(toggle.indicator, {0.2}, {
                    Position = UDim2.new(1, -18, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(0, 255, 140)
                })
            else
                Tween(toggle.indicator, {0.2}, {
                    Position = UDim2.new(0, 2, 0.5, -8),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                })
            end

            if options.callback then
                options.callback(value)
            end
        end

        toggle.button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                toggle:Set(not toggle.enabled)
            end
        end)

        toggle:Set(toggle.enabled)
        return toggle
    end

    function tab:AddSlider(options)
        options = options or {}
        local slider = {}
        
        -- Create slider container
        slider.container = Create("Frame", {
            Parent = tab.content,
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            Size = UDim2.new(1, 0, 0, 50),
            BorderSizePixel = 0
        })

        -- Slider text
        slider.text = Create("TextLabel", {
            Parent = slider.container,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 5),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.Gotham,
            Text = options.text or "Slider",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        -- Slider value text
        slider.value = Create("TextLabel", {
            Parent = slider.container,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -60, 0, 5),
            Size = UDim2.new(0, 50, 0, 20),
            Font = Enum.Font.Gotham,
            Text = tostring(options.default or options.min or 0),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right
        })

        -- Slider bar
        slider.bar = Create("Frame", {
            Parent = slider.container,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Position = UDim2.new(0, 10, 0, 35),
            Size = UDim2.new(1, -20, 0, 5),
            BorderSizePixel = 0
        })

        slider.fill = Create("Frame", {
            Parent = slider.bar,
            BackgroundColor3 = Color3.fromRGB(0, 255, 140),
            Size = UDim2.new(0, 0, 1, 0),
            BorderSizePixel = 0
        })

        -- Slider functionality
        local min = options.min or 0
        local max = options.max or 100
        local default = math.clamp(options.default or min, min, max)
        
        function slider:Set(value)
            value = math.clamp(value, min, max)
            local percent = (value - min) / (max - min)
            
            slider.fill.Size = UDim2.new(percent, 0, 1, 0)
            slider.value.Text = tostring(math.floor(value))
            Library.flags[options.flag or options.text] = value
            
            if options.callback then
                options.callback(value)
            end
        end

        -- Slider interaction
        local dragging = false
        
        slider.bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local percent = math.clamp((input.Position.X - slider.bar.AbsolutePosition.X) / slider.bar.AbsoluteSize.X, 0, 1)
                local value = min + (max - min) * percent
                slider:Set(value)
            end
        end)

        slider:Set(default)
        return slider
    end

    function tab:AddButton(options)
        options = options or {}
        local button = {}
        
        -- Create button container
        button.container = Create("TextButton", {
            Parent = tab.content,
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            Size = UDim2.new(1, 0, 0, 35),
            BorderSizePixel = 0,
            Font = Enum.Font.Gotham,
            Text = options.text or "Button",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            AutoButtonColor = false
        })

        -- Button interaction
        button.container.MouseButton1Click:Connect(function()
            if options.callback then
                options.callback()
            end
        end)

        button.container.MouseEnter:Connect(function()
            Tween(button.container, {0.2}, {
                BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            })
        end)

        button.container.MouseLeave:Connect(function()
            Tween(button.container, {0.2}, {
                BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            })
        end)

        return button
    end

    return tab
end

-- Toggle UI Visibility
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Library.keybind then
        Library.toggled = not Library.toggled
        Library.main.Enabled = Library.toggled
    end
end)

return Library
