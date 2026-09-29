# 🏦 fivem-banking

Système bancaire **multi-framework** pour FiveM avec une interface **React + TypeScript**.
Conçu avec la sécurité côté serveur comme priorité : aucune donnée envoyée par le client n'est considérée comme fiable.

![Lua](https://img.shields.io/badge/Lua-5.4-2C2D72?logo=lua)
![React](https://img.shields.io/badge/React-18-61DAFB?logo=react&logoColor=black)
![TypeScript](https://img.shields.io/badge/TypeScript-5-3178C6?logo=typescript&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-oxmysql-4479A1?logo=mysql&logoColor=white)

<!-- Ajoute une capture d'écran ou un GIF ici : ![Aperçu](docs/preview.png) -->

## ✨ Fonctionnalités

- **Compatible ESX, QBCore et Qbox**, détection automatique via un bridge unique
- Dépôt, retrait et virement entre joueurs
- Historique des transactions stocké en base (oxmysql)
- Interface React moderne, testable dans le navigateur avec des données fictives
- Support **ox_target** ou interaction classique (touche `E`) au choix
- Blips sur la carte pour chaque agence
- **Logs Discord** (webhook) de toutes les opérations et des activités suspectes

## 🔒 Sécurité

| Protection | Détail |
| --- | --- |
| Session serveur | Une opération n'est acceptée que si le joueur a réellement ouvert la banque |
| Contrôle de distance | Session annulée si le joueur s'éloigne du point d'ouverture |
| Anti-spam | Délai minimum entre deux opérations |
| Validation des montants | Entier, positif, plafonné ; toute valeur anormale est loggée |
| Webhook protégé | Stocké dans un fichier serveur uniquement, jamais envoyé aux clients |

## 📦 Installation

1. Dépendances : [ox_lib](https://github.com/overextended/ox_lib), [oxmysql](https://github.com/overextended/oxmysql)
2. Importer `sql/install.sql` dans ta base de données
3. Placer le dossier dans `resources/` puis ajouter dans `server.cfg` :
   ```cfg
   ensure ox_lib
   ensure oxmysql
   ensure fivem-banking
   ```
4. (Optionnel) renseigner le webhook dans `server/sv_config.lua`

## 🛠️ Développement de l'interface

```bash
cd web
npm install
npm run dev    # aperçu dans le navigateur avec données fictives
npm run build  # génère web/dist utilisé en jeu
```

## 📁 Structure

```
fivem-banking/
├── bridge/        # abstraction ESX / QBCore / Qbox
├── client/        # interactions, blips, NUI
├── server/        # logique métier, validation, logs Discord
├── sql/           # schéma de la base
└── web/           # interface React + TypeScript (Vite)
```

## 📄 Licence

MIT, voir [LICENSE](LICENSE).
