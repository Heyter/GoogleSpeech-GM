if (!netlibs) then
	return
end

local goospeech = goospeech
local string_gsub, string_format, string_len, IsValid, ipairs, vgui_Create = string.gsub, string.format, string.len, IsValid, ipairs, vgui.Create

local GoogleBool = CreateClientConVar("cl_google_enabled", "1", true)
local GoogleInWorld = CreateClientConVar("cl_google_enabled_3d", "0", true)
local GoogleVoice = CreateClientConVar("cl_google_voice", "oksana", true, true)

local function httpUrlEncode(text) -- thanks to wiremod
	local ndata = string_gsub(text, "[^%w _~%.%-]", function(str)
		local nstr = string_format("%X", string.byte(str))
		return "%"..((string_len(nstr) == 1) and "0" or "")..nstr
	end)
	return string_gsub(ndata, " ", "+")
end

hook.Add("OnPlayerChat", "goospeech.OnPlayerChat", function(player, text)
	if !IsValid(player) or !GoogleBool:GetBool() then return end
	
	if goospeech:HasValue(player) then
		local encode = string_format("http://tts.voicetech.yandex.net/tts?speaker=%s&text=%s", goospeech:GetVoice(player), httpUrlEncode(text))
		local flag = "mono"
		if GoogleInWorld:GetBool() then
			flag = "3D"
		end
		sound.PlayURL(encode, flag, function(station)
			if IsValid(station) then
				if GoogleInWorld:GetBool() then
					station:SetPos(player:GetPos())
				end
				station:Play()
			else
				chat.AddText(Color(0, 255, 0), "voicetech.yandex not working!")
			end
		end)
		
		encode, flag = nil, nil
	end
end)

local voices = goospeech.voices
local function GetVoices(ply)
	for _, v in ipairs(voices) do
		if (GoogleVoice:GetString() or goospeech:GetVoice(ply)) == v.en_name then
			return v.ru_name
		end
	end
end

local menu
netstream.Hook("goospeech.start", function()
	if IsValid(menu) then menu:Remove() end
	
	menu = vgui_Create("DFrame")
	menu:SetSize(ScrW() * 0.2, ScrH() * 0.2)
	menu:Center()
	menu:SetDraggable(true)
	menu:ShowCloseButton(true)
	menu:SetTitle("Google speech")
	menu:MakePopup()
	
	local voice = menu:Add('DComboBox')
	voice:Dock(TOP)
	voice:DockMargin(0,0,0,5)
	voice:SetTooltip("Voice speech")
	voice:SetValue(GetVoices(LocalPlayer()))
	for _, add in ipairs(voices) do
		voice:AddChoice(add.ru_name)
	end
	voice.OnSelect = function(idx, val, data)
		for _, add in ipairs(voices) do
			if data == add.ru_name then
				RunConsoleCommand("cl_google_voice", add.en_name)
				netstream.Start("goospeech.end")
				break
			end
		end
	end
	
	local sgs = menu:Add('DForm')
	//sgs:SetTall(48)
	sgs:Dock(FILL)
	sgs:SetName("Settings")
	sgs:CheckBox("Enable google speech?", "cl_google_enabled")
	sgs:CheckBox("Enable 3D google speech?", "cl_google_enabled_3d")
end)