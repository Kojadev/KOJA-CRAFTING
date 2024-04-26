fx_version 'cerulean'

game 'gta5'

lua54 'on'
author 'Koja-Scripts'
description 'Crafting System'
version '1.0'

shared_script {
	'config.lua',
}

client_scripts {
	'client/main.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	--'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server_config.lua',
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

escrow_ignore {
	'config.lua',
	'server_config.lua',
}   

ui_page "assets/ui.html"

