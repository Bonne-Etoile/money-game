# Décisions d'architecture

Chaque décision donne son contexte, le choix fait, sa raison et ses conséquences. Une décision qui change est mise à jour ici, sans effacer l'historique : on ajoute « Remplacée par … ». Les règles opérationnelles qui en découlent vont dans `CLAUDE.md`.

Les décisions 1 à 15 viennent du modèle (validées sur *River Cleaner: India*). Les décisions propres au jeu commencent à 16.

## 1. Moteur : Godot 4.7.2, version épinglée

- **Choix** : Godot **4.7.2-stable**, version standard (sans .NET). La version est écrite dans `.godot-version`, lu par `tools/setup-cloud.sh` et par la CI.
- **Pourquoi** : scènes et ressources en texte (relisibles en PR), moteur pilotable en ligne de commande (tests, export, captures, vidéos), licence MIT sans redevance.
- **Conséquence** : on ne monte de version qu'avec un ticket dédié (guide de migration officiel, tests, captures avant/après).

## 2. Langage : GDScript entièrement typé

- **Choix** : GDScript typé partout ; `untyped_declaration` et `unsafe_*` en **erreurs** (`project.godot`, garde-fou `project_settings_test.gd`). Style officiel vérifié par `gdlint` et `gdformat`.
- **Pourquoi** : pas de .NET dans la CI ; le typage strict attrape beaucoup de bugs avant de jouer.

## 3. Logique pure séparée des scènes

- **Choix** : les règles du jeu sont des classes `RefCounted` de `game/core/`, sans nœud. Les scènes appellent cette logique et affichent le résultat.
- **Pourquoi** : la logique se teste en millisecondes, sans lancer le jeu ; l'équilibrage peut être simulé par un script (`tools/`).

## 4. Communication : autoload `Events`, état dans `GameState`

- **Choix** : `Events` porte les signaux globaux ; les scènes ne se connaissent pas. `GameState` tient l'état de la partie (`GameProgress`) et est le seul à le modifier.
- **Pourquoi** : une scène s'ajoute ou se retire sans toucher aux autres ; un test vérifie un signal sans monter tout le jeu.

## 5. Organisation par fonctionnalité

- **Choix** : `game/autoload/`, `game/core/`, `game/data/`, puis un dossier par fonctionnalité (`game/player/`, `game/ui/`…) ; `assets/`, `locale/`, `test/` (`unit/`, `scenario/`, `fixtures/`), `tools/`, `docs/`.
- **Pourquoi** : ce qui touche à une fonctionnalité est au même endroit.

## 6. Données en ressources typées

- **Choix** : chaque définition du jeu (objet, amélioration, niveau…) est une ressource `.tres` d'une classe typée de `game/data/`.
- **Pourquoi** : texte, typé, éditable dans l'éditeur comme dans un fichier ; ajouter un élément ne demande pas de code.
- **Attention** : une liste exportée en `PackedFloat32Array` peut être vidée à l'export ; utiliser `Array[float]` (pitfalls, GDScript).

## 7. Traductions : anglais en base, CSV

- **Choix** : `locale/translations.csv` (clé, `en`, `fr`, `_notes`), une clé par texte. Aucun texte en dur ; un test vérifie que chaque clé est traduite et que chaque texte de scène est une clé.
- **Attention** : l'import sans éditeur ne déclare pas les traductions ; la liste est écrite à la main dans `project.godot`.

## 8. Sauvegardes et réglages : JSON versionné

- **Choix** : `SaveGame` (version, migrations), `SaveSlots` (un fichier par emplacement, fichier temporaire puis renommage, `.bak` gardé), réglages à part (`WindowSettings`, `GameSettings`, `AudioSettings`), lus sans confiance (`JsonRead`). Seul le jeu exporté écrit ses réglages.
- **Pourquoi pas une ressource** : charger une ressource peut exécuter du code ; une sauvegarde partagée deviendrait un vecteur d'attaque.

## 9. Qualité : quatre commandes

| Commande | Contenu |
|---|---|
| `make lint` | `gdlint` et `gdformat --check` |
| `make check` | import, puis chargement de chaque fichier (`tools/check_project.gd`) : l'import seul ne compile pas les scripts |
| `make test` | gdUnit4 sous Xvfb (il refuse le mode sans affichage) |
| `make build` | exports Windows et Linux, puis lancement de l'export Linux (`tools/smoke_test.sh`) |

- **Captures** : `tools/screenshot.gd` (Xvfb, jamais `--headless` qui n'a pas de pixels). Claude regarde chaque capture avant de conclure.

## 10. CI : GitHub Actions, runners de GitHub

- **Choix** : `ci.yml` (`lint check test`) sur les PR vers `main` et les pushs sur `dev`/`main` ; `build.yml` à la demande (branche `claude/test-build-*`, bouton, PR vers `main`). Outils installés par le même `tools/setup-cloud.sh`, mis en cache, tout écrit hors du dépôt sous `$RUNNER_TOOL_CACHE`.
- **Pas de job sur les PR vers `dev`** : trop lent avec un jeu 3D en rendu logiciel ; Claude lance les quatre commandes dans sa session.
- **Runner auto-hébergé** : essayé sur River Cleaner (WSL), abandonné ; voir `docs/pitfalls/ci-et-session-cloud.md` avant d'y revenir.

## 11. Session cloud de Claude

- **Choix** : `.claude/hooks/session-start.sh` lance `tools/setup-cloud.sh` (Godot et modèles d'export depuis les releases GitHub, Xvfb, `mesa-vulkan-drivers`, gdtoolkit) puis importe le projet. Idempotent.
- **Rendu** : Forward+ tourne en rendu logiciel (lavapipe) : lent, mais juste pour les captures et les tests. Les temps de rendu n'y valent rien : ils se mesurent sur la machine du joueur.

## 12. Entrées : actions de l'Input Map, touches physiques

- **Choix** : tout passe par des actions ; les touches sont définies par leur position physique (`physical_keycode`).
- **Pourquoi** : ZQSD et WASD sans réglage, réassignation et manette possibles plus tard, entrées simulables dans les tests.

## 13. Branches et travail autonome

- **Choix** : `main` (versions publiées, mergée par l'humain) ← `dev` (intégration) ← une branche par ticket `claude/<ticket>-<sujet>`. Tickets dans `docs/backlog.md`, pièges dans `docs/pitfalls/`, règles dans `CLAUDE.md`. Les essais non intégrés vont sur une branche `claude/essais-<sujet>`.
- **Ce qui reste humain** : sensations, son, fluidité sur une vraie machine, testés par lots sur un build de test.

## 14. Rapports de crash et mesures copiées par le joueur

- **Choix** : l'autoload `Diagnostics` (le premier) ajoute un `Logger` (`SessionLog`) qui écrit tout dans `user://logs/session.log`, vidé à chaque ligne, terminé par une ligne de fin à la sortie normale. Au lancement suivant, un journal sans cette ligne est un crash : le menu propose de copier le rapport (`CrashReport`). `always_track_call_stacks` garde la pile GDScript dans le jeu exporté.
- **Pourquoi** : en *release*, le journal de Godot n'est vidé qu'à la fermeture et la plupart des erreurs de script ne sont pas signalées ; après un crash, il était vide.
- **Même principe** pour tout ce qui se mesure sur la machine du joueur : un bouton qui copie un rapport texte (performance, journal de partie), listé dans `docs/avant-la-sortie.md` pour être retiré.

## 15. Assets : formats ouverts, licences tracées

- **Choix** : `.glb`, PNG, OGG. Chaque asset externe et chaque usage d'IA dans `assets/LICENSES.md` dès son entrée (source unique pour les crédits et la déclaration Steamworks). Pas de Git LFS au départ.
- **Production des modèles** : références d'abord (planche de quatre vues générée par le joueur), puis l'outil adapté (outil 3D par IA pour personnages, Blender par script pour accessoires, `SurfaceTool` pour le procédural), jugé sur une capture du jeu (`docs/recettes/assets.md`).

<!-- Décisions propres au jeu : à partir de 16. -->

## 16. Technologie : Godot 4.7 pour Android, pubs AdMob (2026-11-08)

- **Contexte** : jeu mobile financé par la pub, Android d'abord. Deux options étudiées (`docs/strategies-pub.md`, section 9) : SvelteKit + Capacitor, ou Godot.
- **Choix** (décision de Stelio, 2026-11-08) : **Godot 4.7**, en gardant le modèle du dépôt. Pubs et consentement par le plugin **poingstudios `godot-admob-plugin`** (MIT, version 5.1.0 testée jusqu'à Godot 4.7.2).
- **Pourquoi** : le dépôt est déjà outillé (tests, captures, CI, règles) ; Godot laisse ouverts tous les genres, y compris l'action.
- **Conséquences** (tickets à créer) : passer au rendu Mobile ou Compatibility ; ajouter le préréglage d'export Android (AAB, Gradle build, API cible 36, `minSdk` 24) ; installer le SDK Android, un JDK 17 et les modèles d'export Android dans `tools/setup-cloud.sh` et la CI ; entrées tactiles par actions de l'Input Map ; pubs derrière un autoload (comme `Platform` pour Steam) avec une version factice pour le développement et les tests.


## 17. Jeu 2D en portrait, rendu Compatibility (2026-11-08, G0)

- **Contexte** : le modèle visait un jeu 3D sur PC (Forward+, Jolt, 1920 × 1080, déplacement ZQSD). Le jeu est un puzzle 2D sur téléphone.
- **Choix** : fenêtre de référence **720 × 1280 en portrait** (`display/window/handheld/orientation` = portrait), étirement `canvas_items` avec l'aspect `expand` (l'image s'allonge sur les téléphones plus hauts au lieu d'avoir des bandes noires : l'interface s'ancre en haut et en bas) ; rendu **Compatibility** (OpenGL ES 3) partout ; une seule action de pointage, `pointer` (clic gauche), le toucher étant converti en souris (`emulate_mouse_from_touch`, réglage par défaut) ; sur PC, fenêtre 450 × 800 pour tester. Retirés : la physique Jolt, les actions de déplacement, la scène 3D, les outils de modèles 3D.
- **Pourquoi** : Compatibility tourne sur le plus de téléphones Android (y compris les anciens sans Vulkan correct), démarre plus vite, et suffit largement à un jeu 2D ; un seul doigt suffit à un puzzle de glisser-déposer, et la conversion toucher → souris permet de tester à la souris sur PC et dans les tests de scénario.
- **Garde-fou** : `test/unit/project_settings_test.gd`.


## 18. Pubs derrière l'autoload `Ads`, version factice hors Android (2026-11-08, G3)

- **Contexte** : décision 16 (plugin poingstudios). Les tests et les builds PC tournent sans réseau publicitaire ; le plugin n'a de côté natif que sur Android et iOS.
- **Choix** : l'autoload `Ads` (`game/autoload/ads.gd`) est le seul point d'entrée : une scène appelle `Ads.show_rewarded(<emplacement>)` et écoute `Events.rewarded_ad_finished(emplacement, récompensé)` et `Events.rewarded_ad_ready_changed`. Derrière, un `AdsBackend` (`game/ads/`) : `AdMobAdsBackend` sur Android (consentement UMP, puis initialisation, puis une pub récompensée chargée d'avance, rechargée après chaque affichage), `FakeAdsBackend` ailleurs (pub toujours prête, finie tout de suite ; les tests règlent `ready` et `grants_reward`). Les identifiants de blocs d'annonces sont dans `game/data/ad_settings.tres`. Le plugin est copié dans `addons/admob` ; ses binaires natifs (Android et iOS, non versionnés) sont installés par `tools/install-admob-binaries.sh`, appelé par `tools/setup-cloud.sh` et `tools/setup-android.sh`, pour que le greffon ne les télécharge jamais lui-même sans rien dire (accord de Stelio pour ces deux téléchargements, 2026-11-08).
- **Pourquoi** : les scènes et les tests ne dépendent pas du plugin ; changer de réseau publicitaire ne touche qu'un fichier ; seules des pubs récompensées choisies par le joueur (`docs/strategies-pub.md`).
- **Aucune pub forcée pour le moment** (décision de Stelio, 2026-11-09) : ni interstitiel ni bannière ; `Ads` n'expose que les pubs récompensées. À rouvrir seulement sur décision de Stelio, avec les plafonds de `docs/strategies-pub.md` (section 5).
- **Export** : préréglage « Android » (build Gradle, APK de test signé avec la clé de débogage, `minSdk` 24 et API cible 36 par défaut de Godot 4.7.2, arm64 et armv7). `tools/setup-android.sh` installe le JDK 17, le SDK et les modèles d'export Android ; `make android` produit `build/android/block_tiles.apk`. Il faut l'accès à `dl.google.com` (environnement cloud « money-game »).
- **Greffon d'éditeur AdMob activé** (2026-11-08) : sans lui, l'export n'ajoute ni la bibliothèque ni l'identifiant d'application AdMob au manifeste. Il réécrit `project.godot` à chaque lancement (`docs/pitfalls/godot-gdscript-et-scenes.md`). L'export Android demande aussi la compression ETC2/ASTC (`project.godot`) et les chemins du SDK et du JDK 17 dans les réglages de l'éditeur (écrits par `tools/setup-android.sh`).


## 19. Suivi du joueur dans la sauvegarde, difficulté adaptative dans `game/core/` (2026-11-09, G9)

- **Contexte** : Stelio (2026-11-09) : le jeu est trop facile, aucune pub n'est vue ; il faut suivre le comportement du joueur et adapter la difficulté pour l'amener à acheter des bonus avec une pub.
- **Choix** : `PlayerStats` (`game/core/`) garde sessions, parties, scores récents, offres de pub, pubs vues ou fermées par emplacement, bonus utilisés. Il vit dans `GameProgress`, donc dans la sauvegarde JSON (version 2, migration depuis la version 1) ; seul `GameState` le modifie (`record_game`, `record_offer`, `record_bonus`, et les fins de pub écoutées sur `Events.rewarded_ad_finished`). Le jeu exporté ouvre à son lancement la dernière sauvegarde (une nouvelle la première fois) et compte la session : un seul profil, pas de menu d'emplacements. `DifficultyDirector` (`game/core/`) calcule un niveau à partir de `PlayerStats` et de la partie en cours ; `PieceGenerator.next_piece_among` tire autant de pièces que le niveau le dit et donne celle qui a le moins de place. Réglages dans `game/data/difficulty_rules.tres`.
- **Pourquoi** : le hasard « méchant » (choisir la pire pièce parmi quelques-unes) monte la tension sans tricher de façon visible ni rendre le jeu impossible (règle Google Play : pas de mur qui oblige à regarder une pub). Garder les statistiques dans la sauvegarde évite un deuxième fichier et profite des écritures sûres de `SaveSlots`.
- **Plus tard** : envoyer ces événements à un outil d'analyse (Firebase Analytics ou une table Supabase) pour les voir sur tous les joueurs ; régler les seuils à distance (`docs/strategies-pub.md`, section 5).

## 20. Mode à niveaux : `LevelGame` autour de `TileBlocksGame`, écran par héritage (2026-11-09, G17)

- **Contexte** : Stelio (2026-11-09, « Ok pour C ») : un seul jeu avec un mode infini et un mode à niveaux à objectifs, sur les règles de G1.
- **Choix** : `LevelGame` (`game/core/`) enveloppe un `TileBlocksGame` (hasard pur : pas de difficulté adaptative ni de reprise) et compte les pièces, l'objectif (score, groupes d'un symbole, tuiles dorées) et les pièces offertes par pub. Les tuiles spéciales vivent dans `LevelBoard` (or, glace), branché sur `TileBlocksGame.layer` : il dit quelles cases effacées partent vraiment ; les pierres sont une valeur de case (`TileGrid.STONE`) qu'aucun groupe ne prend. Les niveaux sont des `LevelDefinition` dans `game/data/levels.tres` (grille en texte, une lettre par case), écrits par `tools/generate_levels.py`. L'écran `LevelScreen` hérite de `TileBlocksScreen` et remplace quelques méthodes (`_make_game`, `_place_piece`, `_is_finished`, `_show_record`, `_show_end_panel`…) ; la scène `game/levels/level.tscn` hérite de celle du jeu infini et change son script.
- **Pourquoi** : les règles, le glisser-déposer, les bonus, les retours d'effacement et l'aide restent les mêmes dans les deux modes sans copie ; un niveau se teste sans écran (un robot gagne chaque niveau dans les tests).
- **Plus tard** : partager la grande tuile une fois finie, mode expert, plus de niveaux et d'éléments (un nouveau tous les 10 niveaux environ).

## 21. Musique par un autoload `Music`, bus audio, thème d'interface global (2026-11-12, G20)

- **Contexte** : Stelio (2026-11-12) trouve le jeu « trop plat » à l'œil et à l'oreille. Pas de clé ElevenLabs dans la session : les sons restent faits par le code.
- **Choix** : bus `Music` et `Effects` (`default_bus_layout.tres`) ; un autoload `Music` (après `Ads`) joue une boucle sur le bus `Music` d'un écran à l'autre et coupe les bus selon `GameSettings.music` / `sounds` (boutons du menu). La musique est **composée par un script** (`tools/assets/compose_music.py`, numpy et ffmpeg) et versionnée en OGG (385 Ko) : la calculer au lancement prendrait plusieurs secondes sur un téléphone. Les bruitages, courts, restent calculés au lancement par `SoundSynth`, une fois par lancement (cache statique de `GameSounds`). L'apparence des boutons vient d'un thème global (`gui/theme/custom` = `game/ui/game_theme.tres`), avec la variante `PrimaryButton` pour l'action principale.
- **Pourquoi** : rien à acheter ni à déclarer (tout est fait par nous), en gamme de do majeur pour que musique et effets ne jurent jamais ; un thème global évite de régler chaque bouton.
- **Plus tard** : de vrais sons et une ou deux autres musiques (`docs/recettes/sons-et-musique.md`), choisis à l'écoute par Stelio ; régler les volumes par curseur (`AudioSettings` existe déjà).

