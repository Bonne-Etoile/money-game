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
- **D2. Genre du jeu** (2026-11-08) : jeu idle de gestion (recommandé), puzzle de fusion ou réflexion à niveaux. Analyse : `docs/strategies-pub.md`, section 8. → bloque la conception (`docs/conception-du-jeu.md`).
- **D3. Public cible** (2026-11-08) : 13 ans et plus recommandé, pour éviter le programme Familles qui interdit la plupart des leviers pub (`docs/deploiement-android.md`, section 6).

## Actions attendues du joueur

- **A1. Créer le compte développeur Google Play personnel** (25 $, pièce d'identité, téléphone Android) et le compte AdMob : `docs/deploiement-android.md`, sections 1 et 2.
- **A2. Réunir 15 à 20 testeurs** (téléphone Android, adresse Gmail) pour le test fermé obligatoire de 14 jours : `docs/deploiement-android.md`, section 7. À lancer tôt : c'est l'étape la plus longue.
- **A3. Choisir un nom de domaine** pour la politique de confidentialité et `app-ads.txt` : `docs/deploiement-android.md`, section 3.

## Socle technique (fourni par le modèle)

### T1. Projet, commandes, session cloud, CI — fait (modèle `Bonne-Etoile/godot-template`)

- Renommer le jeu (`tools/new-game.sh`), `make lint check test build` verts dans la session.

## Phase 0 — Proof of concept

### G1. …

- **Objectif** :
- **Périmètre** :
- **Critères** :
- **Dépend de** :
