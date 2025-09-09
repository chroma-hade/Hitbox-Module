local Hitbox = {}

local Hitboxs = workspace["Hitboxs"] -- Hitbox Parent
local Transparency = .5 -- Hitbox Transparency

type Data = {
	["Attacker"] : Model,
	["CFrame"] : Instance | CFrame,
	["Offset"] : CFrame,
	["Size"] : Vector3,
	["HitLimit"] : number,
	["LifeTime"] : number,
	["Callback"] : RBXScriptSignal,
}

type VictimData = {
	["Attacker"] : Model,
	["Parts"] : {BasePart},
	["Box"] : BasePart,
	["Callback"] : RBXScriptSignal,
}

type MixData = {
	["Attacker"] : Model,
	["Box"] : BasePart,
	["HitLimit"] : number,
	["Callback"] : RBXScriptSignal,
	["Connection"] : RBXScriptConnection,
}

local function RemoveObject(Object : Instance)
	if Object then
		Object:Destroy()
	end
end

local function CreateBox(CFrame : CFrame, Size : Vector3)
	local Part = Instance.new("Part", Hitboxs)
	Part.Material = Enum.Material.SmoothPlastic
	Part.Color = Color3.fromRGB(255, 0, 0)
	Part.CastShadow = false
	Part.CanCollide = false
	Part.Anchored = true
	Part.Transparency = Transparency
	Part.CFrame = CFrame
	Part.Size = Size
	return Part
end

local function IsCharacter(BasePart : BasePart)
	local Humanoid : BasePart = BasePart.Parent:FindFirstChild("Humanoid")
	if Humanoid then
		return Humanoid.Parent
	end
end

local function GetVictims(Victims, Data : VictimData)
	local Attacker = Data["Attacker"]
	local Parts = Data["Parts"]
	local Box = Data["Box"]
	local Callback = Data["Callback"]
	
	for Index, Part : BasePart in Parts do
		local Character = IsCharacter(Part)
		if Character and Attacker ~= Character and not table.find(Victims, Character) then
			Callback(Character, Box.CFrame)
			table.insert(Victims, Character)
		end
	end
	
	return #Victims
end

local function WaitForHit(Data : MixData)
	local Victims = {}
	
	local Attacker = Data["Attacker"]
	local Box = Data["Box"]
	local HitLimit = Data["HitLimit"]
	local Callback = Data["Callback"]
	local Connection = Data["Connection"]
	
	local TotalHit = 0
	local TouchingParts = nil
	
	repeat task.wait()
		TouchingParts = Box:GetTouchingParts()
		local LeastVictims = GetVictims(Victims, 
			{
				["Attacker"] = Attacker,
				["Parts"] = TouchingParts,
				["Box"] = Box,
				["Callback"] = Callback,
			}
		)
		if #Victims >= HitLimit then
			break
		end
	until Box.Parent == nil
	
	table.clear(Victims)
	Victims = nil
	
	if Connection then
		Connection:Disconnect()
	end
end

local function Create(Data : Data)
	local Attacker = Data["Attacker"] or nil
	local _CFrame = Data["CFrame"] or CFrame.new(0, 0, 0)
	local Offset = Data["Offset"] or CFrame.new(0, 0, 0)
	local Size = Data["Size"] or Vector3.one
	local HitLimit = Data["HitLimit"] or 1
	local LifeTime = Data["LifeTime"] or 1
	local Callback = Data["Callback"]
	
	local Box = CreateBox(_CFrame, Size)
	local Connection = Box.Touched:Connect(function() end)
	
	task.delay(LifeTime, RemoveObject, Box)
	task.defer(WaitForHit, 
		{
			["Attacker"] = Attacker,
			["Box"] = Box,
			["HitLimit"] = HitLimit,
			["Callback"] = Callback,
			["Connection"] = Connection,
		}
	)
end

Hitbox.Create = Create

return Hitbox
