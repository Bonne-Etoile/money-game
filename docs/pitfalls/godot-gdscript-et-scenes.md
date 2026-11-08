# Pièges : Godot : GDScript, scènes, ressources et shaders

Format : **symptôme**, **cause**, **bonne pratique** (voir `README.md`).

## L'import ne signale pas les erreurs de script

- **Symptôme** : `godot --headless --import` termine avec le code 0 alors qu'un script a une erreur de type.
- **Cause** : l'import ne compile pas les scripts.
- **Bonne pratique** : `make check` charge chaque fichier avec `tools/check_project.gd` (un script en erreur ne se charge pas, `can_instantiate()` est faux).

## Une scène qui référence un fichier absent se charge quand même

- **Symptôme** : `load()` d'une scène dont un `ext_resource` n'existe plus renvoie une `PackedScene` valide.
- **Cause** : Godot remplace la dépendance manquante au lieu d'échouer.
- **Bonne pratique** : vérifier `ResourceLoader.get_dependencies()` (fait par `tools/check_project.gd`).

## Recharger le script en cours d'exécution fait planter Godot

- **Symptôme** : `tools/check_project.gd` plante (signal 11) en se chargeant lui-même avec `CACHE_MODE_IGNORE`.
- **Bonne pratique** : un script lancé avec `--script` ne se recharge pas lui-même (il est ignoré dans la vérification).

## `get_script()` sans type est une erreur

- **Symptôme** : `(get_script() as Script)` → « Casting "Variant" to "Script" is unsafe » (avertissement traité comme une erreur).
- **Bonne pratique** : affecter à une variable typée : `var own_script: Script = get_script()`.

## `look_at()` dans `_initialize()` d'un script `SceneTree`

- **Symptôme** : « Node not inside tree. Use look_at_from_position() instead » en orientant une caméra ajoutée dans `_initialize()`.
- **Cause** : l'arbre ne tourne pas encore ; les nœuds ajoutés ne sont pas « dans l'arbre ».
- **Bonne pratique** : calculer la transformation (`Transform3D(Basis.looking_at(cible - position), position)`) et activer la caméra avec `current = true` avant de l'ajouter.

## `Dictionary.get()` renvoie un `Variant`, même pour un dictionnaire typé

- **Symptôme** : « requires the subtype "String" but the supertype "Variant" was provided » (avertissement traité comme une erreur).
- **Bonne pratique** : passer par une variable typée (`var texte: String = options.get("cle", "")`) avant de l'utiliser. Pour convertir un texte en entier : `texte.to_int()`, pas `int(texte)`.

## L'import sans éditeur ne déclare pas les traductions

- **Symptôme** : après `godot --headless --import`, les fichiers `locale/translations.<langue>.translation` existent mais le jeu reste en anglais.
- **Cause** : c'est l'éditeur (interface) qui ajoute les traductions importées à `internationalization/locale/translations` ; l'import en ligne de commande ne le fait pas.
- **Bonne pratique** : écrire la liste à la main dans `project.godot`. `test/unit/translations_test.gd` vérifie qu'elle contient chaque langue.

## Un `PackedFloat32Array` exporté est vidé dans le jeu exporté

- **Symptôme** : dans le jeu exporté (pas dans l'éditeur ni les tests), `trash_weights` de la rivière vaut `[]` ; le test de lancement (`make build`) affiche « River: trash_scenes and trash_weights must have the same size ».
- **Cause** : en convertissant une scène qui **instancie** une autre scène (ici `main.tscn` → `poc_river.tscn`), l'export de Godot 4.7.2 ajoute sur l'instance une valeur `[]` pour une propriété `@export` de type `PackedFloat32Array`, qui écrase la vraie valeur. Vérifié en lisant le `SceneState` des scènes converties dans `.godot/exported/`.
- **Bonne pratique** : pour les listes exportées, utiliser un tableau typé (`Array[float]`, `Array[int]`), et convertir au besoin (`PackedFloat32Array(liste)`). Le test de lancement de `make build` attrape ce genre d'écart.

## Ordre des valeurs de `Transform3D` dans un `.tscn`

- **Symptôme** : le joueur, tourné de 90° « vers la rivière » en écrivant la scène à la main, regarde dans la direction opposée.
- **Cause** : dans un fichier de scène, `Transform3D(a, b, c, d, e, f, g, h, i, x, y, z)` liste la base **ligne par ligne** (`a, b, c` = première ligne), pas colonne par colonne.
- **Bonne pratique** : pour une rotation de θ autour de Y, écrire `Transform3D(cos θ, 0, sin θ, 0, 1, 0, -sin θ, 0, cos θ, x, y, z)` ; le regard (−Z local) pointe alors vers (−sin θ, 0, −cos θ). Toujours vérifier une orientation avec une capture.

## Signal émis dans `_ready()` avant que l'interface écoute

- **Symptôme** : le compteur des mains reste vide au lancement et n'apparaît qu'au premier ramassage.
- **Cause** : `_ready()` des enfants s'exécute dans l'ordre de l'arbre ; `Pickup` émettait `hands_changed` avant que le HUD, plus bas dans l'arbre, se connecte.
- **Bonne pratique** : annoncer l'état initial avec `call_deferred` ; un test vérifie l'affichage au démarrage.

## Une erreur de shader ne fait échouer ni `make check` ni les tests

- **Symptôme** : les ondulations des déchets s'affichaient en carrés blancs, puis plus du tout ; `make check` et `make test` passaient.
- **Cause** : un shader n'est compilé qu'au rendu ; `make check` charge la ressource sans la compiler et les tests (`RIVER_CLEANER_TESTS`) ne regardent pas l'image. Deux erreurs : `smoothstep(largeur, 0.0, x)` (bornes inversées : résultat non défini en GLSL, ici 1 partout) et une variable locale du même nom qu'un `instance uniform` (« Redefinition »), qui empêche toute compilation.
- **Bonne pratique** : après chaque changement de shader, lancer une capture qui le montre (`make screenshot`) et chercher `SHADER ERROR` dans la sortie. Écrire `1.0 - smoothstep(0.0, largeur, x)` plutôt que des bornes inversées ; ne pas réutiliser le nom d'un uniform pour une variable locale.

## Un cylindre généré vu de l'intérieur

- **Symptôme** : canettes et bouteilles générées (`build_trash.gd`) en demi-tubes : on voyait l'intérieur de la moitié du fond, et le texte de l'étiquette en miroir.
- **Cause** : les faces avant de Godot tournent dans le sens horaire vu de l'extérieur ; l'ordre des sommets était inversé, la face extérieure était éliminée (*culling*). L'angle et la coordonnée `u` allaient en sens opposés.
- **Bonne pratique** : regarder chaque modèle généré en capture de près (`trash_lineup_close`) ; pour une surface vue des deux côtés, inverser l'ordre des sommets de la face arrière.

## `ProjectSettings.save()` réécrit tout `project.godot`

- **Symptôme** : un script qui ajoute un réglage puis appelle `ProjectSettings.save()` change tout le fichier : commentaire d'en-tête, format des touches de l'Input Map, et supprime les réglages égaux à leur valeur par défaut (ici `renderer/rendering_method`).
- **Bonne pratique** : s'en servir seulement pour voir le format exact d'une entrée, puis annuler (`git checkout project.godot`) et ajouter l'entrée à la main.

## Uniform global de shader : à déclarer, et illisible hors de l'éditeur

- **Symptôme** : un `global uniform` non déclaré empêche le shader de compiler ; `RenderingServer.global_shader_parameter_get()` renvoie `null` dans le jeu et les tests (« should never be used outside the editor »).
- **Bonne pratique** : déclarer l'uniform dans `[shader_globals]` de `project.godot` ; le régler avec `global_shader_parameter_set()` ; dans les tests, vérifier l'état qui le pilote (ex. `River.dirt`), pas l'uniform lui-même, et regarder les captures.
