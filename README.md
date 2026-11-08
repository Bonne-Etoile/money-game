# Template Godot de Bonne Etoile

Modèle de départ pour un jeu Godot développé par Claude et un humain, tiré de ce qu'a appris *River Cleaner: India* (`Bonne-Etoile/indian-river-cleaner`, 70 tickets, du projet vide à un jeu jouable). Chaque fichier a déjà payé ses pièges : on le reprend tel quel et on change les noms.

## Ce qu'il contient

| Quoi | Où | Pourquoi |
|---|---|---|
| Projet Godot 4.7.2 prêt à l'emploi | `project.godot`, `.godot-version`, `export_presets.cfg` | Forward+, Jolt, GDScript typé strict (avertissements en erreurs), entrées par position physique, traductions déclarées, exports Windows et Linux sans les outils de test. |
| Squelette de jeu | `game/` | Autoloads `Events`, `GameState`, `Diagnostics`, `Display`, `Options` ; logique pure dans `game/core/` (sauvegarde JSON versionnée, réglages, rapport de crash, lecture JSON sans confiance, statistiques d'images) ; un menu de démarrage et une scène de jeu. |
| Tests | `test/` | gdUnit4 6.2.2 (`addons/gdUnit4`) : 49 tests unitaires et de scénario, dont les garde-fous (réglages du projet, traductions complètes, textes de scène traduits). |
| Quatre commandes | `Makefile` | `make lint check test build`, identiques dans la session cloud, en CI et avant chaque PR ; `make screenshot(s)` pour voir le jeu. |
| Outils | `tools/` | Installation de la session cloud, vérification du projet, captures d'écran, test de lancement de l'export, renommage du jeu ; `tools/assets/` : génération et traitement des sons, modèles par script (Godot, Blender), import glb avec niveaux de détail. |
| CI | `.github/workflows/` | Vérifications sur `main`/`dev`, build Windows à la demande (branche `claude/test-build-*`). |
| Règles pour Claude | `CLAUDE.md` | Règles de code, de test, de workflow et de travail autonome, à compléter. |
| Documentation | `docs/` | Pièges par thème, recettes (dont sons et musique, modèles 3D), ressources, modèles de documents (architecture, backlog, feuille de route, conception, avant la sortie). |

## Démarrer un nouveau jeu

1. Créer le dépôt depuis ce modèle (bouton « Use this template » de GitHub, ou copie), puis la branche `dev`.
2. `tools/new-game.sh "Nom Du Jeu" nom_du_jeu` : renomme le jeu partout (nom affiché, binaires, artefacts).
3. Ouvrir une session Claude Code sur le dépôt : le hook de démarrage installe Godot, les modèles d'export, Xvfb, le Vulkan logiciel et gdtoolkit (`tools/setup-cloud.sh`).
4. `make lint check test build` : tout doit passer avant la première ligne de jeu.
5. Remplir `docs/conception-du-jeu.md`, puis `docs/feuille-de-route.md` et `docs/backlog.md` ; compléter `CLAUDE.md` (sections marquées « À compléter »).
6. Lire `docs/pitfalls/methode.md` et `docs/recettes/README.md`.

Le détail : `docs/recettes/demarrer-un-jeu.md`.

## Pour aller plus loin

- `docs/lecons-river-cleaner.md` : ce que le premier jeu a appris, et ce qui n'a pas encore été extrait ici.
- `docs/ressources.md` : documentation, outils, banques d'assets, ce qui est accessible depuis la session cloud.
- Une leçon qui vaut pour tout jeu, apprise sur un projet : la remonter ici (pièges, recettes, squelette), pour que chaque jeu rende le suivant plus rapide.
