local GuiLib = {}
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local THEME = {
    Background = Color3.fromRGB(17, 17, 17),    
    TabBackground = Color3.fromRGB(22, 22, 22), 
    ModuleBackground = Color3.fromRGB(15, 15, 15), 
    Border = Color3.fromRGB(30, 30, 30),        
    TabActive = Color3.fromRGB(40, 40, 40),     
    TabInactive = Color3.fromRGB(22, 22, 22),   
    Text = Color3.fromRGB(255, 255, 255),       
    TextDark = Color3.fromRGB(150, 150, 150),   
    Enabled = Color3.fromRGB(50, 168, 82),      
    Disabled = Color3.fromRGB(180, 40, 40),     
    Hover = Color3.fromRGB(35, 35, 35),         
    AccentDark = Color3.fromRGB(35, 35, 35),    
    Divider = Color3.fromRGB(40, 40, 40),        
    SettingsTab = Color3.fromRGB(25, 25, 25)  
}

function GuiLib.new(title)
    local window = Instance.new("ScreenGui")
    window.Name = title .. "_GUI"
    local main = Instance.new("Frame")
    local titleBar = Instance.new("Frame")
    local titleText = Instance.new("TextLabel")
    local container = Instance.new("Frame")
    local elementList = Instance.new("UIListLayout")

    if syn and syn.protect_gui then
        syn.protect_gui(window)
        window.Parent = CoreGui
    elseif gethui then
        window.Parent = gethui()
    else
        window.Parent = CoreGui
    end

    main.Parent = window

    main.Name = "Main"
    main.Size = UDim2.new(0, 650, 0, 400)         
    main.Position = UDim2.new(0.5, -325, 0.5, -200)
    main.BackgroundColor3 = THEME.Background
    main.BorderSizePixel = 1
    main.BorderColor3 = THEME.Border

    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 24)
    titleBar.BackgroundColor3 = THEME.TabBackground
    titleBar.BorderSizePixel = 1
    titleBar.BorderColor3 = THEME.Border
    titleBar.Parent = main

    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, 0, 1, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = title
    titleText.TextColor3 = THEME.Text
    titleText.Font = Enum.Font.SourceSans
    titleText.TextSize = 15
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Position = UDim2.new(0, 8, 0, 0)
    titleText.Parent = titleBar

    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "Tabs"
    tabContainer.Size = UDim2.new(0, 150, 1, -24)  
    tabContainer.Position = UDim2.new(0, 0, 0, 24)
    tabContainer.BackgroundColor3 = THEME.TabBackground
    tabContainer.BorderSizePixel = 1
    tabContainer.BorderColor3 = THEME.Border
    tabContainer.Parent = main

    local tabList = Instance.new("UIListLayout")
    tabList.FillDirection = Enum.FillDirection.Vertical
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Padding = UDim.new(0, 0)
    tabList.Parent = tabContainer

    container.Name = "Container"
    container.Size = UDim2.new(1, -150, 1, -24)
    container.Position = UDim2.new(0, 150, 0, 24)
    container.BackgroundColor3 = THEME.ModuleBackground
    container.BorderSizePixel = 1
    container.BorderColor3 = THEME.Border
    container.Parent = main

    elementList.Parent = container
    elementList.SortOrder = Enum.SortOrder.LayoutOrder
    elementList.Padding = UDim.new(0, 4)

    local dragging = false
    local dragStart = nil
    local startPos = nil

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    local guiVisible = true
    local toggleKey = Enum.KeyCode.Insert

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == toggleKey then
            guiVisible = not guiVisible
            window.Enabled = guiVisible
        end
    end)

    local window_methods = {}
    local tabs = {}
    local currentTab = nil

    function window_methods:AddTab(name, isSettings)
        local tabButton = Instance.new("TextButton")
        local tabContent = Instance.new("ScrollingFrame")
        local tabElementList = Instance.new("UIListLayout")

        tabButton.Size = UDim2.new(1, 0, 0, 32)
        tabButton.BackgroundColor3 = isSettings and THEME.SettingsTab or THEME.TabInactive
        tabButton.BorderSizePixel = 0
        tabButton.Text = "  " .. name
        tabButton.TextColor3 = THEME.TextDark
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.SourceSansSemibold
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.AutoButtonColor = false
        tabButton.LayoutOrder = isSettings and 999 or #tabs
        tabButton.Parent = tabContainer

        tabContent.Size = UDim2.new(1, -2, 1, 0)
        tabContent.Position = UDim2.new(0, 2, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 2
        tabContent.ScrollBarImageColor3 = THEME.TextDark
        tabContent.Visible = false
        tabContent.Parent = container

        tabElementList.Parent = tabContent
        tabElementList.HorizontalAlignment = Enum.HorizontalAlignment.Left
        tabElementList.Padding = UDim.new(0, 1)

        local activeIndicator = Instance.new("Frame")
        activeIndicator.Size = UDim2.new(0, 2, 1, -6)
        activeIndicator.Position = UDim2.new(0, 0, 0, 3)
        activeIndicator.BackgroundColor3 = THEME.Enabled
        activeIndicator.BorderSizePixel = 0
        activeIndicator.Visible = false

        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(0, 1)
        indicatorCorner.Parent = activeIndicator
        activeIndicator.Parent = tabButton

        local tab = {
            button = tabButton,
            content = tabContent,
            indicator = activeIndicator,
            isSettings = isSettings
        }
        table.insert(tabs, tab)

        tabButton.MouseButton1Click:Connect(function()
            if currentTab then
                currentTab.content.Visible = false
                currentTab.button.BackgroundColor3 = currentTab.isSettings and THEME.SettingsTab or THEME.TabInactive
                currentTab.button.TextColor3 = THEME.TextDark
                currentTab.indicator.Visible = false
            end

            currentTab = tab
            tabContent.Visible = true
            tabButton.BackgroundColor3 = isSettings and THEME.SettingsTab or THEME.TabActive
            tabButton.TextColor3 = THEME.Text
            activeIndicator.Visible = true
        end)

        if #tabs == 1 and not isSettings then
            currentTab = tab
            tabContent.Visible = true
            tabButton.BackgroundColor3 = THEME.TabActive
            tabButton.TextColor3 = THEME.Text
            activeIndicator.Visible = true
        end

        local tab_methods = {}

        function tab_methods:AddButton(text, callback)
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(0.9, 0, 0, 30)
            button.BackgroundColor3 = THEME.Border
            button.BorderSizePixel = 1
            button.BorderColor3 = THEME.Border
            button.Text = text
            button.TextColor3 = THEME.Text
            button.Font = Enum.Font.SourceSans
            button.TextSize = 14
            button.Parent = tabContent

            button.MouseButton1Click:Connect(callback)

            button.MouseEnter:Connect(function()
                button.BackgroundColor3 = THEME.Hover
            end)

            button.MouseLeave:Connect(function()
                button.BackgroundColor3 = THEME.Border
            end)
        end

        function tab_methods:AddToggle(text, callback)
            local toggle = Instance.new("TextButton")
            local enabled = false

            toggle.Size = UDim2.new(1, 0, 0, 32)
            toggle.BackgroundColor3 = THEME.ModuleBackground
            toggle.BorderSizePixel = 0
            toggle.Text = "  " .. text
            toggle.TextColor3 = THEME.TextDark
            toggle.TextSize = 14
            toggle.Font = Enum.Font.SourceSans
            toggle.TextXAlignment = Enum.TextXAlignment.Left
            toggle.AutoButtonColor = false
            toggle.Parent = tabContent

            local status = Instance.new("Frame")
            status.Size = UDim2.new(0, 2, 1, 0)        
            status.Position = UDim2.new(0, 0, 0, 0)     
            status.BackgroundColor3 = THEME.Disabled
            status.BorderSizePixel = 0
            status.Parent = toggle

            local activeBackground = Instance.new("Frame")
            activeBackground.Size = UDim2.new(1, 0, 1, 0)
            activeBackground.BackgroundColor3 = THEME.AccentDark
            activeBackground.BorderSizePixel = 0
            activeBackground.BackgroundTransparency = 1
            activeBackground.ZIndex = 1
            activeBackground.Parent = toggle

            toggle.ZIndex = 2
            status.ZIndex = 3

            local function updateToggle()
                status.BackgroundColor3 = enabled and THEME.Enabled or THEME.Disabled
                toggle.TextColor3 = enabled and THEME.Text or THEME.TextDark

                local targetTransparency = enabled and 0 or 1
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(activeBackground, tweenInfo, {
                    BackgroundTransparency = targetTransparency
                })
                tween:Play()

                callback(enabled)
            end

            toggle.MouseButton1Click:Connect(function()
                enabled = not enabled
                updateToggle()
            end)

            toggle.MouseEnter:Connect(function()
                if not enabled then
                    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local tween = TweenService:Create(toggle, tweenInfo, {
                        BackgroundColor3 = THEME.Hover
                    })
                    tween:Play()
                end
            end)

            toggle.MouseLeave:Connect(function()
                if not enabled then
                    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local tween = TweenService:Create(toggle, tweenInfo, {
                        BackgroundColor3 = THEME.ModuleBackground
                    })
                    tween:Play()
                end
            end)
        end

        function tab_methods:AddToggleWithSettings(text, settings, callback)
            local toggle = Instance.new("TextButton")
            local enabled = false
            local settingsData = {
                enabled = false,
                keybind = "NONE",
                checkboxes = {}
            }

            toggle.Size = UDim2.new(1, 0, 0, 32)
            toggle.BackgroundColor3 = THEME.ModuleBackground
            toggle.BorderSizePixel = 0
            toggle.Text = "  " .. text
            toggle.TextColor3 = THEME.TextDark
            toggle.TextSize = 14
            toggle.Font = Enum.Font.SourceSansSemibold
            toggle.TextXAlignment = Enum.TextXAlignment.Left
            toggle.AutoButtonColor = false
            toggle.Parent = tabContent

            local status = Instance.new("Frame")
            status.Size = UDim2.new(0, 2, 1, 0)
            status.Position = UDim2.new(0, 0, 0, 0)
            status.BackgroundColor3 = THEME.Disabled
            status.BorderSizePixel = 0
            status.Parent = toggle

            local gear = Instance.new("ImageLabel")
            gear.Size = UDim2.new(0, 16, 0, 16)
            gear.Position = UDim2.new(1, -24, 0.5, -8)
            gear.BackgroundTransparency = 1
            gear.Image = "rbxassetid://7059346373"
            gear.ImageColor3 = THEME.TextDark
            gear.Parent = toggle

            local function updateToggle()
                settingsData.enabled = enabled
                status.BackgroundColor3 = enabled and THEME.Enabled or THEME.Disabled
                toggle.TextColor3 = enabled and THEME.Text or THEME.TextDark
                gear.ImageColor3 = enabled and THEME.Text or THEME.TextDark
                callback(settingsData)
            end

            local function setupKeybind(keybindButton)
                local awaitingBind = false

                keybindButton.MouseButton1Click:Connect(function()
                    awaitingBind = true
                    keybindButton.Text = "..."
                end)

                local function handleInput(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        if awaitingBind then
                            local keyName = input.KeyCode.Name
                            if keyName ~= "Unknown" then
                                settingsData.keybind = keyName
                                keybindButton.Text = keyName
                                awaitingBind = false
                                callback(settingsData)
                            end
                        elseif settingsData.keybind ~= "NONE" and input.KeyCode.Name == settingsData.keybind then
                            enabled = not enabled
                            settingsData.enabled = enabled
                            updateToggle()
                        end
                    end
                end

                local inputConnection = game:GetService("UserInputService").InputBegan:Connect(handleInput)

                return function()
                    if inputConnection then
                        inputConnection:Disconnect()
                    end
                end
            end

            local function createSettingsWindow()
                local settingsGui = Instance.new("ScreenGui")
                local main = Instance.new("Frame")
                local title = Instance.new("TextLabel")
                local close = Instance.new("TextButton")
                local container = Instance.new("ScrollingFrame")

                if syn and syn.protect_gui then
                    syn.protect_gui(settingsGui)
                    settingsGui.Parent = CoreGui
                elseif gethui then
                    settingsGui.Parent = gethui()
                else
                    settingsGui.Parent = CoreGui
                end

                main.Name = "Settings"
                main.Size = UDim2.new(0, 250, 0, 300)
                main.Position = UDim2.new(0.5, -125, 0.5, -150)
                main.BackgroundColor3 = THEME.Background
                main.BorderSizePixel = 1
                main.BorderColor3 = THEME.Border
                main.ClipsDescendants = true
                main.Parent = settingsGui

                title.Size = UDim2.new(1, -24, 0, 32)
                title.Position = UDim2.new(0, 8, 0, 0)
                title.BackgroundTransparency = 1
                title.Text = text .. " Settings"
                title.TextColor3 = THEME.Text
                title.TextSize = 14
                title.Font = Enum.Font.SourceSansSemibold
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.Parent = main

                close.Size = UDim2.new(0, 24, 0, 24)
                close.Position = UDim2.new(1, -28, 0, 4)
                close.BackgroundColor3 = THEME.Border
                close.BorderSizePixel = 0
                close.Text = "×"
                close.TextColor3 = THEME.Text
                close.TextSize = 16
                close.Font = Enum.Font.SourceSansBold
                close.Parent = main

                container.Size = UDim2.new(1, -16, 1, -40)
                container.Position = UDim2.new(0, 8, 0, 32)
                container.BackgroundTransparency = 1
                container.ScrollBarThickness = 2
                container.ScrollBarImageColor3 = THEME.TextDark
                container.BorderSizePixel = 0
                container.ClipsDescendants = true
                container.Parent = main

                local listLayout = Instance.new("UIListLayout")
                listLayout.Parent = container
                listLayout.SortOrder = Enum.SortOrder.LayoutOrder
                listLayout.Padding = UDim.new(0, 1)

                local keybindFrame = Instance.new("Frame")
                keybindFrame.Size = UDim2.new(1, 0, 0, 32)
                keybindFrame.BackgroundTransparency = 1
                keybindFrame.Parent = container

                local keybindLabel = Instance.new("TextLabel")
                keybindLabel.Size = UDim2.new(0, 60, 1, 0)
                keybindLabel.BackgroundTransparency = 1
                keybindLabel.Text = "Bind"
                keybindLabel.TextColor3 = THEME.TextDark
                keybindLabel.TextSize = 14
                keybindLabel.Font = Enum.Font.SourceSans
                keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                keybindLabel.Parent = keybindFrame

                local keybindButton = Instance.new("TextButton")
                keybindButton.Size = UDim2.new(0, 60, 0, 20)
                keybindButton.Position = UDim2.new(1, -60, 0.5, -10)
                keybindButton.BackgroundColor3 = THEME.Border
                keybindButton.BorderSizePixel = 0
                keybindButton.Text = settingsData.keybind
                keybindButton.TextColor3 = THEME.Text
                keybindButton.TextSize = 12
                keybindButton.Font = Enum.Font.SourceSans
                keybindButton.Parent = keybindFrame

                for i, setting in ipairs(settings) do
                    local checkboxFrame = Instance.new("Frame")
                    checkboxFrame.Size = UDim2.new(1, 0, 0, 32)
                    checkboxFrame.BackgroundTransparency = 1
                    checkboxFrame.Parent = container

                    local checkboxLabel = Instance.new("TextLabel")
                    checkboxLabel.Size = UDim2.new(1, -30, 1, 0)
                    checkboxLabel.BackgroundTransparency = 1
                    checkboxLabel.Text = setting
                    checkboxLabel.TextColor3 = THEME.TextDark
                    checkboxLabel.TextSize = 14
                    checkboxLabel.Font = Enum.Font.SourceSans
                    checkboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                    checkboxLabel.Parent = checkboxFrame

                    local checkbox = Instance.new("TextButton")
                    checkbox.Size = UDim2.new(0, 20, 0, 20)
                    checkbox.Position = UDim2.new(1, -20, 0.5, -10)
                    checkbox.BackgroundColor3 = THEME.Border
                    checkbox.BorderSizePixel = 0
                    checkbox.Text = ""
                    checkbox.Parent = checkboxFrame

                    local checkmark = Instance.new("Frame")
                    checkmark.Size = UDim2.new(0.8, 0, 0.8, 0)
                    checkmark.Position = UDim2.new(0.1, 0, 0.1, 0)
                    checkmark.BackgroundColor3 = THEME.Enabled
                    checkmark.BorderSizePixel = 0
                    checkmark.Visible = settingsData.checkboxes[setting]
                    checkmark.Parent = checkbox

                    checkbox.MouseButton1Click:Connect(function()
                        settingsData.checkboxes[setting] = not settingsData.checkboxes[setting]
                        checkmark.Visible = settingsData.checkboxes[setting]
                        callback(settingsData)
                    end)
                end

                listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
                end)

                local cleanupKeybind = setupKeybind(keybindButton)

                close.MouseButton1Click:Connect(function()
                    if cleanupKeybind then
                        cleanupKeybind()
                    end
                    settingsGui:Destroy()
                end)

                local dragging = false
                local dragStart = nil
                local startPos = nil

                title.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        dragStart = input.Position
                        startPos = main.Position
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local delta = input.Position - dragStart
                        main.Position = UDim2.new(
                            startPos.X.Scale,
                            startPos.X.Offset + delta.X,
                            startPos.Y.Scale,
                            startPos.Y.Offset + delta.Y
                        )
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
            end

            toggle.MouseButton1Click:Connect(function()
                enabled = not enabled
                updateToggle()
            end)

            toggle.MouseButton2Click:Connect(createSettingsWindow)

            setupKeybind(Instance.new("TextButton"))

            return settingsData
        end

        return tab_methods
    end

    local settingsTab = window_methods:AddTab("SETTINGS", true)
    settingsTab:AddToggleWithSettings("Menu Key", {}, function(data)
        if data.keybind ~= "NONE" then
            toggleKey = Enum.KeyCode[data.keybind]
        end
    end)

    return window_methods
end

return GuiLib
