--[[----------------------
	GTA V Weapon Wheel
	Made by Doliman100
----------------------]]--

--[[---------
	Fonts
---------]]--

surface.CreateFont("gta5weaponwheel_icons_hl2", {
	font = "HL2MP",
	size = 100
})

surface.CreateFont("gta5weaponwheel_icons_css", {
	font = "csd",
	size = 100
})

surface.CreateFont("gta5weaponwheel_ammo", {
	size = 23
})


--[[----------------------------
	Weapon Wheel: Properties
----------------------------]]--

-- Muddle
local middleX = math.Round(ScrW() / 2)
local middleY = math.Round(ScrH() / 2.5)

-- Arrow
local arrowM = Material("materials/gta5hud/weaponwheel/arrow.png")

-- Parts
local weaponwheelPartM = Material("materials/gta5hud/weaponwheel/part.png")
local weaponwheelPartMAng = Material("materials/gta5hud/weaponwheel/part_ang.png")

local weaponwheelPartSelectedM = Material("materials/gta5hud/weaponwheel/selected.png")
local weaponwheelPartSelectedMAng = Material("materials/gta5hud/weaponwheel/selected_ang.png")

local weaponwheelPartCurrentM = Material("materials/gta5hud/weaponwheel/current.png")
local weaponwheelPartCurrentMAng = Material("materials/gta5hud/weaponwheel/current_ang.png")

-- Sides
local weaponwheelPartLeftX = middleX - 240
local weaponwheelPartLeftY = middleY

local weaponwheelPartRightX = middleX + 240
local weaponwheelPartRightY = middleY

local weaponwheelPartTopX = middleX
local weaponwheelPartTopY = middleY - 240

local weaponwheelPartBottomX = middleX
local weaponwheelPartBottomY = middleY + 240

-- Angles
local weaponwheelPartTLeftX = middleX - 178
local weaponwheelPartTLeftY = middleY - 178

local weaponwheelPartTRightX = middleX + 178
local weaponwheelPartTRightY = middleY - 178

local weaponwheelPartBLeftX = middleX - 178
local weaponwheelPartBLeftY = middleY + 178

local weaponwheelPartBRightX = middleX + 178
local weaponwheelPartBRightY = middleY + 178

-- Info
local slotSelected = 3
 GTAV.SlotSelectedSub = GTAV.SlotSelectedSub or {1, 1, 1, 1, 1, 1, 1, 1}

local weaponwheelIconW = 0

local weaponwheelIconLetters = {"A", "B", "I", "O", "P", "Q", "a", "b", "c", "c", "d", "e", "f", "h", "i", "j", "k", "l", "m", "n", "o", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}
local weaponwheelIconHalfLife2 = {
	weapon_stunstick	= "!",
	weapon_slam			= "*",
	weapon_physgun		= ",",
	weapon_physcannon	= ",",
	weapon_pistol		= "-",
	weapon_357			= ".",
	weapon_smg1			= "/",
	weapon_shotgun		= "0",
	weapon_crossbow		= "1",
	weapon_ar2			= "2",
	weapon_rpg			= "3",
	weapon_frag			= "4",
	weapon_bugbait		= "5",
	weapon_crowbar		= "6"
}


--[[----------------------
	Weapon Wheel: Draw
----------------------]]--

local slotCurrent, weaponSlots, keyPressedPrev, keyPressedNext, weaponwheelStatus
function GTAV:DrawWeaponwheel()
	if not weaponwheelStatus then return end
	if not LocalPlayer():Alive() then return end
	
	-- Slot Selected
	local cursorX = gui.MouseX() - middleX
	local cursorY = gui.MouseY() - middleY
	
	local cursorPos = Vector(cursorX, cursorY, 0)
	
	if cursorPos:Length2D() > GTAV.Custom.WeaponwheelSensitivity then
		local slotSelectedOld = slotSelected
		slotSelected = math.ceil((cursorPos:Angle().y + 22.5) % 360 / 45)
		
		if slotSelected ~= slotSelectedOld then
			surface.PlaySound("gta5hud/weaponselect.wav")
		end
	end
	
	if GTAV.Custom.WeaponwheelLock then
		gui.SetMousePos(middleX, middleY)
	end
	
	-- Slot Selected Sub
	if input.IsMouseDown(MOUSE_LEFT) then
		if not keyPressedPrev then
			keyPressedPrev = true
			GTAV.SlotSelectedSub[slotSelected] = GTAV.SlotSelectedSub[slotSelected] > 1 and GTAV.SlotSelectedSub[slotSelected] - 1 or #weaponSlots[slotSelected]
			
			surface.PlaySound("gta5hud/weaponselect.wav")
		end
	elseif keyPressedPrev then
		keyPressedPrev = false
	end
	
	if input.IsMouseDown(MOUSE_RIGHT) then
		if not keyPressedNext then
			keyPressedNext = true
			GTAV.SlotSelectedSub[slotSelected] = GTAV.SlotSelectedSub[slotSelected] < #weaponSlots[slotSelected] and GTAV.SlotSelectedSub[slotSelected] + 1 or 1
			
			surface.PlaySound("gta5hud/weaponselect.wav")
		end
	elseif keyPressedNext then
		keyPressedNext = false
	end
	
	-- Draw
	surface.SetDrawColor(255, 255, 255)
	
	-- Parts
	surface.SetMaterial(weaponwheelPartM)
	
	if slotSelected ~= 5 then
		surface.DrawTexturedRect(weaponwheelPartLeftX - 128, weaponwheelPartLeftY - 128, 256, 256)
	end
	if slotSelected ~= 3 then
		surface.DrawTexturedRectRotated(weaponwheelPartBottomX, weaponwheelPartBottomY, 256, 256, 90)
	end
	if slotSelected ~= 1 then
		surface.DrawTexturedRectRotated(weaponwheelPartRightX, weaponwheelPartRightY, 256, 256, 180)
	end
	if slotSelected ~= 7 then
		surface.DrawTexturedRectRotated(weaponwheelPartTopX, weaponwheelPartTopY, 256, 256, 270)
	end
	
	surface.SetMaterial(weaponwheelPartMAng)
	
	if slotSelected ~= 6 then
		surface.DrawTexturedRect(weaponwheelPartTLeftX - 128, weaponwheelPartTLeftY - 128, 256, 256)
	end
	if slotSelected ~= 4 then
		surface.DrawTexturedRectRotated(weaponwheelPartBLeftX, weaponwheelPartBLeftY, 256, 256, 90)
	end
	if slotSelected ~= 2 then
		surface.DrawTexturedRectRotated(weaponwheelPartBRightX, weaponwheelPartBRightY, 256, 256, 180)
	end
	if slotSelected ~= 8 then
		surface.DrawTexturedRectRotated(weaponwheelPartTRightX, weaponwheelPartTRightY, 256, 256, 270)
	end
	
	-- Selected
	if slotSelected % 2 == 0 then
		surface.SetMaterial(weaponwheelPartSelectedMAng)
	else
		surface.SetMaterial(weaponwheelPartSelectedM)
	end
	
	if slotSelected == 1 then
		surface.DrawTexturedRectRotated(weaponwheelPartRightX, weaponwheelPartRightY, 256, 256, 180)
	elseif slotSelected == 2 then
		surface.DrawTexturedRectRotated(weaponwheelPartBRightX, weaponwheelPartBRightY, 256, 256, 180)
	elseif slotSelected == 3 then
		surface.DrawTexturedRectRotated(weaponwheelPartBottomX, weaponwheelPartBottomY, 256, 256, 90)
	elseif slotSelected == 4 then
		surface.DrawTexturedRectRotated(weaponwheelPartBLeftX, weaponwheelPartBLeftY, 256, 256, 90)
	elseif slotSelected == 5 then
		surface.DrawTexturedRect(weaponwheelPartLeftX - 128, weaponwheelPartLeftY - 128, 256, 256)
	elseif slotSelected == 6 then
		surface.DrawTexturedRect(weaponwheelPartTLeftX - 128, weaponwheelPartTLeftY - 128, 256, 256)
	elseif slotSelected == 7 then
		surface.DrawTexturedRectRotated(weaponwheelPartTopX, weaponwheelPartTopY, 256, 256, 270)
	elseif slotSelected == 8 then
		surface.DrawTexturedRectRotated(weaponwheelPartTRightX, weaponwheelPartTRightY, 256, 256, 270)
	end
	
	local weapon = weaponSlots[slotSelected][GTAV.SlotSelectedSub[slotSelected]]
	if weapon then
		draw.SimpleTextOutlined(language.GetPhrase(isfunction(weapon.GetPrintName) and weapon:GetPrintName() or weapon:GetClass()), "gta5weaponwheel_ammo", middleX, middleY - 115, Color(255, 255, 255), 1, 0, 1, Color(0, 0, 0))
		
		if #weaponSlots[slotSelected] > 1 then
			local textW, textH = surface.GetTextSize(GTAV.SlotSelectedSub[slotSelected].." / "..#weaponSlots[slotSelected])
			draw.SimpleTextOutlined(GTAV.SlotSelectedSub[slotSelected].." / "..#weaponSlots[slotSelected], "gta5weaponwheel_ammo", middleX - textW / 2 , middleY - textH / 2 - 59, Color(255, 255, 255), 0, 0, 1, Color(0, 0, 0)) --59
			
			surface.SetMaterial(arrowM)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRectRotated(middleX - textW / 2 - 24, middleY - 59, 32, 32, 180)
			surface.DrawTexturedRect(middleX + textW / 2 + 8, middleY - 75, 32, 32)
		end
	end
	
	-- Current
	if slotCurrent then
		if slotCurrent % 2 == 0 then
			surface.SetMaterial(weaponwheelPartCurrentMAng)
		else
			surface.SetMaterial(weaponwheelPartCurrentM)
		end
		
		if slotCurrent == 1 then
			surface.DrawTexturedRectRotated(weaponwheelPartRightX, weaponwheelPartRightY, 256, 256, 180)
		elseif slotCurrent == 2 then
			surface.DrawTexturedRectRotated(weaponwheelPartBRightX, weaponwheelPartBRightY, 256, 256, 180)
		elseif slotCurrent == 3 then
			surface.DrawTexturedRectRotated(weaponwheelPartBottomX, weaponwheelPartBottomY, 256, 256, 90)
		elseif slotCurrent == 4 then
			surface.DrawTexturedRectRotated(weaponwheelPartBLeftX, weaponwheelPartBLeftY, 256, 256, 90)
		elseif slotCurrent == 5 then
			surface.DrawTexturedRect(weaponwheelPartLeftX - 128, weaponwheelPartLeftY - 128, 256, 256)
		elseif slotCurrent == 6 then
			surface.DrawTexturedRect(weaponwheelPartTLeftX - 128, weaponwheelPartTLeftY - 128, 256, 256)
		elseif slotCurrent == 7 then
			surface.DrawTexturedRectRotated(weaponwheelPartTopX, weaponwheelPartTopY, 256, 256, 270)
		elseif slotCurrent == 8 then
			surface.DrawTexturedRectRotated(weaponwheelPartTRightX, weaponwheelPartTRightY, 256, 256, 270)
		end
	end
	
	-- Icons
	for weaponSlot, weaponSlotSub in pairs(weaponSlots) do
		local weapon = weaponSlotSub[GTAV.SlotSelectedSub[weaponSlot]]
		if not weapon then continue end
		
		local x, y
		if weaponSlot == 1 then
			x = weaponwheelPartRightX
			y = weaponwheelPartRightY
		elseif weaponSlot == 2 then
			x = weaponwheelPartBRightX
			y = weaponwheelPartBRightY
		elseif weaponSlot == 3 then
			x = weaponwheelPartBottomX
			y = weaponwheelPartBottomY
		elseif weaponSlot == 4 then
			x = weaponwheelPartBLeftX
			y = weaponwheelPartBLeftY
		elseif weaponSlot == 5 then
			x = weaponwheelPartLeftX
			y = weaponwheelPartLeftY
		elseif weaponSlot == 6 then
			x = weaponwheelPartTLeftX
			y = weaponwheelPartTLeftY
		elseif weaponSlot == 7 then
			x = weaponwheelPartTopX
			y = weaponwheelPartTopY
		elseif weaponSlot == 8 then
			x = weaponwheelPartTRightX
			y = weaponwheelPartTRightY
		end
		
		local textW, textH
		if weaponwheelIconHalfLife2[weapon:GetClass()] then
			surface.SetFont("gta5weaponwheel_icons_hl2")
			textW, textH = surface.GetTextSize(weaponwheelIconHalfLife2[weapon:GetClass()])
			draw.SimpleTextOutlined(weaponwheelIconHalfLife2[weapon:GetClass()], "gta5weaponwheel_icons_hl2", x, y - textH / 3, Color(125, 125, 125), 1, 0, 1, Color(0, 0, 0))
			
			y = y + textH / 4
		elseif weapon.IconLetter and table.HasValue(weaponwheelIconLetters, weapon.IconLetter) then
			surface.SetFont("gta5weaponwheel_icons_css")
			textW, textH = surface.GetTextSize(weapon.IconLetter)
			draw.SimpleTextOutlined(weapon.IconLetter, "gta5weaponwheel_icons_css", x, y - textH / 3, Color(125, 125, 125), 1, 0, 1, Color(0, 0, 0))
			
			y = y + textH / 4
		else
			surface.SetDrawColor(255, 255, 255)
			surface.SetTexture(weapon.WepSelectIcon or 81)
			surface.DrawTexturedRect(x - 64, y - 42, 128, 64)
			
			y = y + 21
		end
		
		if weaponSlot == 3 then continue end
		
		local weaponClip = weapon:Clip1()
		
		local weaponPrimaryType = weapon:GetPrimaryAmmoType()
		local weaponSecondaryType = weapon:GetSecondaryAmmoType()
		
		local weaponPrimary =  LocalPlayer():GetAmmoCount(weaponPrimaryType)
		local weaponSecondary =  LocalPlayer():GetAmmoCount(weaponSecondaryType)
		
		if weaponPrimaryType > -1 then
			if weaponClip > -1 then
				surface.SetFont("gta5weaponwheel_ammo")
				local primaryW = surface.GetTextSize(weaponPrimary)
				local clipW = surface.GetTextSize(" / "..weaponClip)
				
				local primaryX = x - (primaryW + clipW) / 2
				local clipX = primaryX + primaryW
				
				draw.SimpleTextOutlined(weaponPrimary, "gta5weaponwheel_ammo", primaryX, y , Color(255, 255, 255), 0, 0, 1, Color(0, 0, 0))
				draw.SimpleTextOutlined(" / "..weaponClip, "gta5weaponwheel_ammo", clipX, y, Color(140, 140, 140), 0, 0, 1, Color(0, 0, 0))
			else
				draw.SimpleTextOutlined(weaponPrimary, "gta5weaponwheel_ammo", x, y, Color(255, 255, 255), 1, 0, 1, Color(0, 0, 0))
			end
		elseif weaponSecondaryType > -1 then
			draw.SimpleTextOutlined(weaponSecondary, "gta5weaponwheel_ammo", x, y, Color(255, 255, 255), 1, 0, 1, Color(0, 0, 0))
		end
	end
end


--[[------------------------
	Weapon Wheel: Active
------------------------]]--

local keyPressedShow = false

local function weaponwheelShow()
	weaponwheelStatus = true
	gui.EnableScreenClicker(true)
	gui.SetMousePos(middleX, middleY)
	
	weaponSlots = {{}, {}, {}, {}, {}, {}, {}, {}}
	
	local weapon = LocalPlayer():GetActiveWeapon()
	for _, wep in pairs(LocalPlayer():GetWeapons()) do
		local weaponSlot = GTAV.Administrate.WeaponwheelSlots[wep:GetClass()]
		if weaponSlot then
			table.insert(weaponSlots[weaponSlot], wep)
			
			if wep == weapon then
				slotCurrent = weaponSlot
				slotSelected = weaponSlot
				
				GTAV.SlotSelectedSub[weaponSlot] = #weaponSlots[weaponSlot]
			end
		end
	end
	
	for k, v in pairs(GTAV.SlotSelectedSub) do
		if v > #weaponSlots[k] then
			GTAV.SlotSelectedSub[k] = #weaponSlots[k] > 1 and #weaponSlots[k] or 1
		end
	end
end

local function weaponwheelHide()
	weaponwheelStatus = false
	gui.EnableScreenClicker(false)
	
	local weapon = weaponSlots[slotSelected][GTAV.SlotSelectedSub[slotSelected]]
	
	if IsValid(weapon) then
		RunConsoleCommand("use", weapon:GetClass())
	end
end

hook.Add("Think", "gta5hud_weaponwheel", function()
	if input.IsKeyDown(GTAV.Custom.WeaponwheelKey) or input.IsMouseDown(GTAV.Custom.WeaponwheelKey) then
		if not keyPressedShow and GTAV.Administrate.ShowWeaponwheel then
			keyPressedShow = true
			weaponwheelShow()
		end
	elseif keyPressedShow and (GTAV.Administrate.ShowWeaponwheel or weaponwheelStatus) then
		keyPressedShow = false
		weaponwheelHide()
	end
end)

print("[GTAV HUD] Loaded: cl_weaponwheel.lua")