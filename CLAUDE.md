# Block Tiles

Jeu mobile Android (portrait, iOS mis de côté), gratuit et financé par la pub (AdMob) : un puzzle hybride **blocs + tuiles de mahjong** (`docs/etude-concurrence.md`, annexe B). Développé par Claude pour Stelio ; titre de travail « Block Tiles ».

## Documentation (`docs/`)

- `docs/conception-du-jeu.md` : conception du jeu (mécaniques, progression, interface). Référence pour tout ce qui touche au gameplay.
- `docs/architecture.md` : décisions d'architecture (contexte, choix, raison). Y ajouter ou mettre à jour une entrée à chaque décision structurante.
- `docs/feuille-de-route.md` : phases du projet (proof of concept → sortie). Cocher ce qui est livré.
- `docs/backlog.md` : la feuille de route découpée en tickets (statut, critères, dépendances), les décisions et actions attendues. Tenu à jour à chaque ticket.
- `docs/avant-la-sortie.md` : ce qui est provisoire et doit être repris, vérifié ou déclaré avant la sortie. Y ajouter une ligne dès qu'un élément provisoire entre dans le jeu (bouton de test, asset fait au mieux…).
- `docs/performance.md` : mesures de performance avant/après chaque remède.
- `docs/pitfalls/` : pièges connus (symptôme, cause, bonne pratique), un fichier par thème, écrits pour servir à n'importe quel jeu ; `methode.md` pour la façon de travailler. Les relire avant de travailler sur un thème ; y ajouter une entrée dès qu'une erreur fait perdre du temps ou risque de revenir.
- `docs/recettes/` : comment faire les choses courantes (ajouter un texte, un réglage, une migration de sauvegarde, un test de scénario, une capture…).
- `docs/ressources.md` : documentation, outils et banques d'assets.
- `docs/deploiement-android.md` : publication sur Google Play (compte, test fermé, build AAB, questionnaires, consentement).
- `docs/strategies-pub.md` : monétisation par la pub (formats, règles AdMob et Google Play à ne jamais franchir, leviers pour faire regarder des pubs, genre et technologie recommandés).
- `docs/etude-concurrence.md` : concurrence et tendances des classiques de réflexion (blocs, mahjong, flèches, tri, vis).

## Stack

- **Godot 4.7.2-stable** (version standard, sans .NET), épinglée dans `.godot-version`. Jeu 2D en portrait (720 × 1280, étirement `canvas_items` + `expand`), rendu Compatibility (OpenGL ES 3, le plus compatible sur Android), entrées tactiles par l'action `pointer` (le toucher est converti en souris).
- **GDScript entièrement typé** : `untyped_declaration` et les avertissements `unsafe_*` sont des erreurs (garde-fou : `test/unit/project_settings_test.gd`).
- Tests : **gdUnit4 6.2.2**, copié dans `addons/gdUnit4` (ne pas modifier ; exclu des exports, sinon l'export plante). Lint et format : **gdtoolkit 4.5.0** (`requirements-dev.txt`).
- Steam (si besoin) : GodotSteam (GDExtension), derrière un autoload `Platform`, avec une version factice pour le développement et les tests.

## Structure

- `game/autoload/` : `Diagnostics` (journal de session, rapport de crash ; le premier autoload), `Events` (signaux globaux), `GameState` (état de la partie, seul à le modifier), `Display` (fenêtre, F11), `Options` (réglages du joueur).
- `game/core/` : logique pure (`RefCounted`, sans nœud), testée unitairement.
- `game/data/` : définitions du jeu en ressources typées `.tres` (et leurs classes).
- `game/<fonctionnalité>/` : une scène et son script par fonctionnalité (`player/`, `ui/`, …), rangés par fonctionnalité, pas par type de fichier.
- `assets/` (modèles `.glb`, textures PNG, sons OGG, polices, `LICENSES.md`), `locale/`, `test/` (`unit/`, `scenario/`, `fixtures/`), `tools/`, `docs/`.

## Commandes

- `make lint` (gdlint + gdformat --check sur `game/`, `test/`, `tools/`), `make check` (import, puis `tools/check_project.gd` charge chaque script, scène et ressource et vérifie leurs dépendances), `make test` (gdUnit4 sous Xvfb ; `GAME_TESTS=1` permet de laisser de côté ce qui est purement visuel et lent : `AutomatedTests`), `make build` (exports Windows et Linux, puis `tools/smoke_test.sh` lance l'export Linux quelques images et échoue sur un plantage ou une erreur). Claude les lance toutes les quatre avant chaque PR.
- CI (`.github/workflows/ci.yml`) : `make lint check test` sur chaque PR vers `main` et chaque push sur `dev` ou `main`. Pas de job sur les PR vers `dev` (trop lent pour un jeu 3D) : Claude y fait foi de ses propres vérifications.
- Build de test (`.github/workflows/build.yml`) : `make build` et l'export Windows en artefact (14 jours). Déclenché par une branche `claude/test-build-<n>` créée depuis le commit à tester (la session cloud ne peut pas pousser de tag), par le bouton « Run workflow » (une fois le fichier sur `main`) et sur chaque PR vers `main`.
- Installation de la session cloud : `tools/setup-cloud.sh`, lancé par le hook `.claude/hooks/session-start.sh` (sessions cloud seulement), puis import du projet. Chaque étape est sautée si elle est déjà faite. Après un changement de `.godot-version` ou de `requirements-dev.txt`, relancer le script.
- Assets : `tools/assets/` (sons : `generate_audio.py`, `audio_prompts.json`, `process_audio.sh`). Méthode : `docs/recettes/sons-et-musique.md`. Le jeu est en 2D : les graphismes du prototype sont dessinés par le code (`_draw()`).
- Capture d'écran : `make screenshot SCENE=res://… OUT=chemin.png` (options `LOCALE=fr`, `FRAMES=N`, `RESOLUTION=720x1280` par défaut, la taille d'un téléphone en portrait). Toujours **regarder** la capture (outil Read) avant de conclure. `make screenshots` produit les captures utiles à la relecture d'une PR : y ajouter chaque scène qui compte. Une situation de jeu à capturer : une scène de `test/fixtures/` qui instancie le jeu et le prépare.

## Règles de code

- Code, identifiants, noms de fichiers et commentaires en **anglais** ; documentation en français.
- Guide de style officiel de Godot : fichiers et dossiers en `snake_case`, classes en `PascalCase`, `class_name` pour les classes réutilisées.
- **Logique pure dans `game/core/`** (classes `RefCounted`, sans nœud). Les scènes affichent et appellent la logique ; elles ne calculent pas les règles du jeu.
- **Signaux globaux** par l'autoload `Events` ; les scènes ne se référencent pas directement entre elles. Un signal d'`Events` est émis ailleurs : le déclarer avec `@warning_ignore("unused_signal")`.
- **État de la partie** : l'autoload `GameState` contient un `GameProgress` (`game/core/`). On modifie l'état par les méthodes de `GameState`, qui appliquent les règles de `GameProgress` et émettent les signaux d'`Events` ; jamais en écrivant `GameState.progress` depuis une scène.
- **Argent et compteurs** : nombres entiers (`int`), jamais de `float`.
- **Données** dans des ressources typées `.tres` de `game/data/`, pas de chiffres en dur dans les scripts.
- **Entrées** : uniquement des actions de l'Input Map, touches définies par leur position physique (ZQSD et WASD fonctionnent sans réglage). Jamais de touche lue directement.
- **Textes** : aucun texte d'interface en dur. Chaque texte est une clé en MAJUSCULES de `locale/translations.csv` (colonnes `en` de référence, `fr`, et `_notes` pour le contexte des traducteurs), affichée via `tr()` ou la traduction automatique des nœuds `Control` (le nœud contient la clé). Un texte avec des valeurs est une clé avec des `%d` (`tr("HUD_MONEY") % total`) dont la propriété `text` reste vide dans la scène. `test/unit/translations_test.gd` vérifie chaque clé et chaque texte de scène.
- **Typographie française** : espace fine insécable (U+202F) avant `: ! ? ;` et `%` dans la colonne `fr`.
- **Sauvegardes et réglages** : JSON versionné, jamais une ressource Godot (une ressource peut exécuter du code). Écriture dans un fichier temporaire, ancien fichier gardé en `.bak` (`SaveSlots`). Lecture sans confiance (`JsonRead`). Toute modification du format ajoute une migration (`SaveGame.migrate`) et un test. Seul le jeu exporté lit et écrit ses fichiers de réglages (`OS.has_feature("template")`) ; les tests utilisent `user://test_saves`.
- **Écrans en pause** : `CanvasLayer` en `process_mode` « toujours », qui mettent `get_tree().paused` et libèrent la souris.
- Un nœud qui annonce un état au démarrage le fait en différé (`call_deferred`), sinon l'interface, prête après lui, rate le signal.
- Couleurs données aux sommets et aux instances : passer par `srgb_to_linear()`.
- Les fichiers `.uid` générés par Godot (un par script) sont versionnés, y compris dans `addons/`.
- Code appelé à la fermeture (`_exit_tree`, `NOTIFICATION_WM_CLOSE_REQUEST`) : `free()`, jamais `queue_free()`.
- Hasard : jamais le générateur global (`randf()`) pour la logique ; un `RandomNumberGenerator` à graine.

> **À compléter** au fil du jeu : une puce par système (joueur, interface, son, sauvegarde…) qui dit où il vit et comment l'étendre. C'est ce qui permet à une nouvelle session de reprendre sans relire tout le code.

## Vérifier les API de Godot

- L'IA mélange facilement Godot 3 et Godot 4 : vérifier chaque classe, méthode et propriété dans la référence de **la version installée**.
- Doc officielle de la version : https://docs.godotengine.org/en/4.7/ (lire avec `curl` depuis la session ; l'outil WebFetch ne la résout pas). Secours hors ligne : `godot --headless --doctool <dossier>` (XML de toutes les classes), hors du dépôt.
- Vérifier chaque commande CLI et chaque option dans la documentation officielle (ou `godot --help`) avant de l'utiliser. Ne jamais inventer une commande.

## Tests et vérification

- Toute logique de `game/core/` vient avec des tests unitaires (`test/unit/`).
- Toute fonctionnalité de gameplay vient avec un test de scénario (`test/scenario/`, scene runner de gdUnit4, entrées simulées) et des **captures d'écran regardées par Claude** avant la PR.
- Les tests gdUnit4 tournent sous Xvfb (`xvfb-run`) ; sans affichage et sans `--ignoreHeadlessMode`, le lanceur s'arrête avec le code 103.
- Un test ne dépend ni du temps réel ni du hasard : boucler image par image jusqu'à l'état voulu, avec une limite.
- Ce que Claude ne peut pas juger : la fluidité, les sensations et le son. Une PR qui change le gameplay le dit dans sa description et attend le test du joueur sur sa machine.

## Assets

- Modèles `.glb`, textures PNG, sons OGG. Chaque asset externe est listé dans `assets/LICENSES.md` dès son entrée : source, auteur, licence (et le texte de crédit exigé) ; pour un asset généré par IA, l'outil, sa licence d'usage commercial et les retouches.
- Assets générés par IA autorisés ; à déclarer dans le questionnaire de contenu de Steamworks (tenir la liste à jour).
- Pas de Git LFS au départ : pas de fichiers lourds (vidéos, sources de travail) dans le dépôt.

## Publication

- **Rien n'est publié sans l'accord explicite du joueur-producteur**, à chaque publication (vidéos, textes, page Steam).
- Aucun identifiant de compte, mot de passe ou clé d'API dans le dépôt ni dans la session ; une clé d'API passe par une variable d'environnement de la session.

## Travail autonome

Claude enchaîne les tickets de `docs/backlog.md` sans attendre de relecture entre deux tickets.

- **Branches** : `main` (versions publiées, mergée uniquement par l'humain) ← `dev` (intégration) ← une branche par ticket, `claude/<ticket>-<sujet>`, créée depuis `dev` à jour.
- **Un ticket** :
  1. prendre le premier ticket **prêt** dont les dépendances sont **faites** ;
  2. relire `docs/pitfalls/` pour le thème ;
  3. implémenter, tester (`make lint check test build`, captures d'écran pour tout ce qui se voit) ;
  4. PR vers `dev` avec le statut du ticket mis à jour dans `docs/backlog.md` ;
  5. vérifications vertes et relecture adversariale de son propre diff → Claude merge dans `dev`.
- **Exception gameplay** : une PR qui change les sensations de jeu (déplacement, contrôles, rythme, équilibrage) reste ouverte jusqu'au test du joueur, sauf décision contraire notée ici. Sa description dit quoi tester ; l'export vient du build de test. Claude passe au ticket suivant qui n'en dépend pas.
- **Bloqué** : une décision manquante, une action externe (compte, achat) ou deux échecs de CI sur la même cause → noter la raison dans le ticket, passer au suivant. Ne jamais contourner une règle de ce fichier pour avancer.
- **Décisions** : chaque décision du joueur va, le jour même, là où on la cherchera (règle ici, choix structurant dans `docs/architecture.md`, choix de ticket dans `docs/backlog.md`, leçon dans `docs/pitfalls/`), datée.
- **Fin de session ou de lot** : résumé court (fait, en revue, à tester, bloqué, décisions attendues).

## Workflow

- Jamais de push direct sur `main` ni sur `dev`. Une PR = un ticket, petite, avec une description claire.
- Ne pas modifier sans demande explicite (ou ticket qui le prévoit) : `.github/workflows`, la configuration d'export et de publication, les secrets.
- Si une règle de ce fichier bloque une tâche, le dire dans la PR plutôt que la contourner.
