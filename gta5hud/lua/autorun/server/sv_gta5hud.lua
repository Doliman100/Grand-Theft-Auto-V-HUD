--[[----------------------
	GTA V Init SV
	Made by Doliman100
----------------------]]--

--[[-------------------------
	Administrate: Default
-------------------------]]--

local Administrate = {}
local AdministrateDefault = {
	WeaponwheelSlots = {
		weapon_ar2			= 1,
		
		weapon_crossbow		= 2,
		
		weapon_fists		= 3,
		weapon_physgun		= 3,
		weapon_physcannon	= 3,
		weapon_crowbar		= 3,
		weapon_stunstick	= 3,
		weapon_bugbait		= 3,
		weapon_medkit		= 3,
		gmod_tool			= 3,
		
		weapon_shotgun		= 4,
		
		weapon_rpg			= 5,
		
		weapon_frag			= 6,
		weapon_slam			= 6,
		
		weapon_pistol		= 7,
		weapon_357			= 7,
		
		weapon_smg1			= 8,
	},
	RadarDist			= 250,
	RadarDistView		= 100,
	RadarSafe			= 0,
	RadarFeelsWall		= false,
	ShowRadar			= true,
	ShowNotice			= true,
	ShowNoticeRight		= true,
	ShowScoreboard		= true,
	ShowScoreboardGroup	= false,
	ShowDeathscreen		= true,
	ShowWeaponwheel		= true,
	ShowMoney			= false,
	ShowAmmo			= true,
	ShowHunger			= false,
	ShowStamina			= false,
}


local f = file.Read("gta5hud_administrate.txt", "DATA")
if f and f ~= "" then
	Administrate = util.JSONToTable(f)

	for k, v in pairs(AdministrateDefault) do
		if Administrate[k] == nil then
			Administrate[k] = v
		end
	end
else
	Administrate = AdministrateDefault
end

file.Write("gta5hud_administrate.txt", util.TableToJSON(Administrate))


--[[------------------------
	Administrate: Update
------------------------]]--

util.AddNetworkString("gta5settings_get")
util.AddNetworkString("gta5settings_update")

net.Receive("gta5settings_update", function(_, ply)
	if not ply:IsSuperAdmin() then return end
	
	local tab = net.ReadTable()
	if not tab then return end
	
	Administrate = tab
	file.Write("gta5hud_administrate.txt", util.TableToJSON(Administrate))

	net.Start("gta5settings_get")
	net.WriteTable(Administrate)
	net.Broadcast()
end)


--[[------------------
	Player: Update
------------------]]--

util.AddNetworkString("gta5player_update")
net.Receive("gta5player_update", function(_, ply)
	if not ply:IsSuperAdmin() then return end
	
	net.Start("gta5player_update")
	net.Broadcast()
end)


--[[--------------------------
	Hook: PlayerDeathSound
--------------------------]]--

hook.Add("PlayerDeathSound", "gta5hud_PlayerDeathSound", function()
	if Administrate.ShowDeathscreen then
		return true
	end
end)


--[[---------------
	Hook: Death
---------------]]--

util.AddNetworkString("gta5death")

hook.Add("DoPlayerDeath", "gta5hud_DoPlayerDeath", function(victim, attacker, dmg)
	if not Administrate.ShowDeathscreen then return end

	local kill_type = dmg:GetDamageType()
	local ammo_type = dmg:GetAmmoType()
	
	if attacker:IsVehicle() then
		attacker = attacker:GetDriver()
		kill_type = 16
	end
	
	net.Start("gta5death")
	net.WriteEntity(attacker)
	net.WriteInt(kill_type, 29)
	net.WriteInt(ammo_type, 4)
	net.Send(victim)
end)


--[[----------------
	Hook: Killed
----------------]]--

util.AddNetworkString("gta5killed")

hook.Add("PlayerDeath", "gta5hud_PlayerDeath", function(victim, _, attacker)
	if not Administrate.ShowNotice then return end

	if IsValid(attacker) then
		if attacker:GetClass() == "trigger_hurt" then
			attacker = victim
		elseif attacker:IsVehicle() and IsValid(attacker:GetDriver()) then
			attacker = attacker:GetDriver()
		end
	end
	
	net.Start("gta5killed")
	net.WriteEntity(attacker)
	net.WriteEntity(victim)
	net.Broadcast()
end)

hook.Add("OnNPCKilled", "gta5hud_OnNPCKilled", function(victim, attacker)
	if not Administrate.ShowNotice or victim:GetClass() == "npc_bullseye" or victim:GetClass() == "npc_launcher" then return end
	
	if IsValid(attacker) then
		if attacker:GetClass() == "trigger_hurt" then
			attacker = victim
		elseif attacker:IsVehicle() and IsValid(attacker:GetDriver()) then
			attacker = attacker:GetDriver()
		end
	end
	
	net.Start("gta5killed")
	net.WriteEntity(attacker)
	net.WriteEntity(victim)
	net.Broadcast()
end)


--[[--------------
	Hook: Join
--------------]]--

util.AddNetworkString("gta5player_join")

hook.Add("PlayerInitialSpawn", "gta5hud_PlayerInitialSpawn", function(ply)
	local tab = player.GetHumans()
	
	for k, v in pairs(tab) do
		if v == ply then
			tab[k] = nil
		end
	end
	
	if Administrate.ShowNotice then
		net.Start("gta5player_join")
		net.WriteColor(team.GetColor(ply:Team()))
		net.WriteString(ply:Name())
		net.Send(tab)
	end
	
	net.Start("gta5settings_get")
	net.WriteTable(Administrate)
	net.Send(ply)
	
	net.Start("gta5player_update")
	net.Send(ply)
end)


--[[--------------
	Hook: Left
--------------]]--

util.AddNetworkString("gta5player_left")

hook.Add("PlayerDisconnected", "gta5hud_PlayerDisconnected", function(ply)
	if not Administrate.ShowNotice then return end
	
	net.Start("gta5player_left")
	net.WriteColor(team.GetColor(ply:Team()))
	net.WriteString(ply:Name())
	net.Broadcast()
end)

print("[GTAV HUD] Loaded: sv_gta5hud.lua")