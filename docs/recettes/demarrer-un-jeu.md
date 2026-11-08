# Démarrer un jeu depuis le modèle

1. **Dépôt** : sur GitHub, « Use this template » depuis `Bonne-Etoile/godot-template` (ou cloner et pousser), privé. Créer la branche `dev` depuis `main`. Protéger `main` et `dev` (pas de push direct).
2. **Renommer** : `tools/new-game.sh "Nom Du Jeu" nom_du_jeu`. Le script remplace `My Game` (nom affiché, titre du `CLAUDE.md`, traductions) et `my_game` / `my-game` (binaires, artefacts de la CI). Relire `git diff`, puis `make lint check test build`.
3. **Session cloud** : ouvrir une session Claude Code sur le dépôt. Le hook installe tout (premier lancement : quelques minutes, les modèles d'export pèsent 1,3 Go). Vérifier que `godot.org` et `docs.godotengine.org` sont autorisés dans le réseau de l'environnement (sinon : releases GitHub et `--doctool`).
4. **Conception** : remplir `docs/conception-du-jeu.md` avec le joueur, sous forme de questions et de décisions datées. Ne rien coder avant que la boucle de jeu soit écrite.
5. **Feuille de route et backlog** : phase 0 = proof of concept (la boucle de jeu, avec des formes simples) ; découper en tickets de la taille d'une PR, avec critères et dépendances (`docs/backlog.md`). Lister les décisions et actions attendues du joueur en tête du backlog.
6. **CLAUDE.md** : compléter le paragraphe d'introduction ; ajouter une puce par système dès qu'il existe.
7. **Premier ticket** : branche `claude/<ticket>-<sujet>` depuis `dev`, PR vers `dev`.

## Ce qu'il faut décider tôt (River Cleaner l'a payé plus tard)

- **L'échelle visée** : combien d'objets à l'écran au maximum ? Concevoir pour elle dès le premier jour (`docs/pitfalls/methode.md`, « Concevoir pour l'échelle »).
- **Les plateformes testées par le joueur** (Windows seulement ? Steam Deck ?) : elles fixent ce que construit `build.yml`.
- **Quand le joueur teste** : à chaque PR de gameplay, ou par lots ? Le noter dans `CLAUDE.md` (« Exception gameplay »).
- **Les boutons de développement** (partie de test, tout débloquer, mesure de performance) : prévus dès le début, listés dans `docs/avant-la-sortie.md`.
