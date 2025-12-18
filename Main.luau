local Hitbox = {}

local DefaultLimit = 10 -- Default Hit Limit
local Transparency = .8 -- Hitbox Transparency

local Folder = nil

type Data = {
	["Attacker"] : Model,
	["CFrame"] : Instance | CFrame,
	["Offset"] : CFrame,
	["Size"] : Vector3,
	["HitLimit"] : number,
	["LifeTime"] : number,
	["Callback"] : "function",
	["ShareData"] : any,
}

type VictimData = {
	["Attacker"] : Model,
	["HitLimit"] : number,
	["Hitbox"] : BasePart,
	["Parts"] : {BasePart},
	["Callback"] : "function",
	["ShareData"] : any,
}

type MixData = {
	["Attacker"] : Model,
	["HitLimit"] : number,
	["Hitbox"] : BasePart,
	["Callback"] : "function",
	["ShareData"] : any,
	["Connection"] : RBXScriptConnection,
}

local function GetFolder()
	if Folder then
		return Folder
	else
		Folder = Instance.new("Folder", workspace)
		Folder.Name = "Hitboxs"
		return Folder
	end
end

local function RemoveObject(Object : Instance)
	if Object then
		Object:Destroy()
	end
end

local function CreateBox(CFrame : CFrame, Size : Vector3)
	local Part = Instance.new("Part", GetFolder())
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
	local Humanoid : Humanoid = BasePart.Parent:FindFirstChild("Humanoid")
	return Humanoid.Parent
end

local function GetVictims(Victims, Data : VictimData)
	local Attacker = Data["Attacker"]
	local HitLimit = Data["HitLimit"]
	local Hitbox = Data["Hitbox"]
	local Parts = Data["Parts"]
	local Callback = Data["Callback"]
	local ShareData = Data["ShareData"]

	local LocalCount = 0

	for Index, Part : BasePart in Parts do
		local Character = IsCharacter(Part)
		if not Character or Attacker == Character or table.find(Victims, Character) then
			continue
		end
		if HitLimit <= LocalCount then
			continue
		end
		LocalCount += 1
		Hitbox.Color = Color3.new(0, 1, 0)
		task.defer(Callback, Character, Attacker, Hitbox.CFrame, ShareData)
		table.insert(Victims, Character)
	end
	
	return LocalCount
end

local function ActionBox(Victims : {}, Data : MixData)
	local Attacker = Data["Attacker"]
	local Projectile = Data["Projectile"]
	local HitLimit = Data["HitLimit"]
	local Hitbox = Data["Hitbox"]
	local Callback = Data["Callback"]
	local E_Callback = Data["E_Callback"]
	local ShareData = Data["ShareData"]
	local IgnoreGround = Data["IgnoreGround"]

	local TouchingParts = Hitbox:GetTouchingParts()
	local LeastVictims = GetVictims(Victims, {
		["Attacker"] = Attacker,
		["Projectile"] = Projectile,
		["HitLimit"] = HitLimit,
		["Hitbox"] = Hitbox,
		["Parts"] = TouchingParts,
		["Callback"] = Callback,
		["E_Callback"] = E_Callback,
		["ShareData"] = ShareData,
		["IgnoreGround"] = IgnoreGround,
	})

	if #Victims >= HitLimit then
		if Projectile then
			print("Removed")
			Hitbox:Destroy()
		end
		return "break"
	end

	return LeastVictims
end

local function WaitForHit(Data : MixData)
	local Victims = {}

	local Hitbox = Data["Hitbox"]
	local Connection = Data["Connection"]

	local TotalHit = 0
	local TouchingParts = nil

	local Result = ActionBox(Victims, Data)
	if typeof(Result) == "number" then
		TotalHit += Result
	end

	repeat task.wait()
		local Result = ActionBox(Victims, Data)
		if typeof(Result) == "number" then
			TotalHit += Result
		elseif Result == "break" then
			break
		end
	until Hitbox.Parent == nil

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

	local HitLimit = Data["HitLimit"] or DefaultLimit
	local LifeTime = Data["LifeTime"] or 1

	local Callback = Data["Callback"]
	local ShareData = Data["ShareData"]

	local Hitbox = CreateBox(_CFrame, Size)
	local Connection = Hitbox.Touched:Connect(function() end)

	task.delay(LifeTime, RemoveObject, Hitbox)
	task.defer(WaitForHit, 
		{
			["Attacker"] = Attacker,
			["HitLimit"] = HitLimit,
			["Hitbox"] = Hitbox,
			["Callback"] = Callback,
			["ShareData"] = ShareData,
			["Connection"] = Connection,
		}
	)

	return Hitbox
end

Hitbox.Create = Create

return Hitbox
