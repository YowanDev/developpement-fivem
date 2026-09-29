Bridge = {}

local framework = Config.Framework
local core

if framework == 'auto' then
    if GetResourceState('qbx_core') == 'started' then
        framework = 'qbox'
    elseif GetResourceState('qb-core') == 'started' then
        framework = 'qbcore'
    elseif GetResourceState('es_extended') == 'started' then
        framework = 'esx'
    else
        error('[fivem-banking] Aucun framework compatible détecté (ESX, QBCore, Qbox).')
    end
end

if framework == 'esx' then
    core = exports['es_extended']:getSharedObject()
elseif framework == 'qbcore' then
    core = exports['qb-core']:GetCoreObject()
end

print(('[fivem-banking] Framework détecté : ^2%s^7'):format(framework))

local function getPlayer(src)
    if framework == 'esx' then
        return core.GetPlayerFromId(src)
    elseif framework == 'qbcore' then
        return core.Functions.GetPlayer(src)
    elseif framework == 'qbox' then
        return exports.qbx_core:GetPlayer(src)
    end
end

---@return { identifier: string, name: string } | nil
function Bridge.GetIdentity(src)
    local player = getPlayer(src)
    if not player then return end

    if framework == 'esx' then
        return { identifier = player.identifier, name = player.getName() }
    end

    local info = player.PlayerData.charinfo
    return {
        identifier = player.PlayerData.citizenid,
        name = ('%s %s'):format(info.firstname, info.lastname),
    }
end

---@param account 'bank' | 'cash'
function Bridge.GetMoney(src, account)
    local player = getPlayer(src)
    if not player then return 0 end

    if framework == 'esx' then
        if account == 'cash' then return player.getMoney() end
        return player.getAccount('bank').money
    end

    return player.PlayerData.money[account] or 0
end

---@param account 'bank' | 'cash'
function Bridge.AddMoney(src, account, amount, reason)
    local player = getPlayer(src)
    if not player then return false end

    if framework == 'esx' then
        if account == 'cash' then
            player.addMoney(amount, reason)
        else
            player.addAccountMoney('bank', amount, reason)
        end
        return true
    end

    return player.Functions.AddMoney(account, amount, reason) ~= false
end

---@param account 'bank' | 'cash'
function Bridge.RemoveMoney(src, account, amount, reason)
    local player = getPlayer(src)
    if not player then return false end
    if Bridge.GetMoney(src, account) < amount then return false end

    if framework == 'esx' then
        if account == 'cash' then
            player.removeMoney(amount, reason)
        else
            player.removeAccountMoney('bank', amount, reason)
        end
        return true
    end

    return player.Functions.RemoveMoney(account, amount, reason) ~= false
end
