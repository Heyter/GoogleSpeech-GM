if (!netlibs) then
	return
end

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

goospeech.voices = {}
goospeech.voices[1] = { ru_name = "Zahar", en_name = "zahar" }
goospeech.voices[2] = { ru_name = "Ermil", en_name = "ermil" }
goospeech.voices[3] = { ru_name = "Oksana", en_name = "oksana" }
goospeech.voices[4] = { ru_name = "Alyss", en_name = "alyss" }
goospeech.voices[5] = { ru_name = "Omazh", en_name = "omazh" }
goospeech.voices[6] = { ru_name = "Jane", en_name = "jane" }

function goospeech:HasValue(ply)
	return self.steamids[ply:SteamID()] or self.steamids[ply:GetUserGroup()]
end

function goospeech:SetVoice(player, voice)
	if (!self:HasValue(player)) then return end
	
	if (!voice) then
		voice = 'oksana'
	end
	
	for _, name in ipairs(self.voices) do
		if (voice != name.en_name) then
			voice = 'oksana'
		else
			break
		end
	end
	
	if (SERVER) then
		player:setNetVar("google_voice", voice)
	end
end

function goospeech:GetVoice(ply)
	return ply:getNetVar("google_voice", "oksana")
end