Example is down blow.

```lua
local Players = game:GetService("Players")
local Hitbox = require("ModuleLocation")

local Character : Model = nil

local function Callback(Victim : Model, _CFrame : CFrame) -- CFrame is hitbox cframe.
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

Hitbox.Create(
	{
		["Attacker"] = Character, -- For ignore but don't need to put if is for everyone
		["CFrame"] = CFrame.new(0, 0, 0), -- Hitbox CFrame
		["Size"] = Vector3.new(6, 6, 9), -- Hitbox Size
		["LifeTime"] = .1, -- Lifetime for automatic remove
		["HitLimit"] = 1, -- How many victim able to hit
		["Callback"] = Callback, -- Use callback function
	}
)
```
