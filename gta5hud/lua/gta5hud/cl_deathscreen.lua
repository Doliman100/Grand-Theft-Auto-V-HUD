--[[----------------------
	GTA V Death Screen
	Made by Doliman100
----------------------]]--

--[[---------
	Fonts
---------]]--

surface.CreateFont("gta5deathscreen_title", {
	font = "PricedownGTAVInt",
	size = GTAV:ScreenScale(90)
})

surface.CreateFont("gta5deathscreen_subtitle", {
	size = GTAV:ScreenScale(34)
})


--[[---------------
	Death Types
---------------]]--

local ammoTypes = {}
local killTypes = {}
local deathTypes = {}

ammoTypes[1] = " shot you down."
ammoTypes[4] = " shot you down."
ammoTypes[2] = " dissolved you."
ammoTypes[3] = " gunned you down."
ammoTypes[5] = " gunned you down."
ammoTypes[6] = " broke through you."
ammoTypes[7] = " filled you with buckshot."

killTypes.normal  = " killed you."
killTypes.vehicle = " flattened you."
killTypes.blast   = " blew you up."
killTypes.club    = " beat you."

deathTypes.suicide = "You committed suicide."
deathTypes.club    = "You've died from beatings."
deathTypes.bullet  = "You've died from a bullet."
deathTypes.fall    = "You've died from the fall."
deathTypes.blast   = "You've died from the explosion."
deathTypes.crush   = "You've died because of a prop."


--[[----------------
	Death Screen
----------------]]--

-- Screen
local deathscreenM = Material("gta5hud/deathscreen.png")

-- Effect
local deathscreenTimer = CurTime() + 1
local deathscreenDarkenEffect = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0,
}

-- Line
local deathscreenLineMin = GTAV:ScreenScale(138)
local deathscreenLineMax = GTAV:ScreenScale(222)
local deathscreenLineMid = deathscreenLineMax - deathscreenLineMin
local deathscreenLinePoly = {
	{x = 0, y = (ScrH() - deathscreenLineMin) / 2},
	{x = 0, y = (ScrH() + deathscreenLineMin) / 2},
	{x = ScrW(), y = (ScrH() + deathscreenLineMax) / 2},
	{x = ScrW(), y = (ScrH() - deathscreenLineMax) / 2},
}

-- Title
local deathscreenTitleX = ScrW() / 2
local deathscreenTitleYMin = (ScrH() - deathscreenLineMid / 2) / 2
local deathscreenTitleYMax = ScrH() / 2

-- Subtitle
local deathscreenSubtitleAttacker = ""
local deathscreenSubtitleAttackerX = 0
local deathscreenSubtitleAttackerColor = Color(255, 255, 255)

local deathscreenSubtitleMessage = ""
local deathscreenSubtitleMessageX = 0

local deathscreenSubtitleY = (ScrH() + deathscreenLineMid / 2) / 2


--[[-----------------------
	Death Screen: Reset
-----------------------]]--

net.Receive("gta5death", function()
	local attacker = net.ReadEntity()
	local killType = net.ReadInt(29)
	local ammoType = net.ReadInt(4)
	
	deathscreenTimer = CurTime() + 1
	
	deathscreenSubtitleAttacker = ""
	deathscreenSubtitleMessage = ""
	
	if attacker == LocalPlayer() then
		deathscreenSubtitleMessage = deathTypes.suicide
	elseif attacker:IsPlayer() or attacker:IsNPC() then
		deathscreenSubtitleAttacker = attacker:IsPlayer() and attacker:Name() or "#"..attacker:GetClass()
		deathscreenSubtitleAttackerColor = attacker:IsPlayer() and team.GetColor(attacker:Team()) or team.GetColor(1001)
		
		if ammoType >= 1 and ammoType <= 7 then
			deathscreenSubtitleMessage = ammoTypes[ammoType]
		elseif killType == DMG_BULLET then
			deathscreenSubtitleMessage = ammoTypes[3]
		elseif killType == DMG_VEHICLE then
			deathscreenSubtitleMessage = killTypes.vehicle
		elseif killType == DMG_BLAST then
			deathscreenSubtitleMessage = killTypes.blast
		elseif killType == DMG_CLUB then
			deathscreenSubtitleMessage = killTypes.club
		elseif killType == 4098 then
			deathscreenSubtitleMessage = ammoTypes[6]
		elseif killType == 67108865 then
			deathscreenSubtitleMessage = ammoTypes[2]
		elseif killType == DMG_BUCKSHOT then
			deathscreenSubtitleMessage = ammoTypes[7]
		else
			deathscreenSubtitleMessage = killTypes.normal
		end
	elseif killType == DMG_CRUSH or killType == DMG_VEHICLE then
		deathscreenSubtitleMessage = deathTypes.crush
	elseif killType == DMG_BULLET then
		deathscreenSubtitleMessage = deathTypes.bullet
	elseif killType == DMG_FALL then
		deathscreenSubtitleMessage = deathTypes.fall
	elseif killType == DMG_BLAST then
		deathscreenSubtitleMessage = deathTypes.blast
	elseif killType == DMG_CLUB then
		deathscreenSubtitleMessage = deathTypes.club
	end
	
	surface.SetFont("gta5deathscreen_subtitle")
	local attackerW = surface.GetTextSize(deathscreenSubtitleAttacker)
	local messageW = surface.GetTextSize(deathscreenSubtitleMessage)
	
	deathscreenSubtitleAttackerX = (ScrW() - attackerW - messageW) / 2
	deathscreenSubtitleMessageX = deathscreenSubtitleAttackerX + attackerW
	
	surface.PlaySound("gta5hud/deathsound.wav")
end)


--[[----------------------
	Death Screen: Draw
----------------------]]--

function GTAV:DrawDeathscreen()
	if LocalPlayer():Alive() then return end
	
	-- Blackout
	surface.SetMaterial(deathscreenM)
	surface.SetDrawColor(0, 0, 0, 255 * (1 - math.Max(deathscreenTimer - CurTime(), 0)))
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	
	-- Line
	surface.SetTexture(0)
	surface.SetDrawColor(0, 0, 0, 220)
	surface.DrawPoly(deathscreenLinePoly)
	
	-- Title
	if deathscreenSubtitleMessage == "" then
		draw.SimpleText("Wasted", "gta5deathscreen_title", deathscreenTitleX, deathscreenTitleYMax, LerpVector(math.Max(deathscreenTimer - CurTime(), 0), Vector(182, 86, 87), Vector(130, 130, 130)), 1, 1)
	else
		draw.SimpleText("Wasted", "gta5deathscreen_title", deathscreenTitleX, deathscreenTitleYMin, LerpVector(math.Max(deathscreenTimer - CurTime(), 0), Vector(182, 86, 87), Vector(130, 130, 130)), 1, 1)
		
		-- Subtitle
		if deathscreenSubtitleAttacker == "" then
			draw.SimpleText(deathscreenSubtitleMessage, "gta5deathscreen_subtitle", deathscreenTitleX, deathscreenSubtitleY, Color(255, 255, 255), 1, 5)
		else
			draw.SimpleText(deathscreenSubtitleAttacker, "gta5deathscreen_subtitle", deathscreenSubtitleAttackerX, deathscreenSubtitleY, deathscreenSubtitleAttackerColor, 0, 5)
			draw.SimpleText(deathscreenSubtitleMessage, "gta5deathscreen_subtitle", deathscreenSubtitleMessageX, deathscreenSubtitleY, Color(255, 255, 255), 0, 5)
		end
	end
end


--[[------------------------------------------
	Death Screen: RenderScreenspaceEffects
------------------------------------------]]--

hook.Add("RenderScreenspaceEffects", "gta5deathscreen_RenderScreenspaceEffects", function()
	if LocalPlayer():Alive() or not GTAV.Administrate.ShowDeathscreen then return end
	
	local coeff = math.Max(deathscreenTimer - CurTime(), 0) -- 1~0
	
	deathscreenDarkenEffect["$pp_colour_colour"] = 0.5 + coeff / 2 -- 1~0.5
	DrawColorModify(deathscreenDarkenEffect)
	DrawBloom(0.45 + coeff / 1.8, 4, 9, 9, 0, 0, 1, 1, 1) -- 1~0.45
end)

GTAV.HideElements.CHudDamageIndicator = true

print("[GTAV HUD] Loaded: cl_deathscreen.lua")