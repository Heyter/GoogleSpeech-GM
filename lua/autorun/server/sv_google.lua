assert(netlibs, "netlibs not installed (https://github.com/Heyter/netlibrary)")

local goospeech = goospeech

hook.Add("PlayerSay", "PlayerSay_Google", function(player, text)
	for _, cmd in ipairs(goospeech.ChatCommand) do
		if string.len(cmd) > 0 and string.sub(text, 0, string.len(cmd)) == cmd and goospeech:HasValue(player) then
			netstream.Start(player, "goospeech.start")
			return false
		end
	end
end)

local function set_voice(pl)
	goospeech:SetVoice(pl, pl:GetInfo('cl_google__voice'))
end

netstream.Hook("goospeech.end", set_voice)
hook.Add("PlayerInitialSpawn", "PlayerInitialSpawn_speechVoice", set_voice)
