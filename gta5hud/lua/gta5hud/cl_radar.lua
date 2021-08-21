--[[----------------------
	GTA V Radar
	Made by Doliman100
----------------------]]--

--[[-----------------
	Radar 268x190
-----------------]]--

local radarX = GTAV.Custom.OffsetX
local radarY = ScrH() - 190 - GTAV.Custom.OffsetY


--[[-------
	Map
-------]]--

local mapShadowX = radarX - 25
local mapShadowY = radarY - 25

local mapRadiusNorthMin = math.sqrt(268 ^ 2 + 169 ^ 2) / 2
local mapRadiusNorthMax = math.sqrt(268 ^ 2 + 169 ^ 2) / 2

local mapRadiusTargetMin = math.sqrt((268 / 2) ^ 2 + (169 * 0.75) ^ 2)
local mapRadiusTargetMax = math.sqrt((268 / 2) ^ 2 + (169 * 0.25) ^ 2)

local mapDistPart = GTAV.Administrate.RadarDist / 3

local mapDamageM = Material("gta5hud/radar/damage.png")


--[[-------
	Bar
-------]]--

local barY = radarY + 175
local barBackgorundY = barY - 6

-- Health
local barHealthOld = 0
local barHealthDiff = 0
local barHealthTime = 0
local barHealthPulse = 0

-- Armor
local barArmorX = radarX + 135
local barArmorW = GTAV.Administrate.ShowHunger and 65 or 133
local barArmorStep = barArmorW / 100

-- Hunger
local barHungerX
if GTAV.Administrate.ShowHunger then
	barHungerX = barArmorX + barArmorW + 3
end


--[[---------------
	Radar: Blip
---------------]]--

local blipNorthM = Material("gta5hud/radar/north.png")
local blipPointM = Material("gta5hud/radar/point.png")
local blipBodyM = Material("gta5hud/radar/body.png")
local blipPlayerM = Material("gta5hud/radar/player.png")

local blipPlayerX = radarX + 118
local blipPlayerY = radarY + 110


--[[----------------
	Radar: Voice
----------------]]--

local voiceM = Material("gta5hud/radar/voice.png")
local voiceEnable = false


--[[---------------
	Radar: Draw
---------------]]--

local function VectorToRadar(x, y)
	local targetPos = (Vector(x, y, 0) -  EyePos()) / 10
	local targetAng = (targetPos:Angle()[2] - EyeAngles()[2] + 180) % 360
	
	local targetDist = math.sqrt(targetPos.X ^ 2 + targetPos.Y ^ 2)
	
	targetPos:Mul(100 / GTAV.Administrate.RadarDistView)
	local targetDistMul = math.sqrt(targetPos.X ^ 2 + targetPos.Y ^ 2)
	local targetDistMath = targetDistMul
	
	if targetDist > GTAV.Administrate.RadarDist or targetDistMul < GTAV.Administrate.RadarSafe then return end
	
	if targetAng > 90 and targetAng < 270 then
		targetDistMath = math.min(targetDistMul, mapRadiusTargetMin)
	else
		targetDistMath = math.min(targetDistMul, mapRadiusTargetMax)
	end
	
	local targetX = math.sin(math.rad(targetAng)) * targetDistMath
	local targetY = math.cos(math.rad(targetAng)) * targetDistMath + 42
	
	targetX = math.Clamp(targetX, -134, 134)
	targetY = math.Clamp(targetY, -84, 84)
	
	targetX = radarX + targetX + 134
	targetY = radarY + targetY + 84
	
	return targetX, targetY, targetDist
end

local function VectorToRadarEnt(targetEnt)
	if GTAV.Administrate.RadarFeelsWall then
		local trace = util.TraceLine({
			start = LocalPlayer():EyePos(),
			endpos = targetEnt:EyePos(),
			filter = LocalPlayer()
		})
		
		if trace.HitWorld then return end
	end
	
	local targetPos = targetEnt:GetPos()
	return VectorToRadar(targetPos.X, targetPos.Y)
end

local function DrawTarget(targetEnt)
	local targetX, targetY, targetDist = VectorToRadarEnt(targetEnt)
	if not targetDist then return end
	
	local color = team.GetColor(targetEnt:Team())
	local alpha = 255 / mapDistPart * math.min(GTAV.Administrate.RadarDist - targetDist, mapDistPart)
	
	surface.SetMaterial(blipPointM)
	surface.SetDrawColor(color.r, color.g, color.b, alpha)
	surface.DrawTexturedRect(targetX - 7, targetY - 7, 16, 16)
	
	if GTAV.ScoreboardActive and targetEnt:IsPlayer() and math.abs(targetX - radarX - 134) ~= 134 and math.abs(targetY - radarY - 84) ~= 84 then
		surface.SetFont("gta5scoreboard")
		
		local nameW = surface.GetTextSize(targetEnt:Name())
		local nameX = targetX - nameW - 21
		local nameY = targetY - 14
		
		local poly = {
			{x = nameX, y = nameY},
			{x = nameX + nameW + 6, y = nameY},
			{x = nameX + nameW + 13, y = nameY + 14},
			{x = nameX + nameW + 6, y = nameY + 28},
			{x = nameX, y = nameY + 28}
		}
		surface.SetTexture(0)
		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawPoly(poly)
		
		draw.SimpleText(targetEnt:Name(), "gta5scoreboard", nameX + 3, nameY + 3, Color(255, 255, 255))
	end
end

local function DrawTargetNPC(targetEnt)
	local targetX, targetY, targetDist = VectorToRadarEnt(targetEnt)
	if not targetDist then return end
	
	local color = team.GetColor(1001)
	local alpha = 255 / mapDistPart * math.min(GTAV.Administrate.RadarDist - targetDist, mapDistPart)
	
	surface.SetMaterial(blipPointM)
	surface.SetDrawColor(color.r, color.g, color.b, alpha)
	surface.DrawTexturedRect(targetX - 7, targetY - 7, 16, 16)
end

local function DrawTargetBody(targetEnt)
	local targetX, targetY, targetDist = VectorToRadarEnt(targetEnt)
	if not targetDist then return end
	
	local alpha = 255 / mapDistPart * math.min(GTAV.Administrate.RadarDist - targetDist, mapDistPart)
	
	surface.SetMaterial(blipBodyM)
	surface.SetDrawColor(0, 0, 0, alpha)
	surface.DrawTexturedRect(targetX - 7, targetY - 7, 16, 16)
end

function GTAV:DrawRadar()
	if not LocalPlayer():Alive() then
		barHealthOld = 0
		barHealthDiff = 0
		barHealthTime = 0
		barHealthPulse = 0
	end
	
	-- Map
	for i = 0, 25 do
		draw.RoundedBox(25 - i, mapShadowX + i, mapShadowY + i, 318 - i * 2, 219 - i * 2, i == 25 and Color(75, 75, 75, 200) or Color(0, 0, 0, (i + 1) / 2))
	end
	
	-- Bar
	surface.SetDrawColor(0, 0, 0, 220)
	surface.DrawRect(radarX, barBackgorundY, 268, 21)
	--draw.RoundedBox(0, radarX, barBackgorundY, 268, 21, Color(0, 0, 0, 220))
	
	-- Health
	local barHealth = math.Clamp(LocalPlayer():Health() * 1.32, 0, 132)
    if barHealthOld ~= barHealth then
	    if barHealthOld > barHealth then
	    	barHealthDiff = barHealthOld - barHealth
    		barHealthTime = CurTime() + 1
			barHealthPulse = CurTime() + 1
		end
		barHealthOld = barHealth
	end
	
	if barHealth > 33 then
		surface.SetDrawColor(53, 154, 71, 100)
		surface.DrawRect(radarX, barY, 132, 9)
		--draw.RoundedBox(0, radarX, barY, 132, 9, Color(53, 154, 71, 100))
		surface.SetDrawColor(53, 154, 71)
		surface.DrawRect(radarX, barY, barHealth, 9)
		--draw.RoundedBox(0, radarX, barY, barHealth , 9, Color(53, 154, 71))
	else
		surface.SetDrawColor(224, 50, 50, 100)
		surface.DrawRect(radarX, barY, 132, 9)
		--draw.RoundedBox(0, radarX, barY, 132, 9, Color(224, 50, 50, 100))
		
		if barHealth ~= 0 then
			surface.SetDrawColor(224, 50, 50, 100 + 155 * (barHealthPulse - CurTime()))
			surface.DrawRect(radarX, barY, barHealth, 9)
			--draw.RoundedBox(0, radarX, barY, barHealth , 9, Color(224, 50, 50, 100 + 155 * (barHealthPulse - CurTime())))
		end
		
		if barHealthPulse < CurTime() then
			barHealthPulse = CurTime() + 1
		end
	end
	
	if barHealthTime > CurTime() then
		surface.SetDrawColor(235, 36, 39, 255 * (barHealthTime - CurTime()))
		surface.DrawRect(radarX + barHealth, barY, barHealthDiff, 9)
		--draw.RoundedBox(0, radarX + barHealth, barY, barHealthDiff, 9, Color(235, 36, 39, 255 * (barHealthTime - CurTime())))
		
		surface.SetMaterial(mapDamageM)
		surface.SetDrawColor(235, 36, 39, 255 * (barHealthTime - CurTime()))
		surface.DrawTexturedRect(radarX, radarY, 268, 169)
	end
	
	-- Armor
	surface.SetDrawColor(93, 182, 229, 100)
	surface.DrawRect(barArmorX, barY, barArmorW, 9)
	--draw.RoundedBox(0, barArmorX, barY, barArmorW, 9, Color(93, 182, 229, 100))
	
	local barArmor = math.Clamp(LocalPlayer():Armor() * barArmorStep, 0, barArmorW)
	if barArmor ~= 0 then
		surface.SetDrawColor(93, 182, 229)
		surface.DrawRect(barArmorX, barY, barArmor , 9)
		--draw.RoundedBox(0, barArmorX, barY, barArmor , 9, Color(93, 182, 229))
	end
	
	-- Hunger
	if barHungerX then
		surface.SetDrawColor(240, 200, 80, 100)
		surface.DrawRect(barHungerX, barY, barArmorW, 9)
		--draw.RoundedBox(0, barHungerX, barY, barArmorW, 9, Color(240, 200, 80, 100))
		
		if DarkRP then
			local barHunger = math.Clamp((LocalPlayer():getDarkRPVar("Energy") or 0) * barArmorStep, 0, barArmorW)
			if barHunger ~= 0 then
				surface.SetDrawColor(240, 200, 80)
				surface.DrawRect(barHungerX, barY, barHunger , 9)
				--draw.RoundedBox(0, barHungerX, barY, barHunger , 9, Color(240, 200, 80))
			end
		end
	end
	
	-- Angle
	local plyAng = -LocalPlayer():GetViewEntity():EyeAngles()[2] + 180
	
	-- North
	local northX, northY = math.sin(math.rad(plyAng)) * mapRadiusNorthMin
	
	if plyAng > 90 and plyAng < 270 then
		northY = math.cos(math.rad(plyAng)) * mapRadiusNorthMin
	else
		northY = math.cos(math.rad(plyAng)) * mapRadiusNorthMax
	end
	
	northX = math.Clamp(northX, -134, 134)
	northY = math.Clamp(northY, -84, 84)
	
	northX = radarX + northX + 134
	northY = radarY + northY + 84
	
	surface.SetMaterial(blipNorthM)
	surface.SetDrawColor(255, 255, 255)
	surface.DrawTexturedRect(northX - 16, northY - 16, 32, 32)
	
	-- Target
	surface.SetFont("gta5scoreboard")
	
	-- for _, targetEnt in pairs(table.Add(table.Add(table.Add(ents.FindByClass("class C_ClientRagdoll"), ents.FindByClass("class C_HL2MPRagdoll")), ents.FindByClass("npc_*")), player.GetAll())) do
		-- if targetEnt == LocalPlayer() or targetEnt:IsPlayer() and not targetEnt:Alive() or targetEnt:Health() < 0 or targetEnt:GetClass() ~= "class C_ClientRagdoll" and targetEnt:GetClass() ~= "class C_HL2MPRagdoll" and not targetEnt:IsNPC() and not targetEnt:IsPlayer() then continue end
		
		-- local targetPos = targetEnt:GetPos()
		-- local targetX, targetY, targetDist = VectorToRadar(targetPos[1], targetPos[2])
		-- if not targetDist then continue end
		
		-- local alpha = 255 / (GTAV.Administrate.RadarDist / 4) * math.min(GTAV.Administrate.RadarDist - targetDist, GTAV.Administrate.RadarDist / 4)
		
		-- if targetEnt:GetClass() == "class C_ClientRagdoll" or targetEnt:GetClass() == "class C_HL2MPRagdoll" then
			-- draw.SimpleText("r", "body", targetX, targetY, Color(0, 0, 0, alpha), 1, 1)
		-- else
			-- draw.SimpleTextOutlined("n", "target", targetX, targetY, ColorAlpha(targetEnt:IsPlayer() and team.GetColor(targetEnt:Team()) or team.GetColor(1001), alpha), 1, 1, 1, Color(0, 0, 0, alpha))
			
			-- if GTAV.ScoreboardActive and targetEnt:IsPlayer() and math.abs(targetX - radarX - 134) ~= 134 and math.abs(targetY - radarY - 84) ~= 84 then
				-- local nameW, nameH = surface.GetTextSize(targetEnt:Name())
				-- local nameX = targetX - nameW - 21 - 8
				-- local nameY = targetY - nameH / 2 - 7
				
				-- local poly = {
					-- {x = nameX, y = nameY},
					-- {x = nameX + nameW + 14, y = nameY},
					-- {x = nameX + nameW + 21, y = nameY + nameH / 2 + 7},
					-- {x = nameX + nameW + 14, y = nameY + nameH + 14},
					-- {x = nameX, y = nameY + nameH + 14},
				-- }
				
				-- surface.SetDrawColor(0, 0, 0, 200)
				-- surface.DrawPoly(poly)
				
				-- draw.SimpleText(targetEnt:Name(), "gta5scoreboard", nameX + 3, nameY + 3, Color(255, 255, 255))
			-- end
		-- end
	-- end
	
	for _, targetEnt in pairs(ents.GetAll()) do
		if targetEnt:IsNPC() then
			DrawTargetNPC(targetEnt)
		elseif targetEnt:GetClass() == "class C_ClientRagdoll" or targetEnt:GetClass() == "class C_HL2MPRagdoll" then
			--draw.SimpleText("r", "body", targetX, targetY, Color(0, 0, 0, alpha), 1, 1)
			DrawTargetBody(targetEnt)
		end
	end
	
	for _, targetEnt in pairs(player.GetAll()) do
		if targetEnt == LocalPlayer() or not targetEnt:Alive() then continue end
		DrawTarget(targetEnt)
	end
	
	-- Blips
	for _, tab in pairs(GTAV.Blips) do
		local targetX, targetY, targetDist = VectorToRadar(tab[4], tab[5])
		
		if not targetDist or math.abs(targetX - radarX - 134) == 134 or math.abs(targetY - radarY - 84) == 84 then continue end
		
		surface.SetMaterial(tab[1])
		surface.SetDrawColor(255, 255, 255)
		surface.DrawTexturedRect(targetX - tab[2] / 2, targetY - tab[3] / 2, tab[2], tab[3])
	end
	
	for _, tab in pairs(GTAV.BlipsClass) do
		for _, ent in pairs(ents.FindByClass(tab[4])) do
			local targetPos = ent:GetPos()
			local targetX, targetY, targetDist = VectorToRadar(targetPos[1], targetPos[2])
			
			if not targetDist or math.abs(targetX - radarX - 134) == 134 or math.abs(targetY - radarY - 84) == 84 then continue end
			
			surface.SetMaterial(tab[1])
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(targetX - tab[2] / 2, targetY - tab[3] / 2, tab[2], tab[3])
		end
	end
	
	-- Player
	surface.SetMaterial(blipPlayerM)
	surface.SetDrawColor(255, 255, 255)
	surface.DrawTexturedRect(blipPlayerX, blipPlayerY, 32, 32)
	
	-- Voice
	if voiceEnable then
		surface.SetMaterial(voiceM)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawTexturedRect(radarX + 264, radarY + 132, 64, 64)
	end
end

hook.Remove("HUDPaint", "myaddons_hud")


--[[----------------
	Radar: Voice
----------------]]--

function GAMEMODE:PlayerStartVoice(ply)
	if ply == LocalPlayer() then
		voiceEnable = true
	end
end

function GAMEMODE:PlayerEndVoice(ply)
	if ply == LocalPlayer() then
		voiceEnable = false
	end
end

print("[GTAV HUD] Loaded: cl_radar.lua")