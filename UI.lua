-- Unique Hexagonal UI Library for SMAX V2
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Library = {}
Library.flags = {}
Library.connections = {}

-- Unique color palette
local Colors = {
    Background = Color3.fromRGB(20, 22, 30),
    Primary = Color3.fromRGB(98, 50, 209),    -- Purple
    Secondary = Color3.fromRGB(50, 120, 209), -- Blue
    Accent = Color3.fromRGB(209, 50, 150),    -- Pink
    Text = Color3.fromRGB(240, 240, 245),
    TextDark = Color3.fromRGB(150, 150, 160),
    DarkBG = Color3.fromRGB(15, 17, 24),
    Element = Color3.fromRGB(35, 37, 45)
}

-- Tween info for animations
local TweenFast = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TweenMedium = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TweenSlow = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- Create hexagonal UI elements
local function CreateHexagon(parent, size)
    local hexagon = Instance.new("ImageLabel")
    hexagon.BackgroundTransparency = 1
    hexagon.Image = "rbxassetid://7578947156" -- Hexagon asset ID
    hexagon.Size = UDim2.fromOffset(size, size)
    hexagon.ScaleType = Enum.ScaleType.Slice
    hexagon.SliceCenter = Rect.new(Vector2.new(128, 128), Vector2.new(128, 128))
    hexagon.Parent = parent
    return hexagon
end

-- Shadow effect
local function AddShadow(element, intensity)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.fromScale(0.5, 0.5)
    shadow.Size = UDim2.new(1, intensity * 2, 1, intensity * 2)
    shadow.ZIndex = element.ZIndex - 1
    shadow.Image = "rbxassetid://7743628511" -- Drop shadow
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(Vector2.new(512, 512), Vector2.new(512, 512))
    shadow.Parent = element
    return shadow
end

-- Create a rounded rectangle
local function CreateRoundRect(parent, size, position, color, cornerRadius)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius or 8)
    corner.Parent = frame
    
    frame.Parent = parent
    return frame
end

-- Create gradient effect
local function AddGradient(element, colorA, colorB, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colorA),
        ColorSequenceKeypoint.new(1, colorB)
    })
    gradient.Rotation = rotation or 45
    gradient.Parent = element
    return gradient
end

function Library:Init(title)
    local library = {}
    library.tabs = {}
    library.flags = Library.flags
    library.connections = Library.connections
    
    -- Create main UI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SMAX_V2"
    ScreenGui.Parent = CoreGui
    ScreenGui.DisplayOrder = 999
    ScreenGui.ResetOnSpawn = false
    
    -- Main container with unique shape
    local mainContainer = CreateRoundRect(ScreenGui, UDim2.new(0, 580, 0, 400), UDim2.new(0.5, -290, 0.5, -200), Colors.Background, 16)
    mainContainer.ClipsDescendants = true
    mainContainer.Active = true
    mainContainer.Draggable = true
    
    -- Add shadow to main container
    AddShadow(mainContainer, 30)
    
    -- Add background gradient
    AddGradient(mainContainer, Colors.Background, Color3.fromRGB(25, 25, 35), 135)
    
    -- Create unique decorative elements
    for i = 1, 3 do
        local hex = CreateHexagon(mainContainer, 150)
        hex.ImageColor3 = Colors.Primary
        hex.ImageTransparency = 0.9
        hex.ZIndex = 2
        hex.Position = UDim2.new(0, -30 + (i * 60), 0, -50 + (i * 10))
        
        local hex2 = CreateHexagon(mainContainer, 100)
        hex2.ImageColor3 = Colors.Secondary
        hex2.ImageTransparency = 0.85
        hex2.ZIndex = 2
        hex2.Position = UDim2.new(1, -(i * 80), 1, -(i * 20))
    end
    
    -- Create unique title bar (curved edges)
    local titleContainer = CreateRoundRect(mainContainer, UDim2.new(1, -20, 0, 48), UDim2.new(0, 10, 0, 10), Colors.DarkBG, 12)
    
    -- Hexagonal logo
    local logo = CreateHexagon(titleContainer, 36)
    logo.Position = UDim2.new(0, 6, 0, 6)
    logo.ImageColor3 = Colors.Primary
    AddGradient(logo, Colors.Primary, Colors.Secondary, 90)
    
    -- Title with gradient text
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 50, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Font = Enum.Font.GothamBold
    titleText.TextColor3 = Colors.Text
    titleText.TextSize = 18
    titleText.Text = title
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleContainer
    
    -- Close button (hexagonal)
    local closeBtn = CreateHexagon(titleContainer, 30)
    closeBtn.Position = UDim2.new(1, -36, 0, 9)
    closeBtn.ImageColor3 = Colors.Accent
    closeBtn.ZIndex = 5
    
    local closeX = Instance.new("TextLabel")
    closeX.Size = UDim2.fromScale(1, 1)
    closeX.BackgroundTransparency = 1
    closeX.Text = "×"
    closeX.TextColor3 = Colors.Text
    closeX.TextSize = 24
    closeX.Font = Enum.Font.GothamBold
    closeX.ZIndex = 6
    closeX.Parent = closeBtn
    
    -- Make close button interactive
    closeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            TweenService:Create(closeBtn, TweenFast, {ImageColor3 = Colors.Primary}):Play()
        end
    end)
    
    closeBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            TweenService:Create(closeBtn, TweenFast, {ImageColor3 = Colors.Accent}):Play()
            wait(0.15)
            ScreenGui:Destroy()
        end
    end)
    
    -- Content area with unique curved layout
    local contentFrame = CreateRoundRect(mainContainer, UDim2.new(1, -20, 1, -68), UDim2.new(0, 10, 0, 58), Colors.DarkBG, 12)
    contentFrame.ClipsDescendants = true
    
    -- Unique tab bar (horizontal with diagonal edges)
    local tabBar = CreateRoundRect(contentFrame, UDim2.new(1, -16, 0, 42), UDim2.new(0, 8, 0, 8), Colors.Element, 8)
    
    -- Tab container (horizontal scrolling)
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Size = UDim2.new(1, -16, 0, 42)
    tabContainer.Position = UDim2.new(0, 8, 0, 8)
    tabContainer.BackgroundTransparency = 1
    tabContainer.BorderSizePixel = 0
    tabContainer.ScrollBarThickness = 0
    tabContainer.ScrollingDirection = Enum.ScrollingDirection.X
    tabContainer.Parent = contentFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = tabContainer
    
    -- Content container
    local contentContainer = CreateRoundRect(contentFrame, UDim2.new(1, -16, 1, -58), UDim2.new(0, 8, 0, 50), Color3.fromRGB(0, 0, 0), 8)
    contentContainer.BackgroundTransparency = 1
    
    -- Store UI elements in library
    library.ScreenGui = ScreenGui
    library.mainContainer = mainContainer
    library.contentFrame = contentFrame
    library.tabContainer = tabContainer
    library.contentContainer = contentContainer
    
    -- Create tab function with unique style
    function library:CreateTab(tabName)
        local tab = {}
        tab.name = tabName
        tab.elements = {}
        
        -- Create tab button (pill shaped)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName
        tabButton.Size = UDim2.new(0, 100, 0, 36)
        tabButton.Position = UDim2.new(0, 0, 0, 0)
        tabButton.BackgroundColor3 = Colors.Element
        tabButton.BorderSizePixel = 0
        tabButton.Text = ""
        tabButton.AutoButtonColor = false
        tabButton.Parent = tabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 18) -- Pill shape
        tabCorner.Parent = tabButton
        
        local tabLabel = Instance.new("TextLabel")
        tabLabel.Size = UDim2.new(1, 0, 1, 0)
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = tabName
        tabLabel.TextColor3 = Colors.TextDark
        tabLabel.Font = Enum.Font.GothamSemibold
        tabLabel.TextSize = 14
        tabLabel.Parent = tabButton
        
        -- Hexagonal indicator
        local tabIndicator = CreateHexagon(tabButton, 8)
        tabIndicator.AnchorPoint = Vector2.new(0, 0.5)
        tabIndicator.Position = UDim2.new(0, 10, 0.5, 0)
        tabIndicator.ImageColor3 = Colors.Primary
        tabIndicator.ImageTransparency = 1 -- Hidden by default
        
        -- Create tab content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 3
        tabContent.ScrollBarImageColor3 = Colors.Primary
        tabContent.Visible = false
        tabContent.Parent = contentContainer
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingLeft = UDim.new(0, 10)
        contentPadding.PaddingRight = UDim.new(0, 10)
        contentPadding.PaddingTop = UDim.new(0, 10)
        contentPadding.PaddingBottom = UDim.new(0, 10)
        contentPadding.Parent = tabContent
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.Parent = tabContent
        
        -- Auto-canvas size
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        tab.button = tabButton
        tab.indicator = tabIndicator
        tab.content = tabContent
        
        -- Add tactile hover effect
        tabButton.MouseEnter:Connect(function()
            if tabContent.Visible then return end
            TweenService:Create(tabButton, TweenFast, {BackgroundColor3 = Color3.fromRGB(45, 47, 55)}):Play()
        end)
        
        tabButton.MouseLeave:Connect(function()
            if tabContent.Visible then return end
            TweenService:Create(tabButton, TweenFast, {BackgroundColor3 = Colors.Element}):Play()
        end)
        
        -- Toggle function with tactile animation
        function tab:AddToggle(options)
            local toggle = {}
            toggle.text = options.text
            toggle.flag = options.flag
            toggle.callback = options.callback
            toggle.section = options.section
            
            -- Create toggle container
            local toggleContainer = CreateRoundRect(tabContent, UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), Colors.Element, 8)
            
            -- Gradient effect
            AddGradient(toggleContainer, Colors.Element, Color3.fromRGB(40, 42, 50), 180)
            
            -- Toggle text
            local toggleText = Instance.new("TextLabel")
            toggleText.Size = UDim2.new(1, -60, 1, 0)
            toggleText.Position = UDim2.new(0, 15, 0, 0)
            toggleText.BackgroundTransparency = 1
            toggleText.Text = options.text
            toggleText.TextColor3 = Colors.Text
            toggleText.TextSize = 16
            toggleText.Font = Enum.Font.GothamMedium
            toggleText.TextXAlignment = Enum.TextXAlignment.Left
            toggleText.Parent = toggleContainer
            
            -- Toggle hexagon background
            local toggleBg = CreateHexagon(toggleContainer, 30)
            toggleBg.Position = UDim2.new(1, -42, 0.5, -15)
            toggleBg.ImageColor3 = Color3.fromRGB(40, 42, 50)
            
            -- Toggle state indicator (smaller hexagon)
            local toggleIndicator = CreateHexagon(toggleBg, 20)
            toggleIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
            toggleIndicator.Position = UDim2.fromScale(0.5, 0.5)
            toggleIndicator.ImageColor3 = Colors.Primary
            toggleIndicator.ImageTransparency = 0.8
            
            -- Set default state
            library.flags[options.flag] = options.default or false
            
            -- Update toggle visuals with animation
            local function updateToggle()
                local enabled = library.flags[options.flag]
                
                if enabled then
                    TweenService:Create(toggleBg, TweenFast, {ImageColor3 = Colors.Primary}):Play()
                    TweenService:Create(toggleIndicator, TweenFast, {ImageTransparency = 0}):Play()
                else
                    TweenService:Create(toggleBg, TweenFast, {ImageColor3 = Color3.fromRGB(40, 42, 50)}):Play()
                    TweenService:Create(toggleIndicator, TweenFast, {ImageTransparency = 0.8}):Play()
                end
                
                if options.callback then
                    options.callback(enabled)
                end
            end
            
            -- Tactile press effect
            toggleContainer.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    library.flags[options.flag] = not library.flags[options.flag]
                    
                    -- Scale animation
                    TweenService:Create(toggleIndicator, TweenFast, {
                        Size = UDim2.fromOffset(18, 18),
                    }):Play()
                    
                    wait(0.1)
                    
                    TweenService:Create(toggleIndicator, TweenFast, {
                        Size = UDim2.fromOffset(20, 20),
                    }):Play()
                    
                    updateToggle()
                end
            end)
            
            -- Initial update
            updateToggle()
            table.insert(tab.elements, toggle)
            return toggle
        end
        
        -- Slider with tactile animation
        function tab:AddSlider(options)
            local slider = {}
            slider.text = options.text
            slider.flag = options.flag
            slider.min = options.min or 0
            slider.max = options.max or 100
            slider.default = options.default or slider.min
            slider.callback = options.callback
            slider.section = options.section
            
            -- Create slider container
            local sliderContainer = CreateRoundRect(tabContent, UDim2.new(1, 0, 0, 55), UDim2.new(0, 0, 0, 0), Colors.Element, 8)
            
            -- Gradient effect
            AddGradient(sliderContainer, Colors.Element, Color3.fromRGB(40, 42, 50), 180)
            
            -- Slider text
            local sliderText = Instance.new("TextLabel")
            sliderText.Size = UDim2.new(1, -20, 0, 25)
            sliderText.Position = UDim2.new(0, 15, 0, 5)
            sliderText.BackgroundTransparency = 1
            sliderText.Text = options.text
            sliderText.TextColor3 = Colors.Text
            sliderText.TextSize = 16
            sliderText.Font = Enum.Font.GothamMedium
            sliderText.TextXAlignment = Enum.TextXAlignment.Left
            sliderText.Parent = sliderContainer
            
            -- Value text
            local valueText = Instance.new("TextLabel")
            valueText.Size = UDim2.new(0, 50, 0, 25)
            valueText.Position = UDim2.new(1, -60, 0, 5)
            valueText.BackgroundTransparency = 1
            valueText.Text = tostring(slider.default)
            valueText.TextColor3 = Colors.Secondary
            valueText.TextSize = 16
            valueText.Font = Enum.Font.GothamSemibold
            valueText.TextXAlignment = Enum.TextXAlignment.Right
            valueText.Parent = sliderContainer
            
            -- Create unique slider track (pill shaped)
            local sliderTrack = CreateRoundRect(sliderContainer, UDim2.new(1, -30, 0, 10), UDim2.new(0, 15, 0, 35), Color3.fromRGB(30, 32, 40), 5)
            
            -- Slider fill
            local sliderFill = CreateRoundRect(sliderTrack, UDim2.new(0, 0, 1, 0), UDim2.new(0, 0, 0, 0), Colors.Primary, 5)
            
            -- Gradient on fill
            AddGradient(sliderFill, Colors.Primary, Colors.Secondary, 90)
            
            -- Slider knob (hexagon)
            local sliderKnob = CreateHexagon(sliderTrack, 18)
            sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
            sliderKnob.Position = UDim2.new(0, 0, 0.5, 0)
            sliderKnob.ImageColor3 = Colors.Text
            sliderKnob.ZIndex = 3
            
            -- Shadow for knob
            AddShadow(sliderKnob, 5)
            
            -- Set default value
            library.flags[options.flag] = options.default or slider.min
            
            -- Update slider visuals with animation
            local function updateSlider(value)
                value = math.clamp(value, slider.min, slider.max)
                library.flags[options.flag] = value
                
                local percent = (value - slider.min) / (slider.max - slider.min)
                
                -- Animate fill and knob
                TweenService:Create(sliderFill, TweenFast, {
                    Size = UDim2.new(percent, 0, 1, 0)
                }):Play()
                
                TweenService:Create(sliderKnob, TweenFast, {
                    Position = UDim2.new(percent, 0, 0.5, 0)
                }):Play()
                
                valueText.Text = tostring(math.floor(value * 10) / 10)
                
                if options.callback then
                    options.callback(value)
                end
            end
            
            -- Tactile interaction
            local dragging = false
            
            sliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    
                    -- Pulse animation
                    TweenService:Create(sliderKnob, TweenFast, {
                        Size = UDim2.fromOffset(22, 22) -- Grow
                    }):Play()
                end
            end)
            
            sliderTrack.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                    
                    -- Restore size
                    TweenService:Create(sliderKnob, TweenFast, {
                        Size = UDim2.fromOffset(18, 18) -- Shrink back
                    }):Play()
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = UserInputService:GetMouseLocation()
                    local sliderPos = sliderTrack.AbsolutePosition
                    local sliderSize = sliderTrack.AbsoluteSize
                    
                    local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
                    local value = slider.min + ((slider.max - slider.min) * relativeX)
                    updateSlider(value)
                end
            end)
            
            -- Initial update
            updateSlider(slider.default)
            table.insert(tab.elements, slider)
            return slider
        end
        
        -- Button with ripple effect
        function tab:AddButton(options)
            local button = {}
            button.text = options.text
            button.callback = options.callback
            button.section = options.section
            
            -- Create button container
            local buttonContainer = CreateRoundRect(tabContent, UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), Colors.Element, 8)
            
            -- Gradient effect
            AddGradient(buttonContainer, Colors.Element, Color3.fromRGB(40, 42, 50), 180)
            
            -- Button text
            local buttonText = Instance.new("TextLabel")
            buttonText.Size = UDim2.new(1, 0, 1, 0)
            buttonText.BackgroundTransparency = 1
            buttonText.Text = options.text
            buttonText.TextColor3 = Colors.Text
            buttonText.TextSize = 16
            buttonText.Font = Enum.Font.GothamSemibold
            buttonText.Parent = buttonContainer
            
            -- Hexagonal decoration
            local decoration1 = CreateHexagon(buttonContainer, 12)
            decoration1.Position = UDim2.new(0, 10, 0.5, -6)
            decoration1.ImageColor3 = Colors.Primary
            decoration1.ImageTransparency = 0.7
            
            local decoration2 = CreateHexagon(buttonContainer, 12)
            decoration2.Position = UDim2.new(1, -22, 0.5, -6)
            decoration2.ImageColor3 = Colors.Secondary
            decoration2.ImageTransparency = 0.7
            
            -- Create ripple effect function
            local function createRipple(x, y)
                local ripple = CreateRoundRect(buttonContainer, UDim2.new(0, 0, 0, 0), UDim2.new(0, x, 0, y), Colors.Primary, 100)
                ripple.AnchorPoint = Vector2.new(0.5, 0.5)
                ripple.ZIndex = 2
                ripple.BackgroundTransparency = 0.6
                
                -- Animate ripple
                TweenService:Create(ripple, TweenInfo.new(0.5), {
                    Size = UDim2.new(0, 300, 0, 300),
                    BackgroundTransparency = 1
                }):Play()
                
                delay(0.5, function()
                    ripple:Destroy()
                end)
            end
            
            -- Button click effect
            buttonContainer.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    -- Shrink effect
                    TweenService:Create(buttonContainer, TweenFast, {
                        Size = UDim2.new(0.98, 0, 0, 38),
                        Position = UDim2.new(0.01, 0, 0, 1)
                    }):Play()
                    
                    -- Ripple from mouse position
                    local mousePos = UserInputService:GetMouseLocation()
                    local buttonPos = buttonContainer.AbsolutePosition
                    local relativeX = mousePos.X - buttonPos.X
                    local relativeY = mousePos.Y - buttonPos.Y
                    createRipple(relativeX, relativeY)
                    
                    if options.callback then
                        options.callback()
                    end
                end
            end)
            
            buttonContainer.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    -- Restore size
                    TweenService:Create(buttonContainer, TweenFast, {
                        Size = UDim2.new(1, 0, 0, 40),
                        Position = UDim2.new(0, 0, 0, 0)
                    }):Play()
                end
            end)
            
            table.insert(tab.elements, button)
            return button
        end
        
        -- Section divider
        function tab:CreateSection(sectionName)
            local sectionContainer = CreateRoundRect(tabContent, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), Colors.DarkBG, 5)
            
            -- Section text
            local sectionText = Instance.new("TextLabel")
            sectionText.Size = UDim2.new(1, -20, 1, 0)
            sectionText.Position = UDim2.new(0, 15, 0, 0)
            sectionText.BackgroundTransparency = 1
            sectionText.Text = sectionName
            sectionText.TextColor3 = Colors.Secondary
            sectionText.TextSize = 14
            sectionText.Font = Enum.Font.GothamSemibold
            sectionText.TextXAlignment = Enum.TextXAlignment.Left
            sectionText.Parent = sectionContainer
            
            -- Decorative line
            local line = CreateRoundRect(sectionContainer, UDim2.new(1, -30, 0, 1), UDim2.new(0, 15, 0.8, 0), Colors.Primary, 0)
            AddGradient(line, Colors.Primary, Colors.Primary:Lerp(Colors.Secondary, 0.5), 90)
            
            return sectionContainer
        end
        
        -- Handle tab selection with animation
        tabButton.MouseButton1Click:Connect(function()
            library:SelectTab(tabName)
            
            -- Bubble animation
            TweenService:Create(tabIndicator, TweenFast, {
                Size = UDim2.fromOffset(12, 12),
                Position = UDim2.new(0, 8, 0.5, 0),
                ImageTransparency = 0.6
            }):Play()
            
            wait(0.1)
            
            TweenService:Create(tabIndicator, TweenFast, {
                Size = UDim2.fromOffset(8, 8),
                Position = UDim2.new(0, 10, 0.5, 0),
                ImageTransparency = 0
            }):Play()
        end)
        
        table.insert(library.tabs, tab)
        
        -- Size tab button based on text
        local textSize = game:GetService("TextService"):GetTextSize(
            tabName,
            14,
            Enum.Font.GothamSemibold,
            Vector2.new(math.huge, 36)
        )
        tabButton.Size = UDim2.new(0, textSize.X + 40, 0, 36)
        
        -- If this is the first tab, make it visible
        if #library.tabs == 1 then
            library:SelectTab(tabName)
        end
        
        return tab
    end
    
    -- Tab selection function with animation
    function library:SelectTab(tabName)
        for _, tab in pairs(library.tabs) do
            local isSelected = (tab.name == tabName)
            tab.content.Visible = isSelected
            
            if isSelected then
                TweenService:Create(tab.button, TweenFast, {
                    BackgroundColor3 = Colors.Primary
                }):Play()
                
                TweenService:Create(tab.indicator, TweenFast, {
                    ImageTransparency = 0
                }):Play()
                
                TweenService:Create(tab.button.TextLabel, TweenFast, {
                    TextColor3 = Colors.Text
                }):Play()
            else
                TweenService:Create(tab.button, TweenFast, {
                    BackgroundColor3 = Colors.Element
                }):Play()
                
                TweenService:Create(tab.indicator, TweenFast, {
                    ImageTransparency = 1
                }):Play()
                
                TweenService:Create(tab.button.TextLabel, TweenFast, {
                    TextColor3 = Colors.TextDark
                }):Play()
            end
        end
    end
    
    -- Keyboard toggle (Right Shift) with animation
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightShift then
            local isTweening = false
            
            if mainContainer.Position.Y.Offset == -200 then
                -- Slide in
                TweenService:Create(mainContainer, TweenMedium, {
                    Position = UDim2.new(0.5, -290, 0.5, -200)
                }):Play()
            else
                -- Slide out
                TweenService:Create(mainContainer, TweenMedium, {
                    Position = UDim2.new(0.5, -290, 0, -500)
                }):Play()
            end
        end
    end)
    
    -- Auto-tab size
    tabContainer.CanvasSize = UDim2.new(0, tabLayout.AbsoluteContentSize.X, 0, 0)
    
    return library
end

return Library
