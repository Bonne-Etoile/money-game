# Licences des assets

Chaque asset externe (modèle, texture, son, police, musique) est listé ici dès son entrée. Pour un asset généré par IA : l'outil, sa licence d'usage commercial et les retouches faites. Cette liste sert aussi à l'écran de crédits et au questionnaire de contenu de Steamworks. Un texte de crédit exigé s'écrit entre « » après « crédit obligatoire : ».

| Fichier | Source | Auteur | Licence | IA (outil, retouches) |
|---|---|---|---|---|
| `assets/sounds/music_calm.ogg` | composée par le code du projet (`tools/assets/compose_music.py`, sinusoïdes et bruit, aucun échantillon) | Claude pour le projet | propriété du projet | non (algorithme écrit à la main) |

## Code tiers

| Dossier | Source | Version | Licence |
|---|---|---|---|
| `addons/gdUnit4` | https://github.com/MikeSchulze/gdUnit4 | 6.2.2 | MIT (`addons/gdUnit4/LICENSE`) ; outil de test, exclu des exports |
| `addons/admob` | https://github.com/poingstudios/godot-admob-plugin | 5.1.0 (binaires Android `android-template-v4.7.2.zip` de la même version) | MIT (`addons/admob/LICENSE`) ; pubs AdMob, inclus dans l'export Android |
