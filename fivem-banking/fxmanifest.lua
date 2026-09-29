fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'fivem-banking'
author 'YowanDev'
description 'Système bancaire multi-framework (ESX / QBCore / Qbox) avec NUI React'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'bridge/client.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_config.lua',
    'bridge/server.lua',
    'server/logs.lua',
    'server/main.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/assets/*',
}

dependencies {
    'ox_lib',
    'oxmysql',
}
