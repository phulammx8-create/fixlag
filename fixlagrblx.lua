-- [[ ROBLOX FPS BOOSTER & LAG FIX SCRIPT - COMPACT & FIXED ]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Terrain = Workspace:FindFirstChildOfClass("Terrain")
local LocalPlayer = Players.LocalPlayer

-- Tạo Giao Diện Nút Bấm (UI)
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

ToggleButton.Name = "LagFixToggle"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -20)
ToggleButton.Size = UDim2.new(0, 120, 0, 40)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "Fix Lag: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
ToggleButton.TextSize = 16.000

UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = ToggleButton

-- Biến lưu trạng thái và cài đặt gốc
local isOptimized = false
local originalSettings = {
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    TerrainDecoration = Terrain and Terrain.Decoration or false
}

-- Hàm kiểm tra và tối ưu hóa từng vật thể
local function optimizeObject(obj)
    if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
        if obj.Material ~= Enum.Material.Neon and obj.Transparency < 1 then
            obj.Material = Enum.Material.SmoothPlastic
        end
        obj.CastShadow = false
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
        obj.Enabled = false
    elseif obj:IsA("PostEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("SunRaysEffect") then
        obj.Enabled = false
    end
end

-- Hàm tối ưu hóa (Bật/Tắt)
local function ToggleLagFix()
    isOptimized = not isOptimized
    
    if isOptimized then
        ToggleButton.Text = "Fix Lag: ON"
        ToggleButton.TextColor3 = Color3.fromRGB(100, 255, 100)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 50, 20)
        
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 250
        if Terrain then Terrain.Decoration = false end
        
        local descendants = Workspace:GetDescendants()
        task.spawn(function()
            for i, obj in ipairs(descendants) do
                if not isOptimized then break end
                optimizeObject(obj)
                if i % 200 == 0 then 
                    task.wait() 
                end
            end
        end)
    else
        ToggleButton.Text = "Fix Lag: OFF"
        ToggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        
        Lighting.GlobalShadows = originalSettings.GlobalShadows
        Lighting.FogEnd = originalSettings.FogEnd
        if Terrain then Terrain.Decoration = originalSettings.TerrainDecoration end
    end
end

-- Lắng nghe vật thể mới được thêm vào công khai
Workspace.DescendantAdded:Connect(function(obj)
    if isOptimized then
        task.wait()
        optimizeObject(obj)
    end
end)

ToggleButton.MouseButton1Click:Connect(ToggleLagFix)
