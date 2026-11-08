# Ressources

Vérifiées sur *River Cleaner: India* (octobre–novembre 2026). Une ressource qui ne marche plus : la corriger ici.

## Documentation

| Quoi | Où | Note |
|---|---|---|
| Godot 4.7 | https://docs.godotengine.org/en/4.7/ | Depuis la session : `curl` (WebFetch ne la résout pas). Le domaine doit être autorisé dans le réseau de l'environnement. |
| Référence des classes hors ligne | `godot --headless --doctool <dossier>` | XML de toutes les classes de la version installée, sans descriptions. Hors du dépôt. |
| Ligne de commande de Godot | `godot --help` | Vérifier chaque option avant de l'utiliser. |
| Guide de style GDScript | https://docs.godotengine.org/en/4.7/tutorials/scripting/gdscript/gdscript_styleguide.html | Appliqué par gdtoolkit. |
| gdUnit4 | https://github.com/MikeSchulze/gdUnit4 (doc : https://mikeschulze.github.io/gdUnit4/) | Version 6.2.2 copiée dans `addons/gdUnit4`. |
| gdtoolkit (gdlint, gdformat) | https://github.com/Scony/godot-gdscript-toolkit | 4.5.0, `requirements-dev.txt`. |
| Jolt dans Godot | doc de Godot, « Using Jolt Physics » | Limite `physics/jolt_physics_3d/limits/max_bodies` (10 240 par défaut). |
| Movie Maker | doc de Godot, « Creating movies » | `--write-movie x.avi --fixed-fps 30 --quit-after N` : vidéos image par image, quelle que soit la vitesse du rendu. |
| GodotSteam | https://godotsteam.com | GDExtension, derrière un autoload `Platform`. |
| Steamworks | https://partner.steamgames.com/doc | Steam Direct (100 $), questionnaire de contenu IA, Auto-Cloud pour les sauvegardes. |

## Téléchargements (depuis la session cloud)

- Godot et modèles d'export : `https://github.com/godotengine/godot/releases/download/<version>/…` (fait par `tools/setup-cloud.sh`). Les modèles pèsent 1,3 Go : seuls Linux et Windows x86_64 sont gardés.
- Blender : `apt-get install -y blender python3-numpy` (Blender 4.0 sur Ubuntu 24.04 ; le binaire officiel téléchargé est refusé).
- Images de Wikipédia : API REST `en.wikipedia.org/api/rest_v1/page/media-list/<article>`, avec un `User-Agent` et quelques secondes entre deux requêtes (l'API de Commons répond 429).
- Inaccessibles : artefacts de GitHub Actions (stockage Azure), certains sites de banques d'assets selon le réseau de l'environnement.

## Assets

| Quoi | Où | Licence |
|---|---|---|
| Modèles, sons, interfaces | https://kenney.nl | CC0 |
| Modèles low poly (nature, personnages) | https://quaternius.com (aussi sur OpenGameArt) | CC0 |
| Sons, musiques, modèles | https://opengameart.org | variable, vérifier chaque asset |
| Musiques | https://incompetech.com (Kevin MacLeod) | CC BY 4.0, crédit obligatoire |
| Polices | https://fonts.google.com | OFL : joindre la licence au jeu |
| Icônes | https://lucide.dev | ISC, crédit |
| Modèles 3D par IA | Tripo Studio | usage commercial selon le forfait |
| Sons et musiques par IA | ElevenLabs (API) | usage commercial avec un forfait payant |
| Images de référence | Nano Banana (généré par le joueur) | références seulement, jamais dans le jeu |

## Outils de Claude

- Skill `gauntlet-loop` (CC BY 4.0, https://github.com/robonuggets/gauntlet-loop) : un constructeur et un critique séparé, comparaison à l'aveugle avec une référence réelle. Copié dans `.claude/skills/` de River Cleaner ; à reprendre si le jeu en a besoin, avec son fichier de licence.
- `actionlint` pour vérifier un workflow avant de le pousser.
- `ffmpeg` pour les sons et les vidéos.
