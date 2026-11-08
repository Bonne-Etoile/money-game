# Backlog

Feuille de route (`docs/feuille-de-route.md`) découpée en tickets de la taille d'une PR, pour le travail autonome de Claude (règles dans `CLAUDE.md`, « Travail autonome »). Les tickets sont dans l'ordre de priorité : le prochain à prendre est le premier ticket **prêt** dont les dépendances sont **faites**.

Statuts :

- **prêt** : peut être fait sans attendre personne ;
- **décision requise** : attend une réponse (section « Décisions à prendre ») ;
- **action requise** : attend une action du joueur (compte, achat, test sur sa machine) ;
- **en cours** : branche ouverte (indiquer la branche) ;
- **en revue** : PR ouverte vers `dev` (indiquer la PR) ;
- **à tester** : PR de gameplay prête, en attente du test du joueur (indiquer la PR et quoi tester) ;
- **fait** : mergé dans `dev` (indiquer la PR) ;
- **bloqué** : mis de côté après échec, avec la raison.

Chaque ticket : objectif, périmètre, critères d'acceptation, dépendances. Un ticket trop gros en cours de route est redécoupé ici avant d'être poursuivi. Chaque retour du joueur devient un ticket daté, avec ses mots.

## Décisions à prendre

- ~~**D1. Technologie du jeu**~~ — **tranchée le 2026-11-08 : Godot 4.7** (le modèle actuel), avec le plugin AdMob de poingstudios. Voir `docs/architecture.md`, décision 16.
- ~~**D2. Genre du jeu**~~ — **tranchée le 2026-11-08** : un hybride **blocs + tuiles de mahjong**. Deux prototypes à comparer : piste 1 « blocs de tuiles » et piste 2 « la pyramide fournit les pièces » (`docs/etude-concurrence.md`, annexe B). On garde celle qui donne le plus envie de rejouer (test de Stelio).
- **D3. Public cible** (2026-11-08) : 13 ans et plus recommandé, pour éviter le programme Familles qui interdit la plupart des leviers pub (`docs/deploiement-android.md`, section 6).

## Actions attendues du joueur

- **A1. Créer le compte développeur Google Play personnel** (25 $, pièce d'identité, téléphone Android) et le compte AdMob : `docs/deploiement-android.md`, sections 1 et 2.
- **A2. Réunir 15 à 20 testeurs** (téléphone Android, adresse Gmail) pour le test fermé obligatoire de 14 jours : `docs/deploiement-android.md`, section 7. À lancer tôt : c'est l'étape la plus longue.
- **A3. Choisir un nom de domaine** pour la politique de confidentialité et `app-ads.txt` : `docs/deploiement-android.md`, section 3.

## Socle technique (fourni par le modèle)

### T1. Projet, commandes, session cloud, CI — fait (modèle `Bonne-Etoile/godot-template`)

- Renommer le jeu (`tools/new-game.sh`), `make lint check test build` verts dans la session.

## Phase 0 — Proof of concept

### G0. Préparer le dépôt pour un jeu mobile 2D — prêt

- **Objectif** : un projet qui se lance en portrait, en 2D, avec le rendu mobile, et des entrées tactiles.
- **Périmètre** : renommer le jeu (`tools/new-game.sh`) ; rendu Mobile ou Compatibility ; fenêtre portrait (720 × 1280 par exemple) avec étirement adapté aux écrans de téléphone ; actions de l'Input Map pour le toucher et la souris ; retirer ce qui ne sert qu'à la 3D sur PC ; créer la branche `dev`.
- **Critères** : `make lint check test build` verts ; capture d'écran du menu en portrait.
- **Dépend de** : rien.

### G1. Prototype piste 1 « blocs de tuiles » — prêt

- **Objectif** : savoir si la règle « ligne pleine **ou** 3 symboles identiques qui se touchent » donne envie de rejouer.
- **Périmètre** : grille 8 × 8, 3 pièces proposées sans rotation, glisser-déposer, chaque case de pièce porte un symbole (4 à 6 symboles, formes simples) ; effacement des lignes, colonnes et trios ; score et combos ; fin de partie quand aucune pièce ne rentre ; rejouer. Pas de pub, pas de sauvegarde. Logique dans `game/core/` avec tests unitaires ; réglages (taille, symboles, pièces) en `.tres`.
- **Critères** : tests unitaires de la logique, test de scénario d'une partie, captures regardées ; export Linux/Windows pour le test de Stelio (puis Android dès que G3 est fait).
- **Dépend de** : G0.

### G2. Prototype piste 2 « la pyramide fournit les pièces » — prêt

- **Objectif** : savoir si vider une pile de mahjong en posant ses tuiles sur une grille de blocs est plus prenant que la piste 1.
- **Périmètre** : en haut, une petite pile de tuiles (règle « libre » du mahjong) ; une tuile retirée devient une pièce à poser sur la grille du bas ; effacement par ligne (et par trio si la piste 1 l'a validé) ; niveau gagné quand la pile est vide, perdu quand la pièce ne rentre plus ; 3 à 5 niveaux faits à la main.
- **Critères** : comme G1.
- **Dépend de** : G0 (réutilise la grille de G1 si elle existe).

### G3. Export Android et pubs de test — prêt

- **Objectif** : installer le prototype sur le téléphone de Stelio, avec des pubs de test.
- **Périmètre** : décision 16 de `docs/architecture.md` : SDK Android, JDK, modèles d'export et préréglage Android (APK de test, AAB plus tard) ; plugin AdMob de poingstudios derrière un autoload `Ads` avec une version factice pour les tests ; une pub récompensée de test (« continuer ») dans le prototype retenu.
- **Critères** : APK installable ; pub de test affichée ; tests verts avec la version factice.
- **Dépend de** : G0.

### G4. …

- **Objectif** :
- **Périmètre** :
- **Critères** :
- **Dépend de** :
