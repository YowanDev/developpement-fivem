Config = {}

-- 'auto' détecte le framework démarré. Valeurs possibles : 'auto', 'esx', 'qbcore', 'qbox'
Config.Framework = 'auto'

Config.UseTarget = true -- utilise ox_target s'il est démarré, sinon interaction touche E

Config.AtmModels = {
    `prop_atm_01`,
    `prop_atm_02`,
    `prop_atm_03`,
    `prop_fleeca_atm`,
}

Config.Banks = {
    vec3(149.9, -1040.46, 29.37),
    vec3(314.23, -278.83, 54.17),
    vec3(-350.8, -49.57, 49.04),
    vec3(-1213.0, -330.39, 37.79),
    vec3(-2962.71, 483.0, 15.7),
    vec3(1175.07, 2706.41, 38.09),
    vec3(247.8, 223.3, 106.29),
    vec3(-112.2, 6469.29, 31.63),
}

Config.Blip = {
    enabled = true,
    sprite = 108,
    color = 2,
    scale = 0.8,
    label = 'Banque',
}

Config.Limits = {
    maxAmount = 1000000,   -- montant max par opération
    cooldownMs = 1500,     -- délai minimum entre deux opérations
    sessionDistance = 5.0, -- distance max depuis l'ouverture du menu
    sessionTimeout = 300,  -- durée de vie d'une session (secondes)
    historySize = 20,
}
