if (!netlibs) then
	return
end

local phrases = {}
phrases['en'] = {
	enable_tts = 'Enable voice speech?',
	enable_tts_3d = 'Enable 3D voice speech?',
	settings = 'Settings',
	google_api = 'Google API voice speech',
	menu_title = 'Voice speech',
	error_url = 'Voice speech not working!',
	google_api_tooltip = 'If voice speech not working try enable Google API',
}

phrases['ru'] = {
	enable_tts = 'Включить синтез речи?',
	enable_tts_3d = 'Включить 3D синтез речи?',
	settings = 'Настройки',
	google_api = 'Google API синтез речи',
	menu_title = 'Синтез речи',
	error_url = 'Синтез речи не работает!',
	google_api_tooltip = 'Если синтез речи не работает, попробуйте включить Google API',
}

local function get_language()
	return phrases[GetConVar("gmod_language"):GetString()] or phrases['en']
end

local goospeech = goospeech
local string_gsub, string_format, IsValid, ipairs = string.gsub, string.format, IsValid, ipairs

local GoogleBool = CreateClientConVar("cl_google_enabled", "1", true)
local GoogleInWorld = CreateClientConVar("cl_google_enabled_3d", "0", true)
local GoogleVoice = CreateClientConVar("cl_google_voice", "oksana", true, true)
local GoogleURL = CreateClientConVar("cl_google_url", "0", true)

local function httpUrlEncode(text) -- thanks to wiremod
	local ndata = string_gsub(text, "[^%w _~%.%-]", function(str)
		local nstr = string_format("%X", string.byte(str))
		return "%"..((string.len(nstr) == 1) and "0" or "")..nstr
	end)
	return string_gsub(ndata, " ", "+")
end

hook.Add("OnPlayerChat", "OnPlayerChat_speech", function(player, text, bTeam, bDead)
	if !IsValid(player) or !GoogleBool:GetBool() then return end
	
	if goospeech:HasValue(player) then
		local encode = nil
		
		if (!GoogleURL:GetBool()) then
			encode = string_format("http://tts.voicetech.yandex.net/tts?speaker=%s&text=%s", goospeech:GetVoice(player), httpUrlEncode(text))
		else
			encode = "http://translate.google.com/translate_tts?tl=" .. GetConVar("gmod_language"):GetString() .. "&ie=UTF-8&q=" .. httpUrlEncode(text) .. "&client=tw-ob"
		end

		sound.PlayURL(encode, GoogleInWorld:GetBool() and '3D' or 'mono', function(station)
			if IsValid(station) then
				if GoogleInWorld:GetBool() then
					station:SetPos(player:GetPos())
					//print(station:Get3DCone(), station:Get3DFadeDistance())
				end
				station:Play()
			else
				chat.AddText(Color(200, 0, 0), get_language().error_url)
			end
		end)
		
		encode = nil
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
	local LANG = get_language()
	
	if IsValid(menu) then menu:Remove() end
	
	menu = vgui.Create("DFrame")
	menu:SetSize(ScrW() * 0.2, ScrH() * 0.3)
	menu:Center()
	menu:SetDraggable(true)
	menu:ShowCloseButton(true)
	menu:SetTitle(LANG.menu_title)
	menu:MakePopup()
	
	local voice = menu:Add('DComboBox')
	voice:Dock(TOP)
	voice:DockMargin(0,0,0,5)
	voice:SetTooltip(LANG.menu_title)
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
	sgs:SetName(LANG.settings)
	sgs:CheckBox(LANG.enable_tts, "cl_google_enabled")
	sgs:CheckBox(LANG.enable_tts_3d, "cl_google_enabled_3d")
	local a = sgs:CheckBox(LANG.google_api, 'cl_google_url')
	a:SetTooltip(LANG.google_api_tooltip)
	a:SetChecked(GoogleURL:GetBool())
	
	LANG = nil
end)