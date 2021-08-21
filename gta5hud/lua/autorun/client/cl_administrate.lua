--[[----------------------
	GTA V Administrate
	Made by Doliman100
----------------------]]--

--[[------------------------------
	Administrate: Control Menu
------------------------------]]--

local function AddSlider(panel, text, var, value, min, max, decimals)
	local slider = vgui.Create("DNumSlider")
	slider:SetText(text)
	slider.Label:SetTextColor(Color(0, 0, 0))
	slider:SetMinMax(min, max)
	slider:SetDecimals(decimals or 0)
	slider:SizeToContents()
	slider.Edit = false
	slider.Think = function(self)
		if not LocalPlayer():IsSuperAdmin() or not self.Edit or self:IsEditing() then return end
		self.Edit = false
		
		GTAV.Administrate[var] = self:GetValue()
		
		net.Start("gta5settings_update")
		net.WriteTable(GTAV.Administrate)
		net.SendToServer()
	end
	slider.SetValue = function(self, val)
		val = math.max(tonumber(val) or 0, self:GetMin())
		if self:GetValue() == val then return end
		
		self.Scratch:SetValue(val)
		self:ValueChanged(val)
		
		self.Edit = true
	end
	slider:SetValue(GTAV.Administrate[var] or value)
	panel:AddItem(slider)
end

local function AddCheckBox(panel, text, var, value)
	local checkBox = vgui.Create("DCheckBoxLabel")
	checkBox:SetValue(GTAV.Administrate[var] == nil and value or GTAV.Administrate[var])
	checkBox:SetText(text)
	checkBox:SetTextColor(Color(0, 0, 0))
	checkBox:SizeToContents()
	checkBox.OnChange = function(_, val)
		if not LocalPlayer():IsSuperAdmin() then return end
		
		GTAV.Administrate[var] = val
		
		net.Start("gta5settings_update")
		net.WriteTable(GTAV.Administrate)
		net.SendToServer()
	end
	panel:AddItem(checkBox)
end

local categoryShow = {}
local function WeaponwheelSlot(panel, id)
	local slot = vgui.Create("DCollapsibleCategory")
	slot:SetLabel("Weapon Wheel - Slot "..id)
	slot:SetExpanded(categoryShow[id])
	slot.OnToggle = function(self, status)
		categoryShow[id] = status
	end
	panel:AddItem(slot)
	
	slot.Panel = vgui.Create("DPanelList")
	slot.Panel:SetPadding(1)
	slot.Panel:SetSpacing(1)
	slot.Panel:SetAutoSize(true)
	slot.Panel.Paint = function(self, w, h)
		surface.SetDrawColor(124, 190, 255)
		surface.DrawRect(0, 0, w, h)
		--draw.RoundedBox(0, 0, 0, w, h, Color(124, 190, 255))
	end
	slot:SetContents(slot.Panel)
	
	slot.List = vgui.Create("DListView")
	slot.List:SetHeight(152)
	slot.List:AddColumn("Weapon Class")
	slot.List.Change = function(self)
		self:Clear()
		for k, v in pairs(GTAV.Administrate.WeaponwheelSlots) do
			if v == id then
				self:AddLine(k)
			end
		end
		self:SortByColumn(1)
	end
	slot.List.OnRowRightClick = function()
		local menu = DermaMenu()
		menu:AddOption("Remove", function()
			if not LocalPlayer():IsSuperAdmin() then return end
			
			for _, panel in pairs(slot.List:GetSelected()) do
				GTAV.Administrate.WeaponwheelSlots[panel:GetValue(1)] = nil
			end
			
			slot.List:Change()
			
			net.Start("gta5settings_update")
			net.WriteTable(GTAV.Administrate)
			net.SendToServer()
		end)
		menu:Open()
	end
	slot.List:Change()
	slot.Panel:AddItem(slot.List)
	
	slot.Input = vgui.Create("DTextEntry")
	slot.Input:SetText("Enter new class name")
	slot.Input:SetHeight(22)
	slot.Input:SelectAllOnFocus()
	slot.Panel:AddItem(slot.Input)
	
	slot.Button = vgui.Create("DButton")
	slot.Button:SetText("Add class name")
	slot.Button:SetHeight(18)
	slot.Button.DoClick = function(self)
		if not LocalPlayer():IsSuperAdmin() then return end
		
		if string.Trim(slot.Input:GetValue()) == "" or slot.Input:GetValue() == "Enter new class name" then
			LocalPlayer():ChatPrint("[GTAV HUD] Warning: Enter normal class name!")
			return
		end
		
		GTAV.Administrate.WeaponwheelSlots[slot.Input:GetValue()] = id
		
		slot.List:Change()
		
		net.Start("gta5settings_update")
		net.WriteTable(GTAV.Administrate)
		net.SendToServer()
	end
	slot.Panel:AddItem(slot.Button)
end

local function AdministrateBuildPanel(panel)
	panel:Clear()
	
	-- Weapon Wheel Slots
	if GTAV.Administrate.WeaponwheelSlots then
		for i = 1, 8 do
			WeaponwheelSlot(panel, i)
		end
	end
	
	-- Show
	AddSlider(panel, "Radar Distance", "RadarDist", 250, 0, 1000)
	AddSlider(panel, "Radar Distance View", "RadarDistView", 100, 10, 200)
	AddSlider(panel, "Radar Safe", "RadarSafe", 15, 0, 100)
	AddCheckBox(panel, "Radar Feels Wall", "RadarFeelsWall", false)
	AddCheckBox(panel, "Show Radar", "ShowRadar", true)
	AddCheckBox(panel, "Show Notice", "ShowNotice", true)
	AddCheckBox(panel, "Show Notice Right", "ShowNoticeRight", true)
	AddCheckBox(panel, "Show Scoreboard", "ShowScoreboard", true)
	AddCheckBox(panel, "Show Scoreboard Group", "ShowScoreboardGroup", false)
	AddCheckBox(panel, "Show Deathscreen", "ShowDeathscreen", true)
	AddCheckBox(panel, "Show Weaponwheel", "ShowWeaponwheel", true)
	AddCheckBox(panel, "Show Money", "ShowMoney", false)
	AddCheckBox(panel, "Show Ammo", "ShowAmmo", true)
	AddCheckBox(panel, "Show Hunger", "ShowHunger", false)
	AddCheckBox(panel, "Show Stamina", "ShowStamina", false)
	
	-- Update
	local updateBtn = vgui.Create("DButton")
	updateBtn:SetText("Update")
	updateBtn.DoClick = function()
		if not LocalPlayer():IsSuperAdmin() then return end
		
		net.Start("gta5player_update")
		net.SendToServer()
	end
	panel:AddItem(updateBtn)
	
	-- Author
	panel:Help("Made by Doliman100\nVersion " .. GTAV.Version)
	
	GTAV.AdministratePanel = GTAV.AdministratePanel or panel
end


--[[----------------------
	Administrate: Hook
----------------------]]--

hook.Add("SpawnMenuOpen", "gta5administrate_SpawnMenuOpen", function()
	if GTAV.AdministratePanel then AdministrateBuildPanel(GTAV.AdministratePanel) end
end)

hook.Add("PopulateToolMenu", "gta5administrate_PopulateToolMenu", function()
	spawnmenu.AddToolMenuOption("Options", "GTA V HUD", "gta5hud_Administrate", "Administrate", "", "", AdministrateBuildPanel)
end)

print("[GTAV HUD] Loaded: cl_administrate.lua")