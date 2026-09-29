Logs = {}

local COLORS = {
    deposit = 3066993,
    withdraw = 15105570,
    transfer = 3447003,
    suspicious = 15158332,
}

function Logs.Send(kind, src, fields)
    if SvConfig.Webhook == '' then return end

    local identity = Bridge.GetIdentity(src)
    local embedFields = {
        { name = 'Joueur', value = ('%s (ID %d)'):format(identity and identity.name or 'Inconnu', src), inline = true },
        { name = 'Identifiant', value = identity and identity.identifier or 'N/A', inline = true },
    }

    for i = 1, #fields do
        embedFields[#embedFields + 1] = fields[i]
    end

    PerformHttpRequest(SvConfig.Webhook, function() end, 'POST', json.encode({
        username = 'Banque',
        embeds = {{
            title = kind == 'suspicious' and 'Activité suspecte' or ('Opération : %s'):format(kind),
            color = COLORS[kind] or 9807270,
            fields = embedFields,
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        }},
    }), { ['Content-Type'] = 'application/json' })
end
