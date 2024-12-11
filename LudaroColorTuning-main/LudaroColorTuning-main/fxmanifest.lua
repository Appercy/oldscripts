fx_version('cerulean')
games({ 'gta5' })
author 'Ludaro'
description 'LudaroColorTuning'
version '1.0.0'

lua54 'yes'

shared_script('config.lua');

server_scripts({
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
});


client_scripts({
    '@NativeUILua_Reloaded/src/NativeUIReloaded.lua',
    'client/nativeui.lua',
});
