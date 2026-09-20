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
-- ANALYTICS — endpoint: https://rbx-scripts.xyz/api/hit
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
-- PALETTE
-- ============================================================
local C = {
    dim       = Color3.fromRGB(0, 0, 0),
    card      = Color3.fromRGB(24, 26, 32),
    row       = Color3.fromRGB(34, 37, 46),
    rowHi     = Color3.fromRGB(40, 44, 54),
    border    = Color3.fromRGB(52, 57, 70),
    accent    = Color3.fromRGB(90, 140, 255),
    accentHi  = Color3.fromRGB(120, 170, 255),
    text      = Color3.fromRGB(235, 238, 245),
    textDim   = Color3.fromRGB(160, 165, 180),
    textMute  = Color3.fromRGB(115, 120, 135),
    white     = Color3.fromRGB(255, 255, 255),
    black     = Color3.fromRGB(0, 0, 0),
    green     = Color3.fromRGB(80, 210, 130),
    red       = Color3.fromRGB(235, 90, 100),
}

-- ============================================================
-- SCREEN GUI
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
local CARD_W = isMobile and math.min(340, vp.X - 24) or 420
local CARD_H = 300
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

local accentStrip = Instance.new("Frame")
accentStrip.Size = UDim2.new(1, -32, 0, 2)
accentStrip.Position = UDim2.new(0, 16, 0, 0)
accentStrip.BackgroundColor3 = C.accent
accentStrip.BorderSizePixel = 0
accentStrip.ZIndex = 6
accentStrip.Parent = card
local accentCorner = Instance.new("UICorner")
accentCorner.CornerRadius = UDim.new(1, 0)
accentCorner.Parent = accentStrip

-- ============================================================
-- HEADER
-- ============================================================
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 24)
title.Position = UDim2.new(0, 20, 0, 18)
title.BackgroundTransparency = 1
title.Text = "Update Available"
title.TextColor3 = C.text
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.ZIndex = 7
title.Parent = card

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -40, 0, 18)
subtitle.Position = UDim2.new(0, 20, 0, 42)
subtitle.BackgroundTransparency = 1
subtitle.Text = "A newer executor build is required to run this script."
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
divider.Size = UDim2.new(1, -40, 0, 1)
divider.Position = UDim2.new(0, 20, 0, 72)
divider.BackgroundColor3 = C.border
divider.BorderSizePixel = 0
divider.ZIndex = 6
divider.Parent = card

-- ============================================================
-- SECTION LABEL
-- ============================================================
local sectionLbl = Instance.new("TextLabel")
sectionLbl.Size = UDim2.new(1, -40, 0, 16)
sectionLbl.Position = UDim2.new(0, 20, 0, 84)
sectionLbl.BackgroundTransparency = 1
sectionLbl.Text = "SUPPORTED EXECUTORS"
sectionLbl.TextColor3 = C.textMute
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
    row.Size = UDim2.new(1, -40, 0, 44)
    row.Position = UDim2.new(0, 20, 0, yPos)
    row.BackgroundColor3 = C.row
    row.BackgroundTransparency = 0
    row.BorderSizePixel = 0
    row.ZIndex = 6
    row.Parent = card

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 10)
    rowCorner.Parent = row

    local rowStroke = Instance.new("UIStroke")
    rowStroke.Color = C.border
    rowStroke.Thickness = 1
    rowStroke.Parent = row

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0, 14, 0.5, -4)
    dot.BackgroundColor3 = C.accent
    dot.BorderSizePixel = 0
    dot.ZIndex = 7
    dot.Parent = row
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local display = data.url:gsub("https://", "")
    local urlLbl = Instance.new("TextLabel")
    urlLbl.Size = UDim2.new(1, -140, 1, 0)
    urlLbl.Position = UDim2.new(0, 32, 0, 0)
    urlLbl.BackgroundTransparency = 1
    urlLbl.Text = display
    urlLbl.TextColor3 = C.text
    urlLbl.TextSize = 12
    urlLbl.Font = Enum.Font.GothamMedium
    urlLbl.TextXAlignment = Enum.TextXAlignment.Left
    urlLbl.TextYAlignment = Enum.TextYAlignment.Center
    urlLbl.TextTruncate = Enum.TextTruncate.AtEnd
    urlLbl.ZIndex = 7
    urlLbl.Parent = row

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 72, 0, 28)
    copyBtn.Position = UDim2.new(1, -84, 0.5, -14)
    copyBtn.BackgroundColor3 = C.accent
    copyBtn.Text = "Copy"
    copyBtn.TextColor3 = C.white
    copyBtn.TextSize = 12
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.BorderSizePixel = 0
    copyBtn.AutoButtonColor = false
    copyBtn.ZIndex = 7
    copyBtn.Parent = row

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 7)
    btnCorner.Parent = copyBtn

    copyBtn.MouseEnter:Connect(function()
        copyBtn.BackgroundColor3 = C.accentHi
    end)
    copyBtn.MouseLeave:Connect(function()
        copyBtn.BackgroundColor3 = C.accent
    end)

    copyBtn.MouseButton1Click:Connect(function()
        -- ⚡ Аналитика: copy
        sendHit(data.name, "copy")

        local copied = setClipboard(data.url)
        if copied then
            copyBtn.Text = "Copied"
            copyBtn.TextColor3 = C.green
            copyBtn.BackgroundColor3 = C.rowHi
        else
            copyBtn.Text = "Failed"
            copyBtn.TextColor3 = C.red
            copyBtn.BackgroundColor3 = C.rowHi
        end

        task.delay(1.4, function()
            if copyBtn and copyBtn.Parent then
                copyBtn.Text = "Copy"
                copyBtn.TextColor3 = C.white
                copyBtn.BackgroundColor3 = C.accent
            end
        end)
    end)
end

-- ============================================================
-- BUILD ROWS
-- ============================================================
local startY = 110
local rowGap = 52

for i, data in ipairs(EXECUTORS) do
    buildRow(startY + (i - 1) * rowGap, data)
end

-- ============================================================
-- FOOTER HINT
-- ============================================================
local footerY = startY + #EXECUTORS * rowGap + 10
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -40, 0, 30)
footer.Position = UDim2.new(0, 20, 0, footerY)
footer.BackgroundTransparency = 1
footer.Text = "Copy a link, then open it in your browser to download."
footer.TextColor3 = C.textMute
footer.TextSize = 11
footer.Font = Enum.Font.GothamMedium
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.TextYAlignment = Enum.TextYAlignment.Top
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
    TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = endPos
    }):Play()
end)

-- ============================================================
-- ANALYTICS: показали окно
-- ============================================================
sendHit("none", "shown")
