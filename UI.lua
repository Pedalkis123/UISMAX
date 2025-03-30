-- Simple UI Library for SMAX V2
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Library = {}
Library.flags = {}
Library.connections = {}

function Library:Init(title)
    local library = {}
    library.tabs = {}
    library.flags = Library.flags
    library.connections = Library.connections
    
    -- Create main UI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SMAX_V2"
    ScreenGui.Parent = game:GetService("CoreGui")
    
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 500, 0, 350)
    main.Position = UDim2.new(0.5, -250, 0.5, -175)
    main.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = ScreenGui
    
    -- Create title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main
    
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -10, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 18
    titleText.Font = Enum.Font.SourceSansBold
    titleText.Text = title
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Create container for tabs and content
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 1, -30)
    container.Position = UDim2.new(0, 0, 0, 30)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    container.BorderSizePixel = 0
    container.Parent = main
    
    -- Create tab sidebar
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 120, 1, 0)
    tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = container
    
    local tabList = Instance.new("ScrollingFrame")
    tabList.Name = "TabList"
    tabList.Size = UDim2.new(1, 0, 1, 0)
    tabList.BackgroundTransparency = 1
    tabList.ScrollBarThickness = 0
    tabList.Parent = tabContainer
    
    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Parent = tabList
    
    -- Create content area
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -120, 1, 0)
    contentContainer.Position = UDim2.new(0, 120, 0, 0)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = container
    
    -- Store UI elements in library
    library.ScreenGui = ScreenGui
    library.main = main
    library.container = container
    library.tabList = tabList
    library.contentContainer = contentContainer
    
    -- Create tab function
    function library:CreateTab(tabName)
        local tab = {}
        tab.name = tabName
        tab.elements = {}
        
        -- Create tab button
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName
        tabButton.Size = UDim2.new(1, 0, 0, 30)
        tabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        tabButton.BorderSizePixel = 0
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.SourceSans
        tabButton.Parent = tabList
        
        -- Create tab content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.ScrollBarThickness = 4
        tabContent.Visible = false
        tabContent.Parent = contentContainer
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 10)
        contentLayout.Parent = tabContent
        
        tab.button = tabButton
        tab.content = tabContent
        
        -- Toggle function
        function tab:AddToggle(options)
            local toggle = {}
            toggle.text = options.text
            toggle.flag = options.flag
            toggle.callback = options.callback
            
            -- Create toggle container
            local toggleContainer = Instance.new("Frame")
            toggleContainer.Name = options.text
            toggleContainer.Size = UDim2.new(1, -20, 0, 30)
            toggleContainer.Position = UDim2.new(0, 10, 0, 0)
            toggleContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            toggleContainer.Parent = tabContent
            
            local toggleText = Instance.new("TextLabel")
            toggleText.Name = "Text"
            toggleText.Size = UDim2.new(1, -50, 1, 0)
            toggleText.Position = UDim2.new(0, 10, 0, 0)
            toggleText.BackgroundTransparency = 1
            toggleText.TextColor3 = Color3.fromRGB(200, 200, 200)
            toggleText.TextSize = 14
            toggleText.Font = Enum.Font.SourceSans
            toggleText.Text = options.text
            toggleText.TextXAlignment = Enum.TextXAlignment.Left
            toggleText.Parent = toggleContainer
            
            local toggleButton = Instance.new("TextButton")
            toggleButton.Name = "Button"
            toggleButton.Size = UDim2.new(0, 40, 0, 20)
            toggleButton.Position = UDim2.new(1, -50, 0.5, -10)
            toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            toggleButton.Text = ""
            toggleButton.Parent = toggleContainer
            
            local toggleCircle = Instance.new("Frame")
            toggleCircle.Name = "Circle"
            toggleCircle.Size = UDim2.new(0, 16, 0, 16)
            toggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
            toggleCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            toggleCircle.BorderSizePixel = 0
            toggleCircle.Parent = toggleButton
            
            -- Set default state
            library.flags[options.flag] = options.default or false
            
            -- Update toggle visuals
            local function updateToggle()
                local enabled = library.flags[options.flag]
                local position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                local color = enabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 65)
                
                toggleCircle.Position = position
                toggleButton.BackgroundColor3 = color
            end
            
            -- Handle click
            toggleButton.MouseButton1Click:Connect(function()
                library.flags[options.flag] = not library.flags[options.flag]
                updateToggle()
                
                if options.callback then
                    options.callback(library.flags[options.flag])
                end
            end)
            
            -- Initial update
            updateToggle()
            
            -- Add to elements
            toggle.container = toggleContainer
            table.insert(tab.elements, toggle)
            return toggle
        end
        
        -- Slider function
        function tab:AddSlider(options)
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
            sliderContainer.Size = UDim2.new(1, -20, 0, 45)
            sliderContainer.Position = UDim2.new(0, 10, 0, 0)
            sliderContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            sliderContainer.Parent = tabContent
            
            local sliderText = Instance.new("TextLabel")
            sliderText.Name = "Text"
            sliderText.Size = UDim2.new(1, -60, 0, 20)
            sliderText.Position = UDim2.new(0, 10, 0, 5)
            sliderText.BackgroundTransparency = 1
            sliderText.TextColor3 = Color3.fromRGB(200, 200, 200)
            sliderText.TextSize = 14
            sliderText.Font = Enum.Font.SourceSans
            sliderText.Text = options.text
            sliderText.TextXAlignment = Enum.TextXAlignment.Left
            sliderText.Parent = sliderContainer
            
            local valueText = Instance.new("TextLabel")
            valueText.Name = "Value"
            valueText.Size = UDim2.new(0, 50, 0, 20)
            valueText.Position = UDim2.new(1, -60, 0, 5)
            valueText.BackgroundTransparency = 1
            valueText.TextColor3 = Color3.fromRGB(200, 200, 200)
            valueText.TextSize = 14
            valueText.Font = Enum.Font.SourceSans
            valueText.Text = tostring(slider.default)
            valueText.TextXAlignment = Enum.TextXAlignment.Right
            valueText.Parent = sliderContainer
            
            local sliderBg = Instance.new("Frame")
            sliderBg.Name = "SliderBg"
            sliderBg.Size = UDim2.new(1, -20, 0, 10)
            sliderBg.Position = UDim2.new(0, 10, 0, 30)
            sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            sliderBg.BorderSizePixel = 0
            sliderBg.Parent = sliderContainer
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Name = "Fill"
            sliderFill.Size = UDim2.new(0, 0, 1, 0)
            sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBg
            
            -- Set default value
            library.flags[options.flag] = options.default or slider.min
            
            -- Update slider visuals
            local function updateSlider(value)
                value = math.clamp(value, slider.min, slider.max)
                library.flags[options.flag] = value
                
                local percent = (value - slider.min) / (slider.max - slider.min)
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                valueText.Text = tostring(math.floor(value * 10) / 10)
                
                if options.callback then
                    options.callback(value)
                end
            end
            
            -- Handle input
            local dragging = false
            
            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
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
            updateSlider(slider.default)
            
            -- Add to elements
            slider.container = sliderContainer
            table.insert(tab.elements, slider)
            return slider
        end
        
        -- Button function
        function tab:AddButton(options)
            local button = {}
            button.text = options.text
            button.callback = options.callback
            
            -- Create button container
            local buttonContainer = Instance.new("Frame")
            buttonContainer.Name = options.text
            buttonContainer.Size = UDim2.new(1, -20, 0, 30)
            buttonContainer.Position = UDim2.new(0, 10, 0, 0)
            buttonContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            buttonContainer.Parent = tabContent
            
            local buttonElement = Instance.new("TextButton")
            buttonElement.Name = "Button"
            buttonElement.Size = UDim2.new(1, 0, 1, 0)
            buttonElement.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            buttonElement.BorderSizePixel = 0
            buttonElement.Text = options.text
            buttonElement.TextColor3 = Color3.fromRGB(200, 200, 200)
            buttonElement.TextSize = 14
            buttonElement.Font = Enum.Font.SourceSans
            buttonElement.Parent = buttonContainer
            
            -- Handle click
            buttonElement.MouseButton1Click:Connect(function()
                if options.callback then
                    options.callback()
                end
            end)
            
            -- Add to elements
            button.container = buttonContainer
            table.insert(tab.elements, button)
            return button
        end
        
        -- New Dropdown function
        function tab:AddDropdown(options)
            local dropdown = {}
            dropdown.text = options.text
            dropdown.flag = options.flag
            dropdown.options = options.options or {}
            dropdown.callback = options.callback
            dropdown.selected = options.default or dropdown.options[1]
            dropdown.open = false
            
            -- Create dropdown container
            local dropdownContainer = Instance.new("Frame")
            dropdownContainer.Name = options.text
            dropdownContainer.Size = UDim2.new(1, -20, 0, 30)
            dropdownContainer.Position = UDim2.new(0, 10, 0, 0)
            dropdownContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            dropdownContainer.ClipsDescendants = true
            dropdownContainer.Parent = tabContent
            
            local dropdownText = Instance.new("TextLabel")
            dropdownText.Name = "Text"
            dropdownText.Size = UDim2.new(1, -20, 0, 30)
            dropdownText.Position = UDim2.new(0, 10, 0, 0)
            dropdownText.BackgroundTransparency = 1
            dropdownText.TextColor3 = Color3.fromRGB(200, 200, 200)
            dropdownText.TextSize = 14
            dropdownText.Font = Enum.Font.SourceSans
            dropdownText.Text = options.text
            dropdownText.TextXAlignment = Enum.TextXAlignment.Left
            dropdownText.Parent = dropdownContainer
            
            local selectedText = Instance.new("TextLabel")
            selectedText.Name = "Selected"
            selectedText.Size = UDim2.new(0, 100, 0, 30)
            selectedText.Position = UDim2.new(1, -110, 0, 0)
            selectedText.BackgroundTransparency = 1
            selectedText.TextColor3 = Color3.fromRGB(0, 170, 255)
            selectedText.TextSize = 14
            selectedText.Font = Enum.Font.SourceSans
            selectedText.Text = dropdown.selected or "None"
            selectedText.TextXAlignment = Enum.TextXAlignment.Right
            selectedText.Parent = dropdownContainer
            
            local dropdownArrow = Instance.new("TextButton")
            dropdownArrow.Name = "Arrow"
            dropdownArrow.Size = UDim2.new(0, 30, 0, 30)
            dropdownArrow.Position = UDim2.new(1, -30, 0, 0)
            dropdownArrow.BackgroundTransparency = 1
            dropdownArrow.Text = "▼"
            dropdownArrow.TextColor3 = Color3.fromRGB(200, 200, 200)
            dropdownArrow.TextSize = 14
            dropdownArrow.Font = Enum.Font.SourceSans
            dropdownArrow.Parent = dropdownContainer
            
            local optionList = Instance.new("Frame")
            optionList.Name = "Options"
            optionList.Size = UDim2.new(1, 0, 0, 0)
            optionList.Position = UDim2.new(0, 0, 0, 30)
            optionList.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            optionList.BorderSizePixel = 0
            optionList.Visible = false
            optionList.ClipsDescendants = true
            optionList.Parent = dropdownContainer
            
            local optionListLayout = Instance.new("UIListLayout")
            optionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optionListLayout.Parent = optionList
            
            -- Set default value
            library.flags[options.flag] = dropdown.selected
            
            -- Create option elements
            local function updateOptions()
                -- Clear existing options
                for i, child in pairs(optionList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                -- Add options
                for i, optionValue in pairs(dropdown.options) do
                    local option = Instance.new("TextButton")
                    option.Name = optionValue
                    option.Size = UDim2.new(1, 0, 0, 25)
                    option.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                    option.BorderSizePixel = 0
                    option.Text = optionValue
                    option.TextColor3 = (optionValue == dropdown.selected) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(200, 200, 200)
                    option.TextSize = 14
                    option.Font = Enum.Font.SourceSans
                    option.Parent = optionList
                    
                    option.MouseButton1Click:Connect(function()
                        dropdown.selected = optionValue
                        library.flags[options.flag] = optionValue
                        selectedText.Text = optionValue
                        
                        -- Close dropdown
                        dropdown:Toggle(false)
                        
                        if options.callback then
                            options.callback(optionValue)
                        end
                        
                        -- Update option colors
                        for _, child in pairs(optionList:GetChildren()) do
                            if child:IsA("TextButton") then
                                child.TextColor3 = (child.Name == optionValue) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(200, 200, 200)
                            end
                        end
                    end)
                end
                
                -- Update size based on options
                optionList.Size = UDim2.new(1, 0, 0, #dropdown.options * 25)
            end
            
            -- Toggle dropdown
            function dropdown:Toggle(state)
                dropdown.open = state
                optionList.Visible = state
                dropdownArrow.Text = state and "▲" or "▼"
                
                if state then
                    dropdownContainer.Size = UDim2.new(1, -20, 0, 30 + optionList.Size.Y.Offset)
                else
                    dropdownContainer.Size = UDim2.new(1, -20, 0, 30)
                end
            end
            
            -- Handle click
            dropdownArrow.MouseButton1Click:Connect(function()
                dropdown:Toggle(not dropdown.open)
            end)
            
            -- Initial setup
            updateOptions()
            
            -- Set methods
            function dropdown:SetOptions(newOptions)
                dropdown.options = newOptions
                updateOptions()
                dropdown.selected = dropdown.options[1]
                library.flags[options.flag] = dropdown.selected
                selectedText.Text = dropdown.selected or "None"
                dropdown:Toggle(false) -- Make sure the dropdown is closed
            end
            
            -- Add to elements
            dropdown.container = dropdownContainer
            table.insert(tab.elements, dropdown)
            return dropdown
        end
        
        -- Section creating function
        function tab:CreateSection(sectionName)
            local sectionContainer = Instance.new("Frame")
            sectionContainer.Name = sectionName
            sectionContainer.Size = UDim2.new(1, -20, 0, 30)
            sectionContainer.Position = UDim2.new(0, 10, 0, 0)
            sectionContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            sectionContainer.BorderSizePixel = 0
            sectionContainer.Parent = tabContent
            
            local sectionText = Instance.new("TextLabel")
            sectionText.Size = UDim2.new(1, 0, 1, 0)
            sectionText.BackgroundTransparency = 1
            sectionText.TextColor3 = Color3.fromRGB(255, 255, 255)
            sectionText.TextSize = 14
            sectionText.Font = Enum.Font.SourceSansBold
            sectionText.Text = "--- " .. sectionName .. " ---"
            sectionText.Parent = sectionContainer
            
            return sectionContainer
        end
        
        -- Handle tab selection
        tabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(library.tabs) do
                t.content.Visible = (t.name == tabName)
                t.button.BackgroundColor3 = (t.name == tabName) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 40)
            end
        end)
        
        table.insert(library.tabs, tab)
        
        -- If this is the first tab, make it visible
        if #library.tabs == 1 then
            tabContent.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        end
        
        return tab
    end
    
    -- Tab selection function
    function library:SelectTab(tabName)
        for _, tab in pairs(library.tabs) do
            tab.content.Visible = (tab.name == tabName)
            tab.button.BackgroundColor3 = (tab.name == tabName) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 40)
        end
    end
    
    -- Keyboard toggle (Right Shift)
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.RightShift then
            main.Visible = not main.Visible
        end
    end)
    
    return library
end

return Library
