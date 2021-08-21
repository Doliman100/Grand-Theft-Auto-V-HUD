--[[----------------------
	GTA V HUD
	Made by Doliman100
----------------------]]--

if SERVER then
	-- Content
	resource.AddWorkshop("514740282")
	
	-- Font
	resource.AddSingleFile("resource/fonts/PricedownGTAVInt.ttf")
	
	-- Lua
	AddCSLuaFile("gta5hud/blips.lua")
	AddCSLuaFile("gta5hud/cl_deathscreen.lua")
	AddCSLuaFile("gta5hud/cl_info.lua")
	AddCSLuaFile("gta5hud/cl_init.lua")
	AddCSLuaFile("gta5hud/cl_notice.lua")
	AddCSLuaFile("gta5hud/cl_radar.lua")
	AddCSLuaFile("gta5hud/cl_scoreboard.lua")
	AddCSLuaFile("gta5hud/cl_stamina.lua")
	AddCSLuaFile("gta5hud/cl_weaponwheel.lua")
else
	-- Global Table
	GTAV = GTAV or {}
	GTAV.Version = "23.11.16"
	
	-- Administrate
	net.Receive("gta5settings_get", function()
		GTAV.Administrate = net.ReadTable()
	end)
	
	-- Update
	net.Receive("gta5player_update", function()
		include("gta5hud/cl_init.lua")
	end)
end

print("[GTAV HUD] Loaded: gta5hud.lua")