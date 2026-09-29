-- Fichier chargé uniquement côté serveur : ne jamais mettre le webhook dans config.lua (envoyé aux clients).
SvConfig = {}

SvConfig.Webhook = '' -- URL du webhook Discord, laisser vide pour désactiver

SvConfig.LogThreshold = 50000 -- seuil au-delà duquel une opération est signalée comme suspecte
