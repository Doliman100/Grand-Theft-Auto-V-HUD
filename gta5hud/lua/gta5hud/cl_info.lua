--[[----------------------
	GTA V Info
	Made by Doliman100
----------------------]]--

--[[---------
	Fonts
---------]]--

surface.CreateFont("gta5info_big", {
	font = "PricedownGTAVInt",
	size = 42
})

surface.CreateFont("gta5info_small", {
	font = "PricedownGTAVInt",
	size = 37
})


--[[--------
	Info
--------]]--

local infoX = ScrW() - GTAV.Custom.OffsetX
local infoY = GTAV.Custom.OffsetY

local fontBigH = draw.GetFontHeight("gta5info_big")
local fontSmallH = draw.GetFontHeight("gta5info_small")


--[[-----------------
	Info: Changed
-----------------]]--

local money = LocalPlayer().getDarkRPVar and LocalPlayer():getDarkRPVar("money") or 0
local moneyDiff = 0
local moneyTimer = 0

function GTAV:ChangedInfo(var, old, new)
	if var == "money" then
		if new - old ~= 0 then
			if moneyTimer - 3 > CurTime() then
				moneyDiff = new - old + moneyDiff
			else
				moneyDiff = new - old
			end
			
			moneyTimer = CurTime() + 5
		end
		
		money = new
	end
end


--[[--------------
	Info: Draw
--------------]]--

function GTAV:DrawInfo()
	local offset = 0
	
	-- Money
	if GTAV.Administrate.ShowMoney then
		draw.SimpleTextOutlined("$"..money, "gta5info_big", infoX, infoY + offset, Color(240, 240, 240), 2, 0, 2, Color(0, 0, 0))
		offset = offset + fontBigH
		
		-- Changed
		if moneyTimer > CurTime() then
			if moneyDiff > 0 then
				draw.SimpleTextOutlined("+$"..moneyDiff, "gta5info_small", infoX, infoY + offset, Color(102, 152, 104), 2, 0, 2, Color(0, 0, 0))
			else
				draw.SimpleTextOutlined("-$"..math.abs(moneyDiff), "gta5info_small", infoX, infoY + offset, Color(194, 80, 80), 2, 0, 2, Color(0, 0, 0))
			end
			
			offset = offset + fontSmallH
		end
	end
	
	-- Ammo
	if not GTAV.Administrate.ShowAmmo then return end
	
    local weapon = LocalPlayer():GetActiveWeapon()
    if IsValid(weapon) then
		local weaponPrimaryType = weapon:GetPrimaryAmmoType()
		local weaponSecondaryType = weapon:GetSecondaryAmmoType()
		
		local weaponClip = weapon:Clip1()
		local weaponPrimary = LocalPlayer():GetAmmoCount(weaponPrimaryType)
		local weaponSecondary = LocalPlayer():GetAmmoCount(weaponSecondaryType)
		
		if weaponPrimaryType > 0 or weapon:GetClass() == "weapon_medkit" then
			if weaponClip < 0 then
				draw.SimpleTextOutlined(weaponPrimary, "gta5info_small", infoX, infoY + offset, Color(240, 240, 240), 2, 0, 2, Color(0, 0, 0))
			else
				draw.SimpleTextOutlined(weaponClip, "gta5info_small", infoX, infoY + offset, Color(138, 138, 138), 2, 0, 2, Color(0, 0, 0))
				draw.SimpleTextOutlined(weaponPrimary, "gta5info_small", infoX - surface.GetTextSize(" "..weaponClip), infoY + offset, Color(240, 240, 240), 2, 0, 2, Color(0, 0, 0))
			end
			
			offset = offset + fontSmallH
		end
		
		if weaponSecondaryType > 0 and weaponSecondary > 0 then
			draw.SimpleTextOutlined(weaponSecondary, "gta5info_small", infoX, infoY + offset, Color(240, 240, 240), 2, 0, 2, Color(0, 0, 0))
		end
	end
end

print("[GTAV HUD] Loaded: cl_info.lua")