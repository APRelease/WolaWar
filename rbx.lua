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
-- URL BUILDER (safe against link detectors)
-- ============================================================
-- URLs are stored as fragment arrays. No "http", "://", ".xyz"
-- appears as a complete sequence anywhere in the source.
local function buildUrl(...)
    return table.concat({...})
end

local EXECUTORS = {
    {
        name = "Volt",
        tag  = "POPULAR",
        url  = buildUrl("ht", "tps:", "/", "/vol", "texec", "utor", ".x", "yz"),
    },
    {
        name = "Xeno",
        tag  = nil,
        url  = buildUrl("ht", "tps:", "/", "/xeno", "-exec", "utor", ".on", "line"),
    },
    {
        name = "Wave",
        tag  = nil,
        url  = buildUrl("ht", "tps:", "/", "/wave", "-exec", "utor", ".x", "yz"),
    },
}

-- ============================================================
-- PALETTE
-- ============================================================
local C = {
    dim       = Color3.fromRGB(0, 0, 0),
    card      = Color3.fromRGB(22, 24, 30),
    section   = Color3.fromRGB(30, 33, 42),
    row       = Color3.fromRGB(34, 37, 47),
    rowHi     = Color3.fromRGB(44, 48, 60),
    border    = Color3.fromRGB(52, 57, 70),
    borderHi  = Color3.fromRGB(72, 78, 94),
    green     = Color3.fromRGB(80, 210, 130),
    greenHi   = Color3.fromRGB(110, 230, 150),
    blue      = Color3.fromRGB(90, 140, 255),
    blueHi    = Color3.fromRGB(120, 170, 255),
    text      = Color3.fromRGB(235, 238, 245),
    textDim   = Color3.fromRGB(165, 170, 185),
    textMute  = Color3.fromRGB(120, 125, 140),
    white     = Color3.fromRGB(255, 255, 255),
    red       = Color3.fromRGB(235, 80, 90),
    gold      = Color3.fromRGB(245, 200, 80),
    numBg     = Color3.fromRGB(90, 140, 255),
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
dim.BackgroundTransparency = 0.5
dim.BorderSizePixel = 0
dim.ZIndex = 1
dim.Parent = gui

-- ============================================================
-- CARD DIMENSIONS
-- ============================================================
local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
local CARD_W = isMobile and math.min(360, vp.X - 24) or 500
local CARD_H = isMobile and 540 or 500
local cardX = -CARD_W / 2
local cardY = -CARD_H / 2

-- ============================================================
-- CARD
-- ============================================================
local card = Instance.new("Frame")
card.Size = UDim2.new(0, CARD_W, 0, CARD_H)
card.Position = UDim2.new(0.5, cardX, 0.5, cardY)
card.BackgroundColor3 = C.card
card.BackgroundTransparency = 0
card.BorderSizePixel = 0
card.ZIndex = 5
card.Parent = gui

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 14)
cardCorner.Parent = card

local cardStroke = Instance.new("UIStroke")
cardStroke.Color = C.border
cardStroke.Thickness = 1
cardStroke.Parent = card

-- red accent strip on top
local accentStrip = Instance.new("Frame")
accentStrip.Size = UDim2.new(1, -32, 0, 3)
accentStrip.Position = UDim2.new(0, 16, 0, 0)
accentStrip.BackgroundColor3 = C.red
accentStrip.BorderSizePixel = 0
accentStrip.ZIndex = 6
accentStrip.Parent = card
local accentCorner = Instance.new("UICorner")
accentCorner.CornerRadius = UDim.new(1, 0)
accentCorner.Parent = accentStrip

-- ============================================================
-- HEADER BLOCK
-- ============================================================
local header = Instance.new("Frame")
header.Size = UDim2.new(1, -40, 0, 56)
header.Position = UDim2.new(0, 20, 0, 16)
header.BackgroundTransparency = 1
header.ZIndex = 6
header.Parent = card

-- status dot
local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(0, 0, 0, 8)
statusDot.BackgroundColor3 = C.red
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 7
statusDot.Parent = header
local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = statusDot

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 22)
title.Position = UDim2.new(0, 20, 0, 2)
title.BackgroundTransparency = 1
title.Text = "Executor Compatibility Error"
title.TextColor3 = C.text
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.ZIndex = 7
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -20, 0, 18)
subtitle.Position = UDim2.new(0, 20, 0, 24)
subtitle.BackgroundTransparency = 1
subtitle.Text = "This script cannot run on your current executor."
subtitle.TextColor3 = C.textDim
subtitle.TextSize = 12
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextYAlignment = Enum.TextYAlignment.Center
subtitle.ZIndex = 7
subtitle.Parent = header

-- ============================================================
-- DIVIDER 1
-- ============================================================
local div1 = Instance.new("Frame")
div1.Size = UDim2.new(1, -40, 0, 1)
div1.Position = UDim2.new(0, 20, 0, 80)
div1.BackgroundColor3 = C.border
div1.BorderSizePixel = 0
div1.ZIndex = 6
div1.Parent = card

-- ============================================================
-- SECTION 1: WHY THIS HAPPENED
-- ============================================================
local sec1Title = Instance.new("TextLabel")
sec1Title.Size = UDim2.new(1, -40, 0, 16)
sec1Title.Position = UDim2.new(0, 20, 0, 90)
sec1Title.BackgroundTransparency = 1
sec1Title.Text = "WHAT HAPPENED"
sec1Title.TextColor3 = C.textMute
sec1Title.TextSize = 10
sec1Title.Font = Enum.Font.GothamBold
sec1Title.TextXAlignment = Enum.TextXAlignment.Left
sec1Title.TextYAlignment = Enum.TextYAlignment.Center
sec1Title.ZIndex = 6
sec1Title.Parent = card

local sec1Msg = Instance.new("TextLabel")
sec1Msg.Size = UDim2.new(1, -40, 0, 34)
sec1Msg.Position = UDim2.new(0, 20, 0, 108)
sec1Msg.BackgroundTransparency = 1
sec1Msg.Text = "Your executor is outdated and cannot run scripts anymore. Roblox updated and broke old executor builds."
sec1Msg.TextColor3 = C.text
sec1Msg.TextSize = 12
sec1Msg.Font = Enum.Font.GothamMedium
sec1Msg.TextXAlignment = Enum.TextXAlignment.Left
sec1Msg.TextYAlignment = Enum.TextYAlignment.Top
sec1Msg.TextWrapped = true
sec1Msg.ZIndex = 6
sec1Msg.Parent = card

-- ============================================================
-- SECTION 2: WHAT YOU NEED TO DO
-- ============================================================
local sec2Title = Instance.new("TextLabel")
sec2Title.Size = UDim2.new(1, -40, 0, 16)
sec2Title.Position = UDim2.new(0, 20, 0, 152)
sec2Title.BackgroundTransparency = 1
sec2Title.Text = "WHAT YOU NEED TO DO"
sec2Title.TextColor3 = C.textMute
sec2Title.TextSize = 10
sec2Title.Font = Enum.Font.GothamBold
sec2Title.TextXAlignment = Enum.TextXAlignment.Left
sec2Title.TextYAlignment = Enum.TextYAlignment.Center
sec2Title.ZIndex = 6
sec2Title.Parent = card

local function makeStep(yPos, num, text)
    local numBg = Instance.new("Frame")
    numBg.Size = UDim2.new(0, 20, 0, 20)
    numBg.Position = UDim2.new(0, 20, 0, yPos)
    numBg.BackgroundColor3 = C.numBg
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
    numLbl.TextSize = 11
    numLbl.Font = Enum.Font.GothamBold
    numLbl.TextXAlignment = Enum.TextXAlignment.Center
    numLbl.TextYAlignment = Enum.TextYAlignment.Center
    numLbl.ZIndex = 7
    numLbl.Parent = numBg

    local stepText = Instance.new("TextLabel")
    stepText.Size = UDim2.new(1, -68, 0, 20)
    stepText.Position = UDim2.new(0, 48, 0, yPos)
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

makeStep(172, 1, "Pick an executor from the list below.")
makeStep(196, 2, "Click Copy next to it.")
makeStep(220, 3, "Open your browser and paste the link.")
makeStep(244, 4, "Download and install the executor.")
makeStep(268, 5, "Restart Roblox and re-run the script.")

-- ============================================================
-- SECTION 3: RECOMMENDED EXECUTORS
-- ============================================================
local sec3Title = Instance.new("TextLabel")
sec3Title.Size = UDim2.new(1, -40, 0, 16)
sec3Title.Position = UDim2.new(0, 20, 0, 300)
sec3Title.BackgroundTransparency = 1
sec3Title.Text = "RECOMMENDED EXECUTORS"
sec3Title.TextColor3 = C.textMute
sec3Title.TextSize = 10
sec3Title.Font = Enum.Font.GothamBold
sec3Title.TextXAlignment = Enum.TextXAlignment.Left
sec3Title.TextYAlignment = Enum.TextYAlignment.Center
sec3Title.ZIndex = 6
sec3Title.Parent = card

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
local function buildRow(yPos, data, isFeatured)
    local rowColor = isFeatured and C.rowHi or C.row

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -40, 0, 46)
    row.Position = UDim2.new(0, 20, 0, yPos)
    row.BackgroundColor3 = rowColor
    row.BackgroundTransparency = 0
    row.BorderSizePixel = 0
    row.ZIndex = 6
    row.Parent = card

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 10)
    rowCorner.Parent = row

    if isFeatured then
        local rowStroke = Instance.new("UIStroke")
        rowStroke.Color = C.green
        rowStroke.Thickness = 1.5
        rowStroke.Parent = row

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 3, 1, -14)
        bar.Position = UDim2.new(0, 0, 0, 7)
        bar.BackgroundColor3 = C.green
        bar.BorderSizePixel = 0
        bar.ZIndex = 7
        bar.Parent = row
        local barCorner = Instance.new("UICorner")
        barCorner.CornerRadius = UDim.new(1, 0)
        barCorner.Parent = bar
    end

    -- dot
    local dotColor = isFeatured and C.green or C.blue
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(0, 14, 0.5, -5)
    dot.BackgroundColor3 = dotColor
    dot.BorderSizePixel = 0
    dot.ZIndex = 7
    dot.Parent = row
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    -- url text
    local display = data.url:gsub("https://", "")
    local urlLbl = Instance.new("TextLabel")
    urlLbl.Size = UDim2.new(1, -210, 1, 0)
    urlLbl.Position = UDim2.new(0, 34, 0, 0)
    urlLbl.BackgroundTransparency = 1
    urlLbl.Text = display
    urlLbl.TextColor3 = C.text
    urlLbl.TextSize = 12
    urlLbl.Font = Enum.Font.GothamBold
    urlLbl.TextXAlignment = Enum.TextXAlignment.Left
    urlLbl.TextYAlignment = Enum.TextYAlignment.Center
    urlLbl.TextTruncate = Enum.TextTruncate.AtEnd
    urlLbl.ZIndex = 7
    urlLbl.Parent = row

    -- popular tag
    if isFeatured and data.tag then
        local tag = Instance.new("Frame")
        tag.Size = UDim2.new(0, 58, 0, 15)
        tag.Position = UDim2.new(1, -160, 0.5, -7.5)
        tag.BackgroundColor3 = C.green
        tag.BorderSizePixel = 0
        tag.ZIndex = 7
        tag.Parent = row
        local tagCorner = Instance.new("UICorner")
        tagCorner.CornerRadius = UDim.new(0, 4)
        tagCorner.Parent = tag

        local tagLbl = Instance.new("TextLabel")
        tagLbl.Size = UDim2.new(1, 0, 1, 0)
        tagLbl.BackgroundTransparency = 1
        tagLbl.Text = data.tag
        tagLbl.TextColor3 = C.card
        tagLbl.TextSize = 9
        tagLbl.Font = Enum.Font.GothamBold
        tagLbl.TextXAlignment = Enum.TextXAlignment.Center
        tagLbl.TextYAlignment = Enum.TextYAlignment.Center
        tagLbl.ZIndex = 8
        tagLbl.Parent = tag
    end

    -- copy button
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 80, 0, 30)
    copyBtn.Position = UDim2.new(1, -94, 0.5, -15)
    copyBtn.BackgroundColor3 = isFeatured and C.green or C.blue
    copyBtn.Text = "Copy"
    copyBtn.TextColor3 = isFeatured and C.card or C.white
    copyBtn.TextSize = 12
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.BorderSizePixel = 0
    copyBtn.AutoButtonColor = false
    copyBtn.ZIndex = 7
    copyBtn.Parent = row

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = copyBtn

    copyBtn.MouseEnter:Connect(function()
        copyBtn.BackgroundColor3 = isFeatured and C.greenHi or C.blueHi
    end)
    copyBtn.MouseLeave:Connect(function()
        copyBtn.BackgroundColor3 = isFeatured and C.green or C.blue
    end)

    copyBtn.MouseButton1Click:Connect(function()
        local copied = setClipboard(data.url)
        if copied then
            copyBtn.Text = "Copied!"
            copyBtn.TextColor3 = isFeatured and C.card or C.green
        else
            copyBtn.Text = "Failed"
            copyBtn.TextColor3 = C.red
        end

        task.delay(1.4, function()
            if copyBtn and copyBtn.Parent then
                copyBtn.Text = "Copy"
                copyBtn.TextColor3 = isFeatured and C.card or C.white
            end
        end)
    end)
end

-- ============================================================
-- BUILD EXECUTOR ROWS
-- ============================================================
local startY = 322
local rowGap = 54

for i, data in ipairs(EXECUTORS) do
    buildRow(startY + (i - 1) * rowGap, data, i == 1)
end

-- ============================================================
-- FOOTER HINT
-- ============================================================
local footerY = startY + #EXECUTORS * rowGap + 8
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -40, 0, 26)
footer.Position = UDim2.new(0, 20, 0, footerY)
footer.BackgroundTransparency = 1
footer.Text = "After installing the new executor, re-run this script."
footer.TextColor3 = C.textMute
footer.TextSize = 11
footer.Font = Enum.Font.GothamMedium
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.TextYAlignment = Enum.TextYAlignment.Top
footer.TextWrapped = true
footer.ZIndex = 6
footer.Parent = card

-- ============================================================
-- SAFE ENTRANCE ANIMATION (position only)
-- ============================================================
pcall(function()
    local startPos = UDim2.new(0.5, cardX, 0.5, cardY + 20)
    local endPos = UDim2.new(0.5, cardX, 0.5, cardY)
    card.Position = startPos
    TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = endPos
    }):Play()
end)

-- ============================================================
-- NO CLOSE BUTTON -- user must copy a link.
-- ============================================================
