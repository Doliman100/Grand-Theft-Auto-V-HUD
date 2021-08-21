--[[----------------------
	GTA V Stamina
	Made by Doliman100
----------------------]]--


--[[---------
	Fonts
---------]]--

surface.CreateFont("gta5stamina", {
	size = 20
})


--[[----------
	Stamina
----------]]--

local staminaM = Material("gta5hud/gradient.png")

local staminaX = ScrW() - GTAV.Custom.OffsetX - 298
local staminaY = ScrH() - GTAV.Custom.OffsetY - 30


--[[----------------
	Stamina: Draw
----------------]]--

function GTAV:DrawStamina()
	surface.SetMaterial(staminaM)
	surface.SetDrawColor(255, 255, 255, 200)
	surface.DrawTexturedRect(staminaX, staminaY, 298, 30)
	
	surface.SetDrawColor(45, 110, 185, 100)
	surface.DrawRect(staminaX + 158, staminaY + 8, 131, 12)
	--draw.RoundedBox(0, staminaX + 158, staminaY + 8, 131, 12, Color(45, 110, 185, 100))
	
	local staminaStamina = math.Clamp((LocalPlayer():GetNWInt("tcb_stamina") or 0) * 1.31, 0, 131)
	if staminaStamina ~= 0 then
		surface.SetDrawColor(45, 110, 185)
		surface.DrawRect(staminaX + 158, staminaY + 8, staminaStamina, 12)
		--draw.RoundedBox(0, staminaX + 158, staminaY + 8, staminaStamina, 12, Color(45, 110, 185))
	end
	
	draw.SimpleText("STAMINA", "gta5stamina", staminaX + 143, staminaY + 6, Color(255, 255, 255), 2)
end

print("[GTAV HUD] Loaded: cl_stamina.lua")