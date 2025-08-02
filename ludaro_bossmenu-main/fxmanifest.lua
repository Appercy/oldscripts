fx_version 'cerulean'
author 'Ludaro'
use_experimental_fxv2_oal 'yes'
version '1.0'
game "gta5"
lua54 "yes"
description 'ludaro_job menu'

client_scripts {
    'client/**/*'
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    'server/**/*',
}

shared_scripts {
    "@ox_lib/init.lua",
    'shared/**/*'
}

files {
    'functions/**/*',
    "html/*",
    "html/assets/*",
    "html/img/*",
}


dependencies {
    '/server:6116',
    '/onesync',
    'es_extended',
    'oxmysql',
    'ox_lib'
}