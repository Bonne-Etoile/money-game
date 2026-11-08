# Mesurer

## Performance

Dès qu'un objet existera en centaines ou milliers d'exemplaires :

1. **Une scène de mesure** (`game/benchmark/` dans River Cleaner, `make benchmark`) : paliers de quantité (0, 150, 1 000, 10 000… et bien au-delà de la cible), temps d'image moyen / 95e centile / pire (`FrameStats`), objets et appels de dessin.
2. **Sans dessin** pour les scripts et la physique : sous Xvfb, `RenderingServer.render_loop_enabled = false`, `Engine.max_fps = 0`, vsync coupée, temps pris avec `Time.get_ticks_usec()` entre deux images. Pas `--headless` (boucle plafonnée vers 145 images/s).
3. **Variantes qui retirent un poste à la fois** : ce sont elles qui désignent le coupable.
4. **Rendu** : seulement sur la machine du joueur. Un bouton du menu lance la mesure et **copie un rapport texte** que le joueur colle à Claude.
5. **Lire le journal** de chaque mesure : les limites du moteur (Jolt à 10 240 corps, tampon des `instance uniform`) se signalent par une erreur, pas par un plantage.
6. Consigner chaque mesure avant/après dans `docs/performance.md`.

Règles à appliquer d'emblée : `docs/pitfalls/methode.md` (« Concevoir pour l'échelle ») et `docs/pitfalls/rendu-et-performance.md`.

## Journal de partie (équilibrage)

- Une classe `PlayLog` (`game/core/`) note au temps de jeu réel (pauses exclues) les moments clés : début et fin de niveau, paliers, achats, avec l'argent à ce moment. Sauvegardée avec la partie.
- Un bouton « Copier le journal de partie » (écran de fin) : le joueur le colle, Claude équilibre sur de vraies parties.
- Une simulation d'équilibrage (`tools/balance_simulation.gd`, `make balance`) qui joue une partie moyenne avec les vraies données, recalée sur ces journaux.

## Rapport de crash (déjà dans le modèle)

- `Diagnostics` + `SessionLog` + `CrashReport` : au lancement qui suit un crash, le menu s'ouvre sur le rapport et un bouton « Copier le rapport ».
- Sous Windows, `user://` est `%APPDATA%\Godot\app_userdata\<nom du jeu>\` (un « : » du nom devient « - ») ; le journal y est dans `logs/session.log`, celui du crash dans `logs/crashed_session.log`.
- Pour reproduire une erreur de script : un export *debug*, qui les signale (le *release* en tait la plupart).
- Vérifier le rapport : lancer l'export Linux, le tuer (`kill -9`), le relancer.
