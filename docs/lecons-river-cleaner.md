# Leçons de River Cleaner: India

*River Cleaner: India* (`Bonne-Etoile/indian-river-cleaner`) est le premier jeu de Bonne Etoile fait avec Claude : un jeu 3D à la première personne, 70 tickets en trois semaines (octobre–novembre 2026). Ce modèle en est tiré. Ce document dit ce qui a marché, ce qui a coûté, et ce qui reste dans River Cleaner sans avoir encore été extrait.

## Ce qui a marché (repris tel quel ici)

- **Le socle du premier jour** : session cloud installée par un hook, quatre commandes `make`, vérification de chaque fichier (`check_project.gd`), test de lancement de l'export (`smoke_test.sh`), captures d'écran regardées par Claude. Chaque pièce a attrapé de vrais bugs (erreurs de script que l'import ne voyait pas, listes vidées à l'export, blocage à la fermeture).
- **GDScript typé strict**, **logique pure testée** dans `game/core/`, **`Events`** et **`GameState`** : plus de 30 classes de logique testées unitairement, des scènes qui ne se connaissent pas.
- **Textes en clés** avec un test qui les vérifie : le jeu est passé en français complet sans chasse aux textes oubliés.
- **Sauvegardes et réglages en JSON versionné**, migrations testées.
- **Rapports copiés par le joueur** : crash, performance, journal de partie. Quelques minutes pour avoir les vrais chiffres de sa machine.
- **Travail autonome par tickets** (`docs/backlog.md`) avec statuts et dépendances, PR petites, et un build de test par lot.
- **Pièges notés le jour même**, écrits pour tout jeu : ils sont dans `docs/pitfalls/`.

## Ce qui a coûté (à éviter dès le début)

- **Ne pas avoir conçu pour l'échelle** : écrit pour 150 objets, porté à 10 000 en six tickets (G48 à G52, G54). Voir `docs/pitfalls/methode.md`.
- **Des décisions qui ne vivaient que dans la conversation** : à écrire le jour même, datées.
- **La CI sur chaque PR** : trop lente avec un jeu 3D en rendu logiciel (17 min) ; retirée des PR vers `dev`. Un runner auto-hébergé sous Windows/WSL a coûté plusieurs tickets avant d'être abandonné.
- **Des tests dépendants du temps réel ou du hasard global** : échecs intermittents en CI.
- **Des optimisations « évidentes » non mesurées** : l'une empirait les chiffres.
- **Des modèles jugés dans l'outil d'origine** plutôt que dans le jeu.

## Ce qui n'est pas encore extrait (à reprendre depuis River Cleaner au besoin)

| Quoi | Fichiers de River Cleaner (branche `dev`) | Pourquoi pas ici |
|---|---|---|
| Son : autoload `Audio`, banque de sons en données, musique avec silences | `game/autoload/audio.gd`, `game/data/sound_bank.gd`, `sound_def.gd`, `music_set.gd`, `game/core/music_schedule.gd` | Lié aux événements du jeu ; la méthode et les outils de production sont ici (`docs/recettes/sons-et-musique.md`), le code à généraliser au deuxième jeu. |
| Page d'options complète (volumes, plein écran, vsync, champ de vision, souris, langue) | `game/ui/options_panel.gd/.tscn` | Dépend du thème et de l'audio du jeu. `GameSettings`, `AudioSettings` et `Options` sont déjà ici. |
| Menu de démarrage complet (continuer, charger, supprimer, crédits) | `game/ui/main_menu.gd/.tscn` | Le modèle n'a qu'une version minimale (jouer, quitter, rapport de crash). |
| Écran de crédits généré depuis `assets/LICENSES.md` | `game/core/credits_reader.gd`, `game/data/credit*.gd`, `tools/make_credits.gd` | À reprendre dès qu'il y a des assets. |
| Mesure de performance (scène, variantes, bouton du menu) | `game/benchmark/`, `tools/benchmark.tscn` | Propre aux objets du jeu ; `FrameStats` est ici. |
| Journal de partie | `game/core/play_log.gd` | Colonnes propres à River Cleaner (rivière) ; recette dans `docs/recettes/mesurer.md`. |
| Simulation d'équilibrage | `tools/balance_simulation.gd`, `docs/equilibrage.md` | Propre à l'économie du jeu. |
| Carte quadrillée d'un niveau (vue de dessus, cases nommées) | `tools/river_map.gd`, `river_mapper.gd`, `game/core/map_grid.gd` | Utile pour discuter d'un emplacement ; `MapGrid` est générique. |
| Thème d'interface dessiné par script | `tools/assets/make_ui_theme.py`, `game/ui/theme/` | Propre à l'univers du jeu ; la méthode (neuf-parties, motifs générés) se reprend. |
| Modèles générés par script (Godot, Blender) | `tools/assets/build_*.gd`, branche `claude/essais-blender` | La méthode et deux exemples génériques sont ici (`docs/recettes/modeles-3d.md`) ; les scripts du jeu restent des exemples. |
| Skill `gauntlet-loop` | `.claude/skills/gauntlet-loop/` | Sans lien avec Godot ; à copier avec sa licence si besoin. |
| Plan marketing (page Steam, vidéos, calendrier) | `docs/marketing/plan-marketing.md` | Un modèle de plan marketing pourrait venir ici. |

## À corriger dans River Cleaner

- `docs/architecture.md` de la branche `dev` contient des marqueurs de conflit de merge non résolus (`<<<<<<< HEAD`, `=======`, `>>>>>>> origin/dev`) autour des décisions 32 et 33.
