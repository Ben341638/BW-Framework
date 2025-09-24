fx_version 'cerulean'
game 'gta5'

author 'BW Framework'
description 'BW Framework - jobs_recycling'
version '1.0.0'

shared_scripts {
    '@bw_framework/shared/config.lua',
    'shared/config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/script.js',
    'html/img/*.png',
}

dependencies {
    'bw_framework',
    'oxmysql'
}

lua54 'yes'
