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

- **D1. …** → bloque …

## Actions attendues du joueur

- **A1. …**

## Socle technique (fourni par le modèle)

### T1. Projet, commandes, session cloud, CI — fait (modèle `Bonne-Etoile/godot-template`)

- Renommer le jeu (`tools/new-game.sh`), `make lint check test build` verts dans la session.

## Phase 0 — Proof of concept

### G1. …

- **Objectif** :
- **Périmètre** :
- **Critères** :
- **Dépend de** :
