# À valider avant la sortie

Tout ce qui est fait « au mieux » pour avancer et doit être repris, vérifié ou déclaré avant la sortie. Ajouter une ligne dès qu'un élément provisoire entre dans le jeu ; cocher quand il est validé.

## Contenu à peaufiner

- [ ] Nom du jeu : « Block Tiles » est un titre de travail (G0, `tools/new-game.sh`) ; choisir le vrai nom (recherche de marque, Google Play) et relancer `tools/new-game.sh` depuis l'ancien nom.

- [ ] Réglages de la difficulté adaptative et des bonus (G9 : 200 points par niveau, 1 à 4 pièces tirées, 1 utilisation gratuite et 3 par pub) : chiffres de départ, à régler avec les tests de Stelio puis les chiffres des joueurs.

- [ ] Sons faits par le code (G13, enrichis en G20 : `game/audio/sound_synth.gd`, `GameSounds`) : à faire juger par Stelio, à remplacer s'ils ne plaisent pas (`docs/recettes/sons-et-musique.md`).
- [ ] Musique composée par le code (G20, `assets/sounds/music_calm.ogg`, `tools/assets/compose_music.py`) : une seule boucle de 42 s ; à faire juger, et prévoir d'autres morceaux ou des silences pour ne pas lasser.
- [ ] Refonte visuelle de G20 (2026-11-12) : palette, tuiles, effets, carte de fin, menu : à faire juger par Stelio sur son téléphone (lisibilité des symboles en petit dans le plateau, taille des textes, effets ni trop ni trop peu). La police Fredoka (OFL) n'a pas l'espace fine insécable (U+202F) : elle est rendue par la police de secours, vérifier le rendu des « : » et « ! » en français.
- [ ] Étoiles d'un niveau réussi (G20, `LevelSet.star_pieces` : 1 pièce restante → 2 étoiles, 3 → 3 étoiles) : seuils de départ, affichés sur la carte de fin seulement ; décider s'ils sont sauvegardés et montrés sur la carte des niveaux.
- [ ] Effets visuels de G20 (`juice_rules.tres`, `tile_art.tres`) : chiffres de départ, à régler à l'œil ; vérifier la fluidité sur un petit téléphone (alléger les effets si besoin).
- [ ] Mots d'encouragement, éclats, tremblement, vibration (G13, `game/data/juice_rules.tres`) : chiffres de départ, à régler à l'œil et au toucher.
- [ ] Délai de l'aide à l'hésitation (G15, 10 s, `hint_after_seconds`) : à régler avec les tests.

## Boutons et outils de développement à retirer

- [ ] Option « Pièces : une à la fois / trois à la fois » du menu (G12) : pour comparer les deux sur le même APK ; garder la meilleure et retirer l'option.
- [ ] Affichage « Difficulté N » en haut de l'écran (G9) : pour que Stelio voie la difficulté s'adapter pendant ses tests ; à retirer (ou à garder caché) avant la sortie.

- [ ] Pubs de test (G3) : `game/data/ad_settings.tres` et le réglage `admob/general/android/app_id` (laissé à sa valeur par défaut) utilisent les identifiants de test de Google. Les remplacer par ceux du compte AdMob de Stelio, et vérifier `docs/strategies-pub.md` (bouton qui dit qu'une pub va passer, aucune pub surprise).
- [ ] APK signé avec la clé de débogage de Godot (`make android`) : créer la clé d'envoi Google Play (hors du dépôt, mot de passe en variable d'environnement), passer le préréglage Android en AAB (`gradle_build/export_format=1`) et exporter en release.
- [ ] Icône du jeu (2026-11-12, `assets/icon/`, dessinée par `tools/assets/make_icon.py`) : la regarder sur le téléphone de Stelio (masque rond ou arrondi du lanceur, icône thématique d'Android 13, petite taille dans la liste des applications) et la faire valider. Pour la fiche Google Play : `assets/icon/icon.png` (512 × 512) peut servir d'icône haute résolution ; l'image de présentation (1024 × 500) et les captures restent à faire. Pas d'icône dans le `.exe` Windows (`application/icon` attend un `.ico` et `application/modify_resources` est coupé) : à faire seulement si le jeu sort sur PC.
- [ ] APK de test en *debug* (174 Mo, symboles et armv7 compris) : la version Google Play sera un AAB *release*, bien plus léger ; vérifier sa taille (objectif < 100 Mo).
- [ ] Plafonds de pubs récompensées (G18, `game/data/ad_pacing_rules.tres`) écrits dans le jeu : les rendre réglables à distance (Firebase Remote Config ou Supabase) et envoyer les mesures de `docs/reglages-recommandes.md` (section 8) avant la sortie.
- [ ] Identifiant du paquet `com.bonneetoile.blocktiles` (préréglage Android) : provisoire, à confirmer avec le vrai nom du jeu avant le premier envoi sur Google Play (il ne peut plus changer ensuite).

## Relectures et vérifications

- [ ] Recherche de marque sur le nom du jeu.
- [ ] …

## Déclarations et crédits

- [ ] Questionnaire de contenu de Steamworks : chaque asset généré par IA (liste dans `assets/LICENSES.md`).
- [ ] Licences de chaque asset externe vérifiées (usage commercial, attribution).
- [ ] Écran de crédits : chaque auteur humain cité, même en CC0.
- [ ] Licences des polices jointes au jeu exporté (OFL) : Fredoka (`assets/fonts/OFL.txt`) à citer dans l'écran de crédits.
- [ ] Crédits du moteur (licence de Godot et de ses composants).
- [ ] Formulaire de consentement AdMob (UMP) : le créer dans la console AdMob (RGPD) et vérifier qu'il s'affiche dans l'Espace économique européen ; déclarer la pub dans la fiche Google Play et la section « Sécurité des données ».
