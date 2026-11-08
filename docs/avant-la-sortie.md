# À valider avant la sortie

Tout ce qui est fait « au mieux » pour avancer et doit être repris, vérifié ou déclaré avant la sortie. Ajouter une ligne dès qu'un élément provisoire entre dans le jeu ; cocher quand il est validé.

## Contenu à peaufiner

- [ ] Nom du jeu : « Block Tiles » est un titre de travail (G0, `tools/new-game.sh`) ; choisir le vrai nom (recherche de marque, Google Play) et relancer `tools/new-game.sh` depuis l'ancien nom.

## Boutons et outils de développement à retirer

- [ ] Pubs de test (G3) : `game/data/ad_settings.tres` et le réglage `admob/general/android/app_id` (laissé à sa valeur par défaut) utilisent les identifiants de test de Google. Les remplacer par ceux du compte AdMob de Stelio, et vérifier `docs/strategies-pub.md` (bouton qui dit qu'une pub va passer, aucune pub surprise).
- [ ] APK signé avec la clé de débogage de Godot (`make android`) : créer la clé d'envoi Google Play (hors du dépôt, mot de passe en variable d'environnement), passer le préréglage Android en AAB (`gradle_build/export_format=1`) et exporter en release.
- [ ] Identifiant du paquet `com.bonneetoile.blocktiles` (préréglage Android) : provisoire, à confirmer avec le vrai nom du jeu avant le premier envoi sur Google Play (il ne peut plus changer ensuite).

## Relectures et vérifications

- [ ] Recherche de marque sur le nom du jeu.
- [ ] …

## Déclarations et crédits

- [ ] Questionnaire de contenu de Steamworks : chaque asset généré par IA (liste dans `assets/LICENSES.md`).
- [ ] Licences de chaque asset externe vérifiées (usage commercial, attribution).
- [ ] Écran de crédits : chaque auteur humain cité, même en CC0.
- [ ] Licences des polices jointes au jeu exporté (OFL).
- [ ] Crédits du moteur (licence de Godot et de ses composants).
- [ ] Formulaire de consentement AdMob (UMP) : le créer dans la console AdMob (RGPD) et vérifier qu'il s'affiche dans l'Espace économique européen ; déclarer la pub dans la fiche Google Play et la section « Sécurité des données ».
