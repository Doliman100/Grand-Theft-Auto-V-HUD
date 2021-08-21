--[[----------------------
	GTA V Scoreboard
	Made by Doliman100
----------------------]]--

--[[---------------------
	Scoreboard: Clear
---------------------]]--

if ValidPanel(GTAV.Scoreboard) then
	GTAV.Scoreboard:Remove()
end


--[[---------
	Fonts
---------]]--

surface.CreateFont("gta5scoreboard", {
	size = 22
})

surface.CreateFont("gta5scoreboard_friend", {
	size = 12
})


--[[--------------
	Scoreboard
--------------]]--

local scoreboardW = 426

local title = GetHostName()
if game.SinglePlayer() then
	title = title.." (Solo, "
elseif GetConVar("sv_lan"):GetInt() == 1 then
	title = title.." (Local, "
else
	title = title.." (Public, "
end

surface.SetFont("gta5scoreboard")
local titleW = surface.GetTextSize(title) + 93 -- "000) (0/0)"

local keyPressedLeft, keyPressedRight


--[[---------------------
	Scoreboard: Panel
---------------------]]--

local PANEL = {}

function PANEL:Init()
	self.Page = 1
	
	self:SetVisible(false)
	self:SetPos(GTAV.Custom.OffsetX, GTAV.Custom.OffsetY)
	self:Update()
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(0, 0, 0, 240)
	surface.DrawRect(0, 0, w, 32)
	--draw.RoundedBox(0, 0, 0, w, 32, Color(0, 0, 0, 240))
	draw.SimpleText(title..#player.GetAll()..")", "gta5scoreboard", 5, 5)
	
	if self.Pages > 1 then
		draw.SimpleText("("..self.Page.."/"..self.Pages..")", "gta5scoreboard", w - 5, 5, Color(255, 255, 255), 2)
	end
end

function PANEL:Update()
	surface.SetFont("gta5scoreboard")
	scoreboardW = math.max(426, titleW)
	
	self:Clear()
	self.Players = {}
	
	for id, ply in pairs(player.GetAll()) do
		self.Players[#self.Players + 1] = ply
		
		local lineW = surface.GetTextSize(ply:Name()..team.GetName(ply:Team())..(GTAV.Administrate.ShowScoreboardGroup and "  "..ply:GetUserGroup() or "")) + 140
		if scoreboardW < lineW then
			scoreboardW = lineW
		end
		
		ply.Line = true
	end
	
	table.sort(self.Players, function(a, b)
		if team.GetName(a:Team()) != team.GetName(b:Team()) then return team.GetName(a:Team()) < team.GetName(b:Team()) end
		if a:Frags() != b:Frags() then return a:Frags() > b:Frags() end
		return a:Name() < b:Name()
	end)
	
	self.Pages = math.max(math.ceil(#self.Players / 16), 1)
	self.Page = math.min(self.Page, self.Pages)
	
	for id = 16 * self.Page - 15, math.min(16 * self.Page, #self.Players) do
		local line = self:Add("gta5scoreboard_line")
		line:Init(self.Players[id], id - 16 * (self.Page - 1))
	end
	
	self:SetSize(scoreboardW, 32 * (math.min(16 * self.Page, #self.Players) - 16 * (self.Page - 1) + 1))
end

function PANEL:Think()
	if input.IsKeyDown(KEY_LEFT) and not keyPressedLeft then
		keyPressedLeft = true
		
		self.Page = self.Page > 1 and self.Page - 1 or self.Pages
		self:Update()
	elseif not input.IsKeyDown(KEY_LEFT) and keyPressedLeft then
		keyPressedLeft = false
	end
	
	if input.IsKeyDown(KEY_RIGHT) and not keyPressedRight then
		keyPressedRight = true
		
		self.Page = self.Page < self.Pages and self.Page + 1 or 1
		self:Update()
	elseif not input.IsKeyDown(KEY_RIGHT) and keyPressedRight then
		keyPressedRight = false
	end
	
	for k, v in pairs(player.GetAll()) do
		if not v.Line then
			self:Update()
			break
		end
	end
end

vgui.Register("gta5scoreboard", PANEL, "Panel")

--[[--------------------
	Scoreboard: Line
--------------------]]--

PANEL = {}

function PANEL:Init(ply, id)
	if not IsValid(ply) then return end
	
	self.Id = id
	self.Player = ply
	
	self.Volume = 0
	self.VolumeTime = 0
	
	self:SetPos(0, 32 * id)
	self:SetSize(scoreboardW, 32)
	
	self.AvatarBotton = self:Add("Button")
	self.AvatarBotton:SetSize(32, 32)
	self.AvatarBotton.DoClick = function()
		self.Player:ShowProfile()
	end
	
	self.Avatar = self.AvatarBotton:Add("AvatarImage")
	self.Avatar:SetSize(32, 32)
	self.Avatar:SetPlayer(self.Player, 32)
	self.Avatar:SetMouseInputEnabled(false)
	
	self.Friend = self.AvatarBotton:Add("Panel")
	self.Friend:SetPos(2, 2)
	self.Friend:SetSize(4, 7)
	self.Friend.Paint = function(self)
		draw.SimpleText(self.Text, "gta5scoreboard_friend", -1, -2, Color(0, 0, 0))
	end
	
	self.Frags = self:Add("Panel")
	self.Frags:SetPos(scoreboardW - 71, 5)
	self.Frags:SetSize(39, 22)
	self.Frags.Text = self.Player:Frags() --"-999"
	self.Frags.Paint = function(self)
		draw.SimpleText(self.Text, "gta5scoreboard", 39, 0, Color(255, 255, 255), 2)
	end
	
	self.MutedButton = self:Add("DImageButton")
	self.MutedButton:SetPos(scoreboardW - 32, 0)
	self.MutedButton:SetSize(32, 32)
	self.MutedButton:SetText("")
	self.MutedButton.DoClick = function()
		self.Player:SetMuted(not self.Player:IsMuted())
	end
end

function PANEL:Think()
	if not IsValid(self.Player) or self.Frags.Text ~= self.Player:Frags() then
		GTAV.Scoreboard:Update()
		return
	end
	
	self.Friend.Text = self.Player:GetFriendStatus() == "friend" and "F" or ""
	self.Muted = self.Player:IsMuted()
	
	if not self.Muted and self.VolumeTime < CurTime() then
		if math.Round(self.Player:VoiceVolume(), 1) > 0 then
			self.Volume = self.Player:VoiceVolume()
			self.VolumeTime = CurTime() + 0.25
		else
			self.Volume = 0
		end
	end
	
	if self.Muted then
		self.MutedButton:SetImage("gta5hud/scoreboard/audio_mute.png")
	elseif self.Volume > 0.6 then
		self.MutedButton:SetImage("gta5hud/scoreboard/audio_3.png")
	elseif self.Volume > 0.3 then
		self.MutedButton:SetImage("gta5hud/scoreboard/audio_2.png")
	elseif self.Volume > 0 then
		self.MutedButton:SetImage("gta5hud/scoreboard/audio_1.png")
	else
		self.MutedButton:SetImage("gta5hud/scoreboard/audio_0.png")
	end
end

function PANEL:Paint(w, h)
	local playerName = self.Player:Name()
	local playerTeam = team.GetName(self.Player:Team())
	
	surface.SetFont("gta5scoreboard")
	local nameW = surface.GetTextSize(playerName)
	local teamW = surface.GetTextSize(playerTeam) + 14
	
	local teamX = nameW + 50
	
	surface.SetTexture(0)
	
	-- Team Color
	surface.SetDrawColor(45, 110, 185)
	surface.DrawRect(32, 0, 6, 32)
	--draw.RoundedBox(0, 32, 0, 6, 32, Color(45, 110, 185))
	
	-- Line
	if self.Id % 2 == 0 then
		surface.SetDrawColor(58, 103, 156, 250)
		--draw.RoundedBox(0, 38, 0, w - 38, 32, Color(58, 103, 156, 250))
	else
		surface.SetDrawColor(67, 120, 181, 250)
		--draw.RoundedBox(0, 38, 0, w - 38, 32, Color(67, 120, 181, 250))
	end
	surface.DrawRect(38, 0, w - 38, 32)
	
	-- Name
	draw.SimpleText(playerName, "gta5scoreboard", 41, 5)
	
	-- Tag
	draw.RoundedBox(2, teamX - 1, 4, teamW + 2, 24, Color(0, 0, 0))
	draw.RoundedBox(2, teamX, 5, teamW, 22, Color(255, 255, 255))
	draw.SimpleText(playerTeam, "gta5scoreboard", teamX + 7, 5, Color(0, 0, 0))
	
	-- ULX Group
	if GTAV.Administrate.ShowScoreboardGroup then
		draw.SimpleText(" "..self.Player:GetUserGroup(), "gta5scoreboard", teamX + teamW, 5, Color(255, 255, 255))
	end
end

vgui.Register("gta5scoreboard_line", PANEL, "Panel")


--[[----------------------
	Scoreboard: Active
----------------------]]--

GTAV.Scoreboard = vgui.Create("gta5scoreboard")

hook.Add("ScoreboardShow", "gta5scoreboard_ScoreboardShow", function()
	GTAV.ScoreboardActive = true
	if not GTAV.Administrate.ShowScoreboard then return end
	
	gui.EnableScreenClicker(true)
	GTAV.Scoreboard:SetVisible(true)
	return false
end)

hook.Add("ScoreboardHide", "gta5scoreboard_ScoreboardHide", function()
	GTAV.ScoreboardActive = false
	if not GTAV.Administrate.ShowScoreboard and not GTAV.Scoreboard:IsVisible() then return end
	
	gui.EnableScreenClicker(false)
	GTAV.Scoreboard:SetVisible(false)
	return false
end)

print("[GTAV HUD] Loaded: cl_scoreboard.lua")