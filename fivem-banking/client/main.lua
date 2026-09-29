local isOpen = false

local function openBank()
    if isOpen then return end

    local state = lib.callback.await('fivem-banking:open', false)
    if not state then return end

    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', data = state })
end

local function closeBank()
    if not isOpen then return end

    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    lib.callback('fivem-banking:close', false, function() end)
end

RegisterNUICallback('close', function(_, cb)
    closeBank()
    cb(true)
end)

RegisterNUICallback('deposit', function(data, cb)
    cb(lib.callback.await('fivem-banking:deposit', false, data.amount))
end)

RegisterNUICallback('withdraw', function(data, cb)
    cb(lib.callback.await('fivem-banking:withdraw', false, data.amount))
end)

RegisterNUICallback('transfer', function(data, cb)
    cb(lib.callback.await('fivem-banking:transfer', false, data.target, data.amount))
end)

if Config.Blip.enabled then
    for _, coords in ipairs(Config.Banks) do
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, Config.Blip.sprite)
        SetBlipColour(blip, Config.Blip.color)
        SetBlipScale(blip, Config.Blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(Config.Blip.label)
        EndTextCommandSetBlipName(blip)
    end
end

local useTarget = Config.UseTarget and GetResourceState('ox_target') == 'started'

if useTarget then
    local option = {
        name = 'fivem-banking:open',
        icon = 'fa-solid fa-building-columns',
        label = 'Accéder à la banque',
        distance = 2.0,
        onSelect = openBank,
    }

    exports.ox_target:addModel(Config.AtmModels, option)

    for i, coords in ipairs(Config.Banks) do
        exports.ox_target:addSphereZone({
            name = ('fivem-banking:bank_%d'):format(i),
            coords = coords,
            radius = 1.5,
            options = { option },
        })
    end
else
    local function isNearAtm(coords)
        for _, model in ipairs(Config.AtmModels) do
            if GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.5, model, false, false, false) ~= 0 then
                return true
            end
        end
        return false
    end

    local function isNearBank(coords)
        for _, bank in ipairs(Config.Banks) do
            if #(coords - bank) < 1.5 then return true end
        end
        return false
    end

    CreateThread(function()
        local shown = false

        while true do
            local coords = GetEntityCoords(cache.ped)
            local near = not isOpen and (isNearBank(coords) or isNearAtm(coords))

            if near and not shown then
                lib.showTextUI('[E] Accéder à la banque')
                shown = true
            elseif not near and shown then
                lib.hideTextUI()
                shown = false
            end

            if near then
                if IsControlJustReleased(0, 38) then openBank() end
                Wait(0)
            else
                Wait(500)
            end
        end
    end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and isOpen then
        SetNuiFocus(false, false)
    end
end)
