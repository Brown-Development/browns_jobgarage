fx_version 'bodacious'
author 'Brown Development'
description 'Advanced Job Garage'
game 'gta5'
lua54 'yes'

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config/*.lua',
    'shared/*.lua'
}

files {
    'ui/*.html',
    'ui/*.css',
    'ui/*.js'
}

ui_page 'ui/index.html'

dependencies {
    'oxmysql',
    'ox_lib'
}