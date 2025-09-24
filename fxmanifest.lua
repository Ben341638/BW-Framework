fx_version 'cerulean'
game 'gta5'

author 'BW Framework'
description 'BW Framework - A comprehensive FiveM roleplay framework'
version '1.0.0'

shared_scripts {
    '@oxmysql/lib/MySQL.lua',
    'shared/config.lua',
    'shared/utils.lua',
    'shared/functions.lua',
    'shared/events.lua',
}

client_scripts {
    'client/main.lua',
    'client/functions.lua',
    'client/events.lua',
    'client/commands.lua',
    'client/nui.lua',
}

server_scripts {
    'server/main.lua',
    'server/functions.lua',
    'server/events.lua',
    'server/commands.lua',
    'server/player.lua',
    'server/database.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js',
    'html/img/*.png',
}

dependencies {
    'oxmysql',
}

server_export 'BW.Testing.RunAllTests'
server_export 'BW.Testing.RunTest'

lua54 'yes'