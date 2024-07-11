fx_version 'cerulean'
game 'gta5'
lua54 'yes'

files {
    'config.lua',
    'timecycle.json'
}

shared_scripts {
    '@ox_lib/init.lua',
}
client_script 'client.lua'
server_scripts {
    '@oxmysql/lib/MySQL.lua',   
    'server.lua'
}