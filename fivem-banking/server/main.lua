local sessions = {}
local lastAction = {}

local function addTransaction(identifier, kind, amount, label)
    MySQL.insert('INSERT INTO bank_transactions (identifier, type, amount, label) VALUES (?, ?, ?, ?)', {
        identifier, kind, amount, label,
    })
end

local function getState(src)
    local identity = Bridge.GetIdentity(src)
    if not identity then return end

    local history = MySQL.query.await(
        'SELECT type, amount, label, UNIX_TIMESTAMP(created_at) AS date FROM bank_transactions WHERE identifier = ? ORDER BY id DESC LIMIT ?',
        { identity.identifier, Config.Limits.historySize }
    )

    return {
        name = identity.name,
        bank = Bridge.GetMoney(src, 'bank'),
        cash = Bridge.GetMoney(src, 'cash'),
        transactions = history or {},
    }
end

--- Vérifie que la requête provient d'un joueur ayant réellement ouvert la banque,
--- qu'il n'a pas bougé depuis, qu'il ne spamme pas et que le montant est valide.
local function validate(src, amount)
    local session = sessions[src]
    if not session then return false, 'Session invalide.' end

    if os.time() - session.openedAt > Config.Limits.sessionTimeout then
        sessions[src] = nil
        return false, 'Session expirée, rouvre la banque.'
    end

    local coords = GetEntityCoords(GetPlayerPed(src))
    if #(coords - session.coords) > Config.Limits.sessionDistance then
        sessions[src] = nil
        return false, 'Tu es trop loin de la banque.'
    end

    local now = GetGameTimer()
    if lastAction[src] and now - lastAction[src] < Config.Limits.cooldownMs then
        return false, 'Doucement, patiente un instant.'
    end
    lastAction[src] = now

    amount = tonumber(amount)
    if not amount or amount ~= math.floor(amount) or amount <= 0 or amount > Config.Limits.maxAmount then
        Logs.Send('suspicious', src, {
            { name = 'Montant reçu', value = tostring(amount), inline = false },
        })
        return false, 'Montant invalide.'
    end

    return true, amount
end

local function reply(src, ok, message)
    return { ok = ok, message = message, state = getState(src) }
end

local function flagIfLarge(src, kind, amount)
    if amount >= SvConfig.LogThreshold then
        Logs.Send('suspicious', src, {
            { name = 'Type', value = kind, inline = true },
            { name = 'Montant', value = ('$%d'):format(amount), inline = true },
        })
    end
end

lib.callback.register('fivem-banking:open', function(src)
    sessions[src] = {
        coords = GetEntityCoords(GetPlayerPed(src)),
        openedAt = os.time(),
    }
    return getState(src)
end)

lib.callback.register('fivem-banking:close', function(src)
    sessions[src] = nil
    return true
end)

lib.callback.register('fivem-banking:deposit', function(src, amount)
    local ok, result = validate(src, amount)
    if not ok then return reply(src, false, result) end
    amount = result

    if not Bridge.RemoveMoney(src, 'cash', amount, 'bank-deposit') then
        return reply(src, false, "Tu n'as pas assez de liquide.")
    end
    Bridge.AddMoney(src, 'bank', amount, 'bank-deposit')

    addTransaction(Bridge.GetIdentity(src).identifier, 'deposit', amount, 'Dépôt')
    Logs.Send('deposit', src, { { name = 'Montant', value = ('$%d'):format(amount), inline = true } })
    flagIfLarge(src, 'deposit', amount)

    return reply(src, true, ('Dépôt de $%d effectué.'):format(amount))
end)

lib.callback.register('fivem-banking:withdraw', function(src, amount)
    local ok, result = validate(src, amount)
    if not ok then return reply(src, false, result) end
    amount = result

    if not Bridge.RemoveMoney(src, 'bank', amount, 'bank-withdraw') then
        return reply(src, false, 'Solde insuffisant.')
    end
    Bridge.AddMoney(src, 'cash', amount, 'bank-withdraw')

    addTransaction(Bridge.GetIdentity(src).identifier, 'withdraw', amount, 'Retrait')
    Logs.Send('withdraw', src, { { name = 'Montant', value = ('$%d'):format(amount), inline = true } })
    flagIfLarge(src, 'withdraw', amount)

    return reply(src, true, ('Retrait de $%d effectué.'):format(amount))
end)

lib.callback.register('fivem-banking:transfer', function(src, targetId, amount)
    local ok, result = validate(src, amount)
    if not ok then return reply(src, false, result) end
    amount = result

    targetId = tonumber(targetId)
    if not targetId or targetId == src then
        return reply(src, false, 'Destinataire invalide.')
    end

    local target = Bridge.GetIdentity(targetId)
    if not target then
        return reply(src, false, "Ce joueur n'est pas connecté.")
    end

    if not Bridge.RemoveMoney(src, 'bank', amount, 'bank-transfer') then
        return reply(src, false, 'Solde insuffisant.')
    end
    Bridge.AddMoney(targetId, 'bank', amount, 'bank-transfer')

    local sender = Bridge.GetIdentity(src)
    addTransaction(sender.identifier, 'transfer_out', amount, ('Virement à %s'):format(target.name))
    addTransaction(target.identifier, 'transfer_in', amount, ('Virement de %s'):format(sender.name))

    TriggerClientEvent('ox_lib:notify', targetId, {
        title = 'Banque',
        description = ('Tu as reçu $%d de %s.'):format(amount, sender.name),
        type = 'success',
    })

    Logs.Send('transfer', src, {
        { name = 'Destinataire', value = ('%s (ID %d)'):format(target.name, targetId), inline = true },
        { name = 'Montant', value = ('$%d'):format(amount), inline = true },
    })
    flagIfLarge(src, 'transfer', amount)

    return reply(src, true, ('Virement de $%d envoyé à %s.'):format(amount, target.name))
end)

AddEventHandler('playerDropped', function()
    sessions[source] = nil
    lastAction[source] = nil
end)
