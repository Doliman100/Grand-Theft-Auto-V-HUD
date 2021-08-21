--[[----------------------
	GTA V Init CL
	Made by Doliman100
----------------------]]--

--[[----------
	Tables
----------]]--

GTAV.Blips = {}
GTAV.BlipsClass = {}
GTAV.HideElements = {}

--[[----------
	Global
----------]]--

GTAV.Global = {}

GTAV.Global.RadarScale = 2

--[[--------------------
	Settings: Custom
--------------------]]--

GTAV.Custom = {}

local safezoneSize = math.Clamp(GetConVar("gta5hud_safezone_size"):GetFloat(), 0, 1)

GTAV.Custom.OffsetX = ScrW() / 20 * safezoneSize
GTAV.Custom.OffsetY = ScrH() / 20 * safezoneSize

GTAV.Custom.NoticeStack = GetConVar("gta5hud_notice_stack"):GetBool()
GTAV.Custom.NoticeMax = GetConVar("gta5hud_notice_max"):GetInt()
GTAV.Custom.NoticeDuration = GetConVar("gta5hud_notice_duration"):GetFloat()
GTAV.Custom.NoticeAppearance = GetConVar("gta5hud_notice_appearance"):GetFloat()

GTAV.Custom.WeaponwheelKey = GetConVar("gta5hud_weaponwheel_key"):GetInt()
GTAV.Custom.WeaponwheelSensitivity = GetConVar("gta5hud_weaponwheel_sensitivity"):GetInt()
GTAV.Custom.WeaponwheelLock = GetConVar("gta5hud_weaponwheel_lock"):GetBool()


--[[-----------
	Methods
-----------]]--

function GTAV:ScreenScale(size)
	return math.floor(size * (ScrH() / 1080))
end

function GTAV:AddBlip(mat, w, h, x, y)
	table.insert(GTAV.Blips, {Material(mat, "smooth"), w, h, x, y})
end

function GTAV:AddBlipClass(mat, w, h, class)
	table.insert(GTAV.BlipsClass, {Material(mat, "smooth"), w, h, class})
end


--[[-----------
	Modules
-----------]]--

include("gta5hud/blips.lua")
include("gta5hud/cl_radar.lua")
include("gta5hud/cl_notice.lua")
include("gta5hud/cl_info.lua")
include("gta5hud/cl_stamina.lua")
include("gta5hud/cl_weaponwheel.lua")
include("gta5hud/cl_deathscreen.lua")
include("gta5hud/cl_scoreboard.lua")


--[[------------------
	Hook: HUDPaint
------------------]]--

hook.Add("HUDPaint", "gta5hud_HUDPaint", function()
	if LocalPlayer():GetActiveWeapon() ~= NULL and LocalPlayer():GetActiveWeapon():GetClass() == "gmod_camera" then return end
	
	if GTAV.Administrate.ShowRadar then
		GTAV:DrawRadar()
	end
	
	if GTAV.Administrate.ShowNotice then
		GTAV:DrawNotice()
	end
	
	if GTAV.Administrate.ShowStamina then
		GTAV:DrawStamina()
	end
	
	GTAV:DrawInfo()
	
	if GTAV.Administrate.ShowWeaponwheel then
		GTAV:DrawWeaponwheel()
	end
	
	if GTAV.Administrate.ShowDeathscreen then
		GTAV:DrawDeathscreen()
	end
end)


--[[--------------------------
	Hook: DarkRPVarChanged
--------------------------]]--

hook.Add("DarkRPVarChanged", "gta5hud_DarkRPVarChanged", function(ply, var, old, new)
	if ply ~= LocalPlayer() then return end
	
	old = old or new
	
	if GTAV.ChangedInfo then
		GTAV:ChangedInfo(var, old, new)
	end
end)


--[[-----------------------
	Hook: HUDShouldDraw
-----------------------]]--

hook.Add("HUDShouldDraw", "gta5hud_HUDShouldDraw", function(name)
	if GTAV.HideElements[name] then return false end
	if GTAV.Administrate.ShowRadar and (name == "CHudHealth" or name == "CHudBattery" or name == "DarkRP_LocalPlayerHUD") then return false end
	if GTAV.Administrate.ShowAmmo and (name == "CHudAmmo" or name == "CHudSecondaryAmmo") then return false end
end)

print("[GTAV HUD] Loaded: cl_init.lua")