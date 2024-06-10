fx_version 'cerulean'
game 'gta5'

lua54 'yes'

client_scripts {
    'client/cl_*.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/sv_*.lua'
}

shared_scripts {
    '@es_extended/locale.lua',
    'locales/*.lua',
    "@es_extended/imports.lua",
    '@ox_lib/init.lua',
    "config.lua"
}

dependency {
    "ox_lib",
    "es_extended",
    "oxmysql"
}