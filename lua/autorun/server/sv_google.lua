if (!netlibs) then
	ErrorNoHalt('Need install this addon https://github.com/Heyter/netlibrary\n')
	return
end

local goospeech = goospeech

hook.Add("PlayerSay", "PlayerSay_Google", function(player, text)
	for _, cmd in ipairs(goospeech.ChatCommand) do
		if string.len(cmd) > 0 and string.sub(text, 0, string.len(cmd)) == cmd then
			if !goospeech:HasValue(player) then return end
			netstream.Start(player, "goospeech.start")
			return false
		end
	end
end)

local playerGetInfo = FindMetaTable("Player").GetInfo

local function set_voice(pl)
	goospeech:SetVoice(pl, playerGetInfo(pl, 'cl_google_voice'))
end

netstream.Hook("goospeech.end", function(player)
	set_voice(player)
end)

hook.Add("PlayerInitialSpawn", "goospeech.initialSpawn", function(player)
	set_voice(player)
end)