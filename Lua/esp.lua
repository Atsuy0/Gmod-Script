CreateClientConVar("atsuyo_wh_radius", 750)
CreateClientConVar("atsuyo_wh", 0)
CreateClientConVar("atsuyo_wh_type",0)
CreateClientConVar("atsuyo_wh_noprops", 0)

local radius = GetConVarNumber("atsuyo_wh_radius")
local whtype = GetConVarNumber("atsuyo_wh_type")
local noprops = GetConVarNumber("atsuyo_wh_noprops")

local plys = {}
local props = {}
local trackents = {
"spawned_money",
"spawned_shipment",
"spawned_weapon",
"money_printer",
"weapon_ttt_knife",
"weapon_ttt_c4",
"npc_tripmine"
}

local function entmenu()
	local menu = vgui.Create("DFrame")
	menu:SetSize(500,350)
	menu:MakePopup()
	menu:SetTitle("Entity Finder")
	menu:Center()
	menu:SetKeyBoardInputEnabled()


	local noton = vgui.Create("DListView",menu)
	noton:SetSize(200,menu:GetTall()-40)
	noton:SetPos(10,30)
	noton:AddColumn("Not Being Tracked")

	local on = vgui.Create("DListView",menu)
	on:SetSize(200,menu:GetTall()-40)
	on:SetPos(menu:GetWide()-210,30)
	on:AddColumn("Being Tracked")

	local addent = vgui.Create("DButton",menu)
	addent:SetSize(50,25)
	addent:SetPos(menu:GetWide()/2-25,menu:GetTall()/2-20)
	addent:SetText("+")
	addent.DoClick = function() 
		if noton:GetSelectedLine() != nil then 
			local ent = noton:GetLine(noton:GetSelectedLine()):GetValue(1)
			if !table.HasValue(trackents,ent) then 
				table.insert(trackents,ent)
				noton:RemoveLine(noton:GetSelectedLine())
				on:AddLine(ent)
			end
		end
	end

	local rement = vgui.Create("DButton",menu)
	rement:SetSize(50,25)
	rement:SetPos(menu:GetWide()/2-25,menu:GetTall()/2+20)
	rement:SetText("-")
	rement.DoClick = function()
		if on:GetSelectedLine() != nil then
			local ent = on:GetLine(on:GetSelectedLine()):GetValue(1)
			if table.HasValue(trackents,ent) then 
				for k,v in pairs(trackents) do 
					if v == ent then 
					table.remove(trackents,k) 
					end 
				end
					on:RemoveLine(on:GetSelectedLine())
					noton:AddLine(ent)
			end
		end
	end

	local added = {}
	for _,v in pairs(ents.GetAll()) do

		if !table.HasValue(added,v:GetClass()) and !table.HasValue(trackents,v:GetClass()) and !string.find(v:GetClass(),"grav")  and !string.find(v:GetClass(),"phys") and v:GetClass() != "player" then
			
			table.insert(added,v:GetClass())
		end

	end
	table.sort(added)
	for k, v in pairs(added) do
		noton:AddLine(v)
	end
	table.sort(trackents)
	for _,v in pairs(trackents) do
		on:AddLine(v)
	end

end
concommand.Add("atsuyo_ents", entmenu)

timer.Create("entrefresh", 1, 0, function()
	plys = {}
	props = {}
	for k, v in pairs(ents.FindInSphere(LocalPlayer():GetPos(), radius)) do
		if (v:IsPlayer() and !(LocalPlayer() == v)) or v:IsNPC() then
			table.insert(plys, v)
		elseif v:GetClass() == "prop_physics" and noprops == 0 then
			table.insert(props, v)
		end
	end
end)

local function wh()
	cam.Start3D()
		for k, v in pairs(props) do
			if v:IsValid() then
				render.SetColorModulation( 0, 255, 0, 0)
				render.SetBlend(.4)
				v:DrawModel()
			end
		end
		for k, v in pairs(plys) do
			if v:IsValid()  then
				local teamcolor = v:IsPlayer() and team.GetColor(v:Team()) or Color(255,128,0,255)
				if whtype >= 1 then
				v:SetMaterial("models/debug/debugwhite") 
				else
				v:SetMaterial("models/wireframe")	
				end
				render.SetColorModulation(teamcolor.r / 255, teamcolor.g / 255, teamcolor.b / 255) 
				render.SetBlend(teamcolor.a / 255) 
				v:SetColor(teamcolor) 
				v:DrawModel() 
				v:SetColor(Color(255,255,255)) 
				v:SetMaterial("")
			end
		end
	cam.End3D()
end

-- prepping
hook.Remove("HUDPaint", "wh")

if GetConVarNumber("lenny_wh") == 1 then
	hook.Add("HUDPaint", "wh", wh)
end
-- end of prep


cvars.AddChangeCallback("atsuyo_wh_radius", function() 
	radius = GetConVarNumber("atsuyo_wh_radius")
end)
cvars.AddChangeCallback("atsuyo_wh_type", function() 
 whtype = GetConVarNumber("atsuyo_wh_type")
end)
cvars.AddChangeCallback("atsuyo_wh", function() 
	if GetConVarNumber("atsuyo_wh") == 1 then
		hook.Add("HUDPaint", "wh", wh)
	else
		hook.Remove("HUDPaint", "wh")
	end
end)

local nonanonp = {}
local nonanon = {}
local lennysuser = {}

local function NonAnonPSuccess(body)
	local ID64s = string.Explode("|", body)

	if #ID64s > 0 then
		table.remove(ID64s, #ID64s)
		for k, v in pairs(ID64s) do
			table.insert(nonanonp, v)
		end
	end
end

local function OnFail(error)
	print(error)
	
end

local function GetNonAnonPMembers()
end

function CurrentUsersSuccess(body) 
	local plys = {}
	local scopestart = string.find(body, "Server IP")
	local scopeend = string.find(body, "*only public profiles are displayed")
	local scope = string.sub(body, scopestart, scopeend)
	local results = {}
	for match in string.gmatch(scope, "<tr>.-</tr>") do
		table.insert(results, match)
	end
	for i = 1, #results do
		local subresults = {}
		for match in string.gmatch(results[i], "<td>.-</td>") do
			local submatch = string.gsub(match, "(<.-td>)", "")
			table.insert(subresults, submatch)
		end
		table.insert(plys, {name = subresults[1], ip = subresults[2]})
	end
	for i = 1, #plys do
		table.insert(lennysuser, plys[i].name)
	end
end


local function GetLennysUsers()
end
GetNonAnonPMembers()
GetLennysUsers()



CreateClientConVar("atsuyo_esp_radius", 1500)
CreateClientConVar("atsuyo_esp", 0)
CreateClientConVar("atsuyo_esp_view", 0) 
local espradius = GetConVarNumber("atsuyo_esp_radius")

local nonanons = {}
local lennysusers = {}
local espplys = {}
local espspecial= {}
local espnpcs = {}
local espfriends = {}
local esp

local espents = {}

local function isfriend(ent)
	if Lenny then
		if Lenny.friends then
			return table.HasValue(Lenny.friends, ent)
		end
	end
	return false
end

local function sortents(ent)
	if (ent:IsPlayer() and LocalPlayer() != ent) then
		local steamname = ""
		if SteamName != nil then
			steamname = ent:SteamName()
		else
			steamname = ent:Name()
		end
		if ent:GetFriendStatus() == "friend" then
			table.insert(espfriends, ent)
		elseif isfriend(ent) then
			table.insert(espfriends, ent)
		elseif table.HasValue(lennysuser, steamname) then
			table.insert(lennysusers, ent)
		elseif table.HasValue(nonanonp, ent:SteamID64()) then
			table.insert(nonanons, ent)
		elseif ent:GetNWString("usergroup") != "user" and ent:GetNWString("usergroup") != "" then
			table.insert(espspecial, ent)
		else
			table.insert(espplys, ent)
		end
	elseif ent:IsNPC() then
		table.insert(espnpcs, ent)
	elseif table.HasValue(trackents,ent:GetClass()) then
		table.insert(espents, ent)
	end
end

-- getting all releveant esp items
timer.Create("espentrefresh", 1, 0, function()
	nonanons = {}
	lennysusers = {}
	espplys = {}
	espspecial	= {}
	espnpcs = {}
	espfriends = {}

	espents = {}

	if espradius != 0 then
		for k, v in pairs(ents.FindInSphere(LocalPlayer():GetPos(), espradius)) do
			sortents(v)
		end
	else
		for k, v in pairs(ents.GetAll()) do
			sortents(v)
		end
	end
end)

concommand.Add("atsuyo_printadmins", function()
	local plys = player.GetAll()
	for k, v in pairs(plys) do
		if v:GetNWString("usergroup") != "user" then
			print(v:GetName() .. string.rep("\t", math.Round(8 / #v:GetName())), v:GetNWString("usergroup"))
		end
	end
end)

local function realboxesp(min, max, diff, ply)
	cam.Start3D()
		render.DrawLine( min, min+Vector(0,0,diff.z), Color(0,0,255) )
		render.DrawLine( min+Vector(diff.x,0,0), min+Vector(diff.x,0,diff.z), Color(0,0,255) )
		render.DrawLine( min+Vector(0,diff.y,0), min+Vector(0,diff.y,diff.z), Color(0,0,255) )
		render.DrawLine( min+Vector(diff.x,diff.y,0), min+Vector(diff.x,diff.y,diff.z), Color(0,0,255) )
		render.DrawLine( max, max-Vector(diff.x,0,0) , Color(0,0,255) )
		render.DrawLine( max, max-Vector(0,diff.y,0) , Color(0,0,255) )
		render.DrawLine( max-Vector(diff.x, diff.y,0), max-Vector(diff.x,0,0) , Color(0,0,255) )
		render.DrawLine( max-Vector(diff.x, diff.y,0), max-Vector(0,diff.y,0) , Color(0,0,255) )
		render.DrawLine( min, min+Vector(diff.x,0,0) , Color(0,255,0) )
		render.DrawLine( min, min+Vector(0,diff.y,0) , Color(0,255,0) )
		render.DrawLine( min+Vector(diff.x, diff.y,0), min+Vector(diff.x,0,0) , Color(0,255,0) )
		render.DrawLine( min+Vector(diff.x, diff.y,0), min+Vector(0,diff.y,0) , Color(0,255,0) )
	if GetConVarNumber("atsuyo_esp_view") == 1 then
		local shootpos = ply:IsPlayer() and ply:GetShootPos() or 0
		local eyetrace = ply:IsPlayer() and ply:GetEyeTrace().HitPos or 0

		if (shootpos != 0 and eyetrace != 0) then
		render.DrawBeam(shootpos, eyetrace,2,1,1, team.GetColor(ply:Team()))
		end
	end
		
	cam.End3D()
end


local function calctextopactity(ply)
	if espradius != 0 then
		dis = ply:GetPos():Distance(LocalPlayer():GetPos())
		return (dis / espradius) * 255
	else
		return 0
	end
end


local function drawesptext(text, posx, posy, color)
	draw.DrawText(text, "Default", posx, posy, color, 1)
end

local function esp()
	--text esp
	for k, v in pairs(nonanons) do
		if v:IsValid() then
			local min, max = v:WorldSpaceAABB()
			local diff = max-min
			local pos = (min+Vector(diff.x*.5, diff.y*.5,diff.z)):ToScreen()
			realboxesp(min, max, diff, v)
			drawesptext("[NoN-AnonP]"..v:GetName(), pos.x, pos.y-20, Color(0, 255, 255, 255 - calctextopactity(v)))
		end
	end
	for k, v in pairs(lennysusers) do
		if v:IsValid() then
			local min, max = v:WorldSpaceAABB()
			local diff = max-min
			local pos = (min+Vector(diff.x*.5, diff.y*.5,diff.z)):ToScreen()
			realboxesp(min, max, diff, v)
			drawesptext("[Lenny's User]"..v:GetName(), pos.x, pos.y-20, Color(0, 255, 255, 255 - calctextopactity(v)))
		end
	end
	for k, v in pairs(espnpcs) do
		if v:IsValid() then
			local min, max = v:WorldSpaceAABB()
			local diff = max-min
			realboxesp(min, max, diff, v)
			local pos = (min+Vector(diff.x*.5, diff.y*.5,diff.z)):ToScreen()
			drawesptext("[NPC]"..v:GetClass(), pos.x, pos.y-10, Color(255,0,0,255 - calctextopactity(v)))
		end
	end
	for k,v in pairs(espplys) do
		if v:IsValid() then
			local min, max = v:WorldSpaceAABB()
			local diff = max-min
			local pos = (min+Vector(diff.x*.5, diff.y*.5,diff.z)):ToScreen()
			realboxesp(min, max, diff, v)
			drawesptext(v:GetName(), pos.x, pos.y-10, Color(255, 255,0,255 - calctextopactity(v)))
		end
	end
	for k,v in pairs(espspecial) do
		if v:IsValid() then
			local min, max = v:WorldSpaceAABB()
			local diff = max-min
			local pos = (min+Vector(diff.x*.5, diff.y*.5,diff.z)):ToScreen()
			realboxesp(min, max, diff, v)
			drawesptext("["..v:GetNWString("usergroup").."]"..v:GetName(), pos.x, pos.y-10, Color(255, 0, 255,255 -calctextopactity(v)))
		end
	end
	for k,v in pairs(espfriends) do
		if v:IsValid() then
			local min, max = v:WorldSpaceAABB()
			local diff = max-min
			local pos = (min+Vector(diff.x*.5, diff.y*.5,diff.z)):ToScreen()
			realboxesp(min, max, diff, v)
			drawesptext("[Friend]"..v:GetName(), pos.x, pos.y-10, Color(0, 255, 0, 255 - calctextopactity(v)))
		end
	end
	if espents then
		for k, v in pairs(espents) do
			if v:IsValid() then
				local min, max = v:WorldSpaceAABB()
				local diff = max-min
				local pos = (min+Vector(diff.x*.5, diff.y*.5,diff.z)):ToScreen()
				realboxesp(min, max, diff, v)
				drawesptext(v:GetClass(), pos.x, pos.y-10, Color(0 ,255, 0,255 - calctextopactity(v)))
				if v:GetClass() == "spawned_money" then
					drawesptext("$"..v:Getamount(), pos.x, pos.y, Color(0 ,255, 255,255 - calctextopactity(v)))
				end
			end
		end
	end
end
local function checkstatus()
	GetNonAnonPMembers()
	GetLennysUsers()
end

hook.Remove("HUDPaint", "esp")

if GetConVarNumber("atsuyo_esp") == 1 then
	hook.Add("HUDPaint", "esp", esp)
end

hook.Remove("PlayerConnect", "l_checkstatus")

if GetConVarNumber("atsuyo_esp") == 1 then
	hook.Add("PlayerConnect", "l_checkstatus", checkstatus)
end

cvars.AddChangeCallback("atsuyo_esp_radius", function() 
	espradius = GetConVarNumber("atsuyo_esp_radius")
end)

cvars.AddChangeCallback("atsuyo_esp", function() 
	if GetConVarNumber("atsuyo_esp") == 1 then
		hook.Add("HUDPaint", "esp", esp)
		hook.Add("PlayerConnect", "l_checkstatus", checkstatus)
		checkstatus()
	else
		hook.Remove("HUDPaint", "esp")
		hook.Remove("PlayerConnect", "l_checkstatus")
	end
end)


MsgC(Color(0,255,0), "\nESP GOOD\n")
