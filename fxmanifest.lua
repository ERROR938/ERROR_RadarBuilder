fx_version 'cerulean'
game 'gta5'

client_scripts {
    'client/cl_*.lua'
}
server_scripts {
    'server/sv_**.lua'
}

shared_scripts {
    "@es_extended/imports.lua",
    '@ox_lib/init.lua',
    "config.lua"
}