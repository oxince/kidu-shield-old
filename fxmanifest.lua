fx_version 'cerulean'
game 'gta5'

server_scripts {
    'data/sh_key.lua',
    'data/sh_weapons.lua',
    'config/sv_config.lua',
    'config/cl_config.lua',
    'server/main.lua',
}

client_scripts {
    'data/sh_key.lua',
    'data/sh_weapons.lua',
    'config/cl_config.lua',
    'client/main.lua',
}

exports {
    'GiveWeaponToKiduPed',
    'SetKiduEntityVisible'
}