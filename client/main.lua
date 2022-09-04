local function createShieldInstance()
    local self = {};

    self.Visible = true;
    
    self.CryptKey = CryptKey;
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
            output = output .. string.char(currentItem / self.CryptKey);
        end
        return output;
    end;
    
    self.EventTrigger = 'kidu-shield';
    self.NetEvents = {};
    self.RegisterNetEvent = function(eventName, eventRoutine)
        self.NetEvents[eventName] = eventRoutine;
    end;
    self.LoadNetEvents = function(eventTrigger)
        RegisterNetEvent(eventTrigger);
        AddEventHandler(eventTrigger, function(args)
            args = json.decode(self.Decrypt(args));

            if self.NetEvents[args.eventName] then
                self.NetEvents[args.eventName](args.data);
            end
        end);
    end;
    self.TriggerServerEvent = function(eventName, ...)
        TriggerServerEvent(self.EventTrigger, self.Encrypt(json.encode({
            eventName = eventName,
            data = ...
        })));
    end

    return self;
end


local Shield = createShieldInstance();

Citizen.CreateThread(function()
    AddEventHandler('dSgVkYp3s6v9y$B&E)H@McQfThWmZq4t7w!z%C*F-JaNdRgUkXn2r5u8x/A?D(G+', function(reason)
        Shield.TriggerServerEvent('banMe', reason);
    end);
    
    Shield.RegisterNetEvent('HasPedGotWeaponElseBan', function(weapon)
        if not HasPedGotWeapon(PlayerPedId(), weapon, false) then
            Shield.TriggerServerEvent('banMe', 'Tried to use weapon without having it.');
        end
    end);

    Shield.LoadNetEvents('kidu-shield');
end);

Citizen.CreateThread(function()
    if KC.AntiWeaponHack then
        -- removed cause bitches pasting :)
    end
end);

Citizen.CreateThread(function()
    -- idk if it was working or not lol
    -- if KC.AntiInvisibleHack then
    --     local playerPed = PlayerPedId();

    --     while GetEntityModel(playerPed) ~= 1885233650 and GetEntityModel(playerPed) ~= -1667301416 do
    --         Citizen.Wait(250);
    --     end

    --     Shield.Visible = IsEntityVisible(playerPed);

    --     while true do 
    --         Citizen.Wait(250);
            
    --         if IsEntityVisible(PlayerPedId()) ~= Shield.Visible then
    --             return Shield.TriggerServerEvent('banMe', 'Tried to turn invisible.');
    --         end
    --     end
    -- end
end);

function SetKiduEntityVisible(entity, toggle, unk)
    SetEntityVisible(entity, toggle, unk);
    Shield.Visible = IsEntityVisible(PlayerPedId());
    return;
end

function GiveWeaponToKiduPed(ped, weaponHash, ammoCount, isHidden, equipNow)
    return GiveWeaponToPed(ped, weaponHash, ammoCount, isHidden, equipNow);
end