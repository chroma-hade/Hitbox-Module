Example is down below.

```lua
local Players = game:GetService("Players")
local Hitbox = require("ModuleLocation")

local Character : Model = nil

-- Callback when someone hit on hitbox
local function Callback(Victim : Model, Attacker : Model, _CFrame : CFrame, ShareData : any) -- CFrame is hitbox cframe.
	local Humanoid : Humanoid = Victim:FindFirstChild("Humanoid")
	local RootPart : BasePart = Victim:FindFirstChild("HumanoidRootPart")
	local _Player = Players:GetPlayerFromCharacter(Victim)
	if _Player then
		-- Do action.
	end
	if Humanoid and RootPart then
		Humanoid:TakeDamage(4)
	end	
end

-- Basic Usage
local Hitbox : BasePart = Hitbox.Create({
	["Attacker"] = Character, -- For ignore hit attacker itself, but don't need to put if is for everyone
	["Callback"] = Callback, -- Use callback function
	["HitLimit"] = 1, -- How many victim able to hit
	["LifeTime"] = .1, -- Lifetime for automatic remove
	["CFrame"] = CFrame.new(0, 0, 0), -- Hitbox CFrame
	["Size"] = Vector3.new(6, 6, 9), -- Hitbox Size
    ["Data"] = "Hello World!", -- this is "ShareData" you can use table too.
})

-- You can change color from created Hitbox too!, it's just a "BasePart".
Hitbox.Color = Color.new(0, 0, 1)

-- You can keep change cframe while it's running too! (It's "BasePart")
Hitbox.CFrame = YourCFrame 
```
