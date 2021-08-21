--[[----------------------
	GTA V Notice
	Made by Doliman100
----------------------]]--

--[[---------
	Fonts
---------]]--

surface.CreateFont("gta5notice", {
	font = "Tahoma",
	size = 20,
	weight = 600
})


--[[----------
	Notice
----------]]--

local noticeBackground = Material("gta5hud/radar/gradient.png")
local noticeBackgroundFlip = Material("gta5hud/radar/gradient_flip.png")

local noticeX = GTAV.Custom.OffsetX
local noticeY = ScrH() - GTAV.Custom.OffsetY

surface.SetFont("gta5notice")
local _, noticeFontH = surface.GetTextSize("gta5notice")


--[[---------------
	Notice: Add
---------------]]--

local noticeList = {}
local function noticeAdd(duration, ...)
	local args = {...}
	local lines = {{}}
	
	local lineId = 1
	local lineW = 0
	local lineStr = ""
	
	surface.SetFont("gta5notice")
	for argId, arg in pairs(args) do
		if IsColor(arg) then
			if string.Trim(lineStr) ~= "" then
				table.insert(lines[lineId], lineStr)
				lineStr = ""
			end
			
			table.insert(lines[lineId], arg)
		else
			for WordN, Word in pairs(string.Split(arg, " ")) do
				local WordW = surface.GetTextSize(" "..Word)
				
				if WordN ~= 1 and lineW + WordW <= 244 then
					Word = " "..Word
				else
					WordW = surface.GetTextSize(Word)
					
					if WordW > 244 then
						if WordN ~= 1 then Word = " "..Word end
						
						for CharN, Char in pairs(string.ToTable(Word)) do
							local CharW = surface.GetTextSize(Char)
							
							if lineW + CharW > 244 then
								table.insert(lines[lineId], lineStr)
								
								lineId = lineId + 1
								lineW = 0
								lineStr = ""
								
								lines[lineId] = {}
							end
							
							lineW = lineW + CharW
							lineStr = lineStr..Char
						end
						
						continue
					elseif lineW + WordW > 244 or WordN ~= 1 and string.Left(Word, 1) ~= " " then
						table.insert(lines[lineId], lineStr)
						
						lineId = lineId + 1
						lineW = 0
						lineStr = ""
						
						lines[lineId] = {}
					end
				end
				
				lineW = lineW + WordW
				lineStr = lineStr..Word
			end
		end
	end
	
	if string.Trim(lineStr) ~= "" then
		table.insert(lines[lineId], lineStr)
	end
	
	local lastTimer = 0
	if noticeList[1] then lastTimer = noticeList[1].Timer end
	
	table.insert(noticeList, 1, {
		Lines = lines,
		Duration = duration,
		Timer = lastTimer + GTAV.Custom.NoticeAppearance > CurTime() and lastTimer or CurTime()
	})
	
	if #noticeList > GTAV.Custom.NoticeMax then
		table.remove(noticeList, #noticeList)
	end
end


--[[----------------
	Notice: Draw
----------------]]--

function GTAV:DrawNotice()
	local offset = 0
	
	for noticeId, noticeTab in pairs(noticeList) do
		local color = Color(255, 255, 255)
		
		local offsetX = 0
		local offsetY = 0
		
		local noticeH = noticeFontH * #noticeTab.Lines + 24
		local noticeY = noticeY - noticeH - offset + 12 - (GTAV.Administrate.ShowNoticeRight and (GTAV.Administrate.ShowStamina and 33 or 0) or 190 + 22)
		
		surface.SetMaterial(GTAV.Administrate.ShowNoticeRight and noticeBackgroundFlip or noticeBackground)
		surface.SetDrawColor(255, 255, 255, 240)
		surface.DrawTexturedRect(GTAV.Administrate.ShowNoticeRight and ScrW() - 268 - noticeX or noticeX, noticeY - 12, 268, noticeH)
		
		for _, line in pairs(noticeTab.Lines) do
			for _, arg in pairs(line) do
				if IsColor(arg) then
					color = arg
				else
					draw.SimpleText(arg, "gta5notice", (GTAV.Administrate.ShowNoticeRight and ScrW() - 268 - noticeX or noticeX) + offsetX + 12, noticeY + offsetY, color)
					offsetX = offsetX + surface.GetTextSize(arg)
				end
			end
			
			offsetX = 0
			offsetY = offsetY + noticeFontH
		end
		
		if noticeId == 1 and noticeTab.Timer + GTAV.Custom.NoticeAppearance > CurTime() then
			offset = offset + (noticeH + 3) / GTAV.Custom.NoticeAppearance * (CurTime() - noticeTab.Timer)
		else
			offset = offset + noticeH + 3
		end
		
		if noticeTab.Timer + noticeTab.Duration < CurTime() then
			table.remove(noticeList, noticeId)
		end
	end
end


--[[------------------
	Notice: Killed
------------------]]--

net.Receive("PlayerKilled", nil)
net.Receive("PlayerKilledSelf", nil)
net.Receive("PlayerKilledByPlayer", nil)
net.Receive("PlayerKilledNPC", nil)
net.Receive("NPCKilledNPC", nil)

net.Receive("gta5killed", function()
	if gmod.GetGamemode().ThisClass == "gamemode_darkrp" and GAMEMODE.Config.showdeaths == false then return end
	
	local attacker, attackerName, attackerColor = net.ReadEntity()
	local victim, victimName, victimColor = net.ReadEntity()
	
	if not IsValid(attacker) or not IsValid(victim) then return end
	
	if attacker:IsPlayer() then
		attackerName = attacker:Name()
		attackerColor = team.GetColor(attacker:Team())
	elseif attacker:IsValid() then
		attackerName = language.GetPhrase(attacker:GetClass())
		attackerColor = team.GetColor(1001)
	end
	
	if victim:IsPlayer() then
		victimName = victim:Name()
		victimColor = team.GetColor(victim:Team())
	elseif victim:IsValid() then
		victimName = language.GetPhrase(victim:GetClass())
		victimColor = team.GetColor(1001)
	end
	
	if attacker == LocalPlayer() or victim == LocalPlayer() then
		if attacker == victim or attacker == "worldspawn" then
			noticeAdd(GTAV.Custom.NoticeDuration, "You committed suicide.")
		elseif attacker == LocalPlayer() then
			noticeAdd(GTAV.Custom.NoticeDuration, "You killed ", victimColor, victimName)
		elseif attacker:IsPlayer() or attacker:IsNPC() then
			noticeAdd(GTAV.Custom.NoticeDuration, attackerColor, attackerName, Color(255, 255, 255), " killed you.")
		else
			noticeAdd(GTAV.Custom.NoticeDuration, "You died.")
		end
	elseif attacker == victim or attacker == "worldspawn" then
		noticeAdd(GTAV.Custom.NoticeDuration, victimColor, victimName, Color(255, 255, 255), " has chosen the easy way out.")
	elseif attacker:IsPlayer() or attacker:IsNPC() then
		noticeAdd(GTAV.Custom.NoticeDuration, attackerColor, attackerName, Color(255, 255, 255), " killed ", victimColor, victimName..".")
	else
		noticeAdd(GTAV.Custom.NoticeDuration, victimColor, victimName, Color(255, 255, 255), " died.")
	end
end)


--[[---------------------
	Notice: Picked Up
---------------------]]--

hook.Add("HUDItemPickedUp", "gta5hud_HUDItemPickedUp", function(itemName)
	noticeAdd(GTAV.Custom.NoticeDuration, "You picked up ", language.GetPhrase(itemName)..".")
	return false
end)

hook.Add("HUDWeaponPickedUp", "gta5hud_HUDWeaponPickedUp", function(weapon)
	if not IsValid(weapon) then return end
	noticeAdd(GTAV.Custom.NoticeDuration, "You picked up ", language.GetPhrase(isfunction(weapon.GetPrintName) and weapon:GetPrintName() or weapon:GetClass())..".")
	return false
end)

hook.Add("HUDAmmoPickedUp", "gta5hud_HUDAmmoPickedUp", function(itemName, amount)
	local lastTab = noticeList[1]
	local remove = false
	
	if GTAV.Custom.NoticeStack and lastTab and lastTab.Name == itemName then
		amount = amount + lastTab.Amount
		remove = true
	end
	
	noticeAdd(GTAV.Custom.NoticeDuration, "You picked up ", amount, " ammo of type ", language.GetPhrase(itemName.."_ammo")..".")
	
	if GTAV.Custom.NoticeStack then
		noticeList[1].Name = itemName
		noticeList[1].Amount = amount
		noticeList[1].Timer = CurTime() - GTAV.Custom.NoticeAppearance
		
		if remove then
			table.remove(noticeList, 2)
		end
	end
	
	return false
end)


--[[-----------------------
	Notice: Join / Left
-----------------------]]--

net.Receive("gta5player_join", function()
	noticeAdd(GTAV.Custom.NoticeDuration, net.ReadColor(), net.ReadString(), Color(255, 255, 255), " join.")
end)

net.Receive("gta5player_left", function()
	noticeAdd(GTAV.Custom.NoticeDuration, net.ReadColor(), net.ReadString(), Color(255, 255, 255), " left.")
end)


--[[------------------------
	Notice: Notification
------------------------]]--

function notification.AddLegacy(text, type, duration)
	if string.Left(text, 1) == "#" then
		text = string.sub(text, 2)
	end
	
	text = language.GetPhrase(text)
	
	if type == NOTIFY_ERROR then
		noticeAdd(duration, Color(195, 0, 0), "(!) ", Color(255, 255, 255), text)
	elseif type == NOTIFY_HINT then
		noticeAdd(duration, Color(20, 145, 255), "(?) ", Color(255, 255, 255), text)
	elseif type == NOTIFY_UNDO then
		noticeAdd(duration, Color(20, 145, 255), "(U) ", Color(255, 255, 255), text)
	else
		noticeAdd(duration, text)
	end
end


--[[ Debug
noticeAdd(5, Color(0, 0, 0), "[Notice] ", Color(255, 255, 255), "this text.", Color(0, 150, 200), " And this is a long sentence :D ", "and is a great word WWWWWWWWWWWWWWWWW", " More sentence!!!", Color(150, 150, 150), " И про русский текст не забыл :)")

timer.Create("Addnotice", 1, 3, function()
	noticeAdd(5, Color(194, 80, 80), "Doliman100[RUS]", Color(255, 255, 255), " killed ", Color(93, 182, 229), "SHooTeR")
end)
--]]

print("[GTAV HUD] Loaded: cl_notice.lua")
