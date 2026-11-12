# Licences des assets

Chaque asset externe (modèle, texture, son, police, musique) est listé ici dès son entrée. Pour un asset généré par IA : l'outil, sa licence d'usage commercial et les retouches faites. Cette liste sert aussi à l'écran de crédits et au questionnaire de contenu de Steamworks. Un texte de crédit exigé s'écrit entre « » après « crédit obligatoire : ».

| Fichier | Source | Auteur | Licence | IA (outil, retouches) |
|---|---|---|---|---|
| `assets/sounds/music_calm.ogg` | composée par le code du projet (`tools/assets/compose_music.py`, sinusoïdes et bruit, aucun échantillon) | Claude pour le projet | propriété du projet | non (algorithme écrit à la main) |
| `assets/icon/*.png` (icône du jeu, icônes du lanceur Android) | dessinées par le code du projet (`tools/assets/make_icon.py`, Pillow et numpy, aucune image source) | Claude pour le projet | propriété du projet | non (dessin écrit à la main, aucun outil de génération d'images) |
| `assets/fonts/Fredoka-Variable.ttf` | https://github.com/google/fonts/tree/main/ofl/fredoka (police variable, axes graisse et largeur) | The Fredoka Project Authors (https://github.com/hafontia/Fredoka-One) | SIL Open Font License 1.1 (`assets/fonts/OFL.txt`, à joindre au jeu) | non |

## Code tiers

| Dossier | Source | Version | Licence |
|---|---|---|---|
| `addons/gdUnit4` | https://github.com/MikeSchulze/gdUnit4 | 6.2.2 | MIT (`addons/gdUnit4/LICENSE`) ; outil de test, exclu des exports |
| `addons/admob` | https://github.com/poingstudios/godot-admob-plugin | 5.1.0 (binaires Android `android-template-v4.7.2.zip` de la même version) | MIT (`addons/admob/LICENSE`) ; pubs AdMob, inclus dans l'export Android |
