fx_version 'cerulean'
game 'gta5'

name "Vending-Machinee"
author 'Sukra, Ludaro'
description 'Vending-Machinee'
version '1.0'

shared_scripts {
	'config.lua'
}

client_scripts {
	'@NativeUILua_Reloaded/src/NativeUIReloaded.lua',
    '@NativeUI/NativeUI.lua',
	'client.lua'
}

server_scripts {
	'server.lua',
	'@mysql-async/lib/MySQL.lua'
}
