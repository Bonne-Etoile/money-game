# Tester et voir

## Test unitaire (`test/unit/`)

- Un fichier `<classe>_test.gd`, `extends GdUnitTestSuite`, une fonction `test_<ce_qui_est_vrai>()` par règle. Le nom du test dit la règle (« a save from a newer version is refused »).
- Seulement la logique de `game/core/` : pas de scène, pas d'autoload si possible.
- Lancer un seul fichier : `GAME_TESTS=1 xvfb-run -a godot --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://test/unit/x_test.gd`.

## Test de scénario (`test/scenario/`)

- `var runner: GdUnitSceneRunner = scene_runner("res://game/…tscn")`, puis `await runner.simulate_frames(n)`.
- Entrées : `InputEventAction` par `Input.parse_input_event`, ou `runner.simulate_key_pressed`, `simulate_mouse_button_pressed`.
- `before_test` : `GameState.reset()` (l'état des autoloads survit d'un test à l'autre) ; `after_test` : remettre la pause à faux, les sauvegardes de test effacées.
- Attendre un état, pas une durée : `for i in 100: if condition: break; await runner.simulate_frames(1)`, puis l'assertion.
- Un bug signalé : le test doit échouer sur l'ancien code, puis passer.

## Capture d'écran

- `make screenshot SCENE=res://… OUT=build/screenshots/x.png` (`LOCALE=fr FRAMES=30 RESOLUTION=720x1280`).
- Puis **la regarder** (outil Read). Chercher `SHADER ERROR` et `ERROR` dans la sortie : un shader cassé ne fait échouer ni `check` ni `test`.
- Une situation de jeu (un menu ouvert, un objet tenu) : une scène de `test/fixtures/` qui instancie la scène du jeu et un petit script `*_shot.gd` qui la prépare. L'ajouter à `make screenshots`.
- Comparer avant/après dans les mêmes conditions (même vue, mêmes réglages) ; pour un visuel important, faire juger à l'aveugle par un agent séparé.

## Avant chaque PR

`make lint check test build`, `make screenshots` (et les regarder), relecture adversariale de son propre diff.
