--[[----------------------
	GTA V Сustom
	Made by Doliman100
----------------------]]--

--[[----------------------
	Сustom: Con Vars
----------------------]]--

local convars_full = {}
local convars_default = {
	gta5hud_weaponwheel_key = "12",
	gta5hud_weaponwheel_sensitivity = "8",
	gta5hud_weaponwheel_lock = "0",
	gta5hud_safezone_size = "0.50",
	gta5hud_notice_max = "10",
	gta5hud_notice_duration = "5.00",
	gta5hud_notice_appearance = "0.25",
	gta5hud_notice_stack = "1"
}

for name, value in pairs(convars_default) do
	CreateClientConVar(name, value)
	convars_full[#convars_full + 1] = name
end


--[[--------------------------
	Сustom: Control Menu
--------------------------]]--

local function CustomBuildPanel(panel)
	panel:Clear()
	
	-- Profiles
 	panel:AddControl("ComboBox", {
		MenuButton = 1,
		Folder = "gta5hud",
		Options = {["default"] = convars_default},
		CVars = convars_full
	})
	
	-- Binder
	panel:Help("Weapon Wheel Key")
	local binder = vgui.Create("DBinder")
	binder:SetConVar("gta5hud_weaponwheel_key")
	panel:AddItem(binder)
	
	-- Settings
	panel:NumSlider("Weapon Wheel Sensitivity", "gta5hud_weaponwheel_sensitivity", 1, 12)
	panel:CheckBox("Weapon Wheel Lock Mouse", "gta5hud_weaponwheel_lock")
	panel:NumSlider("HUD Safezone Size", "gta5hud_safezone_size", 0, 1, 2)
	panel:NumSlider("Notice Max", "gta5hud_notice_max", 5, 20)
	panel:NumSlider("Notice Duration", "gta5hud_notice_duration", 1, 10, 2)
	panel:NumSlider("Notice Appearance", "gta5hud_notice_appearance", 0.05, 1, 2)
	panel:CheckBox("Notice Stack", "gta5hud_notice_stack")
	
	-- Update
	local updateBtn = vgui.Create("DButton")
	updateBtn:SetText("Update")
	updateBtn.DoClick = function()
		include("gta5hud/cl_init.lua")
	end
	panel:AddItem(updateBtn)
	
	-- Author
	panel:Help("Made by Doliman100\nVersion " .. GTAV.Version)
	
	GTAV.CustomPanel = GTAV.CustomPanel or panel
end

--[[------------------
	Сustom: Hook
------------------]]--

hook.Add("SpawnMenuOpen", "gta5сustom_SpawnMenuOpen", function()
	if GTAV.CustomPanel then CustomBuildPanel(GTAV.CustomPanel) end
end)

hook.Add("PopulateToolMenu", "gta5сustom_PopulateToolMenu", function()
	spawnmenu.AddToolMenuOption("Options", "GTA V HUD", "gta5hud_Сustom", "Сustom", "", "", CustomBuildPanel)
end)

print("[GTAV HUD] Loaded: cl_custom.lua")