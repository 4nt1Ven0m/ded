-- services
local runService = game:GetService("RunService")
local players = game:GetService("Players")

-- variables
local localPlayer = players.LocalPlayer
local camera = workspace.CurrentCamera

-- ESP settings
local ESP = {}
ESP.settings = {
    enabled = false,
    box = {enabled = false, color = Color3.new(1, 1, 1), thickness = 1, transparency = 1, filled = false},
    text = {nameEnabled = false, distanceEnabled = false, color = Color3.new(1, 1, 1), size = 13, center = true, outline = true, outlineColor = Color3.new(0, 0, 0)},
    healthBar = {enabled = false, thickness = 1, filled = true, transparency = 1, color1 = Color3.new(1, 0, 0), color2 = Color3.new(0, 1, 0), outline = {enabled = true, thickness = 2, filled = true, color = Color3.new(0, 0, 0)}},
    healthText = {enabled = false, color = Color3.new(0, 1, 0), size = 13, center = true, outline = true, outlineColor = Color3.new(0, 0, 0)}
}

-- functions
local newVector2, newColor3, newDrawing = Vector2.new, Color3.new, Drawing.new
local tan, rad = math.tan, math.rad
local round = function(...) local a = {} for i,v in next, table.pack(...) do a[i] = math.round(v) end return unpack(a) end
local wtvp = function(...) local a, b = camera.WorldToViewportPoint(camera, ...) return newVector2(a.X, a.Y), b, a.Z end

local espCache = {}
local function createEsp(player)
   local drawings = {}
   
   if ESP.settings.box.enabled then
       drawings.box = newDrawing("Square")
       drawings.box.Thickness = ESP.settings.box.thickness
       drawings.box.Filled = ESP.settings.box.filled
       drawings.box.Color = ESP.settings.box.color
       drawings.box.Transparency = ESP.settings.box.transparency
       drawings.box.Visible = false
       drawings.box.ZIndex = 2
   end

   if ESP.settings.text.nameEnabled then
       drawings.nameText = newDrawing("Text")
       drawings.nameText.Size = ESP.settings.text.size
       drawings.nameText.Visible = false
       drawings.nameText.Center = ESP.settings.text.center
       drawings.nameText.Outline = ESP.settings.text.outline
       drawings.nameText.Color = ESP.settings.text.color
       drawings.nameText.OutlineColor = ESP.settings.text.outlineColor
   end

   if ESP.settings.text.distanceEnabled then
       drawings.distanceText = newDrawing("Text")
       drawings.distanceText.Size = ESP.settings.text.size
       drawings.distanceText.Visible = false
       drawings.distanceText.Center = ESP.settings.text.center
       drawings.distanceText.Outline = ESP.settings.text.outline
       drawings.distanceText.Color = ESP.settings.text.color
       drawings.distanceText.OutlineColor = ESP.settings.text.outlineColor
   end

   if ESP.settings.healthBar.enabled then
       drawings.healthBarBackground = newDrawing("Square")
       drawings.healthBarBackground.Thickness = ESP.settings.healthBar.thickness
       drawings.healthBarBackground.Filled = true
       drawings.healthBarBackground.Color = ESP.settings.healthBar.color1
       drawings.healthBarBackground.Transparency = ESP.settings.healthBar.transparency
       drawings.healthBarBackground.Visible = false
       drawings.healthBarBackground.ZIndex = 3

       drawings.healthBar = newDrawing("Square")
       drawings.healthBar.Thickness = ESP.settings.healthBar.thickness
       drawings.healthBar.Filled = true
       drawings.healthBar.Color = ESP.settings.healthBar.color2
       drawings.healthBar.Transparency = ESP.settings.healthBar.transparency
       drawings.healthBar.Visible = false
       drawings.healthBar.ZIndex = 4

       if ESP.settings.healthBar.outline.enabled then
           drawings.healthBarOutline = newDrawing("Square")
           drawings.healthBarOutline.Thickness = ESP.settings.healthBar.outline.thickness
           drawings.healthBarOutline.Filled = ESP.settings.healthBar.outline.filled
           drawings.healthBarOutline.Color = ESP.settings.healthBar.outline.color
           drawings.healthBarOutline.Visible = false
           drawings.healthBarOutline.ZIndex = 5
       end
   end

   if ESP.settings.healthText.enabled then
       drawings.healthText = newDrawing("Text")
       drawings.healthText.Size = ESP.settings.healthText.size
       drawings.healthText.Visible = false
       drawings.healthText.Center = ESP.settings.healthText.center
       drawings.healthText.Outline = ESP.settings.healthText.outline
       drawings.healthText.Color = ESP.settings.healthText.color
       drawings.healthText.OutlineColor = ESP.settings.healthText.outlineColor
   end

   espCache[player] = drawings
end

local function removeEsp(player)
   if rawget(espCache, player) then
       for _, drawing in next, espCache[player] do
           drawing:Remove()
       end
       espCache[player] = nil
   end
end

local function updateEsp(player, esp)
   local character = player and player.Character
   if character then
       local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
       local head = character:FindFirstChild("Head")
       local humanoid = character:FindFirstChildOfClass("Humanoid")
       if not humanoidRootPart or not head or not humanoid then
           for _, drawing in pairs(esp) do
               if drawing.Visible then
                   drawing.Visible = false
               end
           end
           return
       end

       local hrpPos, hrpVisible, hrpDepth = wtvp(humanoidRootPart.Position)
       local headPos, headVisible, headDepth = wtvp(head.Position)
       local visible = hrpVisible and headVisible

       if ESP.settings.box.enabled then
           esp.box.Visible = visible
           if visible then
               local scaleFactor = 1 / (hrpDepth * tan(rad(camera.FieldOfView / 2)) * 2) * 1000
               local width, height = round(3.5 * scaleFactor, 5.05 * scaleFactor)
               local x, y = round((hrpPos.X + headPos.X) / 2, (hrpPos.Y + headPos.Y) / 2)
               local offset = 6
               esp.box.Size = newVector2(width, height)
               esp.box.Position = newVector2(round(x - width / 2, y - height / 2 + offset))
           end
       end

       if ESP.settings.text.nameEnabled then
           esp.nameText.Visible = visible
           if visible then
               esp.nameText.Position = newVector2(round((hrpPos.X + headPos.X) / 2, (hrpPos.Y + headPos.Y) / 2 + 16))
               esp.nameText.Text = player.Name
           end
       end

       if ESP.settings.text.distanceEnabled then
           esp.distanceText.Visible = visible
           if visible then
               local distance = (localPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).magnitude
               esp.distanceText.Position = newVector2(round((hrpPos.X + headPos.X) / 2, (hrpPos.Y + headPos.Y) / 2 + 26))
               esp.distanceText.Text = "Distance: " .. tostring(math.floor(distance)) .. " studs"
           end
       end

       if ESP.settings.healthBar.enabled then
           esp.healthBarBackground.Visible = visible
           esp.healthBar.Visible = visible
           if ESP.settings.healthBar.outline.enabled then
               esp.healthBarOutline.Visible = visible
           end
           if visible then
               local health = humanoid.Health or 100
               local healthBarWidth = esp.box.Size.X - 2
               esp.healthBarBackground.Position = esp.box.Position - newVector2(0, 4)
               esp.healthBarBackground.Size = newVector2(healthBarWidth, 2)
               esp.healthBar.Position = esp.healthBarBackground.Position
               esp.healthBar.Size = newVector2(healthBarWidth * (health / 100), 2)
               if ESP.settings.healthBar.outline.enabled then
                   esp.healthBarOutline.Position = esp.healthBarBackground.Position
                   esp.healthBarOutline.Size = esp.healthBarBackground.Size
               end
           end
       end

       if ESP.settings.healthText.enabled then
           esp.healthText.Visible = visible
           if visible then
               local health = humanoid.Health or 100
               esp.healthText.Position = newVector2(round((hrpPos.X + headPos.X) / 2, (hrpPos.Y + headPos.Y) / 2 + 36))
               esp.healthText.Text = "HP: " .. math.floor(health)
           end
       end
   else
       for _, drawing in pairs(esp) do
           if drawing.Visible then
               drawing.Visible = false
           end
       end
   end
end

-- main
for _, player in ipairs(players:GetPlayers()) do
   if player ~= localPlayer then
       createEsp(player)
   end
end

players.PlayerAdded:Connect(function(player)
   createEsp(player)
end)

players.PlayerRemoving:Connect(function(player)
   removeEsp(player)
end)

runService:BindToRenderStep("esp", Enum.RenderPriority.Camera.Value, function()
   if ESP.settings.enabled then
       for player, drawings in pairs(espCache) do
           if player ~= localPlayer then
               updateEsp(player, drawings)
           end
       end
   end
end)

return ESP
