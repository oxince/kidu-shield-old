KS = {};

KS.BanSystem = {
    BanServerTokens = true,
    DebugPrint = true,
    IdentifiersToBan = {
        'steam',
        'license',
        'discord',
        'live',
        'xbl',
        'ip',
    }
}

KS.OtherPed = {
    Debug = true,
    AntiGiveWeapon = true, -- Prevents an player to give weapons to other peds
    AntiRemoveWeapon = true, -- Prevents an player to remove weapons from other peds
    AntiRemoveAllWeapons = true, -- Prevents an player to remove ALL weapons from other peds
}

KS.AntiKickPlayerOutOfVehicle = true -- also know as "AntiClearPedTasks"
KS.AntiShootWithoutWeapon = true -- Prevents an player to shoot with a weapon, which he dont have in his inventory

KS.Trolling = {
    AntiTazePlayer = true,
    TazeLimit = 3
}

KS.Explosions = {
    Debug = true,
    CancelExplosions = true, -- Prevents explosions from making damage
    ExplosionBlacklist = true, -- Enable explosion blacklist and bans players if they are causing blacklisted explosions
    BlacklistedExplosions = {
        [0] = 'GRENADE',
        [1] = 'GRENADELAUNCHER',
        [2] = 'STICKYBOMB',
        [3] = 'MOLOTOV',
        [4] = 'ROCKET',
        [5] = 'TANKSHELL',
        -- [6] = 'HI_OCTANE',
        -- [7] = 'CAR',
        -- [8] = 'PLANE',
        [9] = 'PETROL_PUMP',
        -- [10] = 'BIKE',
        -- [11] = 'DIR_STEAM',
        -- [12] = 'DIR_FLAME',
        -- [13] = 'DIR_WATER_HYDRANT',
        -- [14] = 'DIR_GAS_CANISTER',
        -- [15] = 'BOAT',
        -- [16] = 'SHIP_DESTROY',
        -- [17] = 'TRUCK',
        [18] = 'BULLET',
        [19] = 'SMOKEGRENADELAUNCHER',
        -- [20] = 'SMOKEGRENADE',
        -- [21] = 'BZGAS',
        -- [22] = 'FLARE',
        -- [23] = 'GAS_CANISTER',
        -- [24] = 'EXTINGUISHER',
        -- [25] = 'PROGRAMMABLEAR',
        -- [26] = 'TRAIN',
        -- [27] = 'BARREL',
        -- [28] = 'PROPANE',
        -- [29] = 'BLIMP',
        -- [30] = 'DIR_FLAME_EXPLODE',
        -- [31] = 'TANKER',
        [32] = 'PLANE_ROCKET',
        -- [33] = 'VEHICLE_BULLET',
        -- [34] = 'GAS_TANK',
        -- [35] = 'BIRD_CRAP',
        [36] = 'RAILGUN',
        -- [37] = 'BLIMP2',
        -- [38] = 'FIREWORK',
        -- [39] = 'SNOWBALL',
        [40] = 'PROXMINE',
        [41] = 'VALKYRIE_CANNON',
        [42] = 'AIR_DEFENCE',
        [43] = 'PIPEBOMB',
        [44] = 'VEHICLEMINE',
        [45] = 'EXPLOSIVEAMMO',
        [46] = 'APCSHELL',
        [47] = 'BOMB_CLUSTER',
        [48] = 'BOMB_GAS',
        [49] = 'BOMB_INCENDIARY',
        [50] = 'BOMB_STANDARD',
        [51] = 'TORPEDO',
        [52] = 'TORPEDO_UNDERWATER',
        [53] = 'BOMBUSHKA_CANNON',
        [54] = 'BOMB_CLUSTER_SECONDARY',
        [55] = 'HUNTER_BARRAGE',
        [56] = 'HUNTER_CANNON',
        [57] = 'ROGUE_CANNON',
        [58] = 'MINE_UNDERWATER',
        [59] = 'ORBITAL_CANNON',
        [60] = 'BOMB_STANDARD_WIDE',
        [61] = 'EXPLOSIVEAMMO_SHOTGUN',
        [62] = 'OPPRESSOR2_CANNON',
        [63] = 'MORTAR_KINETIC',
        -- [64] = 'VEHICLEMINE_KINETIC',
        -- [65] = 'VEHICLEMINE_EMP',
        -- [66] = 'VEHICLEMINE_SPIKE',
        -- [67] = 'VEHICLEMINE_SLICK',
        -- [68] = 'VEHICLEMINE_TAR',
        [69] = 'SCRIPT_DRONE',
        [70] = 'RAYGUN',
        [71] = 'BURIEDMINE',
        [72] = 'SCRIPT_MISSIL',
    }
}