-- SMAX V2 UI Library - Unique Visual Style
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Library = {}
Library.flags = {}
Library.connections = {}
Library.theme = {
    Background = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(110, 70, 200), -- Purple accent
    Secondary = Color3.fromRGB(40, 40, 60),
    TextColor = Color3.fromRGB(240, 240, 255),
    DarkText = Color3.fromRGB(180, 180, 200),
    Highlight = Color3.fromRGB(140, 90, 230)
}

-- Corner radius
local CORNER_RADIUS = UDim.new(0, 8)

-- Utility functions
local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or CORNER_RADIUS
    corner.Parent = parent
    return corner
end

local function createGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    })
    gradient.Rotation = rotation or 45
    gradient.Parent = parent
    return gradient
end

local function createStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

function Library:Init(title)
    local library = {}
    library.tabs = {}
    library.flags = Library.flags
    library.connections = Library.connections
    
    -- Create main UI with shadow
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SMAX_V2"
    ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Create shadow effect
    local shadowFrame = Instance.new("Frame")
    shadowFrame.Name = "Shadow"
    shadowFrame.Size = UDim2.new(0, 520, 0, 370)
    shadowFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    shadowFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadowFrame.BackgroundTransparency = 0.6
    shadowFrame.BorderSizePixel = 0
    shadowFrame.Parent = ScreenGui
    createCorner(shadowFrame, UDim.new(0, 12))
    
    -- Main frame
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 500, 0, 350)
    main.Position = UDim2.new(0.5, -250, 0.5, -175)
    main.BackgroundColor3 = Library.theme.Background
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.ZIndex = 2
    main.Parent = ScreenGui
    createCorner(main)
    
    -- Animated accent bar at top
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(1, 0, 0, 2)
    accentBar.BackgroundColor3 = Library.theme.Accent
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 3
    accentBar.Parent = main
    
    -- Create animated accent gradient
    local accentGradient = createGradient(
        accentBar, 
        Library.theme.Accent, 
        Library.theme.Highlight,
        0
    )
    
    -- Animate gradient
    task.spawn(function()
        local offset = 0
        while true do
            accentGradient.Offset = Vector2.new(offset, 0)
            offset = (offset + 0.005) % 1
            RunService.RenderStepped:Wait()
        end
    end)
    
    -- Create title bar with unique style
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Library.theme.Secondary
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 2
    titleBar.Parent = main
    createCorner(titleBar, UDim.new(0, 8))
    
    -- Create a top mask to make top corners round but bottom flat
    local topMask = Instance.new("Frame")
    topMask.Name = "TopMask"
    topMask.Size = UDim2.new(1, 0, 0.5, 0)
    topMask.Position = UDim2.new(0, 0, 0.5, 0)
    topMask.BackgroundColor3 = Library.theme.Secondary
    topMask.BorderSizePixel = 0
    topMask.ZIndex = 2
    topMask.Parent = titleBar
    
    -- Create logo circle
    local logoCircle = Instance.new("Frame")
    logoCircle.Name = "Logo"
    logoCircle.Size = UDim2.new(0, 26, 0, 26)
    logoCircle.Position = UDim2.new(0, 12, 0, 7)
    logoCircle.BackgroundColor3 = Library.theme.Accent
    logoCircle.BorderSizePixel = 0
    logoCircle.ZIndex = 3
    logoCircle.Parent = titleBar
    createCorner(logoCircle, UDim.new(1, 0)) -- Make it circular
    
    -- Logo inner
    local logoInner = Instance.new("Frame")
    logoInner.Name = "LogoInner"
    logoInner.Size = UDim2.new(0.7, 0, 0.7, 0)
    logoInner.Position = UDim2.new(0.15, 0, 0.15, 0)
    logoInner.BackgroundColor3 = Library.theme.Background
    logoInner.BorderSizePixel = 0
    logoInner.ZIndex = 3
    logoInner.Parent = logoCircle
    createCorner(logoInner, UDim.new(1, 0))
    
    -- Create "S" text inside logo
    local logoText = Instance.new("TextLabel")
    logoText.Name = "LogoText"
    logoText.Size = UDim2.new(1, 0, 1, 0)
    logoText.BackgroundTransparency = 1
    logoText.Text = "S"
    logoText.TextColor3 = Library.theme.Accent
    logoText.TextSize = 16
    logoText.Font = Enum.Font.GothamBold
    logoText.ZIndex = 4
    logoText.Parent = logoInner
    
    -- Title text with glow effect
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 50, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Library.theme.TextColor
    titleText.TextSize = 22
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Text = title
    titleText.ZIndex = 3
    titleText.Parent = titleBar
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 5)
    closeBtn.BackgroundColor3 = Library.theme.Background
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Library.theme.DarkText
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.ZIndex = 3
    closeBtn.Parent = titleBar
    createCorner(closeBtn, UDim.new(0, 6))
    
    -- Close button hover effect
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(220, 70, 70),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
    end)
    
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Library.theme.Background,
            TextColor3 = Library.theme.DarkText
        }):Play()
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        main.Visible = false
        shadowFrame.Visible = false
    end)
    
    -- Create container for tabs and content
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 1, -40)
    container.Position = UDim2.new(0, 0, 0, 40)
    container.BackgroundColor3 = Library.theme.Background
    container.BorderSizePixel = 0
    container.ZIndex = 2
    container.Parent = main
    
    -- Create stylish tab sidebar
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 130, 1, 0)
    tabContainer.BackgroundColor3 = Library.theme.Secondary
    tabContainer.BorderSizePixel = 0
    tabContainer.ZIndex = 2
    tabContainer.Parent = container
    
    -- Tab list with padding
    local tabList = Instance.new("ScrollingFrame")
    tabList.Name = "TabList"
    tabList.Size = UDim2.new(1, -10, 1, -10)
    tabList.Position = UDim2.new(0, 5, 0, 5)
    tabList.BackgroundTransparency = 1
    tabList.BorderSizePixel = 0
    tabList.ScrollBarThickness = 2
    tabList.ScrollBarImageColor3 = Library.theme.Accent
    tabList.ZIndex = 2
    tabList.Parent = tabContainer
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 5)
    tabPadding.PaddingLeft = UDim.new(0, 5)
    tabPadding.PaddingRight = UDim.new(0, 5)
    tabPadding.Parent = tabList
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 8)
    tabListLayout.Parent = tabList
    
    -- Content container with rounded corners
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -140, 1, -10)
    contentContainer.Position = UDim2.new(0, 135, 0, 5)
    contentContainer.BackgroundColor3 = Library.theme.Secondary
    contentContainer.BorderSizePixel = 0
    contentContainer.ZIndex = 2
    contentContainer.Parent = container
    createCorner(contentContainer)
    
    -- Store UI elements in library
    library.ScreenGui = ScreenGui
    library.main = main
    library.shadow = shadowFrame
    library.container = container
    library.tabList = tabList
    library.contentContainer = contentContainer
    
    -- Create tab function with custom styling
    function library:CreateTab(tabName)
        local tab = {}
        tab.name = tabName
        tab.elements = {}
        
        -- Create tab button with indicator
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName
        tabButton.Size = UDim2.new(1, 0, 0, 36)
        tabButton.BackgroundColor3 = Library.theme.Background
        tabButton.BackgroundTransparency = 0.6
        tabButton.Text = ""
        tabButton.ZIndex = 2
        tabButton.Parent = tabList
        createCorner(tabButton)
        
        -- Indicator bar
        local indicator = Instance.new("Frame")
        indicator.Name = "Indicator"
        indicator.Size = UDim2.new(0, 3, 0.8, 0)
        indicator.Position = UDim2.new(0, 0, 0.1, 0)
        indicator.BackgroundColor3 = Library.theme.Accent
        indicator.BorderSizePixel = 0
        indicator.Visible = false
        indicator.ZIndex = 3
        indicator.Parent = tabButton
        
        -- Tab icon (placeholder - would need actual icons)
        local tabIcon = Instance.new("TextLabel")
        tabIcon.Name = "Icon"
        tabIcon.Size = UDim2.new(0, 24, 0, 24)
        tabIcon.Position = UDim2.new(0, 12, 0.5, -12)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Text = string.sub(tabName, 1, 1)
        tabIcon.TextColor3 = Library.theme.TextColor
        tabIcon.TextSize = 16
        tabIcon.Font = Enum.Font.GothamBold
        tabIcon.ZIndex = 3
        tabIcon.Parent = tabButton
        
        -- Tab text
        local tabText = Instance.new("TextLabel")
        tabText.Name = "Text"
        tabText.Size = UDim2.new(1, -50, 1, 0)
        tabText.Position = UDim2.new(0, 40, 0, 0)
        tabText.BackgroundTransparency = 1
        tabText.Text = tabName
        tabText.TextColor3 = Library.theme.DarkText
        tabText.TextSize = 14
        tabText.Font = Enum.Font.GothamSemibold
        tabText.TextXAlignment = Enum.TextXAlignment.Left
        tabText.ZIndex = 3
        tabText.Parent = tabButton
        
        -- Create tab content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, -15, 1, -15)
        tabContent.Position = UDim2.new(0, 8, 0, 8)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 3
        tabContent.ScrollBarImageColor3 = Library.theme.Accent
        tabContent.Visible = false
        tabContent.ZIndex = 2
        tabContent.Parent = contentContainer
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.Parent = tabContent
        
        -- Auto-size content
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        tab.button = tabButton
        tab.content = tabContent
        tab.indicator = indicator
        tab.icon = tabIcon
        tab.text = tabText
        
        -- Section function to organize elements
        function tab:AddSection(title)
            local section = {}
            
            -- Create section frame
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = title .. "Section"
            sectionFrame.Size = UDim2.new(1, 0, 0, 36)
            sectionFrame.BackgroundColor3 = Library.theme.Background
            sectionFrame.BackgroundTransparency = 0.4
            sectionFrame.ZIndex = 2
            sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            sectionFrame.Parent = tabContent
            createCorner(sectionFrame)
            
            -- Section title
            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Name = "Title"
            sectionTitle.Size = UDim2.new(1, -16, 0, 30)
            sectionTitle.Position = UDim2.new(0, 8, 0, 0)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Text = title
            sectionTitle.TextColor3 = Library.theme.Accent
            sectionTitle.TextSize = 14
            sectionTitle.Font = Enum.Font.GothamBold
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.ZIndex = 3
            sectionTitle.Parent = sectionFrame
            
            -- Container for section elements
            local sectionContainer = Instance.new("Frame")
            sectionContainer.Name = "Container"
            sectionContainer.Size = UDim2.new(1, -16, 0, 0)
            sectionContainer.Position = UDim2.new(0, 8, 0, 30)
            sectionContainer.BackgroundTransparency = 1
            sectionContainer.ZIndex = 2
            sectionContainer.AutomaticSize = Enum.AutomaticSize.Y
            sectionContainer.Parent = sectionFrame
            
            local sectionLayout = Instance.new("UIListLayout")
            sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionLayout.Padding = UDim.new(0, 8)
            sectionLayout.Parent = sectionContainer
            
            -- Auto-size section
            sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                sectionContainer.Size = UDim2.new(1, -16, 0, sectionLayout.AbsoluteContentSize.Y)
                sectionFrame.Size = UDim2.new(1, 0, 0, sectionContainer.Size.Y.Offset + 38)
            end)
            
            section.frame = sectionFrame
            section.container = sectionContainer
            
            return sectionContainer
        end
        
        -- Toggle function
        function tab:AddToggle(options)
            local container = options.section or tabContent
            local toggle = {}
            toggle.text = options.text
            toggle.flag = options.flag
            toggle.callback = options.callback
            
            -- Create toggle container
            local toggleContainer = Instance.new("Frame")
            toggleContainer.Name = options.text
            toggleContainer.Size = UDim2.new(1, 0, 0, 36)
            toggleContainer.BackgroundColor3 = Library.theme.Background
            toggleContainer.BackgroundTransparency = 0.7
            toggleContainer.ZIndex = 2
            toggleContainer.Parent = container
            createCorner(toggleContainer, UDim.new(0, 6))
            
            local toggleText = Instance.new("TextLabel")
            toggleText.Name = "Text"
            toggleText.Size = UDim2.new(1, -60, 1, 0)
            toggleText.Position = UDim2.new(0, 12, 0, 0)
            toggleText.BackgroundTransparency = 1
            toggleText.TextColor3 = Library.theme.TextColor
            toggleText.TextSize = 14
            toggleText.Font = Enum.Font.GothamMedium
            toggleText.Text = options.text
            toggleText.TextXAlignment = Enum.TextXAlignment.Left
            toggleText.ZIndex = 3
            toggleText.Parent = toggleContainer
            
            -- Create modern toggle button
            local toggleButton = Instance.new("Frame")
            toggleButton.Name = "ToggleButton"
            toggleButton.Size = UDim2.new(0, 40, 0, 22)
            toggleButton.Position = UDim2.new(1, -50, 0.5, -11)
            toggleButton.BackgroundColor3 = Library.theme.Background
            toggleButton.BorderSizePixel = 0
            toggleButton.ZIndex = 3
            toggleButton.Parent = toggleContainer
            createCorner(toggleButton, UDim.new(1, 0))
            createStroke(toggleButton, Library.theme.Accent, 1.5)
            
            local toggleCircle = Instance.new("Frame")
            toggleCircle.Name = "Circle"
            toggleCircle.Size = UDim2.new(0, 16, 0, 16)
            toggleCircle.Position = UDim2.new(0, 3, 0.5, -8)
            toggleCircle.BackgroundColor3 = Library.theme.DarkText
            toggleCircle.BorderSizePixel = 0
            toggleCircle.ZIndex = 4
            toggleCircle.Parent = toggleButton
            createCorner(toggleCircle, UDim.new(1, 0))
            
            -- Hitbox for the toggle
            local toggleHitbox = Instance.new("TextButton")
            toggleHitbox.Name = "Hitbox"
            toggleHitbox.Size = UDim2.new(1, 0, 1, 0)
            toggleHitbox.BackgroundTransparency = 1
            toggleHitbox.Text = ""
            toggleHitbox.ZIndex = 4
            toggleHitbox.Parent = toggleContainer
            
            -- Set default state
            library.flags[options.flag] = options.default or false
            
            -- Update toggle visuals
            local function updateToggle()
                local enabled = library.flags[options.flag]
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                
                if enabled then
                    TweenService:Create(toggleButton, tweenInfo, {
                        BackgroundColor3 = Library.theme.Accent
                    }):Play()
                    TweenService:Create(toggleCircle, tweenInfo, {
                        Position = UDim2.new(0, 21, 0.5, -8),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    }):Play()
                else
                    TweenService:Create(toggleButton, tweenInfo, {
                        BackgroundColor3 = Library.theme.Background
                    }):Play()
                    TweenService:Create(toggleCircle, tweenInfo, {
                        Position = UDim2.new(0, 3, 0.5, -8),
                        BackgroundColor3 = Library.theme.DarkText
                    }):Play()
                end
            end
            
            -- Handle click
            toggleHitbox.MouseButton1Click:Connect(function()
                library.flags[options.flag] = not library.flags[options.flag]
                updateToggle()
                
                if options.callback then
                    options.callback(library.flags[options.flag])
                end
            end)
            
            -- Initial update
            updateToggle()
            return toggle
        end
        
        -- Slider function
        function tab:AddSlider(options)
            local container = options.section or tabContent
            local slider = {}
            slider.text = options.text
            slider.flag = options.flag
            slider.min = options.min or 0
            slider.max = options.max or 100
            slider.default = options.default or slider.min
            slider.callback = options.callback
            
            -- Create slider container
            local sliderContainer = Instance.new("Frame")
            sliderContainer.Name = options.text
            sliderContainer.Size = UDim2.new(1, 0, 0, 56)
            sliderContainer.BackgroundColor3 = Library.theme.Background
            sliderContainer.BackgroundTransparency = 0.7
            sliderContainer.ZIndex = 2
            sliderContainer.Parent = container
            createCorner(sliderContainer, UDim.new(0, 6))
            
            local sliderText = Instance.new("TextLabel")
            sliderText.Name = "Text"
            sliderText.Size = UDim2.new(1, -16, 0, 20)
            sliderText.Position = UDim2.new(0, 12, 0, 8)
            sliderText.BackgroundTransparency = 1
            sliderText.TextColor3 = Library.theme.TextColor
            sliderText.TextSize = 14
            sliderText.Font = Enum.Font.GothamMedium
            sliderText.Text = options.text
            sliderText.TextXAlignment = Enum.TextXAlignment.Left
            sliderText.ZIndex = 3
            sliderText.Parent = sliderContainer
            
            local valueText = Instance.new("TextLabel")
            valueText.Name = "Value"
            valueText.Size = UDim2.new(0, 60, 0, 20)
            valueText.Position = UDim2.new(1, -70, 0, 8)
            valueText.BackgroundTransparency = 1
            valueText.TextColor3 = Library.theme.Accent
            valueText.TextSize = 14
            valueText.Font = Enum.Font.GothamSemibold
            valueText.Text = tostring(slider.default)
            valueText.TextXAlignment = Enum.TextXAlignment.Right
            valueText.ZIndex = 3
            valueText.Parent = sliderContainer
            
            local sliderBg = Instance.new("Frame")
            sliderBg.Name = "SliderBg"
            sliderBg.Size = UDim2.new(1, -24, 0, 8)
            sliderBg.Position = UDim2.new(0, 12, 1, -16)
            sliderBg.BackgroundColor3 = Library.theme.Background
            sliderBg.BorderSizePixel = 0
            sliderBg.ZIndex = 3
            sliderBg.Parent = sliderContainer
            createCorner(sliderBg, UDim.new(1, 0))
            createStroke(sliderBg, Library.theme.DarkText, 1)
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Name = "Fill"
            sliderFill.Size = UDim2.new(0, 0, 1, 0)
            sliderFill.BackgroundColor3 = Library.theme.Accent
            sliderFill.BorderSizePixel = 0
            sliderFill.ZIndex = 4
            sliderFill.Parent = sliderBg
            createCorner(sliderFill, UDim.new(1, 0))
            
            local sliderIndicator = Instance.new("Frame")
            sliderIndicator.Name = "Indicator"
            sliderIndicator.Size = UDim2.new(0, 12, 0, 12)
            sliderIndicator.Position = UDim2.new(0, -6, 0.5, -6)
            sliderIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            sliderIndicator.BorderSizePixel = 0
            sliderIndicator.AnchorPoint = Vector2.new(0, 0.5)
            sliderIndicator.ZIndex = 5
            sliderIndicator.Parent = sliderFill
            createCorner(sliderIndicator, UDim.new(1, 0))
            
            -- Set default value
            library.flags[options.flag] = options.default or slider.min
            
            -- Update slider visuals
            local function updateSlider(value, noCallback)
                value = math.clamp(value, slider.min, slider.max)
                library.flags[options.flag] = value
                
                local percent = (value - slider.min) / (slider.max - slider.min)
                
                -- Tween the fill and indicator
                local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(sliderFill, tweenInfo, {
                    Size = UDim2.new(percent, 0, 1, 0)
                }):Play()
                
                valueText.Text = tostring(math.floor(value * 10) / 10)
                
                if options.callback and not noCallback then
                    options.callback(value)
                end
            end
            
            -- Handle input
            local dragging = false
            
            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    
                    local mousePos = UserInputService:GetMouseLocation()
                    local sliderPos = sliderBg.AbsolutePosition
                    local sliderSize = sliderBg.AbsoluteSize
                    
                    local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
                    local value = slider.min + ((slider.max - slider.min) * relativeX)
                    updateSlider(value)
                end
            end)
            
            sliderBg.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = UserInputService:GetMouseLocation()
                    local sliderPos = sliderBg.AbsolutePosition
                    local sliderSize = sliderBg.AbsoluteSize
                    
                    local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
                    local value = slider.min + ((slider.max - slider.min) * relativeX)
                    updateSlider(value)
                end
            end)
            
            -- Initial update
            updateSlider(slider.default, true)
            return slider
        end
        
        -- Button function
        function tab:AddButton(options)
            local container = options.section or tabContent
            local button = {}
            button.text = options.text
            button.callback = options.callback
            
            -- Create button container
            local buttonContainer = Instance.new("Frame")
            buttonContainer.Name = options.text
            buttonContainer.Size = UDim2.new(1, 0, 0, 40)
            buttonContainer.BackgroundTransparency = 1
            buttonContainer.ZIndex = 2
            buttonContainer.Parent = container
            
            local buttonElement = Instance.new("TextButton")
            buttonElement.Name = "Button"
            buttonElement.Size = UDim2.new(1, 0, 1, 0)
            buttonElement.BackgroundColor3 = Library.theme.Secondary
            buttonElement.BorderSizePixel = 0
            buttonElement.Text = ""
            buttonElement.ZIndex = 3
            buttonElement.ClipsDescendants = true
            buttonElement.AutoButtonColor = false
            buttonElement.Parent = buttonContainer
            createCorner(buttonElement, UDim.new(0, 6))
            createStroke(buttonElement, Library.theme.Accent, 1)
            
            local buttonText = Instance.new("TextLabel")
            buttonText.Name = "Text"
            buttonText.Size = UDim2.new(1, 0, 1, 0)
            buttonText.BackgroundTransparency = 1
            buttonText.Text = options.text
            buttonText.TextColor3 = Library.theme.TextColor
            buttonText.TextSize = 14
            buttonText.Font = Enum.Font.GothamSemibold
            buttonText.ZIndex = 4
            buttonText.Parent = buttonElement
            
            -- Create ripple effect
            local function createRipple(x, y)
                local ripple = Instance.new("Frame")
                ripple.Name = "Ripple"
                ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ripple.BackgroundTransparency = 0.7
                ripple.BorderSizePixel = 0
                ripple.Position = UDim2.new(0, x, 0, y)
                ripple.Size = UDim2.new(0, 0, 0, 0)
                ripple.AnchorPoint = Vector2.new(0.5, 0.5)
                ripple.ZIndex = 3
                createCorner(ripple, UDim.new(1, 0))
                ripple.Parent = buttonElement
                
                local maxSize = math.max(buttonElement.AbsoluteSize.X, buttonElement.AbsoluteSize.Y) * 2
                
                TweenService:Create(ripple, TweenInfo.new(0.5), {
                    Size = UDim2.new(0, maxSize, 0, maxSize),
                    BackgroundTransparency = 1
                }):Play()
                
                task.delay(0.5, function()
                    ripple:Destroy()
                end)
            end
            
            -- Handle click with ripple effect
            buttonElement.MouseButton1Down:Connect(function(x, y)
                createRipple(x - buttonElement.AbsolutePosition.X, y - buttonElement.AbsolutePosition.Y)
                
                TweenService:Create(buttonElement, TweenInfo.new(0.2), {
                    BackgroundColor3 = Library.theme.Accent
                }):Play()
            end)
            
            buttonElement.MouseButton1Up:Connect(function()
                TweenService:Create(buttonElement, TweenInfo.new(0.2), {
                    BackgroundColor3 = Library.theme.Secondary
                }):Play()
                
                if options.callback then
                    options.callback()
                end
            end)
            
            buttonElement.MouseLeave:Connect(function()
                TweenService:Create(buttonElement, TweenInfo.new(0.2), {
                    BackgroundColor3 = Library.theme.Secondary
                }):Play()
            end)
            
            return button
        end
        
        -- Handle tab selection with animation
        tabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(library.tabs) do
                local isSelected = (t.name == tabName)
                
                -- Animate tab buttons
                TweenService:Create(t.indicator, TweenInfo.new(0.3), {
                    Visible = isSelected
                }):Play()
                
                TweenService:Create(t.text, TweenInfo.new(0.3), {
                    TextColor3 = isSelected and Library.theme.TextColor or Library.theme.DarkText
                }):Play()
                
                TweenService:Create(t.button, TweenInfo.new(0.3), {
                    BackgroundTransparency = isSelected and 0 or 0.6
                }):Play()
                
                -- Show/hide content
                t.content.Visible = isSelected
            end
        end)
        
        table.insert(library.tabs, tab)
        
        -- If this is the first tab, make it visible
        if #library.tabs == 1 then
            tabContent.Visible = true
            indicator.Visible = true
            tabText.TextColor3 = Library.theme.TextColor
            tabButton.BackgroundTransparency = 0
        end
        
        return tab
    end
    
    -- Tab selection function
    function library:SelectTab(tabName)
        for _, tab in pairs(library.tabs) do
            local isSelected = (tab.name == tabName)
            tab.content.Visible = isSelected
            tab.indicator.Visible = isSelected
            tab.text.TextColor3 = isSelected and Library.theme.TextColor or Library.theme.DarkText
            tab.button.BackgroundTransparency = isSelected and 0 or 0.6
        end
    end
    
    -- Keyboard toggle (Right Shift)
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightShift then
            main.Visible = not main.Visible
            shadowFrame.Visible = main.Visible
        end
    end)
    
    return library
end

return Library
