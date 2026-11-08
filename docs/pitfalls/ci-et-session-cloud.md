# Pièges : CI, runners et session cloud

Format : **symptôme**, **cause**, **bonne pratique** (voir `README.md`).

## Branche distante invisible après un clone superficiel

- **Symptôme** : après `git clone --depth 1`, `git branch -u origin/<branche>` échoue alors que la branche existe sur GitHub ; le hook de fin signale des commits « non poussés ».
- **Cause** : un clone superficiel ne suit que la branche par défaut (`remote.origin.fetch` limité à `main`).
- **Bonne pratique** : `git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'`, puis `git fetch origin <branche>`.

## `cmd | grep -q` échoue avec `set -o pipefail`

- **Symptôme** : dans `tools/setup-cloud.sh`, le test « gdtoolkit déjà installé » échouait toujours, et le paquet était réinstallé à chaque session.
- **Cause** : `grep -q` s'arrête à la première ligne trouvée ; la commande en amont (`pip show`) reçoit SIGPIPE, et `pipefail` rend tout le pipeline faux.
- **Bonne pratique** : capturer la sortie dans une variable, puis `grep -q … <<< "$sortie"`.

## Le contexte `runner` n'existe pas dans `env` au niveau du job

- **Symptôme** : `${{ runner.tool_cache }}` dans `jobs.<job>.env` est refusé par GitHub Actions (et par `actionlint`).
- **Bonne pratique** : écrire la variable dans `$GITHUB_ENV` depuis une étape (`echo "OPT_DIR=$RUNNER_TOOL_CACHE/…" >> "$GITHUB_ENV"`), puis l'utiliser via `${{ env.OPT_DIR }}`. Vérifier un workflow avec `actionlint` avant de le pousser.

## L'export Linux téléchargé depuis la CI ne se lance pas

- **Symptôme** : « Permission denied » en lançant `river_cleaner_india.x86_64` sorti d'un artefact.
- **Cause** : les artefacts GitHub (archives zip) ne gardent pas le bit d'exécution.
- **Bonne pratique** : `chmod +x river_cleaner_india.x86_64` après le téléchargement.

## Pas de carte son dans la session ni en CI

- **Symptôme** : `ERROR: Condition "status < 0" is true. Returning: ERR_CANT_OPEN` (pilote ALSA) au lancement du jeu.
- **Cause** : aucun périphérique audio ; Godot bascule ensuite sur le pilote factice, mais l'erreur est affichée.
- **Bonne pratique** : lancer le jeu avec `--audio-driver Dummy` dans les tests automatiques (fait par `tools/smoke_test.sh`).

## Artefacts de la CI non téléchargeables depuis la session

- **Symptôme** : `CONNECT tunnel failed, response 403` vers `productionresultssa2.blob.core.windows.net` en téléchargeant un artefact.
- **Cause** : les artefacts sont servis depuis un stockage Azure que le réseau de la session n'autorise pas.
- **Bonne pratique** : vérifier les exports dans la CI elle-même (`tools/smoke_test.sh` dans `make build`) plutôt qu'en les téléchargeant.

## Déclencher un workflow GitHub depuis la session cloud

- **Symptôme** : `git push` d'un tag refusé (HTTP 403) ; `workflow_dispatch` par l'API refusé (404) pour un workflow qui n'est pas encore sur `main`.
- **Cause** : la session cloud ne peut pousser que des branches ; GitHub n'accepte un déclenchement manuel que si le workflow est sur la branche par défaut (ou a déjà tourné une fois).
- **Bonne pratique** : déclencher les workflows à la demande par le push d'une branche `claude/…` (ex. `claude/test-build-<n>`).

## Un runner auto-hébergé sous Windows prend les jobs écrits pour Linux

- **Symptôme** : avec `runs-on: self-hosted`, le job tourne sur le PC Windows de Stelio : checkout de 16 min, une ligne `echo … >> "$GITHUB_ENV"` qui échoue, job coupé à 30 min et logs jamais envoyés à GitHub.
- **Cause** : sur Windows, une étape `run` part dans PowerShell (le runner cherche `pwsh` pendant plusieurs minutes avant de prendre `powershell`), alors que toute la chaîne (`bash`, `apt-get`, Xvfb, `tools/setup-cloud.sh`, Makefile) suppose Linux.
- **Bonne pratique** : runner dans WSL2 (Ubuntu), dans le système de fichiers Linux (pas sous `/mnt/c`), et `runs-on: [self-hosted, linux]` pour qu'un runner Windows ne prenne jamais le job. Les logs locaux du runner sont dans `_diag/Worker_*.log`.

## Outils absents d'une Ubuntu neuve (`python3-venv`, `make`)

- **Symptôme** : sur le runner WSL2, « The virtual environment was not created successfully because ensurepip is not available » à l'installation de gdtoolkit, puis `make: command not found`.
- **Cause** : une Ubuntu neuve n'a ni `python3-venv` ni `make` ; les runners de GitHub et la session cloud les avaient déjà.
- **Bonne pratique** : `tools/setup-cloud.sh` l'installe avec les autres paquets système. Tout paquet dont la chaîne a besoin va dans cette liste, pas dans une installation à la main.

## Wikimedia Commons refuse l'API depuis la session cloud (429)

- **Symptôme** : `commons.wikimedia.org/w/api.php` répond « You are making too many requests » (HTTP 429), même pour une première requête et avec un `User-Agent`.
- **Cause** : la sortie réseau de la session est partagée ; l'API de Commons la limite.
- **Bonne pratique** : passer par l'API REST de Wikipédia (`en.wikipedia.org/api/rest_v1/page/media-list/<article>`), qui liste les images d'un article avec leurs URL de miniature, puis télécharger ces miniatures avec un `User-Agent` et quelques secondes entre deux requêtes (sinon 429 aussi).

## Plusieurs runners dans la même WSL partagent `~` et `/usr/local/bin`

- **Symptôme attendu** : avec plusieurs runners auto-hébergés dans la même distribution WSL, des échecs au hasard quand deux jobs tournent en même temps : `godot` qui change de binaire en cours de job, fichiers temporaires de gdUnit4 qui disparaissent, modèles d'export à moitié écrits.
- **Cause** : les runners ont chacun leur dossier de travail, mais le même utilisateur Linux. `tools/setup-cloud.sh` réécrivait les liens de `/usr/local/bin` vers la copie de Godot de son runner, et Godot écrit ses modèles d'export et ses données `user://` (`~/.local/share/godot/app_userdata/River Cleaner_ India/`) dans le même `~` pour tous.
- **Bonne pratique** : en CI, tout ce qui est écrit hors du dépôt passe par le cache d'outils du runner (`$RUNNER_TOOL_CACHE`) : `OPT_DIR`, `BIN_DIR` (ajouté au `PATH`) et `XDG_DATA_HOME` / `XDG_CONFIG_HOME` / `XDG_CACHE_HOME` (chemins absolus, sinon Godot les ignore). Un nouvel outil installé par `setup-cloud.sh` suit la même règle.
