local spammer = {
"---------------------------------------", 
"This server was spammed by BluePrint", 
"https://github.com/atsuyo1/BluePrint", 
"Download Blue Print Free !", 
"---------------------------------------", 
}

command.Add( "atsuyo_spam" , function()
LocalPlayer():ConCommand("say // " ..(spammer).. "")

end )
