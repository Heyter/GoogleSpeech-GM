if (not netlibs) then return end

goospeech = goospeech or {}
goospeech.steamids = {
	["STEAM_0:1:29606990"] = true,
	["superadmin"] = true,
}

goospeech.ChatCommand = {
	"/google",
	"!google",
	"/speech",
	"!speech",
}

goospeech.default_voice = "Oksana"
goospeech.voices = {
	["Zahar"] = true,
	["Ermil"] = true,
	["Oksana"] = true,
	["Alyss"] = true,
	["Omazh"] = true,
	["Jane"] = true
}

/* Functions */
function goospeech:HasValue(ply)
	return self.steamids[ply:SteamID()] or self.steamids[ply:GetUserGroup()]
end

function goospeech:SetVoice(player, voice)
	if (!self:HasValue(player)) then return end
	
	voice = voice or self['default_voice']
	if (not self.voices[voice]) then
		voice = self['default_voice']
	end

	if (SERVER) then
		player:setNetVar("google_voice", string.lower(voice))
	end
end

function goospeech:GetVoice(ply)
	return ply:getNetVar("google_voice", string.lower(self['default_voice']))
end