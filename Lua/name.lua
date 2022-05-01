local names = {
"Fris Prism", 
"Frank Downaing", 
"John Prasm", 
"Crip Myster", 
"Angelo Tyaou", 
"Tarosm Kalisse",
"Profi Mazona",
"Magni Prosmi",
}

concommand.Add( "atsuyo_namechange" , function()
LocalPlayer():ConCommand("say /rpname " ..table.Random(names).. "")

end )
