fx_version 'cerulean'
game 'gta5'
lua54 "yes"
name "Mistgabel"
author 'Ludaro'
description 'MISTGABEL'
version '1.0'

shared_scripts {
    '@ox_lib/init.lua',
'config.lua'
}

client_scripts {
	--'@NativeUILua_Reloaded/src/NativeUIReloaded.lua',
    -- '@NativeUI/NativeUI.lua',

    'config.lua',
    'client.lua',
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
    'config.lua',
    'server.lua'
    
}