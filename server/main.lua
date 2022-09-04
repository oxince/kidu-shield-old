string.startsWith = function(content, value)
    return string.sub(content, 1, string.len(value)) == value;
end

local function createShieldInstance()
    local self = {};
    
    self.BannedPlayers = {};
    self.BanListResourceFile = LoadResourceFile(GetCurrentResourceName(), 'data/bans.json') or {};
    self.BanList = json.decode(self.BanListResourceFile);
    self.SaveBanList = function(banList)
        SaveResourceFile(GetCurrentResourceName(), 'data/bans.json', json.encode(banList, { indent = true }), -1);
    end;
    self.GenerateBanId = function()
        local banId = math.random(100000, 999999);
        for key, value in pairs(self.BanList) do
            if key == banId then
                return self.GenerateBanId();
            end 
        end
        return banId;
    end;
    self.BanPlayer = function(playerId, banReason)
        if not self.BannedPlayers[playerId] then
            local playerIdentifiers = self.GetPlayerIdentifiers(playerId);
            local playerTokens = self.GetPlayerTokens(playerId) or {};
    
            local playerBan = {
                username = GetPlayerName(playerId),
                reason = banReason or "No reason given",
                identifiers = {},
                tokens = {};
            };
    
            for i = 1, #playerIdentifiers do
                local currentIdentifier = playerIdentifiers[i];
                for i = 1, #KS.BanSystem.IdentifiersToBan do
                    if string.startsWith(currentIdentifier, KS.BanSystem.IdentifiersToBan[i]) then
                        table.insert(playerBan.identifiers, currentIdentifier);
                    end
                end
            end
    
            if KS.BanSystem.BanServerTokens then
                playerBan.tokens = playerTokens;
            end
    
            self.BannedPlayers[playerId] = true;
            self.BanList[self.GenerateBanId()] = playerBan;
            self.SaveBanList(self.BanList);
            
            DropPlayer(playerId, "🌍 | Kidu-Shield: You've been banned from this server.");
            
            return true, playerBan;
        end
    end;
    self.RebanPlayer = function(playerId, savedBanData) 
        local playerIdentifiers = self.GetPlayerIdentifiers(playerId);
        local playerTokens = self.GetPlayerTokens(playerId) or {};

        local banData = {
            username = savedBanData.username,
            reason = savedBanData.banReason or "No reason given",
            identifiers = savedBanData.bannedIdentifiers,
            tokens = savedBanData.bannedTokens;
        };

        local rebanned = {
            identifiers = {},
        }

        for i = 1, #playerIdentifiers do
            local currentIdentifier = playerIdentifiers[i];
            for i = 1, #KS.BanSystem.IdentifiersToBan do
                if string.startsWith(currentIdentifier, KS.BanSystem.IdentifiersToBan[i]) then
                    local foundIdentifier = false;

                    for i = 1, #banData.identifiers do
                        if banData.identifiers[i] == currentIdentifier then
                            foundIdentifier = true; 
                        end

                        if i == #banData.identifiers and not foundIdentifier then
                            table.insert(banData.identifiers, currentIdentifier);
                            table.insert(rebanned.identifiers, currentIdentifier);
                        end
                    end
                end
            end
        end

        if KS.BanSystem.BanServerTokens then
            banData.tokens = playerTokens;
        end
        
        self.BanList[savedBanData.banId] = banData;
        self.SaveBanList(self.BanList);

        return true, rebanned;
    end
    self.UnbanID = function(banId)
        print(banId)
        print(json.encode(self.BanList, {indent=true}))
        if self.BanList[banId] then
            local banData = self.BanList[banId];
            self.BanList[banId] = nil;
            self.SaveBanList(self.BanList);
            return true, banData;
        else
            return false;
        end
    end
    self.IsBanned = function(playerId)
        local playerIdentifiers = self.GetPlayerIdentifiers(playerId);
        local playerTokens = self.GetPlayerTokens(playerId) or {};

        local isBanned, banData = false, {
            banId = 0,
            banReason = "",
            username = "",
            bannedIdentifiers = {},
            bannedTokens = {}
        }

        for key, value in pairs(self.BanList) do
            local banIdentifiers = value.identifiers;
            local banTokens = value.tokens;

            for i = 1, #banIdentifiers do
                local currentIdentifier = banIdentifiers[i];
                for i = 1, #playerIdentifiers do
                    if currentIdentifier == playerIdentifiers[i] then
                        table.insert(banData.bannedIdentifiers, currentIdentifier);
                        banData.username = value.username
                        banData.banReason = value.reason
                        banData.banId = key;
                        isBanned = true;
                    end
                end
            end
            
            for i = 1, #banTokens do
                local currentToken = banTokens[i];
                for i = 1, #playerTokens do
                    if currentToken == playerTokens[i] then
                        table.insert(banData.bannedTokens, currentToken);
                        banData.username = value.username
                        banData.banReason = value.reason
                        banData.banId = key;
                        isBanned = true;
                    end
                end
            end

            if isBanned then
                break;
            end
        end

        return isBanned, banData;
    end
    
    self.GetPlayerIdentifiers = function(playerId)
        local output = {};
        for key, value in pairs(GetPlayerIdentifiers(playerId)) do
            table.insert(output, value);
        end
        return output;
    end;
    self.GetPlayerTokens = function(playerId)
        local output = {};
        for i = 0, GetNumPlayerTokens(playerId) do
            table.insert(output, GetPlayerToken(playerId, i));
        end
        return output;
    end;

    self.CryptKey = CryptKey;
    self.SaveKey = function()
        return SaveResourceFile(GetCurrentResourceName(), 'data/sh_key.lua', "--[[\n    discord.gg/kidu | oxince#1337\n    Kidu-Shield: Encryption-Key\n    DON'T TOUCH THIS FILE!!\n\n    You can change this Key per Command. Type 'kidu' in your console for more information.\n]]--\n\nCryptKey = " .. math.random(1000, 9999) .. ";", -1);
    end
    self.Encrypt = function(value)
        local output = {};
        for i = 1, #value do
            local subString = string.sub(value, i, i);
            table.insert(output, string.byte(tostring(subString)) * self.CryptKey);
        end
        return output;
    end;
    self.Decrypt = function(encrypted)
        local output = "";
        for i = 1, #encrypted do
            local currentItem = encrypted[i];
            output = output .. string.char(math.floor(currentItem / self.CryptKey));
        end
        return output;
    end;
    
    self.NetEvents = {};
    self.RegisterNetEvent = function(eventName, eventRoutine)
        self.NetEvents[eventName] = eventRoutine;
    end;
    self.LoadNetEvents = function(eventTrigger)
        RegisterNetEvent(eventTrigger);
        AddEventHandler(eventTrigger, function(args)
            local source = source;
            args = json.decode(self.Decrypt(args));

            if self.NetEvents[args.eventName] then
                self.NetEvents[args.eventName](source, args.data);
            end
        end);
    end;
    self.TriggerClientEvent = function(eventName, source, ...)
        TriggerClientEvent('kidu-shield', source, self.Encrypt(json.encode({
            eventName = eventName,
            data = ...
        })));
    end

    self.SubCommands = {};
    self.RegisterSubCommand = function(commandName, handler, data)
        data.onlyConsole = data.onlyConsole or false;
        data.description = data.description or "No description added";
        data.commandArgs = data.commandArgs or "";

        if data.acePerm then
            data.acePerm = 'kidushield.' .. data.acePerm or "kidushield.*";
        end

        self.SubCommands[commandName] = {
            handler = handler,
            data = data
        };
    end
    self.LoadSubCommands = function(mainCommand)
        RegisterCommand(mainCommand, function(source, args, rawCommand)
            for i = 1, #args do args[i] = string.lower(args[i]); end
            
            if not args[1] then
                print("(^5kidu-shield^0): ^0help > You need to use arguments.");
                
                for key, value in pairs(self.SubCommands) do
                    print("(^5kidu-shield^0): ^0help > " .. mainCommand .. " ^5" .. key .. "^0" .. value.data.commandArgs .. " | " .. value.data.description .. '^0');
                end
                
                return;
            end

            for key, value in pairs(self.SubCommands) do
                if args[1] == key then
                    local data = value.data;
                    local subArgs = args;

                    table.remove(subArgs, 1);
                    
                    if data.onlyConsole then
                        if source == 0 then
                            return value.handler(source, args);
                        else
                            return print("(^5kidu-shield^0): ^0error > You are not in console.^0");
                        end
                    else
                        if source == 0 then
                            return value.handler(source, args);
                        else
                            if IsPlayerAceAllowed(source, data.acePerm) then
                                return value.handler(source, args);
                            end
                        end
                    end
                end
            end
        end, false);
    end

    self.GetResources = function(resourcesToIgnore)
        local resourceList = {};
        for i = 1, GetNumResources() do
            local currentResource = GetResourceByFindIndex(i);
            if currentResource and GetResourceState(currentResource) == "started" then
                if currentResource ~= GetCurrentResourceName() then
                    local ignore = false;
                    if resourcesToIgnore then
                        for i = 1, #resourcesToIgnore do
                            if currentResource == resourcesToIgnore[i] then
                                ignore = true;
                            end
                        end
                    end
                    if not ignore then
                        table.insert(resourceList, currentResource);
                    end
                end
            end
        end
        return resourceList;
    end
    
    self.SeclyInstall = function(resources)
        local seclyFile = LoadResourceFile(GetCurrentResourceName(), 'data/shield');
        local resourcesInstalled = {};

        if seclyFile then
            for i = 1, #resources do
                local resourceManifestFile;
                local resourceManifestFileName;
                local currentResource = resources[i];
                local possibleManifests = {
                    '__resource.lua',
                    'fxmanifest.lua'
                }

                for i = 1, #possibleManifests do
                    resourceManifestFile = LoadResourceFile(currentResource, possibleManifests[i]);
                    if resourceManifestFile then
                        resourceManifestFileName = possibleManifests[i];
                        break;
                    end
                end

                if resourceManifestFile then
                    if string.find(resourceManifestFile, 'client_script') then
                        local seclyResourceFile = 'kidu-shield.lua';
                        resourceManifestFile = resourceManifestFile:gsub('client_script \'kidu-shield.lua\'', "");
                        SaveResourceFile(currentResource, resourceManifestFileName, resourceManifestFile, -1);
                        SaveResourceFile(currentResource, seclyResourceFile, seclyFile, -1);
                        table.insert(resourcesInstalled, currentResource);
                    end
                end
            end
            
            return true, resourcesInstalled;
        end
    end
    
    return self;
end

local Shield = createShieldInstance();

Citizen.CreateThread(function()    
    Shield.RegisterSubCommand('unban', function(source, args)
        if not args[1] then
            return print('(^5kidu-shield^0): ^0error > Please use command "kidu ^5unban ^0<banId>" to unban a player.');            
        end
        
        if not tonumber(args[1]) then
            return print('(^5kidu-shield^0): ^0error > This is not an valid Ban-ID.');            
        end
        
        local success, banData = Shield.UnbanID(args[1]);
        
        if success then
            print('(^5kidu-shield^0): ^0bans > ^5Successfully ^0unbanned Player: ' .. banData.username .. '.');            
        else
            print('(^5kidu-shield^0): ^0error > This Ban-ID is not existing.');            
        end
    end, {
        acePerm = 'unban',
        onlyConsole = true,
        description = 'Remove a ban from banlist with using a command.',
        commandArgs = ' <^5banId^0>'
    });

    Shield.RegisterSubCommand('secly', function(source, args)
        if not Shield.SeclyConfirmable then
            Shield.SeclyConfirmable = true;
            print('(^5kidu-shield^0): ^0info > Please type "kidu ^5secly ^0confirm" in the next ^530 Seconds^0.');            
            Citizen.Wait(30 * 1000);
            
            if Shield.SeclyConfirmable then
                Shield.SeclyConfirmable = nil;
                print('(^5kidu-shield^0): ^0info > "^5Secly ^0installation" request expired^0.');
            end
        elseif args[1] == "confirm" then
            local ignoredResources = json.decode(LoadResourceFile(GetCurrentResourceName(), 'data/secly.json')) or {};
            local success, resourcesInstalled = Shield.SeclyInstall(Shield.GetResources(ignoredResources));
            if success then
                for i = 1, #resourcesInstalled do table.insert(ignoredResources, resourcesInstalled[i]); end
                SaveResourceFile(GetCurrentResourceName(), 'data/secly.json', json.encode(ignoredResources, { indent = true }), -1);
                print('(^5kidu-shield^0): ^0info > Added secly to ^5' .. #resourcesInstalled .. ' ^0resources.');
                Shield.SeclyConfirmable = nil;
                if #resourcesInstalled > 0 then
                    print('(^5kidu-shield^0): ^1warning^0 > ^1Crashed ^0your server, please restart manually.');
                    os.exit();
                end
            else
                print('(^5kidu-shield^0): ^0error > Error while installing secly.');
            end
        end
    end, {
        acePerm = false,
        onlyConsole = true,
        description = '^1WARNING: ^0Restarts your server after.',
        commandArgs = ''
    });

    Shield.RegisterSubCommand('cryptkeyreset', function(source, args)
        if not Shield.ResetKeyConfirmable then
            Shield.ResetKeyConfirmable = true;
            print('(^5kidu-shield^0): ^0info > Please type "kidu ^5cryptkeyreset ^0confirm" in the next ^530 Seconds^0.');            
            Citizen.Wait(30 * 1000);
            
            if Shield.ResetKeyConfirmable then
                Shield.ResetKeyConfirmable = nil;
                print('(^5kidu-shield^0): ^0info > "^5Crypt-Key ^0Reset" request expired^0.');
            end
        elseif args[1] == "confirm" then
            print('(^5kidu-shield^0): ^0info > Successfully ^5renewed ^0Crypt-Key.');
            print('(^5kidu-shield^0): ^1warning^0 > ^1Crashed ^0your server, please restart manually.');
            Shield.ResetKeyConfirmable = nil;
            Shield.SaveKey();
            os.exit();
        end
    end, {
        acePerm = false,
        onlyConsole = true,
        description = 'Reset your ^5sh_key.lua ^0per command. -> ^1WARNING: ^0Restarts your server after.',
        commandArgs = ''
    });
    
    Shield.RegisterNetEvent('banMe', function(source, reason)
        Shield.BanPlayer(source, reason);
    end);

    Shield.LoadSubCommands('kidu');
    Shield.LoadNetEvents('kidu-shield');
end);

Citizen.CreateThread(function()
    AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
        local source = source;

        deferrals.defer();
        deferrals.update("🌍 | Kidu-Shield: Checking your Ban-Status.");
        
        Citizen.Wait(0);

        local isBanned, banData = Shield.IsBanned(source);

        Citizen.Wait(0);
        
        if isBanned then
            local success, rebanned = Shield.RebanPlayer(source, banData);
            
            if success then
                if KS.BanSystem.DebugPrint then
                    for i = 1, #rebanned.identifiers do
                        print('(^5kidu-shield^0): ^0bans > Rebanned Identifier ^5"' .. rebanned.identifiers[i] .. '^0" of user ^5' .. GetPlayerName(source) .. '^0 with Ban-ID: ^5' .. banData.banId .. '^0.');     
                    end

                    if rebanned then
                        print('(^5kidu-shield^0): ^0bans > Replaced all ^5Server-Tokens^0 of user ^5' .. GetPlayerName(source) .. '^0 with Ban-ID: ^5' .. banData.banId .. '^0.');     
                    end
                end
            end

            return deferrals.done("\n🌍 | You're permanently banned from this Server.\n\nBan-Info:\n➥ Ban-ID: " .. banData.banId .. "\n➥ Ban-Reason: " .. banData.banReason .. "\n➥ Ban-Name: " .. banData.username .. "\n\nYou think this is a wrong ban? Get Support here: discord.gg/kidu");
        end;

        deferrals.update("🌍 | Kidu-Shield: Checking your kidu.wtf Global-Ban-Status.");
        
        Citizen.Wait(0);

        deferrals.done();
    end);

    AddEventHandler("giveWeaponEvent", function(source)
        if KS.OtherPed.AntiGiveWeapon then
            CancelEvent();
            Shield.BanPlayer(source, "KS.OtherPed.AntiGiveWeapon is enabled. -> Tried to give weapon to an other Ped.");
        end
    end);

    AddEventHandler("removeWeaponEvent", function(source)
        if KS.OtherPed.AntiRemoveWeapon then
            CancelEvent();
            Shield.BanPlayer(source, "KS.OtherPed.AntiRemoveWeapon is enabled. -> Tried to remove weapon of an other Ped.");
        end
    end);

    AddEventHandler("removeAllWeaponsEvent", function(source)
        if KS.OtherPed.AntiRemoveAllWeapons then
            CancelEvent();
            Shield.BanPlayer(source, "KS.OtherPed.AntiRemoveAllWeapons is enabled. -> Tried to remove all weapons of an other Ped.");
        end
    end);

    AddEventHandler('clearPedTasksEvent', function(sender, ev)
        if KS.AntiKickPlayerOutOfVehicle then
            CancelEvent();
            Shield.BanPlayer(source, "KS.AntiKickPlayerOutOfVehicle is enabled -> Tried to kick player out of vehicle.")
        end
    end);
    
    local tazeLimit = {};
    AddEventHandler('weaponDamageEvent', function(source, data)
        if KS.Trolling.AntiTazePlayer then
            if data.weaponType == 911657153 then -- Stungun
                if not tazeLimit[source] then
                    tazeLimit[source] = 1;
                else
                    tazeLimit[source] = tazeLimit[source] + 1;
                end

                CreateThread(function() Citizen.Wait(3 * 1000); tazeLimit[source] = tazeLimit[source] - 1 end)

                if tazeLimit[source] >= KS.Trolling.TazeLimit then
                    return Shield.BanPlayer(source, 'KS.Trolling.TazeLimit is enabled -> Tazed more than 3 times an other player in 3 seconds')
                end
            end
        end

        if KS.AntiShootWithoutWeapon then
            Shield.TriggerClientEvent('HasPedGotWeaponElseBan', source, data.weaponType);
        end
    end);

    AddEventHandler('explosionEvent', function(source, data)
        local explosionTypes = { 'GRENADE', 'GRENADELAUNCHER', 'STICKYBOMB', 'MOLOTOV', 'ROCKET', 'TANKSHELL', 'HI_OCTANE', 'CAR', 'PLANE', 'PETROL_PUMP', 'BIKE', 'DIR_STEAM', 'DIR_FLAME', 'DIR_WATER_HYDRANT', 'DIR_GAS_CANISTER', 'BOAT', 'SHIP_DESTROY', 'TRUCK', 'BULLET', 'SMOKEGRENADELAUNCHER', 'SMOKEGRENADE', 'BZGAS', 'FLARE', 'GAS_CANISTER', 'EXTINGUISHER', 'PROGRAMMABLEAR', 'TRAIN', 'BARREL', 'PROPANE', 'BLIMP', 'DIR_FLAME_EXPLODE', 'TANKER', 'PLANE_ROCKET', 'VEHICLE_BULLET', 'GAS_TANK', 'BIRD_CRAP', 'RAILGUN', 'BLIMP2', 'FIREWORK', 'SNOWBALL', 'PROXMINE', 'VALKYRIE_CANNON', 'AIR_DEFENCE', 'PIPEBOMB', 'VEHICLEMINE', 'EXPLOSIVEAMMO', 'APCSHELL', 'BOMB_CLUSTER', 'BOMB_GAS', 'BOMB_INCENDIARY', 'BOMB_STANDARD', 'TORPEDO', 'TORPEDO_UNDERWATER', 'BOMBUSHKA_CANNON', 'BOMB_CLUSTER_SECONDARY', 'HUNTER_BARRAGE', 'HUNTER_CANNON', 'ROGUE_CANNON', 'MINE_UNDERWATER', 'ORBITAL_CANNON', 'BOMB_STANDARD_WIDE', 'EXPLOSIVEAMMO_SHOTGUN', 'OPPRESSOR2_CANNON', 'MORTAR_KINETIC', 'VEHICLEMINE_KINETIC', 'VEHICLEMINE_EMP', 'VEHICLEMINE_SPIKE', 'VEHICLEMINE_SLICK', 'VEHICLEMINE_TAR', 'SCRIPT_DRONE', 'RAYGUN', 'BURIEDMINE', 'SCRIPT_MISSIL' }

        if KS.Explosions.CancelExplosions then
            CancelEvent();
        end
        
        if KS.Explosions.ExplosionBlacklist and KS.Explosions.BlacklistedExplosions[data.explosionType] then
            CancelEvent();
            print('(^5kidu-shield^0): ^4debug^0 ^1explosion ^0> ^5' .. GetPlayerName(source) .. '^0 caused a ^1blacklisted ^0Explosion: ^3' .. explosionTypes[data.explosionType + 1] .. '^0, Coords: vector3('..math.floor(data.posX)..', '..math.floor(data.posY)..', '..math.floor(data.posZ)..');');
            Shield.BanPlayer(source, "KS.Explosions.BlacklistedExplosions is enabled. -> Caused blacklisted explosion (" .. KS.Explosions.BlacklistedExplosions[data.explosionType] .. ").");
        else
            print('(^5kidu-shield^0): ^4debug^0 ^3explosion ^0> ^5' .. GetPlayerName(source) .. '^0 caused a Explosion: ^3' .. explosionTypes[data.explosionType + 1] .. '^0, Coords: vector3('..math.floor(data.posX)..', '..math.floor(data.posY)..', '..math.floor(data.posZ)..');');
        end
    end);
end);