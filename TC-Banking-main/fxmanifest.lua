fx_version 'cerulean'
author 'Ludaro + Atzock (Davis) TC'
version '1.0'
game "gta5"
lua54 "yes"
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
    'locales/*.json',
    "html/dist/**",
    'functions/**/*'
}

ui_page 'html/dist/index.html'


dependencies {
    'es_extended',
    'oxmysql',
    'ox_lib'
}


