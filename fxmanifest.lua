fx_version 'cerulean'
game 'gta5'

author 'TT-Modding'
description 'Black Market Selling Script for Qbox using ox_lib and ox_target'
version '1.2.0'

shared_script 'config.lua'

client_scripts {
    '@ox_lib/init.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'qb-core',
    'ox_lib',
    'ox_target',
    'ox_inventory'
}
