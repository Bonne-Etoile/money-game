# Ajouter au jeu

## Un événement global

1. Déclarer le signal dans `game/autoload/events.gd`, typé, avec `@warning_ignore("unused_signal")` et un commentaire (qui l'émet, ce qu'il porte).
2. L'émettre là où l'événement a lieu (`Events.mon_signal.emit(...)`), l'écouter ailleurs (`Events.mon_signal.connect(...)`).
3. Test : `monitor_signals(Events, false)` (le `false` : ne pas libérer l'autoload à la fin du test), puis `assert_signal(Events).is_emitted("mon_signal", [...])`.

## Une règle du jeu

1. La logique dans une classe `RefCounted` de `game/core/` (ou une méthode de `GameProgress`), sans nœud, avec ses tests dans `test/unit/`.
2. Si elle change l'état : une méthode de `GameState` qui l'applique et émet le signal d'`Events`.
3. Ses chiffres dans une ressource de `game/data/`, pas dans le script.

## Un texte d'interface

1. Une ligne dans `locale/translations.csv` : clé en MAJUSCULES, `en`, `fr` (espace fine insécable U+202F avant `: ! ? ;` et `%`), `_notes` (où il s'affiche, ce que valent les `%d`).
2. Texte fixe : la clé dans la propriété `text` du nœud (traduit automatiquement). Texte avec valeurs : `text` vide dans la scène, `label.text = tr("CLE") % [a, b]` dans le script.
3. `make test` vérifie que la clé existe dans toutes les langues.
4. Une nouvelle langue : une colonne du CSV, son `.translation` dans `internationalization/locale/translations` de `project.godot` (à la main), et dans `LAUNCH_LANGUAGES` de `translations_test.gd`.

## Une donnée du jeu

1. Une classe `extends Resource` avec `class_name` dans `game/data/`, champs `@export` typés (`Array[float]`, pas `PackedFloat32Array`).
2. Les `.tres` à côté (un dossier par famille), un catalogue (`.tres` qui liste les autres) si l'ordre compte.
3. Un test qui charge tout le catalogue et vérifie les invariants (ids uniques, valeurs dans leurs bornes).

## Un réglage du joueur

1. Le champ dans `GameSettings` (`game/core/game_settings.gd`) : valeur par défaut, bornes (`clampf`), lecture dans `from_dict` par `JsonRead` (valeur invalide = défaut).
2. Une méthode `set_…` dans l'autoload `Options`, qui applique et émet `changed`.
3. Si le format change de sens : monter `VERSION`. Tests dans `game_settings_test.gd`.

## Un champ de sauvegarde

1. Le champ dans `GameProgress` (ou une nouvelle classe de `game/core/`), écrit par `to_dict`, lu par `from_dict` avec `JsonRead`.
2. Monter `SaveGame.VERSION`, ajouter l'étape dans `SaveGame.migrate` (`if version == N:` donne la valeur des anciennes sauvegardes).
3. Test : une sauvegarde de l'ancienne version (JSON écrit à la main dans le test) se lit et reçoit la bonne valeur.

## Un écran en pause (boutique, menu pause, écran de fin)

1. Un `CanvasLayer` avec `process_mode = PROCESS_MODE_ALWAYS`.
2. À l'ouverture : `get_tree().paused = true`, `Input.mouse_mode = Input.MOUSE_MODE_VISIBLE` ; à la fermeture, l'inverse.
3. Échap (`pause`) n'ouvre le menu pause que si rien d'autre n'a mis le jeu en pause ; l'écran ouvert gère lui-même Échap.
4. Test de scénario : ouvrir, vérifier `paused`, fermer.

## Une action du joueur

1. Dans `project.godot`, section `[input]`, avec `physical_keycode` (copier une entrée existante ; ne jamais passer par `ProjectSettings.save()`, qui réécrit tout le fichier).
2. Lire l'action (`Input.is_action_pressed`, `event.is_action_pressed`), jamais une touche.
3. Test : `InputEventAction` envoyé par `Input.parse_input_event`, puis quelques images.
