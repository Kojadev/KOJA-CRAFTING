fx_version 'cerulean'

game 'gta5'

lua54 'on'
name "Koja-Crafting"
author "KojaScripts <discord.gg/kojascripts>"
version "1.1.0"
description "Koja Crafting System"


shared_scripts {
    "@ox_lib/init.lua", -- if you are using ox
    "shared/**/*"
}

client_scripts {
	'client/main.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua', -- if you are using oxmysql
	--'@mysql-async/lib/MySQL.lua', -- if you are using mysql
	'server/main.lua',
}

files {
	'assets/ui.html',
	'assets/fonts/*.ttf',
	'assets/fonts/*.otf',
	'assets/css/*.css',
	'assets/images/*.jpg',
	'assets/images/*.png',
	'assets/js/*.js'
}

ui_page "assets/ui.html"

