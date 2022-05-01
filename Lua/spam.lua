CreateClientConVar("atsuyo_spam", 0, true, false)

function Flashspam()
	if GetConVar("atsuyo_spam"):GetInt() == 1 then
		if input.IsKeyDown(KEY_H) then
			RunConsoleCommand("impulse", "100")
			return end
	end
end

hook.Add("Think", "Flspam", Flashspam )
