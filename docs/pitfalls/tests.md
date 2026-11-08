# Pièges : Tests (gdUnit4)

Format : **symptôme**, **cause**, **bonne pratique** (voir `README.md`).

## gdUnit4 s'arrête avec le code 103

- **Symptôme** : `runtest.sh --headless …` se termine avec le code 103, sans lancer les tests.
- **Cause** : gdUnit4 refuse le mode sans affichage par défaut (`RETURN_ERROR_HEADLESS_NOT_SUPPORTED`).
- **Bonne pratique** : lancer les tests sous Xvfb (`xvfb-run -a …`, sans `--headless`), ou ajouter `--ignoreHeadlessMode` si un test n'a vraiment pas besoin d'affichage.

## Surveiller les signaux d'un autoload dans un test gdUnit4

- **Symptôme** : un test qui surveille `Events` le libère à la fin (`monitor_signals` libère l'objet par défaut) ; les tests suivants plantent.
- **Bonne pratique** : `monitor_signals(Events, false)` pour un autoload, et remettre l'état à zéro (`GameState.reset()`) avant chaque test.

## Un test de régression qui passe aussi sur l'ancien code

- **Symptôme** : le test « le déchet roule très peu » passait avec et sans la correction (il lançait un sac plastique, une boîte plate qui ne roule pas).
- **Cause** : le test ne reproduisait pas le cas signalé (bouteilles et canettes, des cylindres, qui roulaient de 16 à 23 m).
- **Bonne pratique** : avant de corriger un bug signalé, le reproduire par une mesure (sonde temporaire) sur l'ancien code ; le test de régression doit échouer sur l'ancien code et passer sur le nouveau. Une sonde qui ne compile pas sur l'ancien code bloque toute la série de tests : mettre de côté les tests qui citent les nouveaux champs le temps de la mesure.

## Test qui mesure une distance parcourue en temps réel

- **Symptôme** : « plus lent dans l'eau » échoue de temps en temps (en CI comme en local) : 4,1 m parcourus dans l'eau au lieu d'environ 2,5.
- **Cause** : `simulate_frames(10, 100)` attend du temps réel ; le nombre de pas de physique pendant cette attente dépend de la charge de la machine, donc la distance aussi.
- **Bonne pratique** : comparer des grandeurs qui ne dépendent pas du temps écoulé (vitesse atteinte, état final), pas des distances mesurées sur une durée réelle. Pour attendre un événement physique (un déchet qui touche l'eau), boucler image par image jusqu'à l'état voulu, avec une limite, plutôt qu'attendre une durée fixe (« un raté dans l'eau remet le combo à zéro » échouait sur le runner WSL).

## Un son de test trop court finit avant la vérification

- **Symptôme** : « next saute le silence et le morceau » échoue en CI sur `dev` (G69) : le lecteur de musique affiche l'ambiance au lieu du titre du morceau qui vient de démarrer.
- **Cause** : les morceaux de test sont des silences de 0,3 s. Le son avance en temps réel, pas au rythme des images simulées : sur un runner chargé, deux images peuvent durer plus de 0,3 s, le morceau finit, et `Audio` repasse à l'ambiance avant l'assertion.
- **Bonne pratique** : un son qui doit encore jouer au moment de l'assertion dure largement plus que le test (ici 20 s). Garder des sons courts seulement pour les tests qui attendent leur fin, en bouclant image par image jusqu'à l'état voulu.

## `randf()` dans le jeu change le hasard des tests qui suivent

- **Symptôme** : un test de scénario sans rapport (« un raté au sol remet le combo à zéro ») échoue après l'ajout d'un `randf()` dans `Trash._ready()`, ou d'une nouvelle suite de tests qui passe avant lui dans l'ordre alphabétique ; il passe quand on le lance seul.
- **Cause** : `randf()`, `randi()` puisent dans le générateur global, partagé par tout le jeu et tous les tests d'une même exécution : chaque tirage décale les suivants. Le test dépendait sans le dire du déchet tiré et de sa position au bord de l'eau.
- **Bonne pratique** : pour une variation purement visuelle, ne pas puiser dans le générateur global (ex. `get_instance_id()`) ; pour la logique, un `RandomNumberGenerator` à graine. Un test ne doit pas dépendre du hasard : choisir ses positions (ex. `RiverCourse.land_point`) plutôt que « le premier déchet là où il tombe ».

## Un test lancé avec `--headless` reste bloqué sur `frame_post_draw`

- **Symptôme** : un test de scénario qui prend une photo (`RiverPhotographer.take_photo`) ne rend jamais la main, sans aucune sortie, quand on lance gdUnit4 à la main avec `godot --headless … --ignoreHeadlessMode`.
- **Cause** : sans rendu (`--headless`), `RenderingServer.frame_post_draw` n'est jamais émis : l'`await` attend pour toujours.
- **Bonne pratique** : lancer les tests comme `make test` : sous Xvfb, **sans** `--headless` (`xvfb-run -a -s "-screen 0 1920x1080x24" godot --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a <test>`).
