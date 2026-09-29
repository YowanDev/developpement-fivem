# 🎮 Développement FiveM · YowanDev

Recueil de mes scripts FiveM : Lua côté client et serveur, interfaces NUI en React, bases MySQL et intégrations Discord.
Tous mes scripts sont pensés pour être **sécurisés côté serveur**, **optimisés** et **compatibles multi-framework**.

## 📂 Scripts

| Script | Description | Frameworks | Stack |
| --- | --- | --- | --- |
| [🏦 fivem-banking](fivem-banking) | Banque complète : dépôt, retrait, virement, historique SQL, logs Discord, anti-exploit | ESX · QBCore · Qbox | Lua · React · TS · oxmysql |

## 🧰 Standards appliqués à chaque script

- Aucune donnée venant du client n'est considérée comme fiable : tout est validé côté serveur
- Requêtes SQL préparées (aucune injection possible)
- Boucles client optimisées (attente adaptative, aucune boucle inutile)
- Configuration claire et séparée : les secrets restent côté serveur
- Code lisible et documenté

## 📫 Contact

Profil GitHub : [@YowanDev](https://github.com/YowanDev)
