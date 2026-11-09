# Pièges : Godot en ligne de commande, captures et export

Format : **symptôme**, **cause**, **bonne pratique** (voir `README.md`).

## Pas de rendu Vulkan dans la session cloud

- **Symptôme** : « Your video card drivers seem not to support the required Vulkan version, switching to OpenGL 3 ».
- **Cause** : pas de carte graphique ; le rendu logiciel Vulkan (lavapipe) n'est pas installé par défaut.
- **Bonne pratique** : installer `mesa-vulkan-drivers` (fait par `tools/setup-cloud.sh`). Forward+ tourne alors en rendu logiciel (llvmpipe), lent mais correct.

## Captures d'écran vides en mode `--headless`

- **Symptôme** : image noire ou erreur en lisant la texture du viewport.
- **Cause** : `--headless` utilise un moteur de rendu factice, sans pixels.
- **Bonne pratique** : pour les captures et les vidéos, lancer Godot normalement sous Xvfb. Garder `--headless` pour l'import, la vérification des scripts et `--doctool`.

## Doc de Godot : `curl` oui, WebFetch non

- **Symptôme** : WebFetch échoue sur docs.godotengine.org (`ENOTFOUND`), alors que `curl` dans la session répond 200.
- **Cause** : WebFetch ne passe pas par le réseau de la session. Les domaines godotengine.org et docs.godotengine.org sont autorisés dans l'environnement depuis le 22/10/2026 (avant : 403).
- **Bonne pratique** : lire la doc avec `curl` (et extraire le texte). Télécharger Godot et ses modèles d'export depuis les releases GitHub (`github.com/godotengine/godot/releases/download/<version>/…`). Secours hors ligne : `godot --headless --doctool <dossier>` (référence XML de la version installée, sans les descriptions).

## Vidéo de jeu trop lente à enregistrer

- **Symptôme** : le rendu logiciel tourne à quelques images par seconde ; une capture vidéo en temps réel serait saccadée.
- **Cause** : pas de carte graphique dans la session.
- **Bonne pratique** : Movie Maker de Godot (`--write-movie sortie.avi --fixed-fps 30 --quit-after <images>`) enregistre image par image à cadence fixe, quelle que soit la vitesse réelle. Pour une vidéo verticale nette, rendre directement en 1080×1920 plutôt que recadrer du 16:9.

## L'export plante à la fermeture quand gdUnit4 est exporté

- **Symptôme** : `--export-release` écrit l'exécutable puis s'arrête avec `Aborted` (code 134), au premier export après un import neuf (donc toujours en CI).
- **Cause** : les ressources de `addons/gdUnit4` incluses dans l'export (avec ou sans le plugin activé).
- **Bonne pratique** : exclure `addons/gdUnit4/*` (ainsi que `test/*` et `tools/*`) dans `exclude_filter` de chaque préréglage d'export. Le jeu n'a de toute façon pas à embarquer l'outil de tests.

## Les rapports de tests se retrouvent dans le jeu exporté

- **Symptôme** : le log de l'export montre `Storing File: res://reports/report_1/css/logo.png.import`.
- **Cause** : gdUnit4 écrit ses rapports dans `reports/`, à l'intérieur du projet ; Godot importe ces fichiers et l'export les embarque.
- **Bonne pratique** : tout dossier généré dans le projet (`reports/`, `build/`) contient un `.gdignore` versionné (Godot ignore alors le dossier) et figure dans `exclude_filter`. Vérifier la liste `Storing File` du log d'export quand on ajoute un dossier.

## Modifier du GDScript avec `sed` après `gdformat`

- **Symptôme** : un remplacement `sed` ne change rien (ligne coupée par `gdformat` sur plusieurs lignes), ou une regex multiligne laisse des parenthèses orphelines et casse le fichier.
- **Bonne pratique** : modifier le code avec l'outil Edit (ou un script qui vérifie que le texte cherché existe, `assert a in s`), puis relancer `gdformat` et `gdlint`. Après une vérification par mutation, contrôler que le fichier est bien revenu à l'identique.

## Le cache d'export fausse les essais

- **Symptôme** : après une correction, l'export se comporte comme avant.
- **Cause** : les scènes converties pour l'export sont gardées dans `.godot/exported/` et réutilisées si la scène elle-même n'a pas changé, même si une scène ou un script dont elle dépend a changé.
- **Bonne pratique** : pour diagnostiquer un problème d'export, supprimer `.godot/` avant chaque essai (`make build` part d'un import, mais pas forcément d'un cache vide).

## Script de modification en plusieurs fichiers interrompu

- **Symptôme** : un script Python qui modifie plusieurs fichiers s'arrête sur une `assert` (texte introuvable) ; les fichiers déjà traités sont modifiés, les suivants non, et le commit enchaîné juste après part incomplet.
- **Bonne pratique** : enchaîner le commit avec `&&` après le script (pas sur une nouvelle ligne), et relire `git status` / `git diff --stat` avant chaque commit.

## Script `--script` qui cite une classe dépendant d'un autoload

- **Symptôme** : « Identifier not found: Events » en lançant un script avec `godot --script` qui déclare une variable de type `Player` (ou toute classe qui utilise `Events`/`GameState`).
- **Cause** : le script lancé par `--script` est compilé avant la création des autoloads ; ses références de classes compilent aussi ces classes, qui ne trouvent pas encore les autoloads.
- **Bonne pratique** : dans un script `--script` (outils), charger les scènes à l'exécution et manipuler les nœuds par des types de base (`Node3D`) et `call("methode", …)`, sans nommer les classes du jeu. Les tests gdUnit4 ne sont pas concernés.

## Rendu lent sur les machines sans carte graphique (CI, session cloud)

- **Symptôme** : après le nouveau rendu de la rivière (G17), la CI passe de 3 à 17 min et le test de lancement du build échoue par dépassement de délai (code 124).
- **Cause** : sans carte graphique, Godot dessine avec lavapipe (rendu logiciel) : environ une image par seconde avec la rivière, des dizaines de milliers d'instances de décor et un filtre plein écran.
- **Bonne pratique** : sous `make test`, laisser de côté ce qui est purement visuel (`AutomatedTests`) ; garder peu d'images dans le test de lancement ; mesurer la durée de `make test` avant et après tout ajout visuel lourd.

## Le jeu ne se ferme plus s'il quitte juste après le lancement

- **Symptôme** : le test de lancement de l'export (`--quit-after 20`) et les captures à peu d'images (`--frames=5`) restent bloqués après la dernière image (code 124 du `timeout`). Avec 60 images, tout se ferme. Les tests passent, car ils sautent le décor.
- **Cause** : un interblocage de Godot 4.7.2 à la fermeture (le fil principal attend le pool de fils, inactif), déclenché ici par une `ShaderMaterial` (même un shader déjà utilisé ailleurs) posée sur le maillage de l'écume, construit par `Scenery`. Une `StandardMaterial3D` transparente sur le même maillage ne bloque pas. Cause exacte dans le moteur non trouvée : bissection fichier par fichier (copie du commit précédent avec `git worktree`), puis variante par variante.
- **Bonne pratique** : après un changement de matière ou de shader dans le décor, lancer `make build` (test de lancement) ou une capture courte de la rivière (`--frames=5`, avec `timeout`). Un blocage se voit à `gdb -p <pid> -batch -ex "thread apply all bt"` : tous les fils en attente, 0 % de processeur. Pour l'écume, une `StandardMaterial3D` dont le script anime `uv1_offset`.

## « resources still in use at exit » : un `queue_free()` pendant la fermeture

- **Symptôme** : le test de lancement de l'export échoue (`ERROR: 6 resources still in use at exit`) après l'ajout de l'ambiance sonore (G22).
- **Cause** : `River._exit_tree()` arrête l'ambiance pendant la fermeture du jeu ; les lecteurs, enfants de l'autoload `Audio`, étaient libérés par `queue_free()`, qui ne s'exécute plus quand le jeu quitte : leurs flux restaient en mémoire.
- **Bonne pratique** : dans un code appelé à la fermeture (`_exit_tree`, `NOTIFICATION_WM_CLOSE_REQUEST`), libérer tout de suite (`free()`), pas en différé. Lancer `make build` (test de lancement) après tout ajout de nœuds créés par code dans un autoload.
- **Suite (correctif de G22, build de test des bruitages en échec)** : même libérés tout de suite, des sons **en cours de lecture** au moment de quitter restent « in use » (OGG comme MP3), dès que le jeu a tourné une trentaine d'images : le serveur audio ne libère un son arrêté qu'à son prochain mixage, qui n'arrive pas si le moteur s'arrête aussitôt. `Audio._exit_tree()` arrête tous les sons puis attend 100 ms (`EXIT_MIX_WAIT_MS`). Le test de lancement (20 images) passait juste sous le seuil : vérifier une fermeture après 30 images ou plus (`make screenshot … FRAMES=30`) et chercher « still in use ».

## `godot --script` reste bloqué quand un script préchargé ne compile pas

- **Symptôme** : `godot --headless --script res://tools/…` ne rend jamais la main et n'affiche rien (pas même ses premiers `print`), jusqu'à ce qu'on le tue.
- **Cause** : un script chargé par `preload` (ici un des fichiers d'animaux de `tools/assets/`) a une erreur d'analyse ; le script principal n'arrive jamais à `_initialize()` ni à `quit()`, et Godot attend.
- **Bonne pratique** : lancer ces outils avec `timeout` ; en cas de blocage, charger chaque script préchargé un par un (`load()` dans un petit script) pour voir l'erreur d'analyse.

## Un script `--script` ne connaît pas les autoloads

- **Symptôme** : « Identifier not found: GameState » (ou `Events`, `Audio`) à la compilation d'un outil lancé avec `godot --script`, même s'il ne nomme qu'une classe (`River`, `Statue`) dont le script utilise un autoload.
- **Cause** : le script passé à `--script` est compilé avant que les autoloads soient déclarés comme noms globaux ; à l'exécution, ils existent bien dans l'arbre.
- **Bonne pratique** : garder le script `--script` minimal (lire les options, `load()` un script `Node` et l'ajouter à `root`) et mettre le travail dans ce nœud, compilé plus tard (`tools/river_map.gd` → `tools/river_mapper.gd`). `tools/screenshot.gd` n'a pas le problème : il ne nomme aucune classe du jeu.

## Le journal du jeu exporté est vide après un crash

- **Symptôme** : après un crash du jeu exporté chez Stelio, `user://logs/godot.log` ne contient que l'en-tête ; rien sur le crash.
- **Cause** : en *release*, Godot ne vide son journal sur le disque qu'à la fermeture ou sur une erreur (`application/run/flush_stdout_on_print` est faux hors *debug*) ; et le modèle *release* ne signale pas la plupart des erreurs de GDScript à l'exécution (un index hors limites ne produit rien, un appel sur un objet libéré peut planter le jeu).
- **Bonne pratique** : lire le journal de session du jeu (`user://logs/session.log`, ou `crashed_session.log` après un crash, décision 33 de l'architecture), qui est vidé à chaque ligne. Sous Windows, `user://` est `%APPDATA%\Godot\app_userdata\River Cleaner- India\` (le « : » du nom devient « - »). Pour reproduire une erreur de script, lancer un export *debug*, qui les signale.

## L'export Android sans affichage ne trouve pas le SDK

- **Symptôme** : « Invalid Android SDK path in Editor Settings. Missing 'platform-tools' directory! » alors que `ANDROID_HOME` est bon ; puis, une fois le SDK trouvé, « ETC2/ASTC texture compression is required for Android export ».
- **Cause** : l'export lit les chemins du SDK et du JDK dans les réglages de l'éditeur (`~/.config/godot/editor_settings-4.7.tres`), pas dans les variables d'environnement, et ce fichier existe déjà après le premier import avec des valeurs par défaut (`/root/Android/Sdk`, le JDK de `JAVA_HOME`). La compression ETC2/ASTC est un réglage du projet, désactivé par le modèle de dépôt (PC).
- **Bonne pratique** : `tools/setup-android.sh` écrit `export/android/android_sdk_path` et `java_sdk_path` dans les réglages de l'éditeur ; `project.godot` active `rendering/textures/vram_compression/import_etc2_astc`. Le JDK doit être le 17 : dans la session cloud, `JAVA_HOME` désigne le 21, d'où `ANDROID_JAVA_HOME` dans le `Makefile` (2026-11-08).

## `make check` échoue sur des scripts de `android/build`

- **Symptôme** : après `make android`, `make check` signale des dizaines d'erreurs dans `res://android/build/src/instrumented/assets/test/…` (scripts non typés de Godot).
- **Cause** : le modèle de build Android installé par Godot contient ses propres scripts de test ; il est caché à Godot par `android/build/.gdignore`, mais `tools/check_project.gd` parcourait les dossiers sans regarder ce fichier.
- **Bonne pratique** : un outil qui parcourt le projet saute tout dossier qui contient un `.gdignore` (2026-11-08).

## Gradle échoue sur « 429 Too Many Requests » de Maven Central

- **Symptôme** : le premier `make android` échoue en téléchargeant des dépendances de `repo.maven.apache.org` (code 429).
- **Cause** : limite de débit de Maven Central sur l'adresse de sortie partagée de la session.
- **Bonne pratique** : relancer `make android` (Gradle garde ce qui est déjà téléchargé) ; c'est passé au deuxième essai (2026-11-08).

## Le plugin AdMob télécharge ses binaires sans rien dire

- **Symptôme** : le premier lancement de Godot sans affichage avec le greffon AdMob activé télécharge des archives depuis GitHub ; le contrôle de sécurité de la session cloud peut refuser la commande.
- **Cause** : `addons/admob/admob.gd` appelle `BinaryInstaller.install_missing_binaries_sync()` en mode sans affichage quand `addons/admob/{android,ios}/bin/package.gd` manque.
- **Bonne pratique** : `tools/install-admob-binaries.sh` (appelé par `tools/setup-cloud.sh` et `tools/setup-android.sh`) télécharge lui-même les deux archives de la release du plugin (Android 0,4 Mo, iOS 3 Mo inutilisé, accord de Stelio du 2026-11-08) et écrit `package.gd` : le greffon ne télécharge plus rien.
